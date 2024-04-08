module TestVisualization
#=
   Visualization tests for "Viz/VizProject.jl" functions and "Meshing.jl"

Functions: @ = tested

    @   plotProject!
    @   updatePlot!
    @   generate_mesh(p::project)
    @   remove_mesh!(p::project)
=#
using HOHQMesh
using Test

# We use CairoMakie to avoid some CI-related issues with GLMakie. CairoMakie can be used
# as a testing backend for interactive mesh tool's Makie-based visualization.
using CairoMakie

@testset "Visualization Tests" begin

    projectName = "CirclesInCircle"
    projectPath = "out"

    p_visu = newProject(projectName, projectPath)
    # Outer boundary
    circ = new("outerCircle", [0.0, -1.0, 0.0], 4.0, 0.0, 360.0, "degrees")
    add!(p_visu, circ)

    # Test getting the outer curve name
    dict = getCurve(p_visu, "outerCircle")
    @test dict["TYPE"] == "CIRCULAR_ARC"

    # First inner boundary via a spline from a file
    spline1 = new("big_spline", joinpath(@__DIR__, "test_spline_curve_data.txt"))
    add!(p_visu, spline1, "inner1")

    # Test extracting an inner boundary chain with the generic function
    tup = getInnerBoundary(p_visu, "inner1")
    @test tup[2]["TYPE"] == "CHAIN"

    # Attempt to generate the mesh before the background grid is set. Throws a warning.
    @test_logs (:warn, "A background grid is needed before meshing. Add one and try again.") generate_mesh(p_visu)

    # There is no background grid. Query the different styles of background grids
    # to test that errors are thrown correctly.
    @test_throws ErrorException getBackgroundGridSize(p_visu)
    @test_throws ErrorException getBackgroundGridLowerLeft(p_visu)
    @test_throws ErrorException getBackgroundGridSteps(p_visu)

    # To mesh, a background grid is needed
    addBackgroundGrid!(p_visu, [0.6, 0.6, 0.0])

    # Set file format to ISM-V2 and corresponding output file names
    setMeshFileFormat!(p_visu, "ISM-V2")
    meshFileFormat = getMeshFileFormat(p_visu)
    setFileNames!(p_visu, meshFileFormat)

    # Show initial the model and grid
    @test_nowarn plotProject!(p_visu, MODEL+GRID)

    # Create the mesh which contains a plotting update for ISM
    @test_nowarn generate_mesh(p_visu)

    # Destroy the mesh and reset the background grid
    @test_nowarn remove_mesh!(p_visu)

    # Add another inner boundary via a spline with given data points
    data = [ [0.0  1.75 -1.0 0.0]
             [0.25 2.1  -0.5 0.0]
             [0.5  2.7  -1.0 0.0]
             [0.75 0.6  -2.0 0.0]
             [1.0  1.75 -1.0 0.0] ]
    spline2 = new("small_spline", 5, data)
    add!(p_visu, spline2, "inner2")

    #
    # Test getting the inner curve
    #
    # Purposely get the names wrong to throw a warning
    @test_logs (:warn, "No curve small_spline in boundary inner1. Try again.") dict = getCurve(p_visu, "small_spline", "inner1")
    # Do it correctly this time
    dict = getCurve(p_visu, "small_spline", "inner2")
    @test dict["TYPE"] == "SPLINE_CURVE"

    # Set file format to ISM (to exericise plotting routine)
    setMeshFileFormat!(p_visu, "ISM")
    meshFileFormat = getMeshFileFormat(p_visu)
    setFileNames!(p_visu, meshFileFormat)

    @test_nowarn updatePlot!(p_visu)

    # Create the mesh which contains a plotting update for ISM-V2
    @test_nowarn generate_mesh(p_visu)

    # Destroy the mesh and reset the background grid
    @test_nowarn remove_mesh!(p_visu)

    # Add a final inner boundary that contains multiple links in the chain
    edge1 = newEndPointsLineCurve("edge1", [-2.3, -1.0, 0.0], [-1.7, -1.0, 0.0])
    edge2 = newEndPointsLineCurve("edge2", [-1.7, -1.0, 0.0], [-2.0, -0.4, 0.0])
    edge3 = newEndPointsLineCurve("edge3", [-2.0, -0.4, 0.0], [-2.3, -1.0, 0.0])
    add!(p_visu, edge1, "inner3")
    add!(p_visu, edge2, "inner3")
    add!(p_visu, edge3, "inner3")

    # Create a refinement center and add it with the generic method
    cent = newRefinementCenter("Center1", "smooth", [-1.25, -3.0, 0.0], 0.2, 1.0)
    add!(p_visu, cent)

    # Set file format to ABAQUS (to exericise plotting routine)
    setMeshFileFormat!(p_visu, "ABAQUS")
    meshFileFormat = getMeshFileFormat(p_visu)
    setFileNames!(p_visu, meshFileFormat)

    @test_nowarn updatePlot!(p_visu, MODEL+GRID+REFINEMENTS)

    # Create the mesh which contains a plotting update for ABAQUS
    @test_nowarn generate_mesh(p_visu)

    # Remove the outer boundary from the project
    remove!(p_visu, "outerCircle")

    #
    # Remove the inner boundaries from the project
    #

    # Purposely do this wrong to throw a warning
    #  (1) Give a wrong "new" inner boundary name
    @test_throws ErrorException remove!(p_visu, "big_spline", "wrongName")
    #  (2) Give the wrong inner boundary name that exists but does not contain "big_spline"
    @test_throws ErrorException remove!(p_visu, "big_spline", "inner2")
    #  (3) Give the correct combination and remove the inner boundary
    remove!(p_visu, "big_spline", "inner1")
    @test length(p_visu.innerBoundaryNames) == 2

    # Do the rest of the inner boundary removals correctly.
    remove!(p_visu, "small_spline", "inner2")
    @test length(p_visu.innerBoundaryNames) == 1
    undo()
    @test length(p_visu.innerBoundaryNames) == 2
    redo()

    # Remove a single part of the chain with multiple curves
    @test length(p_visu.innerBoundaryNames[1]) == 3
    remove!(p_visu, "edge2", "inner3")
    @test length(p_visu.innerBoundaryNames[1]) == 2
    undo()
    # To remove the inner boundary with multiple chains we use a different method.
    removeInnerBoundary!(p_visu, "inner3")
    undo()
    redo()

end

end #module