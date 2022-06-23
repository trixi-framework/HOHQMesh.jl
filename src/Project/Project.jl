#=
    The Project is the controller in an MVC paradigm. It manages the model,
    stored in the projectDictionary, and plotting data, and responds to enableNotifications
    of changes.
=#
mutable struct Project
    name::String
    projectDirectory:: String
    projectDictionary::Dict{String,Any}
    plt::Any #For the plot
    plotOptions::Int # = combinations of MODEL, GRID, MESH
#
#   For drawing
#
    outerBndryPoints       ::Array{Any}              # CHAIN
    outerBndryNames        ::Array{String}
    innerBoundaryPoints    ::Array{Any}              # Array of CHAINs
    innerBoundaryNames     ::Array{Any}              # Array of CHAINs of names
    innerBoundaryChainNames::Array{String}           # Array of the names of the CHAINs
    refinementRegionPoints ::Array{Array{Float64,2}} # Array of Array of points
    refinementRegionNames  ::Array{String}
    refinementRegionLoc    ::Array{Array{Float64}}   # Center point of a refinement region
    bounds                 ::Array{Float64}
    userBounds             ::Array{Float64}
    xGrid                  ::Array{Float64}
    yGrid                  ::Array{Float64}
    xMesh                  ::Array{Float64}
    yMesh                  ::Array{Float64}
    backgroundGridShouldUpdate::Bool
    meshShouldUpdate        ::Bool
end

const defaultPlotPts  = 200
const meshFileFormats = Set(["ISM", "ISM-V2", "ABAQUS"])
const plotFileFormats = Set(["sem", "skeleton"])
const smootherTypes   = Set(["LinearSpring", "LinearAndCrossbarSpring"])
const statusValues    = Set(["ON", "OFF"])
const refinementTypes = Set(["smooth", "sharp"])


"""
    openProject(fileName::String, folder::String)

Open existing project described in the control File.

    folder   = folder the control file is in
    fileName = the name of the file
"""
function openProject(fileName::String, folder::String)

    controlFile = joinpath(folder,fileName)
    controlDict = ImportControlFile(controlFile)

    # Strip off the file path into a temporary name
    tempName = splitdir(fileName)
    # Separate the project name from `.control`
    splitName = split(tempName[2], ".")
    # Pull the correct project name
    s = string(splitName[1]) # This is dumb

    # Instantiate an empty project with some defaults
    proj = newProject(s,folder)
#
#   Overwrite defaults
#
    proj.projectDictionary = controlDict

    assemblePlotArrays(proj)
    clearUndoRedo()

    return proj
end


"""
    saveProject(proj::Project)

    proj     = Project to be saved
Save a project dictionary to the file path specified when the project was created.
"""
function saveProject(proj::Project)
    fileName = joinpath(proj.projectDirectory,proj.name)*".control"
    WriteControlFile(proj.projectDictionary,fileName)
end


"""
    newProject(name::String, folder::String)

Create a new project with the given name. That name will be used
for the mesh and plot files in the specified folder.
"""
function newProject(name::String, folder::String)
    ibChainPoints = Any[]
    ibChainNames  = String[]
    ibNames       = Any[]
    obNames       = String[]
    obPnts        = Any[]
    projectDict   = Dict{String,Any}()
    plt           = nothing
    undoStack     = Any[]
    redoStack     = Any[]
    bounds        = emptyBounds() # top, left, bottom, right
    userBounds    = emptyBounds()
    xGrid         = Float64[]
    yGrid         = Float64[]
    xMesh         = Float64[]
    yMesh         = Float64[]
    refinementRegionPts   = Array{Array{Float64,2}}[]
    refinementRegionNames = Array{String}[]
    refinementRegionLocs  = Array{Array{Float64}}[]
    plotOptions   = 0
#
    proj = Project(name, folder, projectDict, plt, plotOptions, obPnts, obNames,
                   ibChainPoints,ibNames, ibChainNames,
                   refinementRegionPts,refinementRegionNames, refinementRegionLocs,
                   bounds, userBounds, xGrid, yGrid, xMesh, yMesh,
                   true, false)

    addObserver(proj,"CURVE_DID_CHANGE_NOTIFICATION",curveDidChange)
    addObserver(proj,"MODEL_DID_CHANGE_NOTIFICATION",modelDidChange)
    addObserver(proj,"BGRID_DID_CHANGE_NOTIFICATION",backgroundGridDidChange)
    addObserver(proj,"MESH_WAS_GENERATED_NOTIFICATION",meshWasGenerated)
    addObserver(proj,"MESH_WAS_DELETED_NOTIFICATION",meshWasDeleted)
    addObserver(proj,"REFINEMENT_WAS_ADDED_NOTIFICATION",refinementWasAdded)
    addObserver(proj,"REFINEMENT_WAS_CHANGED_NOTIFICATION",refinementDidChange)
    enableNotifications()
#
#   Set some default values
#
    addRunParameters!(proj)
    addSpringSmoother!(proj)
    enableUndo()
