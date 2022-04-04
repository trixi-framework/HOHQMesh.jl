module TestProjectAndVisualization

using HOHQMesh
using Test

# We use CairoMakie to avoid some CI-related issues with GLMakie. CairoMakie can be used
# as a testing backend for HQMTool's Makie-based visualization.
using CairoMakie

@testset "Project with Visualization Tests" begin

    projectName = "fromScratch"
    projectPath = "out"

    p = newProject(projectName, projectPath)

    # Bounding box uses box = [TOP, LEFT, BOTTOM, RIGHT]
    bounds = [9.0, -8.0, -8.0, 8.0]
    N = [16, 17, 1]

    # Lay the background grid and plot it
    addBackgroundGrid!(p, bounds,  N)
    plotProject!(p, HOHQMesh.GRID)

    # Build the outer boundary chain and plot piece-by-piece
    outer_line1 = newEndPointsLineCurve("outerline1", [0.0, -7.0, 0.0], [5.0, 3.0, 0.0])
    add!(p, outer_line1)
    outer_arc = newCircularArcCurve("outerarc", [0.0, 3.0, 0.0], 0.0, 0.0, 180.0, "degrees")
    add!(p, outer_arc) # fails because the radius is wrong
    setArcRadius!(outer_arc, 5.0)
    add!(p, outer_arc) # succeed with the proper radius
    outer_line2 = newEndPointsLineCurve("outerline2", [-5.0, 3.0, 0.0], [0.0, -7.0, 0.0])
    add!(p, outer_line2)

    # Check the computed background grid against expected values
    x_grid_control = [-8.0, -7.0, -6.0, -5.0, -4.0, -3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
    y_grid_control = [-8.0, -7.0, -6.0, -5.0, -4.0, -3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
    p.xGrid, p.yGrid = projectGrid(p)

    @test isapprox(p.xGrid, x_grid_control)
    @test isapprox(p.yGrid, y_grid_control)

    # Build the inner pill-shaped boundary chain and plot it piece-by-piece
    inner_line1 = newEndPointsLineCurve("innerLine1", [1.0, 5.0, 0.0], [1.0, 3.0, 0.0])
    add!(p, inner_line1, "inner1")
    inner_bottom_arc = newCircularArcCurve("innerBottomArc", [0.0, 3.0, 0.0], 1.0, 0.0, -180.0, "degrees")
    add!(p, inner_bottom_arc, "inner1")
    inner_line2 = newEndPointsLineCurve("innerLine2", [-1.0, 3.0, 0.0], [-1.0, 5.0, 0.0])
    add!(p, inner_line2, "inner1")
    inner_top_arc = newCircularArcCurve("innerTopArc", [0.0, 5.0, 0.0], 0.0, 180.0, 0.0, "degrees")
    add!(p, inner_top_arc, "inner1") # fails as the curves won't join
    setArcRadius!(inner_top_arc, 1.0)
    add!(p, inner_top_arc, "inner1") # succeed with the proper radius

    # Add in a refinement center and adjust its width manually
    cent = newRefinementCenter("center1", "smooth", [0.0, -1.0, 0.0], 0.25, 1.0)
    setRefinementWidth!(cent, 0.5)
    add!(p, cent)

    # Generate the mesh (automatically updates the plot)
    @test_nowarn generate_mesh(p)

end

end #module