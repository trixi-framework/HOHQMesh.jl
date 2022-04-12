
"""
    newRefinementCenter(name, type,
                        center, meshSize,
                        width)

Create refinement center of `type` "smooth" or "sharp" centered at `center = [x,y,z]``
with a mesh size `meshSize` spread over a radius `width`.
"""
function newRefinementCenter(name::String, type::String,
                              x0::Array{Float64}, h::Float64,
                              w::Float64)
    disableUndo()
    disableNotifications()
    centerDict = Dict{String,Any}()
    centerDict["TYPE"] = "REFINEMENT_CENTER"
    setRefinementType!(centerDict,type)
    setRefinementLocation!(centerDict,x0)
    setRefinementGridSize!(centerDict,h)
    setRefinementWidth!(centerDict,w)
    setRefinementName!(centerDict,name)
    enableNotifications()
    enableUndo()
    return centerDict
end


"""
    addRefinementRegion!(proj::Project,r::Dict{String,Any})

Add the refinement region to the project
"""
function addRefinementRegion!(proj::Project,r::Dict{String,Any})
    lst  = getListInControlDictNamed(proj,"REFINEMENT_REGIONS")
    push!(lst,r)
    addRefinementRegionPoints!(proj,r)
    enableUndo()
    registerWithUndoManager(proj,removeRefinementRegion!, (r["name"],), "Add Refinement Region")
    enableNotifications()
    postNotificationWithName(proj,"REFINEMENT_WAS_ADDED_NOTIFICATION",(nothing,))
end


"""
    addRefinementRegionPoints!(proj::Project, r::Dict{String,Any})

Compute and add to the project the plotting points for the refinement region
"""
function addRefinementRegionPoints!(proj::Project, r::Dict{String,Any})

        x = refinementRegionPoints(r)
        push!(proj.refinementRegionPoints,x)
        push!(proj.refinementRegionNames, r["name"])
        center = getRefinementRegionCenter(r)
        push!(proj.refinementRegionLoc,center)
end


"""
    refinementRegionPoints(r::Dict{String,Any})

Returns Array{Float64,2} being the plotting points of a refinement region
"""
function refinementRegionPoints(r::Dict{String,Any})

    if r["TYPE"] == "REFINEMENT_CENTER"
        center = getRefinementLocation(r)
        radius = getRefinementWidth(r)

        N = defaultPlotPts
        x = zeros(Float64,N+1,2)
        t = zeros(Float64,N+1)
        for i = 1:N+1
            t[i] = (i-1)/N
        end
        arcCurvePoints(center,radius,0.0,360.0,"degrees",t,x)
        return x
    else
       xStart = realArrayForKeyFromDictionary("x0",r)
       xEnd   = realArrayForKeyFromDictionary("x1",r)
       dx     = xEnd - xStart
       l      = sqrt(dx[1]^2 + dx[2]^2)
       w      = realForKeyFromDictionary("w",r)
       v      = [-dx[2]/l,dx[1]/l]
       x1     = xStart[1:2] + w*v
       x2     = xEnd[1:2]   + w*v
       v      = [dx[2]/l,-dx[1]/l]
       x3     = xEnd[1:2]   + w*v
       x4     = xStart[1:2] + w*v
       x      = zeros(Float64,5,2)
       x[1,:] = x1
       x[2,:] = x2
       x[3,:] = x3
       x[4,:] = x4
       x[5,:] = x1
       return x
    end

end


"""
    getRefinementRegionCenter(r::Dict{String,Any})

Get, or compute, the center of the given refinement region.
"""
function getRefinementRegionCenter(r::Dict{String,Any})
    if r["TYPE"] == "REFINEMENT_CENTER"
        center = getRefinementLocation(r)
        return center[1:2]
    else
        xStart = realArrayForKeyFromDictionary("x0",r)
        xEnd   = realArrayForKeyFromDictionary("x1",r)
        xAvg   = 0.5*(xStart + xEnd)
        return xAvg[1:2]
    end
end


"""
    removeRefinementRegion!(proj::Project, name::String)

Delete the named refinement region.
"""
function removeRefinementRegion!(proj::Project, name::String)
    i,r = getRefinementRegion(proj,name)
    lst = getAllRefinementRegions(proj)
    deleteat!(lst,i)
    deleteat!(proj.refinementRegionLoc,i)
    deleteat!(proj.refinementRegionNames,i)
    deleteat!(proj.refinementRegionPoints,i)
    registerWithUndoManager(proj,insertRefinementRegion!, (r,i,), "Remove Refinement Region")
    enableNotifications()
    postNotificationWithName(proj,"REFINEMENT_WAS_ADDED_NOTIFICATION",(nothing,))
end


