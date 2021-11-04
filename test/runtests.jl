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
    control_file = joinpath(HOHQMesh.examples_dir(), "ABAQUS_IceCreamCone.control")
    generate_mesh(control_file)
    parse_mesh = abaqus_read_mesh(joinpath(outdir, "ABAQUS_IceCreamCone.inp"))
    # set some reference values for comparison. These are the corner IDs for element 114
    ref_IDs = [140, 141, 154, 153]
    @test sum(parse_mesh["elements"][114] - ref_IDs) == 0
  end

end # testset "HOHQMesh.jl"

# Clean up afterwards: delete HOHQMesh output directory
@test_nowarn rm(outdir, recursive=true)