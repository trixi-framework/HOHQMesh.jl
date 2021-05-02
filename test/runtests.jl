using HOHQMesh
using Test

@testset "HOHQMesh.jl" begin

  @testset "examples_dir()" begin
    @test occursin("examples", HOHQMesh.examples_dir())
  end

end # testset "HOHQMesh.jl"
