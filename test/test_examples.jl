module TestInteractiveExamples

using HOHQMesh
using Test

# We use CairoMakie to avoid some CI-related issues with GLMakie. CairoMakie can be used
# as a testing backend for HQMTool's Makie-based visualization.
#using CairoMakie

@testset "Interactive Examples Tests" begin

    test_file = joinpath(examples_dir(), "interactive_from_control_file.jl")
    include(test_file)
    @test p.name == "AllFeatures"

    test_file = joinpath(examples_dir(), "interactive_outer_boundary.jl")
    include(test_file)
    @test p.name == "IceCreamCone"

end

end #module