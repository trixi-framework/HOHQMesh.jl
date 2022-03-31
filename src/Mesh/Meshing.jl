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

function generate_mesh(proj::Project)
#
#   Check to be sure background grid has been created (everything else is defaults)
#
    controlDict = getControlDict(proj)
    if !haskey(controlDict,"BACKGROUND_GRID")
        println("A background grid is needed before meshing. Add one and try again.")
        return nothing
    end
    path           = mkpath(proj.projectDirectory)
    saveProject(proj)
    fileName       = joinpath(proj.projectDirectory,proj.name)*".control"
    mesherOutput   = generate_mesh(fileName, output_directory = proj.projectDirectory)
    println(mesherOutput)
    postNotificationWithName(proj,"MESH_WAS_GENERATED_NOTIFICATION",(nothing,))
    return nothing
end

function remove_mesh!(proj::Project)
    meshFile = getMeshFileName(proj)
    rm(meshFile)
    proj.xMesh = Float64[]
    proj.yMesh = Float64[]
    postNotificationWithName(proj,"MESH_WAS_DELETED_NOTIFICATION",(nothing,))
end
