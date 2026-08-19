#
#  --------------------------------------------------------------------------------------
#           OUTER BOUNDARY FUNCTIONS
#  --------------------------------------------------------------------------------------
#
"""
    addCurveToOuterBoundary!(proj::Project, crv::Dict{String,Any})

Add a curve to the outer boundary. The curves must be added in order counter-clockwise
"""
function addCurveToOuterBoundary!(proj::Project, crv::Dict{String,Any})
    chain = getOuterBoundaryChainList(proj)
    i     = chainInsertionIndex(crv,chain)

    enableNotifications()
    insertOuterBoundaryCurveAtIndex!(proj,crv,i)

    enableUndo()
    registerWithUndoManager(proj,removeOuterBoundaryCurveWithName!,(crv["name"],),"Add Outer Boundary Curve")
    println("Added curve ",getCurveName(crv)," to the outer boundary chain.")
end


"""
    removeOuterBoundaryCurveWithName!(proj::Project, name::String)

Remove the named curve in the outer boundary.
"""
function removeOuterBoundaryCurveWithName!(proj::Project, name::String)
    lst = getOuterBoundaryChainList(proj)
    index  = getChainIndex(lst,name)
    if index > 0
        proj.backgroundGridShouldUpdate = true
        removeOuterBoundaryCurveAtIndex!(proj,index) # posts undo/notification
    else
        # `name` to be deleted does not lie in outer boundary chain. Throw an error.
        error("No curve ", name, " in boundary Outer. Try again.")
    end
end


"""
    getOuterBoundaryCurveWithName(proj::Project, name::String)

Return the curve dictionary `crv` with `name` from the `OUTER_BOUNDARY`
curve chain.
"""
function getOuterBoundaryCurveWithName(proj::Project, name::String)
    lst = getOuterBoundaryChainList(proj)
    for crv in lst
        if crv["name"] == name
            return crv
        end
    end
end


"""
    insertOuterBoundaryCurveAtIndex!(proj::Project, crv::Dict{String,Any}, index::Int)

Insert a curve into the outer boundary chain at the specified index.
"""
function insertOuterBoundaryCurveAtIndex!(proj::Project, crv::Dict{String,Any}, index::Int)
    lst = getOuterBoundaryChainList(proj)
    insert!(lst,index,crv)
    insert!(proj.outerBndryPoints,index,curvePoints(crv,defaultPlotPts))
    insert!(proj.outerBndryNames,index,crv["name"])
    proj.backgroundGridShouldUpdate = true
    registerWithUndoManager(proj,removeOuterBoundaryCurveAtIndex!,(index,),"Add Outer Boundary Curve")
    postNotificationWithName(proj,"MODEL_DID_CHANGE_NOTIFICATION",(nothing,))
end


"""
    removeOuterBoundaryCurveAtIndex!(proj::Project, index::Int)

Remove a curve from the outer boundary chain at the specified index.
"""
function removeOuterBoundaryCurveAtIndex!(proj::Project, index::Int)
    lst = getOuterBoundaryChainList(proj)
    crv = lst[index]
    deleteat!(lst,index)
    deleteat!(proj.outerBndryNames,index)
    deleteat!(proj.outerBndryPoints,index)
    proj.backgroundGridShouldUpdate = true
    registerWithUndoManager(proj,insertOuterBoundaryCurveAtIndex!,(crv,index),"Remove Outer Boundary Curve")
    postNotificationWithName(proj,"MODEL_DID_CHANGE_NOTIFICATION",(nothing,))
end


"""
    addOuterBoundary!(proj::Project, outerBoundary::Dict{String,Any})

Add an empty outer boundary to the project. There can be only one.
This function is only used as part of an undo operation removing the outer boundary.
"""
function addOuterBoundary!(proj::Project, outerBoundary::Dict{String,Any})
    model = getModelDict(proj)
    # Recover the complete outer boundary dictionary
    model["OUTER_BOUNDARY"] = outerBoundary
    # Recover the outer boundary points and names for each member of the chain (necessary for plotting)
    chain = getOuterBoundaryChainList(proj)
    for (i, crv) in enumerate(chain)
        crvPoints = curvePoints(crv, defaultPlotPts)
        push!(proj.outerBndryPoints, crvPoints)
        push!(proj.outerBndryNames , crv["name"])
    end
    proj.backgroundGridShouldUpdate = true
    registerWithUndoManager(proj,removeOuterBoundary!, (nothing,), "Add Outer Boundary")
    postNotificationWithName(proj,"MODEL_DID_CHANGE_NOTIFICATION",(nothing,))
