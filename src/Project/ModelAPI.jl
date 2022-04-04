#=
 MIT License

 Copyright (c) 2010-present David A. Kopriva and other contributors: AUTHORS.md

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

 --- End License
=#

include("../Model/Geometry.jl")

#
#  --------------------------------------------------------------------------------------
#
"""
    addCurveToOuterBoundary!(proj::Project, crv::Dict{String,Any})

Add a curve to the outer boundary. The curves must be added in order counter-clockwise
"""
function addCurveToOuterBoundary!(proj::Project, crv::Dict{String,Any})
    chain = getOuterBoundaryChainList(proj)
#
#   Check if the new curve meets the last one added
#
    if !isempty(chain)
        lastCurve = last(chain)
        if !curvesMeet(lastCurve,crv)
            lastName = getCurveName(lastCurve)
            newName  = getCurveName(crv)
            println("the curve $lastName does not meet the previous curve, $newName. Try again.")
            return
        end
    end
#
#   Checks out, add to model
#
    push!(chain,crv)
    crvPoints = curvePoints(crv,defaultPlotPts)
    push!(proj.outerBndryPoints, crvPoints)
    proj.backgroundGridShouldUpdate = true

    push!(proj.outerBndryNames,crv["name"])

    registerWithUndoManager(proj,removeOuterBoundaryCurveWithName!,(crv["name"],),"Add Curve")
    postNotificationWithName(proj,"MODEL_DID_CHANGE_NOTIFICATION",(nothing,))
end
"""
    removeOuterBoundaryCurveWithName!(proj::Project, name::String)

Remove the named curve in the outer boundary
"""
function removeOuterBoundaryCurveWithName!(proj::Project, name::String)
    lst = getOuterBoundaryChainList(proj)
    indx  = getChainIndex(lst,name)
    if indx > 0
        removeOuterBoundaryCurveAtIndex!(proj,indx) # posts undo/notification
        proj.backgroundGridShouldUpdate = true
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
    insertOuterBoundaryCurveAtIndex(proj::Project, crv::Dict{String,Any}, indx::Int)

Insert a curve at the specified index.
"""
function insertOuterBoundaryCurveAtIndex!(proj::Project, crv::Dict{String,Any}, indx::Int)
    lst = getOuterBoundaryChainList(proj)
    insert!(lst,indx,crv)
    insert!(proj.outerBndryPoints,indx,curvePoints(crv,defaultPlotPts))
    insert!(proj.outerBndryNames,indx,crv["name"])
    proj.backgroundGridShouldUpdate = true
    registerWithUndoManager(proj,removeOuterBoundaryCurveAtIndex!,(indx,),"Add Curve")
    postNotificationWithName(proj,"MODEL_DID_CHANGE_NOTIFICATION",(nothing,))
end

function removeOuterBoundaryCurveAtIndex!(proj::Project, indx::Int)
    lst = getOuterBoundaryChainList(proj)
    crv = lst[indx]
    deleteat!(lst,indx)
    deleteat!(proj.outerBndryNames,indx)
    deleteat!(proj.outerBndryPoints,indx)
    proj.backgroundGridShouldUpdate = true
    registerWithUndoManager(proj,insertOuterBoundaryCurveAtIndex!,(crv,indx),"Add Curve")
    postNotificationWithName(proj,"MODEL_DID_CHANGE_NOTIFICATION",(nothing,))
end
"""
    addOuterBoundary!(proj::Project, outerBoundary::Dict{String,Any})

Add an empty outer boundary to the project. There can be only one.
This function is only used as part of an undo operation removing the outer boundary
"""
function addOuterBoundary!(proj::Project, outerBoundary::Dict{String,Any})
    model = getModelDict(proj)
    model["OUTER_BOUNDARY"] = outerBoundary
    registerWithUndoManager(proj,removeOuterboundary!, (nothing,), "Add Outer Boundary")
end
"""
    removeOuterboundary!(proj::Project)

