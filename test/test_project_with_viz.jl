module TestProjectAndVisualization

using HOHQMesh
using Test

# We use CairoMakie to avoid some CI-related issues with GLMakie. CairoMakie can be used
# as a testing backend for HQMTool's Makie-based visualization.
using CairoMakie

@testset "Project with Visualization Tests (from scratch)" begin

    projectName = "fromScratch"
    projectPath = "out"

    p_scratch = newProject(projectName, projectPath)

    # Bounding box uses box = [TOP, LEFT, BOTTOM, RIGHT]
    bounds = [9.0, -8.0, -8.0, 8.0]
    N = [16, 17, 1]

    # Lay the background grid and plot it
    addBackgroundGrid!(p_scratch, bounds,  N)
    plotProject!(p_scratch, HOHQMesh.GRID)

    # Build the outer boundary chain and plot piece-by-piece
    outer_line1 = newEndPointsLineCurve("outerline1", [0.0, -7.0, 0.0], [4.0, 3.0, 0.0])
    add!(p_scratch, outer_line1)
    # Update the endpoint to trigger update plot from `curveDidChange`
    setEndPoint!(outer_line1, [5.0, 3.0, 0.0])
    outer_arc = newCircularArcCurve("outerarc", [0.0, 3.0, 0.0], 5.0, 0.0, 180.0, "degrees")
    add!(p_scratch, outer_arc)
    outer_line2 = newEndPointsLineCurve("outerline2", [-5.0, 3.0, 0.0], [0.0, -7.0, 0.0])
    add!(p_scratch, outer_line2)

    # Check the computed background grid against expected values
    x_grid_control = [-8.0, -7.0, -6.0, -5.0, -4.0, -3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
    y_grid_control = [-8.0, -7.0, -6.0, -5.0, -4.0, -3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
    p_scratch.xGrid, p_scratch.yGrid = projectGrid(p_scratch)

    @test isapprox(p_scratch.xGrid, x_grid_control)
    @test isapprox(p_scratch.yGrid, y_grid_control)

    # Build the inner pill-shaped boundary chain and plot it piece-by-piece
    inner_line1 = newEndPointsLineCurve("innerLine1", [-1.0, 5.0, 0.0], [1.0, 3.0, 0.0])
    add!(p_scratch, inner_line1, "inner1")
    setStartPoint!(inner_line1, [1.0, 5.0, 0.0])
    inner_bottom_arc = newCircularArcCurve("innerBottomArc", [0.0, 3.0, 0.0], 1.0, 0.0, -180.0, "degrees")
    add!(p_scratch, inner_bottom_arc, "inner1")
    inner_line2 = newEndPointsLineCurve("innerLine2", [-1.0, 3.0, 0.0], [-1.0, 5.0, 0.0])
    add!(p_scratch, inner_line2, "inner1")
    inner_top_arc = newCircularArcCurve("innerTopArc", [0.0, 5.0, 0.0], 1.0, 180.0, 0.0, "degrees")
    add!(p_scratch, inner_top_arc, "inner1")

    # Add in a refinement center and adjust its width manually
    cent = newRefinementCenter("center1", "smooth", [0.0, -1.0, 0.0], 0.25, 1.0)
    add!(p_scratch, cent)
    setRefinementWidth!(cent, 0.5)

    # Generate the mesh (automatically updates the plot)
    @test_nowarn generate_mesh(p_scratch)

end

end #module