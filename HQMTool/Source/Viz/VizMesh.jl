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

function getMeshFromMeshFile(meshFile::AbstractString, meshFileFormat::String)

    if meshFileFormat == "ISM-V2"
       open(meshFile,"r") do f
           line   = strip(readline(f)) # Header Should be ISM-V2
           line   = readline(f) # Numbers of nodes, edges ...
           values = split(line)

           nNodes = parse(Int,values[1])
           nEdges = parse(Int,values[2])
#
#          Read the nodes
#
           nodes = zeros(Float64,nNodes,2)
           for i = 1:nNodes
               values = split(readline(f))
               for j = 1:2
                   nodes[i,j] = parse(Float64,values[j])
               end
           end
#
#          Read the edges and construct the lines array
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
    elseif meshFileFormat == "ISM"
        open(meshFile,"r") do f
           # there is no header to read so directly read in
           line   = readline(f) # Numbers of corners, elements and boundary polynomial order
           values = split(line)

           nNodes = parse(Int,values[1])
           nElements = parse(Int,values[2])
           nBndy = parse(Int, values[3])
#
#          Read the nodes
#
           nodes = zeros(Float64,nNodes,2)
           for i = 1:nNodes
               values = split(readline(f))
               for j = 1:2
                   nodes[i,j] = parse(Float64, values[j])
               end
           end
#
#          Read the element ids (and skip all the boundary information)
#
           elements = zeros(Int64,nElements,4)
           temp = zeros(Int64, 4)
           for i = 1:nElements
               values = split(readline(f))
               for j = 1:4
                   elements[i,j] = parse(Int64, values[j])
               end
               values = split(readline(f))
               for j = 1:4
                   temp[j] = parse(Int64, values[j])
               end
               if sum(temp) == 0
                   # straight-sided edge so just skip the boundary labels
                   readline(f)
               else
                   # curved edge so skip the boundary polynomial and the labels
                   for i = 1:nBndy+1
                       readline(f)
                   end
                   readline(f)
               end
           end
           # convenience mapping for element index corners
           p = [[1 2 4 1]
                [2 3 3 4]]
           # Build the edges. This is only for plotting purposes so we might have some
           # repeated edges but we don't care
           edge_id = 0
           hash_table = Dict{Int, Int}()
           edges = Dict{Int, Any}()
           for j in 1:nElements
               for k in 1:4
                   id1 = elements[j , p[1,k]]
                   id2 = elements[j , p[2,k]]
                   key_val = id1 + id2
                   edge_id += 1
                   push!( hash_table , key_val => edge_id   )
                   push!( edges      , edge_id => [id1 id2] )
               end # k
           end # j
           # set the total number of edges
           nEdges = edge_id
           # use the edge information and pull the corner node physical values
           xMesh = zeros(Float64,3*nEdges)
           yMesh = zeros(Float64,3*nEdges)
           edge_id = 0
           for i = 1:3:3*nEdges
               edge_id += 1
               current_edge = edges[edge_id]
               n = current_edge[1]
               m = current_edge[2]

               xMesh[i]   = nodes[n,1]
               xMesh[i+1] = nodes[m,1]
               xMesh[i+2] = NaN

               yMesh[i]   = nodes[n,2]
               yMesh[i+1] = nodes[m,2]
               yMesh[i+2] = NaN
           end
           return xMesh, yMesh
        end
    elseif meshFileFormat == "ABAQUS"
        # read in the entire file
        file_lines = readlines(open(meshFile))
        # obtain the number of corners and elements in a circuitous way due to the ABAQUS format
        # number of corner nodes
        file_idx = findfirst(contains("*ELEMENT"), file_lines) - 1
        current_line = split(file_lines[file_idx], ",")
        nNodes = parse(Int, current_line[1])
        # number of elements
        file_idx = findfirst(contains("** ***** HOHQMesh boundary information ***** **"), file_lines) - 1
        current_line = split(file_lines[file_idx], ",")
        nElements = parse(Int, current_line[1])
#
#       Read in the nodes
#
        nodes = zeros(Float64,nNodes,2)
        file_idx = 4
        for i in 1:nNodes
            current_line = split(file_lines[file_idx], ",")
            for j = 2:3
                nodes[i, j-1] = parse(Float64, current_line[j])
            end
            file_idx += 1
        end # i
#
#          Read the element ids (and skip all the boundary information)
#
        elements = zeros(Int64,nElements,4)
        # eat the element header
        file_idx += 1
        for i = 1:nElements
            current_line = split(file_lines[file_idx], ",")
            for j = 2:5
                elements[i,j-1] = parse(Int64, current_line[j])
            end
            file_idx += 1
        end
        # convenience mapping for element index corners
        p = [[1 2 4 1]
            [2 3 3 4]]
        # Build the edges. This is only for plotting purposes so we might have some
        # repeated edges but we don't care
        edge_id = 0
        hash_table = Dict{Int, Int}()
        edges = Dict{Int, Any}()
        for j in 1:nElements
            for k in 1:4
                id1 = elements[j , p[1,k]]
                id2 = elements[j , p[2,k]]
                key_val = id1 + id2
                edge_id += 1
                push!( hash_table , key_val => edge_id   )
                push!( edges      , edge_id => [id1 id2] )
            end # k
        end # j
        # set the total number of edges
        nEdges = edge_id
        # use the edge information and pull the corner node physical values
        xMesh = zeros(Float64,3*nEdges)
        yMesh = zeros(Float64,3*nEdges)
        edge_id = 0
        for i = 1:3:3*nEdges
            edge_id += 1
            current_edge = edges[edge_id]
            n = current_edge[1]
            m = current_edge[2]

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