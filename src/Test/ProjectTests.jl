using Test
include("../HQMTool.jl")
#
# Project Tests tests the "Project.jl" functions
#
@testset "Project Tests" begin
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

    cDict = getControlDict(q)
    @test haskey(cDict,"SPRING_SMOOTHER") == true
    removeSpringSmoother!(q)
    cDict = getControlDict(q)
    @test haskey(cDict,"SPRING_SMOOTHER") == false



    # p = openProject("AllFeatures.control",projectPath)

    # @test hasBackgroundGrid(p) == true

end