#
#   Create the output directory if it does not exist
#
    if !isdir(abspath(normpath(folder)))
       mkdir(abspath(normpath(folder)))
    end

    return proj
end


"""
    hasBackgroundGrid(proj::Project)

Tests to see if the project has a backgroundGrid dictionary defined.
"""
function hasBackgroundGrid(proj::Project)
    controlDict = getControlDict(proj)
    if haskey(controlDict,"BACKGROUND_GRID")
        return true
    else
        return false
    end
end


function assemblePlotArrays(proj::Project)

    empty!(proj.outerBndryPoints)
    empty!(proj.outerBndryNames)
    empty!(proj.innerBoundaryChainNames)
    empty!(proj.innerBoundaryPoints)
    empty!(proj.innerBoundaryNames)
    empty!(proj.xGrid)
    empty!(proj.yGrid)

    bounds = emptyBounds()

    modelDict = getModelDict(proj)

    if haskey(modelDict,"OUTER_BOUNDARY")
        outerBoundary         = modelDict["OUTER_BOUNDARY"]
        obChain               = outerBoundary["LIST"]
        proj.outerBndryPoints = chainPoints(obChain,defaultPlotPts)

        chB    = chainBounds(proj.outerBndryPoints)
        bounds = bboxUnion(bounds,chB)

        for crv in obChain
            push!(proj.outerBndryNames,crv["name"])
        end
    end

    if haskey(modelDict,"INNER_BOUNDARIES")
        innerBoundaries   = modelDict["INNER_BOUNDARIES"]
        innerBoundaryList = innerBoundaries["LIST"] #LIST of CHAINS
        for d in innerBoundaryList
            push!(proj.innerBoundaryChainNames, d["name"])
            ibChain = d["LIST"]
            ibPnts = chainPoints(ibChain,defaultPlotPts)
            push!(proj.innerBoundaryPoints,ibPnts)
            chB    = chainBounds(ibPnts)
            bounds = bboxUnion(bounds,chB)
                names = String[]
            for crv in ibChain
                push!(names,crv["name"])
            end
            push!(proj.innerBoundaryNames,names)
        end
    end

    controlDict = getControlDict(proj)

    if haskey(controlDict,"REFINEMENT_REGIONS")
        refinementBlock = controlDict["REFINEMENT_REGIONS"]
        refinementsList = refinementBlock["LIST"]
        for ref in refinementsList
            addRefinementRegionPoints!(proj,ref)
        end
    end
    proj.bounds = bounds
end


function projectBounds(proj::Project)
    bounds = emptyBounds()

    if !isempty(proj.outerBndryPoints)
        chB    = chainBounds(proj.outerBndryPoints)
        bounds = bboxUnion(bounds,chB)
    end

    if !isempty(proj.innerBoundaryPoints)
        for i = 1:length(proj.innerBoundaryPoints)
            ibPnts = proj.innerBoundaryPoints[i]
            chB    = chainBounds(ibPnts)
            bounds = bboxUnion(bounds,chB)
        end
    end
    return bounds
end


function projectGrid(proj::Project)

    controlDict  = proj.projectDictionary["CONTROL_INPUT"]

    if haskey(controlDict,"BACKGROUND_GRID")
        bgDict = controlDict["BACKGROUND_GRID"]

        if haskey(bgDict,"dx")
            N      = intArrayForKeyFromDictionary("N", bgDict)
            x0     = realArrayForKeyFromDictionary("x0",bgDict)
            left   = x0[1]
            bottom = x0[2]
            xGrid  = zeros(Float64, N[1]+1)
            yGrid  = zeros(Float64, N[2]+1)
            dx = realArrayForKeyFromDictionary("dx", bgDict)
            for i = 1:N[1]+1
                xGrid[i] = left + (i-1)*dx[1]
            end
            for j = 1:N[2]+1
                yGrid[j] = bottom + (j-1)*dx[2]
            end
        else
            dx = realArrayForKeyFromDictionary("background grid size", bgDict)
            bounds = proj.bounds

            width  = bounds[RIGHT] - bounds[LEFT]
            height = bounds[TOP]   - bounds[BOTTOM]

            Nx = Int(round(width/dx[1])) + 3 # Want the model inside the grid
            Ny = Int(round(height/dx[2])) + 3

            xGrid  = zeros(Float64, Nx)
            yGrid  = zeros(Float64, Ny)

            for i = 1:Nx
                xGrid[i] = bounds[LEFT] + (i-2)*dx[1] # Arrays start at 1, ugh.
            end
            for j = 1:Ny
                yGrid[j] = bounds[BOTTOM] + (j-2)*dx[2]
            end
        end
    end

    return xGrid, yGrid
end


#
# NOTIFICATION ACTIONS
#
function curveDidChange(proj::Project,crv::Dict{String,Any})
    curveName = getCurveName(crv)
