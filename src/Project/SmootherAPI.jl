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
    addSpringSmoother!(status::String, type::String, nIterations::Int)

Status is either `ON` or `OFF`
Type is either `LinearSpring` or `LinearAndCrossbarSpring`
"""
function addSpringSmoother!(proj::Project,status::String = "ON",
                            type::String = "LinearAndCrossbarSpring",
                            nIterations::Int = 25)
    if !in(status,statusValues)
        println("Acceptable smoother status are: ", statusValues,". Try again.")
        return
    end
    if !in(type,smootherTypes)
        println("Acceptable smoothers are:", smootherTypes, ". Try again.")
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
        println("Acceptable smoother status is one of: ", statusValues,". Try again.")
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
        println("Acceptable smoothers are:", smootherTypes, ". Try again.")
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
