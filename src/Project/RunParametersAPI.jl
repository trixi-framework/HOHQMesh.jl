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
    addRunParameters!(proj::Project, 
        plotFormat::String     = "skeleton", 
        meshFileFormat::String = "ISM-V2", 
        polynomialOrder::Int   = 5)

Add a RUN_PARAMETERS block and set all the parameters in one call.
"""
function addRunParameters!(proj::Project, 
    plotFormat::String     = "skeleton", 
    meshFileFormat::String = "ISM-V2", 
    polynomialOrder::Int   = 5)

    setFileNames!(proj)
    setPlotFileFormat!(proj,plotFormat)
    setMeshFileFormat!(proj,meshFileFormat)
    setPolynomialOrder!(proj,polynomialOrder)

    rpDict = getDictInControlDictNamed(proj,"RUN_PARAMETERS")
    registerWithUndoManager(proj,removeRunParameters!, (nothing,), "Add Run Parameters")

    return rpDict
end
"""
    removeRunParameters!(proj::Project)

Remove the run parameters block from the project.
"""
function removeRunParameters!(proj::Project)
    cDict = getControlDict(proj)
    if haskey(cDict,"RUN_PARAMETERS")
        delete!(cDict,"RUN_PARAMETERS")
    end
end

"""
    setName(proj::Project,name::String)

The `name` of the project is the filename to be used by the mesh, plot, and 
stats files. It is also the name of the control file the tool will produce.
"""
function setName!(proj::Project,name::String)

    oldName = proj.name
    registerWithUndoManager(proj,setName!,(oldName,),"Set Project Name")
    proj.name = name
    setFileNames!(proj)
end
"""
    getName(proj::Project)

Returns the filename to be used by the mesh, plot, control, and 
stats files.
"""
function getName(proj::Project)
    return proj.name
end 
"""
setFolder(proj::Project,folder::String)

Set the path to the directory where the mesh, plot, control, and stats files
will be written 
"""
function setFolder(proj::Project,folder::String)
    oldPath = proj.path
    registerWithUndoManager(proj,setFolder,(oldPath,),"Set Project Folder")
    proj.path = folder
end
"""
    path(proj::Project)

Returns the directory where the project files will be written
"""
function getfolder(proj::Project)
    return proj.path
end 
"""
    setPolynomialOrder(proj::Project, p::Int)

Set the polynomial order for boundary curves in the mesh file to `p`.
"""
function setPolynomialOrder!(proj::Project, p::Int)
    key = "polynomial order"
    rpDict = getDictInControlDictNamed(proj,"RUN_PARAMETERS")
    if haskey(rpDict,key)
        oldP   = parse(Int,rpDict[key])
        registerWithUndoManager(proj,setPolynomialOrder!,(oldP,),"Set Order")
    end
    rpDict["polynomial order"] = string(p)
end
"""
    getPolynomialOrder(proj::Project)

Returns the polynomial order for boundary curves in the mesh file.
"""
function getPolynomialOrder(proj::Project)
    rpDict = getDictInControlDictNamed(proj,"RUN_PARAMETERS")
    return rpDict["polynomial order"]
end
"""
    setMeshFileFormat(proj::Project, meshFileFormat::String)

Set the file format for the mesh file. Acceptable choices
are "ISM" and "ISM-V2".
"""
function setMeshFileFormat!(proj::Project, meshFileFormat::String)
    if !in(meshFileFormat,meshFileFormats)
        println("Acceptable file formats are ISM and ISM-V2. Try again.")
        return
    end
    key = "mesh file format"
    rpDict = getDictInControlDictNamed(proj,"RUN_PARAMETERS")
    if haskey(rpDict,key)
        oldFormat   = rpDict[key]
        registerWithUndoManager(proj,setMeshFileFormat!,(oldFormat,),"Set Mesh Format")
    end
    rpDict[key] = meshFileFormat
end
"""
    getMeshFileFormat(proj::Project)

Returns the format in which the mesh will be written.
"""
function getMeshFileFormat(proj::Project)
    rpDict = getDictInControlDictNamed(proj,"RUN_PARAMETERS")
    return rpDict["mesh file format"]
end
"""
    setPlotFileFormat(proj::Project, plotFileFormat::String)

Set the file format for the plot file. Acceptable choices
are "sem", which includes interior nodes and boundary nodes and "skeleton", which includes
only the corner nodes.
"""
function setPlotFileFormat!(proj::Project, plotFileFormat::String)
    rpDict = getDictInControlDictNamed(proj,"RUN_PARAMETERS")
    key = "plot file format"
    if haskey(rpDict,key)
        oldFormat   = rpDict[key]
        registerWithUndoManager(proj,setPlotFileFormat!,(oldFormat,),"Set Plot Format")
    end
    rpDict[key] = plotFileFormat
end
"""
    getPlotFileFormat(proj::Project)

Returns the plot file format.
"""
function getPlotFileFormat(proj::Project)
    rpDict = getDictInControlDictNamed(proj,"RUN_PARAMETERS")
    return rpDict["plot file format"]
end

function setFileNames!(proj::Project)
    rpDict = getDictInControlDictNamed(proj,"RUN_PARAMETERS")
    rpDict["mesh file name"]   = joinpath(proj.projectDirectory, proj.name *".mesh")
    rpDict["plot file name"]   = joinpath(proj.projectDirectory, proj.name *".tec")
    rpDict["stats file name"]  = joinpath(proj.projectDirectory, proj.name *".txt")
 end

 function getMeshFileName(proj::Project)
    rpDict = getDictInControlDictNamed(proj,"RUN_PARAMETERS")
    return rpDict["mesh file name"]
 end
