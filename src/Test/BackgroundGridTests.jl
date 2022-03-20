using Test
include("../HQMTool.jl")
#
# Background Grid Tests tests the "BackgroundGrid.jl" functions
#
@testset "Background Grid Tests" begin

    projectName = "TestProject"
    projectPath = "./Test/TestData"

    p = newProject(projectName, projectPath)

    @test hasBackgroundGrid(p) == false
    addBackgroundGrid!(p,[0.1,0.2,0.0])
    @test hasBackgroundGrid(p) == true
    bgs = getBackgroundGridSize(p)
    @test isapprox(bgs,[0.1,0.2,0.0])
    removeBackgroundGrid!(p)
    @test hasBackgroundGrid(p) == false
    
    addBackgroundGrid!(p,[-1.0,-1.0,0.0],[0.1,0.1,0.0], [10,10,0])
    @test hasBackgroundGrid(p) == true
    @test getBackgroundGridSteps(p) == [10,10,0]
    @test isapprox(getBackgroundGridSize(p),[0.1,0.1,0.0])
    @test isapprox(getBackgroundGridLowerLeft(p),[-1.0,-1.0,0.0])

    undo()
    @test hasBackgroundGrid(p) == false
    redo()
    @test hasBackgroundGrid(p) == true
    removeBackgroundGrid!(p)
    @test hasBackgroundGrid(p) == false

    addBackgroundGrid!(p, [10.0,-10.0,-5.0,5.0], [10,10,0])
    @test hasBackgroundGrid(p) == true
    @test getBackgroundGridSteps(p) == [10,10,0]
    @test isapprox(getBackgroundGridSize(p),[1.5,1.5,0.0])
    @test isapprox(getBackgroundGridLowerLeft(p),[-10.0,-5.0,0.0])
    removeBackgroundGrid!(p)
    @test hasBackgroundGrid(p) == false

end
