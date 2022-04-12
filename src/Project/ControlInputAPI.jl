
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
