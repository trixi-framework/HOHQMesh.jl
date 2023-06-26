using HOHQMesh
using Test
using AbaqusReader

# Start with a clean environment: remove HOHQMesh output directory if it exists
outdir = "out"
isdir(outdir) && rm(outdir, recursive=true)

@testset "HOHQMesh.jl" begin

  @testset "examples_dir()" begin
    @test occursin("examples", HOHQMesh.examples_dir())
  end

  @testset "generate_mesh()" begin
    control_file = joinpath(HOHQMesh.examples_dir(), "GingerbreadMan.control")
    @test generate_mesh(control_file) isa String
  end

  @testset "generate_mesh(; verbose=true)" begin
    control_file = joinpath(HOHQMesh.examples_dir(), "GingerbreadMan.control")
    @test generate_mesh(control_file, verbose=true) isa String
  end

  @testset "generate_mesh() in 2D with ABAQUS output" begin
    control_file = joinpath(HOHQMesh.examples_dir(), "IceCreamCone_Abaqus.control")
    generate_mesh(control_file)
    parse_mesh = abaqus_read_mesh(joinpath(outdir, "IceCreamCone_Abaqus.inp"))
    # set some reference values for comparison. These are the corner IDs for element 114
    reference_ids = [140, 141, 154, 153]
    @test parse_mesh["elements"][114] == reference_ids
  end

  @testset "generate_mesh() in 3D with ABAQUS output" begin
    control_file = joinpath(HOHQMesh.examples_dir(), "HalfCircle3DRot.control")
    generate_mesh(control_file)
    parse_mesh = abaqus_read_mesh(joinpath(outdir, "HalfCircle3DRot.inp"))
    # set some reference values for comparison. These are the corner IDs for element 246
    reference_ids = [297, 321, 322, 302, 363, 387, 388, 368]
    @test parse_mesh["elements"][246] == reference_ids
  end

  @testset "generate_mesh() with invalid format" begin
    # Create temporary control file option that is invalid
    mktemp() do path, io
      write(io, "mesh file format = ABBAKISS")
      flush(io)
      @test_throws ErrorException generate_mesh(path)
    end
  end

end # testset "HOHQMesh.jl"

# Unit tests for the interactive mesh functionality

# Background grid test routines
include("test_background_grid.jl")

# Curve test routines
include("test_curve.jl")

# Model test routines
include("test_model.jl")

# Interactive mesh project test routines
include("test_interactive_project.jl")

# Interactive mesh scripts available in examples folder
include("test_examples.jl")

# Interactive mesh project + visualization test routines
include("test_project_with_viz.jl")

# Refinement test routines
include("test_refinement.jl")

# Run parameters test routines
include("test_run_parameters.jl")

# Smoother test routines
include("test_smoother.jl")

# Visualization test routines
include("test_visualization.jl")

# Clean up afterwards: delete HOHQMesh output directory
@test_nowarn rm(outdir, recursive=true)