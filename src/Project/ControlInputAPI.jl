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

function getControlDict(proj::Project)
    if haskey(proj.projectDictionary,"CONTROL_INPUT")
        return proj.projectDictionary["CONTROL_INPUT"]
    else
        controlDict = Dict{String,Any}()
        proj.projectDictionary["CONTROL_INPUT"] = controlDict
        controlDict["TYPE"] = "CONTROL_INPUT"
        return controlDict
    end
end


function getDictInControlDictNamed(proj::Project,name::String)
    controlDict = getControlDict(proj)

    if haskey(controlDict,name)
        return controlDict[name]
    else
        d = Dict{String,Any}()
        controlDict[name] = d
        d["TYPE"] = name
        return d
    end
end


function getListInControlDictNamed(proj::Project,name::String)
    dict = getDictInControlDictNamed(proj::Project,name::String)
    if haskey(dict,"LIST")
        return dict["LIST"]
    else
        lst = []
        dict["LIST"] = lst
        return lst
    end
end
