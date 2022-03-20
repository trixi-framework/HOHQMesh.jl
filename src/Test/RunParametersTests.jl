using Test
include("../HQMTool.jl")
#
# Run Parameters Tests tests the "BackgroundGrid.jl" functions
#
@testset "Run Parameters Tests" begin

    projectName = "TestProject"
    projectPath = "./Test/TestData"
    newName     = "RPTestsName"

    p = newProject(projectName, projectPath)

    @test getName(p)            == projectName
    setName!(p,newName)
    @test getName(p)            == newName
    setFileNames!(p)
    @test getMeshFileName(p) == "./Test/TestData/RPTestsName.mesh"
    @test getPlotFileName(p) == "./Test/TestData/RPTestsName.tec"
    @test getStatsFileName(p) == "./Test/TestData/RPTestsName.txt"

    @test getPolynomialOrder(p) == 5
    setPolynomialOrder!(p,6)
    @test getPolynomialOrder(p) == 6

    @test getMeshFileFormat(p) == "ISM-V2"
    setMeshFileFormat!(p,"ISM")
    @test getMeshFileFormat(p) == "ISM"
    setMeshFileFormat!(p,"BLORP")
    @test getMeshFileFormat(p) == "ISM"

    @test getPlotFileFormat(p) == "skeleton"
    setPlotFileFormat!(p,"sem") 
    @test getPlotFileFormat(p) == "sem"
    setPlotFileFormat!(p,"BLORP") 
    @test getPlotFileFormat(p) == "sem"

    removeRunParameters!(p)
    cDict = getControlDict(p)
    @test haskey(cDict,"RUN_PARAMETERS") == false

end
