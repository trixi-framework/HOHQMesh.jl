#=
    Project Tests tests the "Project.jl" functions

Functions: @ = tested

    @   openProject(fileName::String, folder::String)
    @   saveProject(proj::Project)
    @   newProject(name::String, folder::String)
    @   hasBackgroundGrid(proj::Project)
    @@  assemblePlotArrays(proj::Project)
    @   projectBounds(proj::Project)
    @   projectGrid(proj::Project)

    curveDidChange(proj::Project,crv::Dict{String,Any})
    modelDidChange(proj::Project, sender::Project)
    backgroundGridDidChange(proj::Project, sender::Project)
    refinementWasAdded(proj::Project, sender::Project)
    refinementDidChange(proj::Project, sender::Dict{String,Any})
    meshWasGenerated(proj::Project, sender::Project)
    meshWasDeleted(proj::Project, sender::Project)

=#
@testset "Project Tests" begin
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

    cDict = getControlDict(q)
    @test haskey(cDict,"SPRING_SMOOTHER") == true
    removeSpringSmoother!(q)
    cDict = getControlDict(q)
    @test haskey(cDict,"SPRING_SMOOTHER") == false

    control_file = joinpath(HOHQMesh.examples_dir(), "AllFeatures.control")
    p = openProject(control_file, projectPath)
    # p = openProject("AllFeatures.control",projectPath)

    @test hasBackgroundGrid(p) == true
    bounds = [25.28, -20.0, -5.0, 20.0]
    @test isapprox(p.bounds,bounds)
    refinementNames = ["center", "line"]
    @test p.refinementRegionNames == refinementNames
    @test isapprox(p.refinementRegionLoc[1],[9.0,-3.0])

    obNames = ["B1", "B2", "B3"]
    @test p.outerBndryNames == obNames

    xGrid = [-23.0, -20.0, -17.0, -14.0, -11.0, -8.0, -5.0, -2.0, 1.0, 4.0, 7.0,
            10.0, 13.0, 16.0, 19.0, 22.0]
    yGrid = [-8.0, -5.0, -2.0, 1.0, 4.0, 7.0, 10.0, 13.0, 16.0, 19.0, 22.0, 25.0, 28.0]
    p.xGrid, p.yGrid = projectGrid(p)
    @test isapprox(p.xGrid,xGrid)
    @test isapprox(p.yGrid,yGrid)
end
