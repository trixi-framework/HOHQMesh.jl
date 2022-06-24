module TestInteractiveExamples

using HOHQMesh
using Test

# We use CairoMakie to avoid some CI-related issues with GLMakie. CairoMakie can be used
# as a testing backend for interactive mesh tool's Makie-based visualization.
#using CairoMakie

@testset "Interactive Examples Tests" begin

    test_file = joinpath(HOHQMesh.examples_dir(), "interactive_from_control_file.jl")
    include(test_file)
    @test p.name == "AllFeatures"

    test_file = joinpath(HOHQMesh.examples_dir(), "interactive_outer_boundary.jl")
    include(test_file)
    @test p.name == "IceCreamCone"

    test_file = joinpath(HOHQMesh.examples_dir(), "interactive_outer_boundary_generic.jl")
    include(test_file)
    N = getPolynomialOrder(p)
    # Test against the default polynomial order of 5 that gets reset in this include
    @test N == 5

    test_file = joinpath(HOHQMesh.examples_dir(), "interactive_outer_box_two_circles.jl")
    include(test_file)
    format = getMeshFileFormat(p)
    # Test against the mesh file format type for this example
    @test format == "ABAQUS"

    test_file = joinpath(HOHQMesh.examples_dir(), "interactive_spline_curves.jl")
    include(test_file)
    spline = getCurve(p, "big_spline", "inner1")
    # Test against the number of spline knots from the testing file
    @test spline["nKnots"] == "77"

end

end #module