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

"""
    addBackgroundGrid(proj::Project, bgSize::Array{Float64})

Add the background grid block with the grid size to be a 3-vector. Use this when there
is an outer boundary defined in the model.
"""
function addBackgroundGrid!(proj::Project, bgSize::Array{Float64})
    disableUndo()
    disableNotifications()
    bgDict = getDictInControlDictNamed(proj,"BACKGROUND_GRID")
    setBackgroundGridSize!(proj, bgSize, "background grid size")
    enableUndo()
    registerWithUndoManager(proj,removeBackgroundGrid!,(nothing,),"Add Background Grid")
    enableNotifications()
    postNotificationWithName(proj,"BGRID_DID_CHANGE_NOTIFICATION",(nothing,))
end
"""
    addBackgroundGrid!(proj::Project, box::Array{Float64},  N::Array{Int} )

Add the background grid block with bounding box = [TOP, LEFT, BOTTOM, RIGHT] 
and the number of intervals in each diredction. Use this when there
is _no_ outer boundary defined in the model.
"""
function addBackgroundGrid!(proj::Project, box::Array{Float64}, N::Array{Int})
    bgDict = getDictInControlDictNamed(proj,"BACKGROUND_GRID")
    disableUndo()
    disableNotifications()
    proj.bounds     = box
    proj.userBounds = deepcopy(box)
    
    dx          = zeros(Float64,3)
    dx[1]       = (box[RIGHT] - box[LEFT])/N[1]
    dx[2]       = (box[TOP] - box[BOTTOM])/N[2]

    setBackgroundGridSize!(proj, dx, "dx")
    setBackgroundGridLowerLeft!(proj,[box[LEFT], box[BOTTOM], 0.0])
    setBackgroundGridSteps!(proj,N)
    enableUndo()
    registerWithUndoManager(proj,removeBackgroundGrid!,(nothing,),"Add Background Grid")
    enableNotifications()
    postNotificationWithName(proj,"BGRID_DID_CHANGE_NOTIFICATION",(nothing,))
    return nothing
end

"""
    addBackgroundGrid!(proj::Project, x0::Array{Float64}, dx::Array{Float64}, N::Array{Int})

Add the background grid block using the left corner, x0, the 
grid size dx, and the number of intervals in each direction. Use this when there
is _no_ outer boundary defined in the model. This version mimics HOHQMesh's 
backgroundGrid block, but the version

    addBackgroundGrid!(proj::Project, box::Array{Float64},  N::Array{Int} )

is a lot easier to use.

TODO: Change HOHQMesh and delete this way to specify the domain and use the bounding box one instead.

"""
function addBackgroundGrid!(proj::Project, x0::Array{Float64}, dx::Array{Float64}, N::Array{Int})
    bgDict = getDictInControlDictNamed(proj,"BACKGROUND_GRID")
    disableUndo()
    disableNotifications()
    setBackgroundGridSize!(proj, dx, "dx")
    setBackgroundGridLowerLeft!(proj,x0)
    setBackgroundGridSteps!(proj,N)
    proj.userBounds[TOP]    = x0[2] + N*dx[2]
    proj.userBounds[LEFT]   = x0[1]
    proj.userBounds[BOTTOM] = x0[2]
    proj.userBounds[RIGHT]  = x0[1] + N*dx[1]
    enableUndo()
    enableNotifications()
    registerWithUndoManager(proj,removeBackgroundGrid!,(nothing,),"Add Background Grid")
    postNotificationWithName(proj,"BGRID_DID_CHANGE_NOTIFICATION",(nothing,))
    return nothing
end

"""
    removeBackgroundGrid!(proj::Project)

Remove the background grid block from the project.
"""
function removeBackgroundGrid!(proj::Project)
    cDict = getControlDict(proj)
    registerWithUndoManager(proj,addBackgroundGrid!,(cDict,),"Delete Background Grid")
    delete!(cDict,"RUN_PARAMETERS")
    postNotificationWithName(proj,"BGRID_DID_CHANGE_NOTIFICATION",(nothing,))
    return nothing
end

"""
    setBackgroundGridSpacing!(proj::Project, dx::Float64, dy::Float64, dz::Float64 = 0.0)

User facing function
"""
function setBackgroundGridSize!(proj::Project, dx::Float64, dy::Float64, dz::Float64 = 0.0)
    bgDict = getDictInControlDictNamed(proj,"BACKGROUND_GRID")

    newSize = [dx,dy]
    if haskey(bgDict,"dx")
        oldSpacing = realArrayForKeyFromDictionary("dx", bgDict)
        setBackgroundGridSize!(proj, newSize, "dx")
        # With the "corner+intervals" setting of the outer boundary deprecated, keep
        # the original bounds fixed.
        x0 = realArrayForKeyFromDictionary("x0",bgDict)
        Nx = round(Int,(proj.userBounds[RIGHT] - proj.userBounds[LEFT])  /dx[1])
        Ny = round(Int,(proj.userBounds[TOP]   - proj.userBounds[BOTTOM])/dx[2])
        N  = [Nx,Ny,0]
        disableNotifications()
        setBackgroundGridSteps!(proj,N)
        enableNotifications()
    else
        oldSpacing = realArrayForKeyFromDictionary("background grid size", bgDict)
        setBackgroundGridSize!(proj, newSize, "background grid size")
    end
    postNotificationWithName(proj,"BGRID_DID_CHANGE_NOTIFICATION",(nothing,))
    registerWithUndoManager(proj,setBackgroundGridSize!,
                            (oldSpacing[1],oldSpacing[2],0.0),"Set Background Grid Spacing")
    return nothing
    end
