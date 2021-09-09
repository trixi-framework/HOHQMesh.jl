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

function getMeshFromMeshFile(meshFile::AbstractString)

    open(meshFile,"r") do f
        line = strip(readline(f)) #Header Should be ISM-V2
        if line != "ISM-V2"
            error("Mesh file must be ISM-V2")
            return nothing
        end
        line   = readline(f) # Numbers of nodes, edges ...
        values = split(line)

        nNodes = parse(Int,values[1])
        nEdges = parse(Int,values[2])
#
#       Read the nodes
#
        nodes = zeros(Float64,nNodes,2)
        for i = 1:nNodes 
            values = split(readline(f))
            for j = 1:2
                nodes[i,j] = parse(Float64,values[j])
            end
        end
#
#       Read the edges and construct the lines array
#
        xMesh = zeros(Float64,3*nEdges)
        yMesh = zeros(Float64,3*nEdges)

        for i = 1:3:3*nEdges

            values = split(readline(f))
            n      = parse(Int,values[1])
            m      = parse(Int,values[2])

            xMesh[i]   = nodes[n,1]
            xMesh[i+1] = nodes[m,1]
            xMesh[i+2] = NaN

            yMesh[i]   = nodes[n,2]
            yMesh[i+1] = nodes[m,2]
            yMesh[i+2] = NaN

        end 
        return xMesh, yMesh
    end 

end

function plotMesh(plt, xMesh::Array{Float64}, yMesh::Array{Float64})
    lines!(plt[1,1], xMesh,yMesh)
end
