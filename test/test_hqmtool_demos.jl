module TestDemos
#=
    Tests for the available demos

Functions: @ = tested
    @   hqmtool_all_features_demo(folder::String)
    @   hqmtool_ice_cream_cone_verbose_demo(folder::String)
    @   hqmtool_ice_cream_cone_demo(folder::String)
=#
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