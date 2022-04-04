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
# as a testing backend for HQMTool's Makie-based visualization.
using CairoMakie

@testset "Visualization Tests" begin

    projectName = "CirclesInCircle"
    projectPath = "out"

    p = newProject(projectName, projectPath)
    # Outer boundary
    circ = new("outerCircle", [0.0, -1.0, 0.0], 4.0, 0.0, 360.0, "degrees")
    add!(p, circ)

    # Test getting the outer curve name
    dict = getCurve(p, "outerCircle")
    @test dict["TYPE"] == "CIRCULAR_ARC"

    # First inner boundary via a spline from a file
    spline1 = new("big_spline", joinpath(@__DIR__, "test_spline_curve_data.txt"))
    add!(p, spline1, "inner1")

    # Test extracting an inner boundary chain with the generic function
    tup = getInnerBoundary(p, "inner1")
    @test tup[2]["TYPE"] == "CHAIN"

    # Attempt to generate the mesh before the background grid is set. Throws an error.
    @test_nowarn generate_mesh(p)

    # To mesh, a background grid is needed
    addBackgroundGrid!(p, [0.6, 0.6, 0.0])

    # Set file format to ISM-V2 and corresponding output file names
    setMeshFileFormat!(p, "ISM-V2")
    meshFileFormat = getMeshFileFormat(p)
    setFileNames!(p, meshFileFormat)

    # Show initial the model and grid
    @test_nowarn plotProject!(p, HOHQMesh.MODEL + HOHQMesh.GRID)

    # Create the mesh which contains a plotting update for ISM
    @test_nowarn generate_mesh(p)

    # Destroy the mesh and reset the background grid
    @test_nowarn remove_mesh!(p)
    addBackgroundGrid!(p, [0.6,0.6,0.0])

    # Add another inner boundary via a spline with given data points
    data = [ [0.0  1.75 -1.0 0.0]
             [0.25 2.1  -0.5 0.0]
             [0.5  2.7  -1.0 0.0]
             [0.75 0.6  -2.0 0.0]
             [1.0  1.75 -1.0 0.0] ]
    spline2 = new("small_spline", 5, data)
    add!(p, spline2, "inner2")
    #
    # Test getting the inner curve and test
    #
    # Purposely get the names wrong to throw a warning
    dict = getCurve(p, "small_spline", "inner1")
    # Do it correctly this time
    dict = getCurve(p, "small_spline", "inner2")
    @test dict["TYPE"] == "SPLINE_CURVE"

    # Set file format to ISM (to exericise plotting routine)
    setMeshFileFormat!(p, "ISM")
    meshFileFormat = getMeshFileFormat(p)
    setFileNames!(p, meshFileFormat)

    @test_nowarn updatePlot!(p)

    # Create the mesh which contains a plotting update for ISM-V2
    @test_nowarn generate_mesh(p)

    # Destroy the mesh and reset the background grid
    @test_nowarn remove_mesh!(p)
    addBackgroundGrid!(p, [0.6,0.6,0.0])

    # Add a final inner boundary that contains multiple links in the chain
    edge1 = newEndPointsLineCurve("edge1", [-2.3, -1.0, 0.0], [-1.7, -1.0, 0.0])
    edge2 = newEndPointsLineCurve("edge2", [-1.7, -1.0, 0.0], [-2.0, -0.4, 0.0])
    edge3 = newEndPointsLineCurve("edge3", [-2.0, -0.4, 0.0], [-2.3, -1.0, 0.0])
    add!(p, edge1, "inner3")
    add!(p, edge2, "inner3")
    add!(p, edge3, "inner3")

    # Create a refinement center and add it with the generic method
    cent = newRefinementCenter("Center1", "smooth", [-1.25, -3.0, 0.0], 0.2, 1.0)
    add!(p, cent)

    # Set file format to ABAQUS (to exericise plotting routine)
    setMeshFileFormat!(p, "ABAQUS")
    meshFileFormat = getMeshFileFormat(p)
    setFileNames!(p, meshFileFormat)

    @test_nowarn updatePlot!(p, HOHQMesh.MODEL + HOHQMesh.GRID + HOHQMesh.REFINEMENTS)

    # Create the mesh which contains a plotting update for ABAQUS
    @test_nowarn generate_mesh(p)

    # Remove the outer boundary from the project
    remove!(p, "outerCircle")

    #
    # Remove the inner boundaries from the project
    #

    # Purposely do this wrong to throw a warning
    #  (1) Give a wrong "new" inner boundary name
    @test_throws ErrorException remove!(p, "big_spline", "wrongName")
    #  (2) Give the wrong inner boundary name that exists but does not contain "big_spline"
    @test_throws ErrorException remove!(p, "big_spline", "inner2")
    #  (3) Give the correct combination and remove the inner boundary
    remove!(p, "big_spline", "inner1")

    # Do the rest of the inner boudary removals correctly. To remove the inner boundary
    # with multiple chains we use a different method
    remove!(p, "small_spline", "inner2")
    removeInnerBoundary!(p, "inner3")

end

end #module