using Test
include("../HQMTool.jl")
#
# Smoother Tests tests the "SmootherAPI.jl" functions
#
@testset "Smoother Tests" begin
#
#   Create, save, and read
#
    projectName = "TestProject"
    projectPath = "./Test/TestData"

    p = newProject(projectName, projectPath)

    saveProject(p)
    q = openProject("TestProject.Control",projectPath)
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