end


"""
    removeOuterBoundary!(proj::Project)

Remove the outer boundary curve if it exists.
"""
function removeOuterBoundary!(proj::Project)
    modelDict = getModelDict(proj)
    if haskey(modelDict,"OUTER_BOUNDARY")
        ob = modelDict["OUTER_BOUNDARY"]
        registerWithUndoManager(proj,addOuterBoundary!, (ob,), "Remove Outer Boundary")
        delete!(modelDict,"OUTER_BOUNDARY")
        proj.outerBndryPoints = Any[]
        proj.outerBndryNames  = String[]
        proj.backgroundGridShouldUpdate = true
        postNotificationWithName(proj,"MODEL_DID_CHANGE_NOTIFICATION",(nothing,))
    end
end


"""
    getOuterBoundaryChainList(proj::Project)

Get the array of outer boundary curves.
"""
function getOuterBoundaryChainList(proj::Project)
    outerBndryDict = getDictInModelDictNamed(proj,"OUTER_BOUNDARY")
    if haskey(outerBndryDict,"LIST")
        lst = outerBndryDict["LIST"]
        return lst
    else
        # This is the creation of the CHAIN for the OUTER_BOUNDARY
        # and here we instantiate the keywords for the boundary
        # curve optimization defaults.
        # Default values are: optimization off,
        #                     tol = 1e-3,
        #                     continuity = 0
        #                     connect = empty
        outerBndryDict["optimize"] = "none"
        outerBndryDict["tolerance"] = "1e-3"
        outerBndryDict["continuity"] = "0"
        outerBndryDict["connect"] = "[]"
        lst = Dict{String,Any}[]
        outerBndryDict["LIST"] = lst
        return lst
    end
end


"""
    getOuterBoundaryOptimizeStatus(proj::Project)

Returns the current type for the boundary curve optimization
for the outer boundary chain.
"""
function getOuterBoundaryOptimizeStatus(proj::Project)
    outerBndryDict = getDictInModelDictNamed(proj,"OUTER_BOUNDARY")
    return outerBndryDict["optimize"]
end


"""
    setOuterBoundaryOptimizeStatus!(proj:Project, type::String)

Adjust the type for the boundary curve optimization for the outer boundary chain.
Available types are `none`, `L2Norm`, or `H1Norm`.
"""
function setOuterBoundaryOptimizeStatus!(proj::Project, type::String)
    if !in(type, optimizeTypes)
        @warn "Acceptable optimization types are `none`, `L2Norm`, or `H1Norm`. Try again."
        return
    end
    outerBndryDict = getDictInModelDictNamed(proj,"OUTER_BOUNDARY")
    outerBndryDict["optimize"] = type
end


"""
    getOuterBoundaryTolerance(proj::Project)

Returns the current tolerance for the boundary optimization of the outer boundary chain.
"""
function getOuterBoundaryTolerance(proj::Project)
    outerBndryDict = getDictInModelDictNamed(proj, "OUTER_BOUNDARY")
    return parse(Float64, outerBndryDict["tolerance"])
end


"""
    setOuterBoundaryTolerance!(proj::Project, tolerance::Float64)

Sets the tolerance for the boundary optimization of the outer boundary chain.
"""
function setOuterBoundaryTolerance!(proj::Project, tolerance::Float64)
    if tolerance < 0
        @warn "The boundary tolerance must be non-negative. Try again."
        return
    elseif tolerance < 1e-5
        @warn "Setting a low tolerance may not be achievable or the mesh generation may take an inordinate amount of time. Think about how accurate of a mesh is needed before choosing a low tolerance like $tolerance."
    end

    outerBndryDict = getDictInModelDictNamed(proj, "OUTER_BOUNDARY")
    outerBndryDict["tolerance"] = string(tolerance)
end


"""
    getOuterBoundaryContinuity(proj::Project)

Returns the current continuity (number of continuous derivatives) for
the boundary optimization of the outer boundary chain.
"""
function getOuterBoundaryContinuity(proj::Project)
    outerBndryDict = getDictInModelDictNamed(proj, "OUTER_BOUNDARY")
    return parse(Int, outerBndryDict["continuity"])
end


