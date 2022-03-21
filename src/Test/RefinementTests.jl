using Test
include("../HQMTool.jl")
#
# Project Tests tests the "Project.jl" functions
#
@testset "Project Tests" begin

    projectName = "TestProject"
    projectPath = "./Test/TestData"

    p = newProject(projectName, projectPath)
    disableNotifications()

    x0 = [1.0,2.0,0.0]
    h  = 0.25
    w  = 0.5

    cent1 = newRefinementCenter("Center1","smooth",x0,h,w)
    disableNotifications()

    @test getRefinementType(cent1)     == "smooth"
    setRefinementType!(cent1,"sharp")
    @test getRefinementType(cent1)     == "sharp"
    undo()
    @test getRefinementType(cent1)     == "smooth"
    redo()
    @test getRefinementType(cent1)     == "sharp"

    @test getRefinementName(cent1)     == "Center1"
    setRefinementName!(cent1,"Second")
    @test getRefinementName(cent1)     == "Second"
    undo()
    @test getRefinementName(cent1)     == "Center1"
    redo()
    @test getRefinementName(cent1)     == "Second"
    undo()
    @test getRefinementName(cent1)     == "Center1"

    @test getRefinementLocation(cent1) == x0
    @test getRefinementWidth(cent1)    == w
    @test getRefinementGridSize(cent1) == h

    setRefinementGridSize!(cent1,0.5)
    @test getRefinementGridSize(cent1) == 0.5
    undo()
    @test getRefinementGridSize(cent1) == h
    redo()
    @test getRefinementGridSize(cent1) == 0.5

    setRefinementLocation!(cent1,[0.0,0.0,0.0])
    @test getRefinementLocation(cent1) == [0.0,0.0,0.0]
    undo()
    @test getRefinementLocation(cent1) == x0
    redo()
    @test getRefinementLocation(cent1) == [0.0,0.0,0.0]

    line1 = newRefinementLine("Line1","smooth",[1.0,0.5,0.0],[1.5,2.0,0.0],h,w)
    disableNotifications()

    @test getRefinementType(line1)     == "smooth"
    @test getRefinementName(line1)     == "Line1"
    @test getRefinementWidth(line1)    == w
    @test getRefinementGridSize(line1) == h
    @test isapprox(getRefinementStart(line1),[1.0,0.5,0.0])
    @test isapprox(getRefinementEnd(line1),[1.5,2.0,0.0])
    
    setRefinementGridSize!(cent1,0.5)

    enableNotifications()
end