"""
    getBackgroundGridSize(proj::Project)

Returns the background grid size array.
"""
function getBackgroundGridSize(proj::Project)
    bgDict = getDictInControlDictNamed(proj,"BACKGROUND_GRID")
    if haskey(bgDict,"dx")
        return realArrayForKeyFromDictionary("dx",bgDict)
    elseif haskey(bgDict,"background grid size")
        return realArrayForKeyFromDictionary("background grid size",bgDict)
    else
        return nothing
    end
end
"""
    function getBackgroundGridLowerLeft(proj::Project)

Returns the [x,y] of the lower left point of thebackground grid.
"""
function getBackgroundGridLowerLeft(proj::Project)
    bgDict = getDictInControlDictNamed(proj,"BACKGROUND_GRID")
    if haskey(bgDict,"x0")
        return realArrayForKeyFromDictionary("x0",bgDict)
    else
        return nothing
    end
end
"""
    function getBackgroundGridLowerLeft(proj::Project)
        
Returns the [x,y,z] of the lower left point of thebackground grid.
"""
function getBackgroundGridSteps(proj::Project)
    bgDict = getDictInControlDictNamed(proj,"BACKGROUND_GRID")
    if haskey(bgDict,"N")
        return realIntForKeyFromDictionary("N",bgDict)
    else
        return nothing
    end
end
"""
    setBackgroundGridLowerLeft!(proj::Project, x0::Array{Float64})

Set the lower left location of the background grid for problems that have no
outer boundary.
"""
function setBackgroundGridLowerLeft!(proj::Project, x0::Array{Float64})

    bgDict = getDictInControlDictNamed(proj,"BACKGROUND_GRID")

    if haskey(bgDict,"x0")
        oldLowerLeft = realArrayForKeyFromDictionary("x0",bgDict)
        registerWithUndoManager(proj,setBackgroundGridLowerLeft!,
        (oldLowerLeft[1],oldLowerLeft[2],0.0),"Set Background Lower Left")
    end 

    x0Str  = @sprintf("[%f,%f,%f]", x0[1], x0[2], x0[3])
    bgDict["x0"] = x0Str   
    postNotificationWithName(proj,"BGRID_DID_CHANGE_NOTIFICATION",(nothing,))
    return nothing
end
"""
setBackgroundGridSteps!(proj::Project, N::Array{Int})

Set how many steps of size setBackgroundGridSpacing in each direction the background grid extends from the
lower left.
"""
function setBackgroundGridSteps!(proj::Project, N::Array{Int})
    bgDict = getDictInControlDictNamed(proj,"BACKGROUND_GRID")

    if haskey(bgDict,"N")
        oldN = intArrayForKeyFromDictionary("N",bgDict)
        registerWithUndoManager(proj,setBackgroundGridSteps!,
        (oldN[1],oldN[2],oldN[3]),"Set Background Steps")
    end

    NStr   = @sprintf("[%i,%i,%i]", N[1], N[2], N[3])
    bgDict["N"]  = NStr

    postNotificationWithName(proj,"BGRID_DID_CHANGE_NOTIFICATION",(nothing,))
    return nothing
end
"""
setBackgroundGridSize!(proj::Project, dx::Array{Float64},key::String)
"""
function setBackgroundGridSize!(proj::Project, dx::Array{Float64}, key::String)
    setBackgroundGridSize!(proj, dx[1], dx[2], key)
    return nothing
end
"""
setBackgroundGridSize!(proj::Project, dx::Float64, dy::Float64,key::String)
"""
function setBackgroundGridSize!(proj::Project, dx::Float64, dy::Float64,key::String)
    bgDict = getDictInControlDictNamed(proj,"BACKGROUND_GRID")

    if haskey(bgDict,key)
        oldDx = realArrayForKeyFromDictionary(key,bgDict)
        registerWithUndoManager(proj,setBackgroundGridSize!,
        (oldDx[1],oldDx[2],oldDx[3]),"Set Background Size")
    end

    dxStr  = @sprintf("[%f,%f,%f]", dx, dy, 0.0)
    bgDict[key] = dxStr
    postNotificationWithName(proj,"BGRID_DID_CHANGE_NOTIFICATION",(nothing,))
    return nothing
end

"""
    addBackgroundGrid!(proj::Project, dict::Dict{String,Any})

Used only for undo/redo.
"""
function addBackgroundGrid!(proj::Project, dict::Dict{String,Any})
    controlDict = getControlDict(proj)
    controlDict["BACKGROUND_GRID"] = dict
    return nothing
end