"""
    setOuterBoundaryContinuity!(proj::Project, continuity::Int)

Sets the continuity (number of continuous derivatives) for
the boundary optimization of the outer boundary chain.
"""
function setOuterBoundaryContinuity!(proj::Project, continuity::Int)
    if continuity < 0
        @warn "The continuity must be non-negative. Try again."
        return
    elseif continuity > 2
        @warn "Higher continuity constraints can lead to ill-conditioned systems in the optimization procedure."
    end

    outerBndryDict = getDictInModelDictNamed(proj, "OUTER_BOUNDARY")
    outerBndryDict["continuity"] = string(continuity)
end


"""
    getOuterBoundaryConnect(proj::Project)

Returns the current connect setting for the boundary optimization of the outer boundary chain.
"""
function getOuterBoundaryConnect(proj::Project)
    outerBndryDict = getDictInModelDictNamed(proj, "OUTER_BOUNDARY")
    return outerBndryDict["connect"]
end


"""
    setOuterBoundaryConnect!(proj::Project, connect::String)

Sets the connect setting for the boundary optimization of the outer boundary chain.

By default, boundary curve optimization is done curve by curve within the chain
with an "empty" `connect = "[]"` key,
as usually there will be discontinuities (e.g. corners) between the curves.
If it is desired to define a more global approximation across multiple curves
update the `connect` key.
For example, if the chain has four segments then `connect = "2-3"` requests
that optimization occurs across curve segments two and three in the list,
where as curves 1 and 4 are optimized individually.
"""
function setOuterBoundaryConnect!(proj::Project, connect::String)
    outerBndryDict = getDictInModelDictNamed(proj, "OUTER_BOUNDARY")
    outerBndryDict["connect"] = connect
end

#
#  --------------------------------------------------------------------------------------
#           INNER BOUNDARY FUNCTIONS
#  --------------------------------------------------------------------------------------
#
"""
    addCurveToInnerBoundary!(proj::Project, crv::Dict{String,Any}, boundaryName::String)

Add a curve to the inner boundary with name `boundaryName`. If an inner boundary of that name
does not exist, one is created.
"""
function addCurveToInnerBoundary!(proj::Project, crv::Dict{String,Any}, boundaryName::String)

    i, chain  = getInnerBoundaryChainWithName(proj,boundaryName)
    curveList = chain["LIST"]
    j         = chainInsertionIndex(crv,curveList)

    enableNotifications()
    insertInnerBoundaryCurveAtIndex!(proj,crv,j,boundaryName)
    enableUndo()
    registerWithUndoManager(proj,removeInnerBoundaryCurve!,
                            (crv["name"],boundaryName),
                            "Add Inner Boundary Curve")
    println("Added curve ",getCurveName(crv)," to the ",boundaryName," chain.")
end

"""
    removeInnerBoundaryCurve!(proj::Project, name::String, chainName::String)

Remove the curve with `name` from an inner boundary chain with `chainName`.
"""
function removeInnerBoundaryCurve!(proj::Project, name::String, chainName::String)
    i, chain = getInnerBoundaryChainWithName(proj,chainName)
    lst   = chain["LIST"]

    # Go through `chainName` and check if the passed `name` is present in said chain
    name_check = 0
    for (i,dict) in enumerate(lst)
       if dict["name"] == name
          name_check += 1
       end
    end

    if isempty(lst)
        # When the chain is empty, `chainName` was not present before the call.
        # Throw an error and remove the empty chain otherwise plotting routine breaks.
        ibChains = getAllInnerBoundaries(proj)
        deleteat!(ibChains,i)
        deleteat!(proj.innerBoundaryChainNames,i)
        deleteat!(proj.innerBoundaryNames,i)
        error("No curve ", name, " in boundary ", chainName, ". Try again.")
    elseif name_check == 0
        # Situation where `chainName` already exists but the `name` to be deleted that
        # was passed does not lie in that `chainName`. Throw an error.
        error("No curve ", name, " in boundary ", chainName, ". Try again.")
    end
    index  = getChainIndex(lst,name)
    removeInnerBoundaryCurveAtIndex!(proj,index,chainName)
end


