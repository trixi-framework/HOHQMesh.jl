
const MODEL = 1; const GRID = 2; const MESH = 4; const EMPTY = 0
const REFINEMENTS = 8; const ALL = 15


"""
    plotProject!(proj::Project, plotOptions::Int = 0)

Plot objects specified by the `plotOptions`. Construct the `plotOptions` by the sum
of what is to be drawn from the choices `MODEL`, `GRID`, `MESH`, `REFINEMENTS`.

Example: To plot the model and the grid, `plotOptions = MODEL + GRID`. To plot
just the mesh, `plotOptions = MESH`.

To plot everything, `plotOptions = MODEL + GRID + MESH + REFINEMENTS`

Contents are overlaid in the order: GRID, MESH, MODEL, REFINEMENTS
"""
function plotProject!(proj::Project, plotOptions::Int = 0)

    if isnothing(proj.plt)
        proj.plt = Figure(resolution = (1000, 1000))
    end
    plt = proj.plt
    ax = plt[1,1] = Axis(plt)

    plotTheModel       = ((plotOptions & MODEL) != 0)
    plotTheGrid        = ((plotOptions & GRID)  != 0)
    plotTheMesh        = ((plotOptions & MESH)  != 0)
    plotTheRefinements = ((plotOptions & REFINEMENTS)  != 0)
    proj.plotOptions   = plotOptions
#
#   Plot the grid
#
    if plotTheGrid && hasBackgroundGrid(proj)
        if proj.backgroundGridShouldUpdate # Lazy evaluation of the background grid
            proj.bounds = projectBounds(proj)
            proj.xGrid, proj.yGrid = projectGrid(proj)
            proj.backgroundGridShouldUpdate = false
        end
        nX = length(proj.xGrid)
        nY = length(proj.yGrid)
        z = zeros(Float64,nX,nY)
        wireframe!(plt[1,1],proj.xGrid,proj.yGrid,z)
    end
#
#   Plot the mesh
#
    if plotTheMesh
        # Lazy creation of mesh plotting arrays
        if proj.meshShouldUpdate || (isempty(proj.xMesh) && isempty(proj.yMesh))
            meshFileName = getMeshFileName(proj)
            if isfile(meshFileName)
                fileFormat = getMeshFileFormat(proj)
                proj.xMesh, proj.yMesh = getMeshFromMeshFile(meshFileName, fileFormat)
                plotMesh(plt, proj.xMesh, proj.yMesh)
            end
            proj.meshShouldUpdate = false
        else
            plotMesh(plt, proj.xMesh, proj.yMesh)
        end
    end
#
#   Plot the model
#
    if plotTheModel
#
#       Plot the outer innerBoundaries
#
        if !isempty(proj.outerBndryNames)
            plotNumbers = ["O."*string(i) for i in 1:length(proj.outerBndryNames)]
            plotNames = String[]
            for j = 1:length(proj.outerBndryNames)
                push!(plotNames, plotNumbers[j]*"| Outer."*proj.outerBndryNames[j] )
            end
            plotChain!(plt,proj.outerBndryPoints, plotNames, plotNumbers)
        end
#
#       Plot the inner innerBoundaries
#
        if !isempty(proj.innerBoundaryChainNames)
            for i = 1:length(proj.innerBoundaryChainNames)
                innerBndryPts = proj.innerBoundaryPoints[i]
                innerBndryNames = [ proj.innerBoundaryChainNames[i]*"."*s for s in proj.innerBoundaryNames[i]]
                plotNumbers = [string(i)*"."*string(j) for j in 1:length(innerBndryNames)]
                plotNames = String[]
                for j = 1:length(innerBndryNames)
                    push!(plotNames, plotNumbers[j]*"| "*innerBndryNames[j] )
                end
                plotChain!(plt,innerBndryPts, plotNames, plotNumbers)
            end
        end
        if !isempty(proj.outerBndryNames) || !isempty(proj.innerBoundaryChainNames)
            plt[1,2] = Legend(plt, ax, "Curves", framevisible = false, labelsize = 24, titlesize = 28)
        end

    end
#
#   Plot refinement regions
#
    if plotTheRefinements
        if !isempty(proj.refinementRegionNames)
            plotRefinement(plt,proj.refinementRegionPoints,
                           proj.refinementRegionNames,
                           proj.refinementRegionLoc)
        end
    end
#
#   Display the plot
#
    ax.aspect = DataAspect()
    display(plt)
end


"""
    updatePlot!(proj::Project)

This version replots the figure with the current options. Legacy.
"""
function updatePlot!(proj::Project)
    if !isnothing(proj.plt)
        proj.plt = Figure(resolution = (1000, 1000))
        plotOptions = proj.plotOptions
        plotProject!(proj, plotOptions)
    end
end


"""
    updatePlot!(proj::Project, plotOptions::Int)

Replot with the new plotOptions = combinations (sums) of

    GRID, MESH, MODEL, REFINEMENTS

Example: updatePlot!(p, MESH + MODEL)
"""
function updatePlot!(proj::Project, plotOptions::Int)
    if !isnothing(proj.plt)
        proj.plt = Figure(resolution = (1000, 1000))
        plotProject!(proj, plotOptions)
    end
end


function plotChain!(plt, chainPoints::Array{Any}, legendLabels::Array{String}, curveLabels::Array{String} )
    x = chainPoints[1]
    plotCurve(plt, x, legendLabels[1], curveLabels[1])

    s = length(legendLabels)

    for i = 2:s
        x = chainPoints[i]
        plotCurve(plt,x,legendLabels[i], curveLabels[i])
    end
end


function plotCurve(plt, points::Matrix{Float64}, legendLabel::String, curveLabel::String)
    lines!(plt[1,1],points[:,1],points[:,2], label = legendLabel, linewidth = 5 )
    s = size(points)
    np = div(s[1], 2, RoundNearest)
    if s[1] == 3
        np = 2
    end
    # dx = points[np+1,1] - points[np-1,1]
    # dy = points[np+1,2] - points[np-1,2]
    # theta = atan(dy,dx)
    # if(abs(dy) <= 0.0001) #Not pretty
    #     theta = 0.0
    # end
    pp = (points[np,1],points[np,2])
    text!(plt[1,1],curveLabel, fontsize = 28, position = pp, align = (:center,:center) )
end


function plotRefinement(plt, points::Array{Matrix{Float64}}, label::Array{String}, loc::Array{Array{Float64}})

    for (i,reg) in enumerate(points)
        lines!(plt[1,1],reg[:,1],reg[:,2], label = label[i], linewidth = 5, linestyle = :dot, color=:black )
        p = loc[i]
        pp = (p[1],p[2])
        text!(plt[1,1],label[i],position = pp, align = (:center,:center))
    end
end
