module TestModel
#=
    Model Tests tests the "ModelAPI.jl" functions

Functions: @  = tested
           @@ = indirectly tested through other tests

    @   addCurveToOuterBoundary!(proj::Project, crv::Dict{String,Any})
    @@  removeOuterBoundaryCurveWithName!(proj::Project, name::String)
    @   getOuterBoundaryCurveWithName(proj::Project, name::String)
    @@  insertOuterBoundaryCurveAtIndex!(proj::Project, crv::Dict{String,Any}, indx::Int)
    @@  removeOuterBoundaryCurveAtIndex!(proj::Project, indx::Int)
    @@  addOuterBoundary!(proj::Project, outerBoundary::Dict{String,Any})
    @   removeOuterboundary!(proj::Project)
    @   getOuterBoundaryChainList(proj::Project)

    @@ addCurveToInnerBoundary!(proj::Project, crv::Dict{String,Any}, boundaryName::String)
    @   removeInnerBoundaryCurve!(proj::Project, name::String, chainName::String)
    @@  insertInnerBoundaryCurveAtIndex!(proj::Project, crv::Dict{String,Any},
                                         indx::Int, boundaryName::String)
    @@  removeInnerBoundaryCurveAtIndex!(proj::Project, indx::Int, chainName::String)
    removeInnerBoundary!(proj::Project, chainName::String)
    @@  addInnerBoundaryWithName!(proj::Project,name::String)
    @   getChainIndex(chain::Vector{Dict{String, Any}},name)
    @@  getAllInnerBoundaries(proj::Project)
    @   getInnerBoundaryChainWithName(proj::Project, name::String)
    @   getInnerBoundaryCurve(proj::Project, curveName::String, boundaryName::String)
    innerBoundaryIndices(proj::Project, curveName::String)

    @   getModelDict(proj::Project)
    @@  getDictInModelDictNamed(proj::Project,name::String)
=#
using HOHQMesh
using Test

@testset "Model Tests" begin
#
# Exercise the different outputs for empty undo / redo stacks
#
    clearUndoRedo()
    @test undo() == "Empty undo stack. No action performed."
    @test undoActionName() == "No undo action in queue"
    @test redo() == "Empty redo stack. No action performed."
    @test redoActionName() == "No redo action in queue"
#
#   Project for the model
#
    projectName = "TestProject"
    projectPath = "out"

    p = newProject(projectName, projectPath)
#
#   Create some boundary curves
#
    obc1 = new("obc1",[0.0,0.0,0.0], [2.0,0.0,0.0])
    obc2 = new("obc2",[2.0,0.0,0.0], [1.0,1.0,0.0])
    obc3 = new("obc3",[1.0,1.0,0.0], [0.0,0.0,0.0])
#
    add!(p,obc1)
    add!(p,obc2)
    addCurveToOuterBoundary!(p,obc3)

    obList = getOuterBoundaryChainList(p)
    @test length(obList) == 3
    @test getChainIndex(obList,"obc3") == 3
    @test undoActionName() == "Add Outer Boundary Curve"
    undo()
    @test length(obList) == 2
    @test redoActionName() == "Remove Outer Boundary Curve"
    redo()
    @test length(obList) == 3

    crv = getOuterBoundaryCurveWithName(p,"obc2")
    @test getCurveName(crv) == "obc2"
#
#   Test remove/add outer boundary
#
    removeOuterBoundary!(p)
    mDict = getModelDict(p)
    @test haskey(mDict,"OUTER_BOUNDARY") == false
    undo()
    @test haskey(mDict,"OUTER_BOUNDARY") == true
    crv = getOuterBoundaryCurveWithName(p,"obc2")
    @test getCurveName(crv) == "obc2"
    redo()
    @test haskey(mDict,"OUTER_BOUNDARY") == false
#
#   Inner boundary curve tests
#
    ib1Name = "Inner1"
    add!(p,obc1,ib1Name)
    add!(p,obc2,ib1Name)
    add!(p,obc3,ib1Name)

    i, chain = getInnerBoundaryChainWithName(p,ib1Name)
    ibList = chain["LIST"]
    @test length(ibList) == 3

    ibc = getInnerBoundaryCurve(p, "obc2",ib1Name)
    @test getCurveName(ibc) == "obc2"

    removeInnerBoundaryCurve!(p,"obc2",ib1Name)
    @test length(ibList) == 2
    undo()
    @test length(ibList) == 3
    ibc = getInnerBoundaryCurve(p, "obc2",ib1Name)
    @test getCurveName(ibc) == "obc2"

#
#   Purposely create outer / inner boundary curves that do
#   not join in a new project. This will trigger error statements.
#
    obc1 = new("obc1",[0.0,0.0,0.0], [2.0,0.0,0.0])
    obc2 = new("obc2",[3.0,0.0,0.0], [1.0,1.0,0.0])

    # Failing outer boundary
    add!(p, obc1)
    add!(p, obc2)

    # Failing inner boundary
    line = newEndPointsLineCurve("line", [0.0,-2.0,0.0], [1.0,0.0,0.0])
    halfCircle  = newCircularArcCurve("halfCircle", [0.0,0.0,0.0], 1.5, 0.0, 180.0, "degrees")

    add!(p, line, "failCurve")
    addCurveToInnerBoundary!(p, halfCircle , "failCurve")

end

end # module