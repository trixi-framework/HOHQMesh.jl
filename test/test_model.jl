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
    @   removeOuterBoundary!(proj::Project)
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
#   Exercise the different outputs for empty undo / redo stacks
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

    # Check the outer boundary curve that are not connected. Throws a warning
    @test_logs (:warn, "The boundary curve Outer is not closed. Fix to generate mesh" ) HOHQMesh.modelCurvesAreOK(p)
    @test HOHQMesh.modelCurvesAreOK(p) == false

    @test redoActionName() == "Remove Outer Boundary Curve"
    redo()
    @test length(obList) == 3

    # Outer boundary is connected again. Check is successful now
    @test HOHQMesh.modelCurvesAreOK(p) == true

    crv = getOuterBoundaryCurveWithName(p,"obc2")
    @test getCurveName(crv) == "obc2"
#
#   Test remove/add outer boundary
#

    # Attempt to remove an outer boundary curve that does not exist. Throws an error
    @test_throws ErrorException removeOuterBoundaryCurveWithName!(p, "wrongName")

    removeOuterBoundary!(p)
    mDict = HOHQMesh.getModelDict(p)
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
    # Check the inner boundary curve that are not connected. Throws a warning
    @test_logs (:warn, "The curve obc3 does not meet the previous curve, obc1.") HOHQMesh.modelCurvesAreOK(p)
    @test HOHQMesh.modelCurvesAreOK(p) == false

    undo()
    @test length(ibList) == 3
    ibc = getInnerBoundaryCurve(p, "obc2",ib1Name)
    @test getCurveName(ibc) == "obc2"

#
#   Purposely create outer / inner boundary curves that do not join in a new project.
#   Attempt to generate a mesh and trigger an appropriate warning statement.
#
    obc1 = new("obc1",[0.0,0.0,0.0], [2.0,0.0,0.0])
    obc2 = new("obc2",[3.0,0.0,0.0], [1.0,1.0,0.0])

    # A background grid is required for the mesh generation call
    addBackgroundGrid!(p, [0.5, 0.5, 0.0])

    # Failing outer boundary
    add!(p, obc1)
    add!(p, obc2)

    # This call actually throws multiple warnings but we just test that the main one is thrown
    @test_logs (:warn, "Meshing aborted: Ensure boundary curve segments are in order and boundary curves are closed and try again.") match_mode=:any generate_mesh(p)

end

end # module