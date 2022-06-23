module TestSmoother
#=
    Smoother Tests tests the "SmootherAPI.jl" functions

Functions: @ = tested
    @   addSpringSmoother!(status::String, type::String, nIterations::Int)
    @   setSmoothingStatus!(proj::Project, status::String)
    @   getSmoothingStatus(proj::Project)
    @   setSmoothingType!(proj::Project, type::String)
    @   getSmoothingType(proj::Project)
    @   setSmoothingIterations!(proj::Project, iterations::Int)
    @   getSmoothingIterations(proj::Project)
    @   removeSpringSmoother!(proj::Project)
=#
using HOHQMesh
using Test

@testset "Smoother Tests" begin
#
#   Create, save, and read
#
    projectName = "TestProject"
    projectPath = "out"

    p = newProject(projectName, projectPath)

    saveProject(p)
    q = openProject( projectName*".control", projectPath )

    # Trigger error statements by setting incorrect values in the smoother options
    @test_logs (:warn, "Acceptable smoother status are: `ON` or `OFF`. Try again.") addSpringSmoother!(p, "PAUSE", "LinearSpring", 50)
    @test_logs (:warn, "Acceptable smoothers are: `LinearAndCrossbarSpring` or `LinearSpring`. Try again.") addSpringSmoother!(p, "ON"   , "MagicSprings", 50)

    setSmoothingIterations!(q, 25)

    @test getSmoothingIterations(q) == 25
    @test getSmoothingStatus(q)     == "ON"
    @test getSmoothingType(q)       == "LinearAndCrossbarSpring"

    setSmoothingStatus!(q,"OFF")
    @test getSmoothingStatus(q) == "OFF"

    # Trigger error statement by setting an invalid spring status
    @test_logs (:warn, "Acceptable smoother status is either: `ON` or `OFF`. Try again.") setSmoothingStatus!(q,"UNKNOWN")
    @test getSmoothingStatus(q) == "OFF"

    setSmoothingType!(q,"LinearSpring")
    @test getSmoothingType(q) == "LinearSpring"

    # Trigger error statement by setting an invalid spring type
    @test_logs (:warn, "Acceptable smoothers are: `LinearAndCrossbarSpring` or `LinearSpring`. Try again.") setSmoothingType!(q,"TorsionalSpring")
    @test getSmoothingType(q) == "LinearSpring"

    cDict = HOHQMesh.getControlDict(q)
    @test haskey(cDict,"SPRING_SMOOTHER") == true
    removeSpringSmoother!(q)
    cDict = HOHQMesh.getControlDict(q)
    @test haskey(cDict,"SPRING_SMOOTHER") == false

end

end # module