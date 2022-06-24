module TestRefinement
#=
    Project Tests tests the "RefinementRegions.jl" functions
Functions: @ = tested
    @   newRefinementCenter
    @   addRefinementRegion!
    addRefinementRegionPoints!
    refinementRegionPoints
    @   getRefinementRegionCenter
    @   removeRefinementRegion!
    @   insertRefinementRegion!
    @   newRefinementLine
    @   getRefinementRegion (1)
    @   getAllRefinementRegions
    @   getRefinementRegion (2)
    @   setRefinementType!
    @   getRefinementType
    @   setRefinementName!
    @   getRefinementName
    @   setRefinementLocation!
    @   getRefinementLocation
    @   setRefinementGridSize!
    @   getRefinementGridSize
    @   setRefinementWidth!
    @   getRefinementWidth
    @   setRefinementStart!
    @   getRefinementStart
    @   setRefinementEnd!
    @   getRefinementEnd
=#
using HOHQMesh
using Test

@testset "Refinement Tests" begin

    projectName = "TestProject"
    projectPath = "out"

    p = newProject(projectName, projectPath)
#
#   Creating and changing refinement regions...
#
    x0 = [1.0,2.0,0.0]
    h  = 0.25
    w  = 0.5
#
# ...Center
#
    cent1 = newRefinementCenter("Center1","smooth",x0,h,w)
    addRefinementRegion!(p,cent1)
    @test length(p.refinementRegionNames) == 1
#
#   Refinement type
#
    @test getRefinementType(cent1)     == "smooth"
    setRefinementType!(cent1,"sharp")
    @test getRefinementType(cent1)     == "sharp"
    undo()
    @test getRefinementType(cent1)     == "smooth"
    redo()
    @test getRefinementType(cent1)     == "sharp"
#
#   Refinement name
#
    @test getRefinementName(cent1)     == "Center1"
    setRefinementName!(cent1,"Second")
    @test getRefinementName(cent1)     == "Second"
    undo()
    @test getRefinementName(cent1)     == "Center1"
    redo()
    @test getRefinementName(cent1)     == "Second"
    undo()
    @test getRefinementName(cent1)     == "Center1"
#
#   Refinement center location
#
    @test getRefinementLocation(cent1) == x0
    @test getRefinementRegionCenter(cent1) == [1.0,2.0]
    setRefinementLocation!(cent1,[0.,0.,0.])
    @test getRefinementLocation(cent1) == [0.,0.,0.]
    undo()
    @test getRefinementLocation(cent1) == x0
    redo()
    @test getRefinementLocation(cent1) == [0.,0.,0.]
#
#   Refinement width
#
    @test getRefinementWidth(cent1)    == w
    setRefinementWidth!(cent1,1.0)
    @test getRefinementWidth(cent1)    == 1.0
    undo()
    @test getRefinementWidth(cent1)    == w
    redo()
    @test getRefinementWidth(cent1)    == 1.0
#
#   Refinement grid size
#
    @test getRefinementGridSize(cent1) == h
    setRefinementGridSize!(cent1,0.5)
    @test getRefinementGridSize(cent1) == 0.5
    undo()
    @test getRefinementGridSize(cent1) == h
    redo()
    @test getRefinementGridSize(cent1) == 0.5
#
#... Line
#
    line1 = newRefinementLine("Line1","smooth",[1.0,0.5,0.0],[1.5,2.0,0.0],h,w)
    addRefinementRegion!(p,line1)
    @test length(p.refinementRegionNames) == 2
    #the following have been tested above
    @test getRefinementType(line1)     == "smooth"
    @test getRefinementName(line1)     == "Line1"
    @test getRefinementWidth(line1)    == w
    @test getRefinementGridSize(line1) == h
#
#   Refinement line start
#
    @test isapprox(getRefinementStart(line1),[1.0,0.5,0.0])
    setRefinementStart!(line1,[0.0,0.0,0.0])
    @test getRefinementStart(line1) == [0.0,0.0,0.0]
    undo()
    @test isapprox(getRefinementStart(line1),[1.0,0.5,0.0])
    redo()
    @test getRefinementStart(line1) == [0.0,0.0,0.0]
#
#   Refinement Line End
#
    @test isapprox(getRefinementEnd(line1),[1.5,2.0,0.0])
    setRefinementEnd!(line1,[0.0,0.0,0.0])
    @test getRefinementEnd(line1) == [0.0,0.0,0.0]
    undo()
    @test isapprox(getRefinementEnd(line1),[1.5,2.0,0.0])
    redo()
    @test getRefinementEnd(line1) == [0.0,0.0,0.0]
#
#   Project functions
#
    lst = getAllRefinementRegions(p)
    @test length(lst) == 2

    (i,r) = getRefinementRegion(p,"Line1")
    @test i == 2
    @test getRefinementName(r) == "Line1"

    s = getRefinementRegion(p,1)
    @test getRefinementName(s) == "Center1"

    # Query for a refinement region that does not exist. Throws an error.
    @test_throws ErrorException (i,r) = getRefinementRegion(p, "Line100")

    # Test that an error is thrown if one requests a refinement region with
    # with an index larger than the number of regions present in the project
    @test_throws ErrorException getRefinementRegion(p, 3)

    c2 = newRefinementCenter("middle","smooth",[2.0,3.0,4.0],0.6,3.0)
    # Attempt to set an refinement type. Simply throws a warning to "Try again"
    @test_logs (:warn, "Acceptable refinement types are `smooth` and `sharp`. Try again.") setRefinementType!(c2, "fancy")

    insertRefinementRegion!(p,c2,2)
    lst = getAllRefinementRegions(p)
    @test length(lst) == 3

    removeRefinementRegion!(p,"middle")
    lst = getAllRefinementRegions(p)
    @test length(lst) == 2
    names = ["Center1", "Line1"]

    for (i,d) in enumerate(lst)
        @test getRefinementName(d) == names[i]
    end

end

end # module