"""
    insertInnerBoundaryCurveAtIndex!(proj::Project, crv::Dict{String,Any},
                                     index::Int, boundaryName::String)

Insert a curve `crv` into an inner boundary chain `boundaryName`
at the specified index `index`.
"""
function insertInnerBoundaryCurveAtIndex!(proj::Project, crv::Dict{String,Any},
                                          index::Int, boundaryName::String)
    i, chain = getInnerBoundaryChainWithName(proj,boundaryName)
    lst   = chain["LIST"]
    insert!(lst,index,crv)

    if i > length(proj.innerBoundaryPoints) # New inner boundary chain
        a = []
        push!(a,curvePoints(crv,defaultPlotPts))
        push!(proj.innerBoundaryPoints,a)
    else
        innerBoundaryPoints = proj.innerBoundaryPoints[i]
        insert!(innerBoundaryPoints,index,curvePoints(crv,defaultPlotPts))
    end
    insert!(proj.innerBoundaryNames[i],index,crv["name"])

    proj.backgroundGridShouldUpdate = true
    postNotificationWithName(proj,"MODEL_DID_CHANGE_NOTIFICATION",(nothing,))
end


"""
    removeInnerBoundaryCurveAtIndex!(proj::Project, index::Int, chainName::String)

Remove the curve at index `index` from an inner boundary chain with `chainName`.
"""
function removeInnerBoundaryCurveAtIndex!(proj::Project, index::Int, chainName::String)
    i, chain = getInnerBoundaryChainWithName(proj,chainName)
    lst      = chain["LIST"]
    if index > 0
        crv = lst[index]
        deleteat!(lst, index)
        if isempty(lst) # Boundary chain contained a single curve
            # Complete removal. Requires a different function to be posted
            # in the Undo Manager
            removeInnerBoundary!(proj::Project, chainName::String)
        else # Boundary chain contained more than one curve
            deleteat!(proj.innerBoundaryNames[i],index)
            deleteat!(proj.innerBoundaryPoints[i],index)
            registerWithUndoManager(proj,insertInnerBoundaryCurveAtIndex!,
                                   (crv,index,chainName),
                                   "Remove Inner Boundary Curve")
        end
        postNotificationWithName(proj,"MODEL_DID_CHANGE_NOTIFICATION",(nothing,))
    end
end


"""
    removeInnerBoundary!(proj::Project, chainName::String)

Remove an entire inner boundary.
"""
function removeInnerBoundary!(proj::Project, chainName::String)
    i, crv = getInnerBoundaryChainWithName(proj, chainName)
    registerWithUndoManager(proj,insertInnerBoundaryAtIndex!,
                            (chainName,i,crv,proj.innerBoundaryPoints[i],proj.innerBoundaryNames[i]),
                            "Remove Inner Boundary")

    deleteat!(proj.innerBoundaryChainNames, i)
    deleteat!(proj.innerBoundaryPoints, i)
    deleteat!(proj.innerBoundaryNames, i)
    ibChains = getAllInnerBoundaries(proj)
    deleteat!(ibChains,i)
    postNotificationWithName(proj,"MODEL_DID_CHANGE_NOTIFICATION",(nothing,))
end


"""
    insertInnerBoundaryAtIndex!(proj::Project, chainName::String, index::Int, chain::??)

Insert an entire inner boundary. Primarily meant for undo operation.
"""
function insertInnerBoundaryAtIndex!(proj::Project, chainName::String, i::Int, chain::Dict{String, Any},
                                     bPoints::Vector{Any}, bNames::Vector{String})

    lst = getAllInnerBoundaries(proj::Project)
    insert!(lst,i,chain)
    insert!(proj.innerBoundaryChainNames,i,chainName)
    insert!(proj.innerBoundaryPoints,i,bPoints)
    insert!(proj.innerBoundaryNames,i,bNames)
    registerWithUndoManager(proj,removeInnerBoundary!,
                            (chainName,),
                            "Remove Inner Boundary")
    postNotificationWithName(proj,"MODEL_DID_CHANGE_NOTIFICATION",(nothing,))
end


"""
    addInnerBoundaryWithName!(proj::Project,name::String)

Create a new empty inner boundary with the given name.
"""
function addInnerBoundaryWithName!(proj::Project,name::String)
#
#   Create a new chain
#
    bndryChain         = Dict{String,Any}()
    bndryChain["name"] = name
    bndryChain["TYPE"] = "CHAIN"
    bndryCurves        = Dict{String,Any}[]
    bndryChain["LIST"] = bndryCurves
#
#   Keywords in the chain for the boundary optimization
#   Default values are: optimization off,
#                       tol = 1e-3,
#                       continuity = 0
#                       connect = empty
#
    bndryChain["optimize"] = "none"
    bndryChain["tolerance"] = "1e-3"
    bndryChain["continuity"] = "0"
    bndryChain["connect"] = "[]"

    innerBoundariesList = getAllInnerBoundaries(proj)
    push!(innerBoundariesList,bndryChain)
