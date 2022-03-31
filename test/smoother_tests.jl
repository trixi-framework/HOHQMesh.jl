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
@testset "Smoother Tests" begin
#
#   Create, save, and read
#
    projectName = "TestProject"
    projectPath = "out"

    p = newProject(projectName, projectPath)

    saveProject(p)
    q = openProject("TestProject.control",projectPath)
    setSmoothingIterations!(q,25)

    @test getSmoothingIterations(q) == 25
    @test getSmoothingStatus(q)     == "ON"
    @test getSmoothingType(q)       == "LinearAndCrossbarSpring"

    setSmoothingStatus!(q,"OFF")
    @test getSmoothingStatus(q) == "OFF"
    setSmoothingStatus!(q,"UNKNOWN")
    @test getSmoothingStatus(q) == "OFF"
    setSmoothingType!(q,"LinearSpring")
    @test getSmoothingType(q) == "LinearSpring"

    cDict = getControlDict(q)
    @test haskey(cDict,"SPRING_SMOOTHER") == true
    removeSpringSmoother!(q)
    cDict = getControlDict(q)
    @test haskey(cDict,"SPRING_SMOOTHER") == false

end