Remove the outer boundary curve if it exists.
"""
function removeOuterboundary!(proj::Project)
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
#
#  --------------------------------------------------------------------------------------
#
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

    i, chain = getInnerBoundaryChainWithName(proj,boundaryName)
    curveList = chain["LIST"]
#
#   Check if the new curve meets the last one added
#
    if !isempty(curveList)
        lastCurve = last(curveList)
        if !curvesMeet(lastCurve,crv)
            lastName = getCurveName(lastCurve)
            newName  = getCurveName(crv)
            println("the curve $lastName does not meet the previous curve, $newName. Try again.")
            return
        end
    end
#
#   Checks out, add to model
#
    push!(curveList,crv)

    if i > length(proj.innerBoundaryPoints) # New inner boundary chain
        a = []
        push!(a,curvePoints(crv,defaultPlotPts))
        push!(proj.innerBoundaryPoints,a)
    else
        a = proj.innerBoundaryPoints[i]
        push!(a,curvePoints(crv,defaultPlotPts))
    end
    push!(proj.innerBoundaryNames[i],crv["name"])
    proj.backgroundGridShouldUpdate = true
    registerWithUndoManager(proj,removeInnerBoundaryCurve!,
                            (crv["name"],boundaryName),
                            "Add Inner Boundary Curve")
    postNotificationWithName(proj,"MODEL_DID_CHANGE_NOTIFICATION",(nothing,))
end
"""
    removeInnerBoundaryCurve!(proj::Project, name::String)

Remove the named curve in the inner boundary
"""
function removeInnerBoundaryCurve!(proj::Project, name::String, chainName::String)
    i, chain = getInnerBoundaryChainWithName(proj,chainName)
    lst   = chain["LIST"]
    if isempty(lst)
        println("No curve ", name, " in boundary ", chainName, ". Try again.")
        return
    end
    indx  = getChainIndex(lst,name)
    removeInnerBoundaryCurveAtIndex!(proj,indx,chainName)
end

function insertInnerBoundaryCurveAtIndex!(proj::Project, crv::Dict{String,Any},
                                         indx::Int, boundaryName::String)
    i, chain = getInnerBoundaryChainWithName(proj,boundaryName)
    lst   = chain["LIST"]
    insert!(lst,indx,crv)
    innerBoundaryPoints = proj.innerBoundaryPoints[i]
    insert!(innerBoundaryPoints,indx,curvePoints(crv,defaultPlotPts))
    insert!(proj.innerBoundaryNames[i],indx,crv["name"])
    proj.backgroundGridShouldUpdate = true
    postNotificationWithName(proj,"MODEL_DID_CHANGE_NOTIFICATION",(nothing,))
end

function removeInnerBoundaryCurveAtIndex!(proj::Project, indx::Int, chainName::String)
    i, chain = getInnerBoundaryChainWithName(proj,chainName)
    lst      = chain["LIST"]
    if indx > 0
        crv      = lst[indx]
        deleteat!(lst,indx)
        deleteat!(proj.innerBoundaryNames[i],indx)
        deleteat!(proj.innerBoundaryPoints[i],indx)
        registerWithUndoManager(proj,insertInnerBoundaryCurveAtIndex!,
                                (crv,indx,chainName),
                                "Remove Inner Boundary Curve")
        if isempty(lst)
            ibChains = getAllInnerBoundaries(proj)
            deleteat!(ibChains,i)
            deleteat!(proj.innerBoundaryChainNames,i)
            deleteat!(proj.innerBoundaryPoints,i)
            deleteat!(proj.innerBoundaryNames,i)
        end
        proj.backgroundGridShouldUpdate = true
        postNotificationWithName(proj,"MODEL_DID_CHANGE_NOTIFICATION",(nothing,))
    end
end
"""
    removeInnerBoundary!(proj::Project, chainName::String)

Remove an entire inner boundary
"""
function removeInnerBoundary!(proj::Project, chainName::String)
    i, crv = getInnerBoundaryChainWithName(proj, chainName)
    deleteat!(proj.innerBoundaryChainNames, i)
    deleteat!(proj.innerBoundaryPoints, i)
    ibChains = getAllInnerBoundaries(proj)
    deleteat!(ibChains,i)
end
#
#  --------------------------------------------------------------------------------------
#
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
#
#----------------------------------------------------------------------------------------
#
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
#
#  --------------------------------------------------------------------------------------
#
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
#
#  --------------------------------------------------------------------------------------
#
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
    println("No curve ", curveName, " in boundary ", boundaryName, ". Try again.")
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
#
#  --------------------------------------------------------------------------------------
#
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
