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

  @testset "generate_mesh() with ABAQUS output" begin
    control_file = joinpath(HOHQMesh.examples_dir(), "IceCreamCone_Abaqus.control")
    generate_mesh(control_file)
    parse_mesh = abaqus_read_mesh(joinpath(outdir, "IceCreamCone_Abaqus.inp"))
    # set some reference values for comparison. These are the corner IDs for element 114
    reference_ids = [140, 141, 154, 153]
    @test parse_mesh["elements"][114] == reference_ids
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

#@testset "HQMTool features" begin

  # Background grid test routines
  include("background_grid_tests.jl")

  # Curve test routines
  include("curve_tests.jl")

  # Model test routines
  include("model_tests.jl")

  # Project test routines
  include("project_tests.jl")

  # Refinement test routines
  include("refinement_tests.jl")

  # Run parameters test routines
  include("run_parameters_tests.jl")

  # Smoother test routines
  include("smoother_tests.jl")

#end # testset "HQMTool features"

# Clean up afterwards: delete HOHQMesh output directory
@test_nowarn rm(outdir, recursive=true)