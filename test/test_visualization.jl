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

    # First inner boundary via a spline from a file
    spline1 = new("inner1", joinpath(@__DIR__, "test_spline_curve_data.txt"))
    add!(p, spline1, "inner1")

    # Attempt to generate the mesh before the background grid is set. Throws an error.
    @test_nowarn generate_mesh(p)

    # To mesh, a background grid is needed
    addBackgroundGrid!(p, [0.6, 0.6, 0.0])

    # Set file format to ISM and corresponding output file names
    setMeshFileFormat!(p, "ISM")
    meshFileFormat = getMeshFileFormat(p)
    setFileNames!(p, meshFileFormat)

    # Show initial the model and grid
    @test_nowarn plotProject!(p, HOHQMesh.MODEL + HOHQMesh.GRID)

    # Create the mesh which contains a plotting update for ISM
    @test_nowarn generate_mesh(p)

    # Destroy the mesh and reset the background grid
    @test_nowarn remove_mesh!(p)
    addBackgroundGrid!(p, [0.6,0.6,0.0])

    # Add another inner boundary
    circ3 = new("inner2", [2.0, -1.25, 0.0], 0.5, 0.0, 360.0, "degrees")
    add!(p, circ3, "inner2")

    # Set file format to ISM-V2 (to exericise plotting routine)
    setMeshFileFormat!(p, "ISM-V2")
    meshFileFormat = getMeshFileFormat(p)
    setFileNames!(p, meshFileFormat)

    @test_nowarn updatePlot!(p)

    # Create the mesh which contains a plotting update for ISM-V2
    @test_nowarn generate_mesh(p)

    # Destroy the mesh and reset the background grid
    @test_nowarn remove_mesh!(p)
    addBackgroundGrid!(p, [0.6,0.6,0.0])

    # Add a final inner boundary
    circ4 = new("inner3", [-2.0, -0.75, 0.0], 0.3, 0.0, 360.0, "degrees")
    add!(p, circ4, "inner3")

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

end

end #module