#
#   Find the curve location: See if the curve is in the outer boundary
#
    for (i,s) in enumerate(proj.outerBndryNames)
        if s == curveName
            proj.outerBndryPoints[i] = curvePoints(crv,defaultPlotPts)
            if !isnothing(proj.plt)
                options = proj.plotOptions
                updatePlot!(proj, options)
            end
            return nothing
        end
    end
#
#   Otherwise, see if it is an inner boundary
#
    crvNumber, bndryNumber = innerBoundaryIndices(proj,curveName)
    if crvNumber == 0 || bndryNumber == 0
        return nothing
    end
    innerBoundaryPoints = proj.innerBoundaryPoints[bndryNumber]
    innerBoundaryPoints[crvNumber] = curvePoints(crv,defaultPlotPts)
    proj.backgroundGridShouldUpdate = true

    if !isnothing(proj.plt)
        options = proj.plotOptions
        updatePlot!(proj, options)
    end
    return nothing
end


function modelDidChange(proj::Project, sender::Project)

    if proj === sender && !isnothing(proj.plt)
        options = proj.plotOptions
        if (options & MODEL) == 0
            options = options + MODEL
        end
        updatePlot!(proj, options)
    end
end


function backgroundGridDidChange(proj::Project, sender::Project)
    if proj === sender &&  !isnothing(proj.plt)
        proj.backgroundGridShouldUpdate = true
        options = proj.plotOptions
        if (options & GRID) == 0
            options = options + GRID
        end
        updatePlot!(proj, options)
    end
end


function refinementWasAdded(proj::Project, sender::Project)
    if proj === sender &&  !isnothing(proj.plt)
        options = proj.plotOptions
        if (options & REFINEMENTS) == 0
            options = options + REFINEMENTS
        end
        updatePlot!(proj, options)
    end
end


function refinementDidChange(proj::Project, sender::Dict{String,Any})
    regionName = sender["name"]
    lst = getAllRefinementRegions(proj)
    indx = 0
    for (i,r) in enumerate(lst)
        if r["name"] == regionName
            indx = i
            break
        end
    end

    if indx > 0
        x    = refinementRegionPoints(sender)
        proj.refinementRegionPoints[indx] = x
        proj.refinementRegionNames[indx] = sender["name"]
        center = getRefinementRegionCenter(sender)
        proj.refinementRegionLoc[indx] = center

        if !isnothing(proj.plt)
            options = proj.plotOptions
            if (options & REFINEMENTS) == 0
                options = options + REFINEMENTS
            end
            updatePlot!(proj, options)
        end
    end
end


function meshWasGenerated(proj::Project, sender::Project)
    if proj === sender &&  !isnothing(proj.plt)
        options = proj.plotOptions
        options = (MODEL & options) + MESH
        proj.meshShouldUpdate = true
        updatePlot!(proj, options)
    end
end


function meshWasDeleted(proj::Project, sender::Project)
    if proj === sender &&  !isnothing(proj.plt)
        options = proj.plotOptions
        if (MESH & options) > 0
            options = options - MESH
        end
        proj.meshShouldUpdate = false
        updatePlot!(proj, options)
    end
end


"""
    modelCurvesAreOK(proj::Project)

Go through all curves in the model and make sure they are connected and closed.
Also, remove any empty outer / inner boundary chains.

Returns true if all curves are connected and closed, false otherwise.
"""
function modelCurvesAreOK(proj::Project)
    result = true
    if !haskey(proj.projectDictionary,"MODEL")
        return true
    end
    modelDict = getModelDict(proj)
    if haskey(modelDict,"OUTER_BOUNDARY")
        chain  = getOuterBoundaryChainList(proj)
        if !isempty(chain)
            result = modelChainIsOK(chain,"Outer")
        else
            delete!(modelDict,"OUTER_BOUNDARY")
        end
    end
    if haskey(modelDict,"INNER_BOUNDARIES")
        innerBoundariesList = getAllInnerBoundaries(proj)
        if isempty(innerBoundariesList)
            delete!(modelDict,"INNER_BOUNDARIES")
            return result
        end
        for chain in innerBoundariesList
            chainName = string(chain["name"])
            chainList = chain["LIST"]
            result = result && modelChainIsOK(chainList,chainName)
        end
    end
    return result
end


"""
    modelChainIsOK(chain::Vector{Dict{String, Any}}, chainName::String)

Returns true if the chain of curves is contiguous and closed; false otherwise.
"""
function modelChainIsOK(chain::Vector{Dict{String, Any}}, chainName::String)
    result = true
    for i in 1:length(chain)-1
        crv1 = chain[i]
        crv2 = chain[i+1]
        if !curvesMeet(crv1,crv2)
            name1 = getCurveName(crv1)
            name2 = getCurveName(crv2)
            @warn "The curve $name2 does not meet the previous curve, $name1."
            result = false
        end
    end
    crv1 = last(chain)
    crv2 = chain[1]
    if !curvesMeet(crv1,crv2)
        name1 = getCurveName(crv1)
        name2 = getCurveName(crv2)
        @warn "The boundary curve $chainName is not closed. Fix to generate mesh"
        result = false
    end

    return result
end
