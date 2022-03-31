#=
    Run Parameters Tests tests the "RunParameters.jl" functions

Functions: @ = tested
    @   addRunParameters!(proj::Project,
            plotFormat::String     = "skeleton",
            meshFileFormat::String = "ISM-V2",
            polynomialOrder::Int   = 5)
    @   removeRunParameters!(proj::Project)
    @   setName!(proj::Project,name::String)
    @   getName(proj::Project)
    @   setPolynomialOrder!(proj::Project, p::Int)
    @   getPolynomialOrder(proj::Project)
    @   setMeshFileFormat!(proj::Project, meshFileFormat::String)
    @   getMeshFileFormat(proj::Project)
    @   setPlotFileFormat!(proj::Project, plotFileFormat::String)
    @   getPlotFileFormat(proj::Project)
    @   setFileNames!(proj::Project)
    @   getMeshFileName(proj::Project)
    @   getPlotFileName(proj::Project)
    @   getStatsFileName(proj::Project)
=#
@testset "Run Parameters Tests" begin

    projectName = "TestProject"
    projectPath = "out"
    newName     = "RPTestsName"

    p = newProject(projectName, projectPath) # Auto sets up run parameters

    @test getName(p)          == projectName
    setName!(p,newName)
    @test getName(p)          == newName

    undo()
    @test getName(p)          == projectName
    redo()
    @test getName(p)          == newName

    setFileNames!(p, getMeshFileFormat(p))
    @test getMeshFileName(p)  == "out/RPTestsName.mesh"
    @test getPlotFileName(p)  == "out/RPTestsName.tec"
    @test getStatsFileName(p) == "out/RPTestsName.txt"

    @test getPolynomialOrder(p) == 5
    setPolynomialOrder!(p,6)
    @test getPolynomialOrder(p) == 6
    undo()
    @test getPolynomialOrder(p) == 5
    redo()
    @test getPolynomialOrder(p) == 6

    setMeshFileFormat!(p, "ABAQUS")
    @test getMeshFileFormat(p) == "ABAQUS"
    undo()

    # ISM-V2 is the default file format type
    @test getMeshFileFormat(p) == "ISM-V2"
    setMeshFileFormat!(p,"ISM")
    @test getMeshFileFormat(p) == "ISM"
    undo()
    @test getMeshFileFormat(p) == "ISM-V2"
    redo()
    @test getMeshFileFormat(p) == "ISM"

    setMeshFileFormat!(p,"BLORP")
    @test getMeshFileFormat(p) == "ISM"

    @test getPlotFileFormat(p) == "skeleton"
    setPlotFileFormat!(p,"sem")
    @test getPlotFileFormat(p) == "sem"
    undo()
    @test getPlotFileFormat(p) == "skeleton"
    redo()
    @test getPlotFileFormat(p) == "sem"

    setPlotFileFormat!(p,"BLORP")
    @test getPlotFileFormat(p) == "sem"

    removeRunParameters!(p)
    cDict = getControlDict(p)
    @test haskey(cDict,"RUN_PARAMETERS") == false

end