#
#   Prepare for plotting
#
    push!(proj.innerBoundaryChainNames,name)
    componentNames = String[]
    push!(proj.innerBoundaryNames,componentNames)

    return bndryChain
end


function getChainIndex(chain::Vector{Dict{String, Any}},name)
    for (i,dict) in enumerate(chain)
        if dict["name"] == name
            return i
        end
    end
    return 0
end


"""
    getInnerBoundaryChainOptimizeStatus(proj::Project, chainName::String)

Returns the current type of the boundary curve optimization
of an inner boundary CHAIN with `chainName`.
"""
function getInnerBoundaryChainOptimizeStatus(proj::Project, chainName::String)
    _, innerBndryDict = getInnerBoundaryChainWithName(proj, chainName)
    return innerBndryDict["optimize"]
end


"""
    setInnerBoundaryChainOptimizeStatus!(proj:Project, chainName::String, type::String)

Adjust the type for the boundary curve optimization of an inner boundary CHAIN with `chainName`.
Available types are `none`, `L2Norm`, or `H1Norm`.
"""
function setInnerBoundaryChainOptimizeStatus!(proj::Project, chainName::String, type::String)
    if !in(type, optimizeTypes)
        @warn "Acceptable optimization types are `none`, `L2Norm`, or `H1Norm`. Try again."
        return
    end
    _, innerBndryDict = getInnerBoundaryChainWithName(proj, chainName)
    innerBndryDict["optimize"] = type
end


"""
    getInnerBoundaryChainTolerance(proj::Project, chainName::String)

Returns the current tolerance for the boundary curve optimization
of an inner boundary CHAIN with `chainName`.
"""
function getInnerBoundaryChainTolerance(proj::Project, chainName::String)
    _, innerBndryDict = getInnerBoundaryChainWithName(proj, chainName)
    return parse(Float64, innerBndryDict["tolerance"])
end


"""
    setInnerBoundaryChainTolerance!(proj::Project, chainName::String, tolerance::Float64)

Sets the tolerance for the boundary curve optimization
of an inner boundary CHAIN with `chainName`.
"""
function setInnerBoundaryChainTolerance!(proj::Project, chainName::String, tolerance::Float64)
    if tolerance < 0
        @warn "The boundary tolerance must be non-negative. Try again."
        return
    elseif tolerance < 1e-5
        @warn "Setting a low tolerance may not be achievable or the mesh generation may take an inordinate amount of time. Think about how accurate of a mesh is needed before choosing a low tolerance like $tolerance."
    end

    _, innerBndryDict = getInnerBoundaryChainWithName(proj, chainName)
    innerBndryDict["tolerance"] = string(tolerance)
end


"""
    getInnerBoundaryChainContinuity(proj::Project, chainName::String)

Returns the current continuity (number of continuous derivatives) for
the boundary curve optimization of an inner boundary CHAIN with `chainName`.
"""
function getInnerBoundaryChainContinuity(proj::Project, chainName::String)
    _, innerBndryDict = getInnerBoundaryChainWithName(proj, chainName)
    return parse(Int, innerBndryDict["continuity"])
end


"""
    setInnerBoundaryChainContinuity!(proj::Project, chainName::String, continuity::Int)

Sets the continuity (number of continuous derivatives) for
the boundary curve optimization of an inner boundary CHAIN with `chainName`.
"""
function setInnerBoundaryChainContinuity!(proj::Project, chainName::String, continuity::Int)
    if continuity < 0
        @warn "The continuity must be non-negative. Try again."
        return
    elseif continuity > 2
        @warn "Higher continuity constraints can lead to ill-conditioned systems in the optimization procedure."
    end

    _, innerBndryDict = getInnerBoundaryChainWithName(proj, chainName)
    innerBndryDict["continuity"] = string(continuity)
end


"""
    getInnerBoundaryChainConnect(proj::Project, chainName::String)

Returns the current connect setting for the boundary curve optimization
of an inner boundary CHAIN with `chainName`.
"""
function getInnerBoundaryChainConnect(proj::Project, chainName::String)
    _, innerBndryDict = getInnerBoundaryChainWithName(proj, chainName)
    return innerBndryDict["connect"]
end