"""
    insertRefinementRegion!(proj::Project, r::Dict{String,Any}, indx::Int)

Used by undo()
"""
function insertRefinementRegion!(proj::Project, r::Dict{String,Any}, indx::Int)
    lst = getAllRefinementRegions(proj)
    registerWithUndoManager(proj,removeRefinementRegion!, (r["name"],), "Set Insert Refinement Region")
    insert!(lst,indx,r)
    x = refinementRegionPoints(r)
    insert!(proj.refinementRegionPoints,indx,x)
    center = getRefinementRegionCenter(r)
    insert!(proj.refinementRegionLoc,indx,center)
    insert!(proj.refinementRegionNames,indx,r["name"])
    postNotificationWithName(proj,"REFINEMENT_WAS_ADDED_NOTIFICATION",(nothing,))
end


"""
    newRefinementLine(name, type,
                      start, end,
                      meshSize,
                      width)

Create refinement line of type "smooth" or "sharp" between `start` = [x,y,z] and `end` = [x,y,z]
with a mesh size `meshSize` spread over a width `width`.
"""
function newRefinementLine(name::String, type::String,
                            x0::Array{Float64}, x1::Array{Float64},
                            h::Float64,
                            w::Float64)
    disableUndo()
    disableNotifications()
    lineDict = Dict{String,Any}()
    lineDict["TYPE"] = "REFINEMENT_LINE"
    setRefinementType!(lineDict,type)
    setRefinementStart!(lineDict,x0)
    setRefinementEnd!(lineDict,x1)
    setRefinementGridSize!(lineDict,h)
    setRefinementWidth!(lineDict,w)
    setRefinementName!(lineDict,name)
    enableNotifications()
    enableUndo()
    return lineDict
end


"""
    getRefinementRegion(proj::Project, indx)

Get the refinement region with index, indx from the project. Returns nothing if
there is none. The return value is a dictionary that represents the refinement region.
"""
function getRefinementRegion(proj::Project, indx::Int)
    lst = getListInControlDictNamed(proj,"REFINEMENT_REGIONS")
    if indx > length(lst)
        error("Index ",indx," is larger than the number of refinement regions ", length(lst))
    end
    return lst[indx]
end


"""
    getAllRefinementRegions(proj::Project)

Get the list of refinement regions.
"""
function getAllRefinementRegions(proj::Project)
    lst = getListInControlDictNamed(proj,"REFINEMENT_REGIONS")
    return lst
end


"""
    (i,r) = getRefinementRegion(project, name)

Get the refinement region with the given name and its location in the list of refinement regions.
"""
function getRefinementRegion(proj::Project, name::String)
    lst = getListInControlDictNamed(proj,"REFINEMENT_REGIONS")
    for (i,r) in enumerate(lst)
        if r["name"] == name
            return i,r
        end
    end
    error("Refinement region with name ", name, " not found!")
end


"""
    setRefinementType!(refinementRegion, type)

Set the type, either "smooth" or "sharp" for the given refinement region.
"""
function setRefinementType!(r::Dict{String,Any}, type::String)
    if !in(type,refinementTypes)
        @warn "Acceptable refinement types are `smooth` and `sharp`. Try again."
        return
    end

    if haskey(r,"type")
        oldType = r["type"]
        registerWithUndoManager(r,setRefinementType!, (oldType,), "Set Refinement Type")
    end
    r["type"] = type
end


"""
    getRefinementType(r::Dict{String,Any})

Return the type of refinement, either "smooth" or "sharp". `r` is the dictionary that
represents the refinement region.
"""
function getRefinementType(r::Dict{String,Any})
    return r["type"]
end


"""
    setRefinementName!(r::Dict{String,Any}, type)

Set a name for the refinement region.`r` is the dictionary that
represents the refinement region.
"""
function setRefinementName!(r::Dict{String,Any}, name::String)
    if haskey(r,"name")
        oldName = r["name"]
        registerWithUndoManager(r,setRefinementName!, (oldName,), "Set Refinement Name")
    end
    r["name"] = name
    postNotificationWithName(r,"REFINEMENT_WAS_CHANGED_NOTIFICATION",(nothing,))
end


"""
    getRefinementName(r::Dict{String,Any})

Return name of the refinement. `r` is the dictionary that represents the refinement region.
"""
function getRefinementName(r::Dict{String,Any})
    return r["name"]
end


"""
    setRefinementLocation!(refinementCenter, location)

Set the location of a refinement center to location = [x,y,z].
"""
function setRefinementLocation!(r::Dict{String,Any}, x::Array{Float64})
    x0Str = "[$(x[1]),$(x[2]),$(x[3])]"
    setRefinementLocation!(r,x0Str)
    return nothing
