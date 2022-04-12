
function getMeshFromMeshFile(meshFile::AbstractString, meshFileFormat::AbstractString)

    if meshFileFormat == "ISM-V2"
       open(meshFile,"r") do f
           line   = strip(readline(f)) # Header Should be ISM-V2
           line   = readline(f) # Numbers of nodes, edges ...
           values = split(line)

           nNodes = parse(Int64, values[1])
           nEdges = parse(Int64, values[2])
#
#          Read the nodes
#
           nodes = zeros(Float64, nNodes, 2)
           for i = 1:nNodes
               values = split(readline(f))
               for j = 1:2
                   nodes[i,j] = parse(Float64, values[j])
               end
           end
#
#          Read the edges and construct the lines array
#
           xMesh = zeros(Float64, 3*nEdges)
           yMesh = zeros(Float64, 3*nEdges)

           for i = 1:3:3*nEdges

               values = split(readline(f))
               n      = parse(Int64,values[1])
               m      = parse(Int64,values[2])

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
        open(meshFile, "r") do f
           # There is no header
           line   = readline(f) # Numbers of corners, elements and boundary polynomial order
           values = split(line)

           nNodes = parse(Int64, values[1])
           nElements = parse(Int64, values[2])
           nBndy = parse(Int64, values[3])
#
#          Read the nodes
#
           nodes = zeros(Float64, nNodes, 2)
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
               else # sum(temp) > 0
                   # At least one curved edge, so skip any boundary polynomial(s) and the labels
                   for j = 1:sum(temp)
                       for i = 1:nBndy+1
                           readline(f)
                       end
                   end
                   readline(f)
               end
           end
           # convenience mapping for element index corners
           p = [[1 2 4 1]
                [2 3 3 4]]
           # Build the edges. This is only for plotting purposes so we might have some
           # repeated edges
           edge_id = 0
           edges = Dict{Int64, Any}()
           for j in 1:nElements
               for k in 1:4
                   id1 = elements[j , p[1,k]]
                   id2 = elements[j , p[2,k]]
                   edge_id += 1
                   push!(edges, edge_id => [id1 id2])
               end # k
           end # j
           # set the total number of edges
           nEdges = edge_id
           # use the edge information and pull the corner node physical values
           xMesh = zeros(Float64, 3*nEdges)
           yMesh = zeros(Float64, 3*nEdges)
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
        nNodes = parse(Int64, current_line[1])
        # number of elements
        file_idx = findfirst(contains("** ***** HOHQMesh boundary information ***** **"), file_lines) - 1
        current_line = split(file_lines[file_idx], ",")
        nElements = parse(Int64, current_line[1])
#
#       Read in the nodes
#
        nodes = zeros(Float64, nNodes, 2)
        file_idx = 4
        for i in 1:nNodes
            current_line = split(file_lines[file_idx], ",")
            for j = 2:3
                nodes[i, j-1] = parse(Float64, current_line[j])
            end
            file_idx += 1
        end # i
#
#       Read the element ids (and skip all the boundary information)
#
        elements = zeros(Int64, nElements, 4)
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
        # repeated edges
        edge_id = 0
        edges = Dict{Int64, Any}()
        for j in 1:nElements
            for k in 1:4
                id1 = elements[j , p[1,k]]
                id2 = elements[j , p[2,k]]
                edge_id += 1
                push!(edges, edge_id => [id1 id2])
            end # k
        end # j
        # set the total number of edges
        nEdges = edge_id
        # use the edge information and pull the corner node physical values
        xMesh = zeros(Float64, 3*nEdges)
        yMesh = zeros(Float64, 3*nEdges)
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