"""
    setInnerBoundaryChainConnect!(proj::Project, chainName::String, connect::String)

Sets the connect setting for the boundary curve optimization
of an inner boundary CHAIN with `chainName`.

By default, boundary curve optimization is done curve by curve within the chain
with an "empty" `connect = "[]"` key,
as usually there will be discontinuities (e.g. corners) between the curves.
If it is desired to define a more global approximation across multiple curves
update the `connect` key.
For example, if the chain has four segments then `connect = "2-3"` requests
that optimization occurs across curve segments two and three in the list,
where as curves 1 and 4 are optimized individually.
"""
function setInnerBoundaryChainConnect!(proj::Project, chainName::String, connect::String)
    _, innerBndryDict = getInnerBoundaryChainWithName(proj, chainName)
    innerBndryDict["connect"] = connect
end


"""
    getAllInnerBoundaries(proj::Project)

Returns an array of the inner boundaries
"""
function getAllInnerBoundaries(proj::Project)
    innerBndryDict = getDictInModelDictNamed(proj,"INNER_BOUNDARIES")
    if haskey(innerBndryDict,"LIST")
        lst = innerBndryDict["LIST"]
        return lst
    else
        lst = []
        innerBndryDict["LIST"] = lst
        return lst
    end
    return nothing
end


"""
    getInnerBoundaryChainWithName(proj::Project, name::String)

Get the inner boundary CHAIN with the given name. If one does not exist, it
is created.
"""
function getInnerBoundaryChainWithName(proj::Project, name::String)
    lst = getAllInnerBoundaries(proj::Project)
    #
    # See if there is an inner boundary with that name
    #
    l = length(lst)
    i = 0
    if l > 0
        for chain in lst
            bCurveName = chain["name"]
            i = i + 1
            if bCurveName == name
                return i, chain
            end
        end
    end
    #
    # If not, create one
    #
    chain = addInnerBoundaryWithName!(proj,name)
    return l+1, chain
end


function getInnerBoundaryCurve(proj::Project, curveName::String, boundaryName::String)
    i, chain = getInnerBoundaryChainWithName(proj, boundaryName)
    lst = chain["LIST"]
    for crv in lst
        if crv["name"] == curveName
            return crv
        end
    end
    @warn "No curve "*curveName*" in boundary "*boundaryName*". Try again."
    return nothing
end


"""
    innerBoundaryIndices(proj::Project, curveName::String)

Returns (curveIndex,chainIndex) for the location of the curve named `curveName`
in it's inner boundary chain.
"""
function innerBoundaryIndices(proj::Project, curveName::String)
#
# For each inner boundary curve chain
#
    chains = getAllInnerBoundaries(proj)
    for (j,chain) in enumerate(chains)
        crvList = chain["LIST"]
        for (i,crv) in enumerate(crvList)
            if crv["name"] == curveName
                return i,j
            end
        end
    end
    return (0,0)
end

#=
        CHAIN OPERATIONS
=#
function chainInsertionIndex(crv::Dict{String,Any}, chainList::Vector{Dict{String, Any}})
#
#   See if the endpoints of crv match up to any of the curves in the chainList. If so,
#   return the index where crv should be inserted into the list.
#
    if isempty(chainList)
        return 1 # Make crv the start of the chain.
    end
#
    nCurves = length(chainList)
    if curvesMeet(chainList[nCurves],crv)
        return nCurves+1 # Check first in likely case that user inputs in order
    end
#
#   Search though list of curves to see if the start of crv matches
#   the end of  one of the curves already in the chain. Linear search because
#   it's easy and likely the list will not be that large.
#
    for i in 1:nCurves
        if curvesMeet(chainList[i],crv)
            return i+1 # Add after the curve that matches.
        end
    end

    return nCurves+1 # No match, so just append to the list
end

#=
        OTHER
=#
function getModelDict(proj::Project)
    if haskey(proj.projectDictionary,"MODEL")
        return proj.projectDictionary["MODEL"]
    else
        modelDict = Dict{String,Any}()
        proj.projectDictionary["MODEL"] = modelDict
        modelDict["TYPE"]               = "MODEL"
        return modelDict
    end
end


function getDictInModelDictNamed(proj::Project,name::String)
    modelDict = getModelDict(proj)

    if haskey(modelDict,name)
        return modelDict[name]
    else
        d = Dict{String,Any}()
        modelDict[name] = d
        d["TYPE"]       = name
        return d
    end
end
