
"""
    addSpringSmoother!(status::String, type::String, nIterations::Int)

Status is either `ON` or `OFF`
Type is either `LinearSpring` or `LinearAndCrossbarSpring`
"""
function addSpringSmoother!(proj::Project,status::String = "ON",
                            type::String = "LinearAndCrossbarSpring",
                            nIterations::Int = 25)
    if !in(status,statusValues)
        @warn "Acceptable smoother status are: `ON` or `OFF`. Try again."
        return
    end
    if !in(type,smootherTypes)
        @warn "Acceptable smoothers are: `LinearAndCrossbarSpring` or `LinearSpring`. Try again."
        return
    end
    setSmoothingStatus!(proj,status)
    setSmoothingType!(proj,type)
    setSmoothingIterations!(proj,nIterations)
end


"""
    setSmoothingStatus(proj:Project, status::String)

Status is either "ON" or "OFF"
"""
function setSmoothingStatus!(proj::Project, status::String)
    if !in(status,statusValues)
        @warn "Acceptable smoother status is either: `ON` or `OFF`. Try again."
        return
    end
    smDict = getDictInControlDictNamed(proj,"SPRING_SMOOTHER")
    smDict["smoothing"] = status
end


"""
    smoothingStatus(proj::Project)

Returns whether the smoother will be "ON" or "OFF"
"""
function getSmoothingStatus(proj::Project)
    smDict = getDictInControlDictNamed(proj,"SPRING_SMOOTHER")
    return smDict["smoothing"]
end


"""
    setSmoothingType!(proj:Project, status::String)

Type is either `LinearSpring` or `LinearAndCrossbarSpring`
"""
function setSmoothingType!(proj::Project, type::String)
    if !in(type,smootherTypes)
        @warn "Acceptable smoothers are: `LinearAndCrossbarSpring` or `LinearSpring`. Try again."
        return
    end
    smDict = getDictInControlDictNamed(proj,"SPRING_SMOOTHER")
    smDict["smoothing type"] = type
end


"""
    getSmoothingType(proj::Project)

Returns either "LinearSpring" or "LinearAndCrossbarSpring"
"""
function getSmoothingType(proj::Project)
    smDict = getDictInControlDictNamed(proj,"SPRING_SMOOTHER")
    return smDict["smoothing type"]
end


"""
    setSmoothingIterations!(proj::Project, iterations::Int)

Set the number of iterations to smooth the mesh.
"""
function setSmoothingIterations!(proj::Project, iterations::Int)
    smDict = getDictInControlDictNamed(proj,"SPRING_SMOOTHER")
    smDict["number of iterations"] = iterations
end


"""
    getSmoothingIterations(proj::Project)

Get the number of iterations to smooth the mesh.
"""
function getSmoothingIterations(proj::Project)
    smDict = getDictInControlDictNamed(proj,"SPRING_SMOOTHER")
    return smDict["number of iterations"]
end


"""
    removeSpringSmoother!(proj::Project)

Remove the background grid block from the project.
"""
function removeSpringSmoother!(proj::Project)
    cDict = getControlDict(proj)
    delete!(cDict,"SPRING_SMOOTHER")
end
