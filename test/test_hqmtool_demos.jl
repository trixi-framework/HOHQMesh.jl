module TestDemos
#=
    Tests for the available demos

Functions: @ = tested
    @   hqmtool_all_features_demo(folder::String)
    @   hqmtool_ice_cream_cone_verbose_demo(folder::String)
    @   hqmtool_ice_cream_cone_demo(folder::String)
=#

# TODO: Fix this. Not sure how to handle the "Press any key" nonsense.
#       Tests wont be very sophisticated, jsut a check that certain files are created
#
#  somthing like this    @test generate_mesh(control_file, verbose=true) isa String
#  or this     @test occursin("examples", HOHQMesh.examples_dir())
using HOHQMesh
using Test

# We use CairoMakie to avoid some CI-related issues with GLMakie. CairoMakie is needed
# because the demos call the visualization routines.
using CairoMakie

@testset "Demo Tests" begin

    projectPath = "out"

    @test_nowarn run_demo( projectPath, called_by_user=false )

    @test_nowarn ice_cream_cone_verbose_demo( projectPath, called_by_user=false )

    @test_nowarn ice_cream_cone_demo( projectPath, called_by_user=false )

end

end # module