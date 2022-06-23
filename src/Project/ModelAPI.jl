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
    indx  = getChainIndex(lst,name)
    if indx > 0
        proj.backgroundGridShouldUpdate = true
        removeOuterBoundaryCurveAtIndex!(proj,indx) # posts undo/notification
    else
        # `name` to be deleted does not lie in outer boundary chain. Throw an error.
        error("No curve ", name, " in boundary Outer. Try again.")
    end
end


"""
    getOuterBoundaryCurveWithName(proj::Project, name::String)
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
    insertOuterBoundaryCurveAtIndex!(proj::Project, crv::Dict{String,Any}, indx::Int)

Insert a curve into the outer boundary chain at the specified index.
"""
function insertOuterBoundaryCurveAtIndex!(proj::Project, crv::Dict{String,Any}, indx::Int)
    lst = getOuterBoundaryChainList(proj)
    insert!(lst,indx,crv)
    insert!(proj.outerBndryPoints,indx,curvePoints(crv,defaultPlotPts))
    insert!(proj.outerBndryNames,indx,crv["name"])
    proj.backgroundGridShouldUpdate = true
    registerWithUndoManager(proj,removeOuterBoundaryCurveAtIndex!,(indx,),"Add Outer Boundary Curve")
    postNotificationWithName(proj,"MODEL_DID_CHANGE_NOTIFICATION",(nothing,))
end


"""
    removeOuterBoundaryCurveAtIndex!(proj::Project, indx::Int)

Remove a curve from the outer boundary chain at the specified index.
"""
function removeOuterBoundaryCurveAtIndex!(proj::Project, indx::Int)
    lst = getOuterBoundaryChainList(proj)
    crv = lst[indx]
    deleteat!(lst,indx)
    deleteat!(proj.outerBndryNames,indx)
    deleteat!(proj.outerBndryPoints,indx)
    proj.backgroundGridShouldUpdate = true
    registerWithUndoManager(proj,insertOuterBoundaryCurveAtIndex!,(crv,indx),"Remove Outer Boundary Curve")
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


# function addOuterBoundary(proj::Project,obDict::Dict{String,Any})
#     modelDict = getModelDict(proj)
#     modelDict["OUTER_BOUNDARY"] = obDict
# end


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
        lst = Dict{String,Any}[]
        outerBndryDict["LIST"] = lst
        return lst
    end
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
    indx  = getChainIndex(lst,name)
    removeInnerBoundaryCurveAtIndex!(proj,indx,chainName)
end


"""
    insertInnerBoundaryCurveAtIndex!(proj::Project, crv::Dict{String,Any},
                                     indx::Int, boundaryName::String)

Insert a curve `crv` into an inner boundary chain `boundaryName`
at the specified index `indx`.
"""
function insertInnerBoundaryCurveAtIndex!(proj::Project, crv::Dict{String,Any},
                                          indx::Int, boundaryName::String)
    i, chain = getInnerBoundaryChainWithName(proj,boundaryName)
    lst   = chain["LIST"]
    insert!(lst,indx,crv)

    if i > length(proj.innerBoundaryPoints) # New inner boundary chain
    a = []
    push!(a,curvePoints(crv,defaultPlotPts))
    push!(proj.innerBoundaryPoints,a)
    else
    innerBoundaryPoints = proj.innerBoundaryPoints[i]
    insert!(innerBoundaryPoints,indx,curvePoints(crv,defaultPlotPts))
    end
    insert!(proj.innerBoundaryNames[i],indx,crv["name"])

    proj.backgroundGridShouldUpdate = true
    postNotificationWithName(proj,"MODEL_DID_CHANGE_NOTIFICATION",(nothing,))
end


"""
    removeInnerBoundaryCurveAtIndex!(proj::Project, indx::Int, chainName::String)

Remove the curve at index `indx` from an inner boundary chain with `chainName`.
"""
function removeInnerBoundaryCurveAtIndex!(proj::Project, indx::Int, chainName::String)
    i, chain = getInnerBoundaryChainWithName(proj,chainName)
    lst      = chain["LIST"]
    if indx > 0
        crv      = lst[indx]
        deleteat!(lst, indx)
        if isempty(lst) # Boundary chain contained a single curve
            # Complete removal. Requires a different function to be posted
            # in the Undo Manager
            removeInnerBoundary!(proj::Project, chainName::String)
        else # Boundary chain contained more than one curve
            deleteat!(proj.innerBoundaryNames[i],indx)
            deleteat!(proj.innerBoundaryPoints[i],indx)
            registerWithUndoManager(proj,insertInnerBoundaryCurveAtIndex!,
                                   (crv,indx,chainName),
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
    insertInnerBoundaryAtIndex!(proj::Project, chainName::String, indx::Int, chain::??)

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
    getInnerBoundaryWithName(proj::Project, name::String)

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
"""

"""
function getInnerBoundaryCurve(proj::Project, curveName::String, boundaryName::String)
    i, chain = getInnerBoundaryChainWithName(proj, boundaryName)
    lst   = chain["LIST"]
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
