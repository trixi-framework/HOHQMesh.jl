module TestVisualization
#=
   Visualization tests for "Viz/VizProject.jl" functions

Functions: @ = tested

    @   plotProject!
    @   updatePlot!
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

    # First inner boundary
    circ2 = new("inner1", [0.0, 0.0, 0.0], 1.0, 0.0, 360.0, "degrees")
    add!(p, circ2, "inner1")

    # To mesh, a background grid is needed
    addBackgroundGrid!(p, [0.6, 0.6, 0.0])

    # Set file format to ISM and corresponding output file names
    setMeshFileFormat!(p, "ISM")
    meshFileFormat = getMeshFileFormat(p)
    setFileNames!(p, meshFileFormat)

    # Show initial the model and grid
    @test_nowarn plotProject!(p, HOHQMesh.MODEL + HOHQMesh.GRID)

    # Add another inner boundary
    circ3 = new("inner2", [2.0, -1.25, 0.0], 0.5, 0.0, 360.0, "degrees")
    add!(p, circ3, "inner2")

    # Set file format to ISM-V2 (to exericise plotting routine)
    setMeshFileFormat!(p, "ISM-V2")
    meshFileFormat = getMeshFileFormat(p)
    setFileNames!(p, meshFileFormat)

    @test_nowarn updatePlot!(p)

    # Add a final inner boundary
    circ4 = new("inner3", [-2.0, -0.75, 0.0], 0.3, 0.0, 360.0, "degrees")
    add!(p, circ4, "inner3")

    # Set file format to ABAQUS (to exericise plotting routine)
    setMeshFileFormat!(p, "ABAQUS")
    meshFileFormat = getMeshFileFormat(p)
    setFileNames!(p, meshFileFormat)

    @test_nowarn updatePlot!(p, HOHQMesh.MODEL + HOHQMesh.GRID)

end

end #module