end


function setRefinementLocation!(r::Dict{String,Any}, x0Str::String)
    if haskey(r,"x0")
        old = r["x0"]
        registerWithUndoManager(r,setRefinementLocation!, (old,), "Set Refinement Center")
    end
    r["x0"] = x0Str
    postNotificationWithName(r,"REFINEMENT_WAS_CHANGED_NOTIFICATION",(nothing,))
    return nothing
end


"""
    getRefinementLocation(r::Dict{String,Any})

Return Array{Float64} of the location of the refinement center.`r` is the dictionary that
represents the refinement region.
"""
function getRefinementLocation(r::Dict{String,Any})
    return realArrayForKeyFromDictionary("x0",r)
end


"""
    setRefinementGridSize!(r::Dict{String,Any}, h)

Set the grid size, `h` for the refinement region. `r` is the dictionary that
represents the refinement region.
"""
function setRefinementGridSize!(r::Dict{String,Any}, h::Float64)
    if haskey(r,"h")
        old = r["h"]
        registerWithUndoManager(r,setRefinementGridSize!, (old,), "Set Refinement Grid Size")
    end
    r["h"] = string(h)
    postNotificationWithName(r,"REFINEMENT_WAS_CHANGED_NOTIFICATION",(nothing,))
end


function setRefinementGridSize!(r::Dict{String,Any}, h::String)
    hf = parse(Float64,h)
    setRefinementGridSize!(r,hf)
end


"""
    getRefinementGridSize(r::Dict{String,Any})

Returns the grid size,h, as Float64. `r` is the dictionary that
represents the refinement region.
"""
function getRefinementGridSize(r::Dict{String,Any})
    return parse(Float64,r["h"])
end


"""
    setRefinementWidth!(r::Dict{String,Any}, width)

Set the width of the refinement region. `r` is the dictionary that
represents the refinement region.
"""
function setRefinementWidth!(r::Dict{String,Any},w::Float64)
    if haskey(r,"w")
        old = r["w"]
        registerWithUndoManager(r,setRefinementWidth!, (old,), "Set Refinement Width")
    end
    r["w"] = string(w)
    postNotificationWithName(r,"REFINEMENT_WAS_CHANGED_NOTIFICATION",(nothing,))
end


function setRefinementWidth!(r::Dict{String,Any},w::String)
    wf = parse(Float64,w)
    setRefinementWidth!(r,wf)
end
#
#  --------------------------------------------------------------------------------------
#
"""
    getRefinementWidth(r::Dict{String,Any})

Returns the region width,w, as Float64. `r` is the dictionary that
represents the refinement region.
"""
function getRefinementWidth(r::Dict{String,Any})
    return parse(Float64,r["w"])
end


"""
    setRefinementStart!(refinementRegion, location)

Set the start point location of a refinement line, `location = [x, y, z]`.
"""
function setRefinementStart!(r::Dict{String,Any}, x::Array{Float64})
    x0Str = "[$(x[1]),$(x[2]),$(x[3])]"
    setRefinementStart!(r,x0Str)
end


function setRefinementStart!(r::Dict{String,Any}, x0Str::String)
    if haskey(r,"x0")
        old = r["x0"]
        registerWithUndoManager(r,setRefinementStart!, (old,), "Set Refinement Start")
    end
    r["x0"] = x0Str
    postNotificationWithName(r,"REFINEMENT_WAS_CHANGED_NOTIFICATION",(nothing,))
end


"""
    getRefinementStart  (r::Dict{String,Any})

Return Array{Float64} of the start location of the refinement line. `r` is the dictionary that
represents the refinement region.
"""
function getRefinementStart(r::Dict{String,Any})
    return realArrayForKeyFromDictionary("x0",r)
end


"""
    setRefinementEnd!(refinementRegion, location)

Set the end point location of a refinement line, `location = [x, y, z]`.
"""
function setRefinementEnd!(r::Dict{String,Any}, x::Array{Float64})
    x0Str = "[$(x[1]),$(x[2]),$(x[3])]"
    setRefinementEnd!(r,x0Str)
end

function setRefinementEnd!(r::Dict{String,Any}, x0Str::String)
    if haskey(r,"x1")
        old = r["x1"]
        registerWithUndoManager(r,setRefinementEnd!, (old,), "Set Refinement End")
    end
    r["x1"] = x0Str
    postNotificationWithName(r,"REFINEMENT_WAS_CHANGED_NOTIFICATION",(nothing,))
end


"""
    getRefinementEnd(r::Dict{String,Any})

Return Array{Float64} of the end location of the refinement line
"""
function getRefinementEnd(r::Dict{String,Any})
    return realArrayForKeyFromDictionary("x1",r)
end
