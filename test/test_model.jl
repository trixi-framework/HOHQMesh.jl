module TestModel
#=
    Model Tests tests the "ModelAPI.jl" functions

Functions: @  = tested
           @@ = indirectly tested through other tests

    @   addCurveToOuterBoundary!(proj::Project, crv::Dict{String,Any})
    @@  removeOuterBoundaryCurveWithName!(proj::Project, name::String)
    @   getOuterBoundaryCurveWithName(proj::Project, name::String)
    @@  insertOuterBoundaryCurveAtIndex!(proj::Project, crv::Dict{String,Any}, index::Int)
    @@  removeOuterBoundaryCurveAtIndex!(proj::Project, index::Int)
    @@  addOuterBoundary!(proj::Project, outerBoundary::Dict{String,Any})
    @   removeOuterBoundary!(proj::Project)
    @   getOuterBoundaryChainList(proj::Project)

    @@ addCurveToInnerBoundary!(proj::Project, crv::Dict{String,Any}, boundaryName::String)
    @   removeInnerBoundaryCurve!(proj::Project, name::String, chainName::String)
    @@  insertInnerBoundaryCurveAtIndex!(proj::Project, crv::Dict{String,Any},
                                         index::Int, boundaryName::String)
    @@  removeInnerBoundaryCurveAtIndex!(proj::Project, index::Int, chainName::String)
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

    # Purposely make an outer boundary with the wrong orientation
    obc4 = new("obc4", [0.0,0.0,0.0], [1.0,1.0,0.0])
    obc5 = new("obc5", [1.0,1.0,0.0], [2.0,0.0,0.0])
    obc6 = new("obc6", [2.0,0.0,0.0], [0.0,0.0,0.0])
    add!(p,obc4)
    add!(p,obc5)
    add!(p,obc6)
    # Check the outer boundary curve that is CLOCKWISE oriented. Throws a warning
    @test_logs match_mode=:any (:warn, "Boundary curves must be defined counterclockwise. The outer boundary is not.") HOHQMesh.modelCurvesAreOK(p)

    # Delete the bad outer boundary before inner curve tests
    removeOuterBoundary!(p)

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
    @test_logs match_mode=:any (:warn, "The curve obc3 does not meet the previous curve, obc1.") HOHQMesh.modelCurvesAreOK(p)
    # Check the inner boundary curve orientation. The inner curve is not connected, so circulation
    # is meaningless. However, still throws a warning
    @test_logs match_mode=:any (:warn, "Boundary curves must be defined counterclockwise. Boundary Inner1 is not.") HOHQMesh.modelCurvesAreOK(p)

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

# Tests for getter / setter functions on the OUTER_BOUNDARY
@testset "Outer Boundary optimization getters/setters" begin
    projectName = "TestProject"
    projectPath = "out"

    p = newProject(projectName, projectPath)

    ell = new("Ellipse", [0.0, -3.0, 0.0], 0.8, 0.35, 0.0, 360.0, -47.0, "degrees")
    addCurveToOuterBoundary!(p, ell)

    @test getOuterBoundaryOptimizeStatus(p) == "none"

    @test_logs (:warn, "Acceptable optimization types are `none`, `L2Norm`, or `H1Norm`. Try again.") begin
        setOuterBoundaryOptimizeStatus!(p, "invalid")
    end

    # Invalid value should not change the current value
    @test getOuterBoundaryOptimizeStatus(p) == "none"

    setOuterBoundaryOptimizeStatus!(p, "L2Norm")
    @test getOuterBoundaryOptimizeStatus(p) == "L2Norm"

    setOuterBoundaryOptimizeStatus!(p, "H1Norm")
    @test getOuterBoundaryOptimizeStatus(p) == "H1Norm"

    # Tolerance keyword functions

    @test getOuterBoundaryTolerance(p) == 1.0e-3

    # Low tolerance: warning should be generated, but value
    # should still be set
    @test_logs (:warn, "Setting a low tolerance may not be achievable or the mesh generation may take an inordinate amount of time. Think about how accurate of a mesh is needed before choosing a low tolerance like 1.0e-6.") begin
        setOuterBoundaryTolerance!(p, 1.0e-6)
    end
    @test getOuterBoundaryTolerance(p) == 1.0e-6

    # Negative tolerance: warning and value should NOT change
    oldTolerance = getOuterBoundaryTolerance(p)

    @test_logs (:warn, "The boundary tolerance must be non-negative. Try again.") begin
        setOuterBoundaryTolerance!(p, -1.0)
    end

    @test getOuterBoundaryTolerance(p) == oldTolerance

    # Continuity keyword functions

    @test getOuterBoundaryContinuity(p) == 0

    setOuterBoundaryContinuity!(p, 2)
    @test getOuterBoundaryContinuity(p) == 2

    # > 2 generates warning but value is still set
    @test_logs (:warn, "Higher continuity constraints can lead to ill-conditioned systems in the optimization procedure.") begin
        setOuterBoundaryContinuity!(p, 3)
    end
    @test getOuterBoundaryContinuity(p) == 3

    # Negative continuity generates warning and should not change value
    oldContinuity = getOuterBoundaryContinuity(p)

    @test_logs (:warn, "The continuity must be non-negative. Try again.") begin
        setOuterBoundaryContinuity!(p, -1)
    end

    @test getOuterBoundaryContinuity(p) == oldContinuity

    # Connect keyword functions

    @test getOuterBoundaryConnect(p) == "[]"

    setOuterBoundaryConnect!(p, "2-3, 5-7")
    @test getOuterBoundaryConnect(p) == "2-3, 5-7"
end

# Tests for getter / setter functions on a CHAIN of INNER_BOUNDARIES
@testset "Inner Boundary Chain getters/setters" begin

    chainName = "IceCreamCone"
    p = newProject("innerTest", "out")

    cone1    = newEndPointsLineCurve("cone1", [0.0, -3.0, 0.0], [1.0, 0.0, 0.0])
    iceCream = newCircularArcCurve("iceCream", [0.0, 0.0, 0.0], 1.0, 0.0, 180.0, "degrees")
    cone2    = newEndPointsLineCurve("cone2", [-1.0, 0.0, 0.0], [0.0, -3.0, 0.0])

    addCurveToInnerBoundary!(p, cone1, "IceCreamCone")
    addCurveToInnerBoundary!(p, iceCream, "IceCreamCone")
    addCurveToInnerBoundary!(p, cone2, "IceCreamCone")

    @test getInnerBoundaryChainOptimizeStatus(p, chainName) == "none"

    @test_logs (:warn, "Acceptable optimization types are `none`, `L2Norm`, or `H1Norm`. Try again.") begin
        setInnerBoundaryChainOptimizeStatus!(p, chainName, "invalid")
    end

    setInnerBoundaryChainOptimizeStatus!(p, chainName, "L2Norm")
    @test getInnerBoundaryChainOptimizeStatus(p, chainName) == "L2Norm"

    setInnerBoundaryChainOptimizeStatus!(p, chainName, "H1Norm")
    @test getInnerBoundaryChainOptimizeStatus(p, chainName) == "H1Norm"

    # Tolerance keyword functions

    @test getInnerBoundaryChainTolerance(p, chainName) == 1.0e-3

    @test_logs (:warn, "Setting a low tolerance may not be achievable or the mesh generation may take an inordinate amount of time. Think about how accurate of a mesh is needed before choosing a low tolerance like 1.0e-6.") begin
        setInnerBoundaryChainTolerance!(p, chainName, 1.0e-6)
    end
    @test getInnerBoundaryChainTolerance(p, chainName) == 1.0e-6

    oldTolerance = getInnerBoundaryChainTolerance(p, chainName)

    @test_logs (:warn, "The boundary tolerance must be non-negative. Try again.") begin
        setInnerBoundaryChainTolerance!(p, chainName, -1.0)
    end

    @test getInnerBoundaryChainTolerance(p, chainName) == oldTolerance

    # Continuity keyword functions

    @test getInnerBoundaryChainContinuity(p, chainName) == 0

    setInnerBoundaryChainContinuity!(p, chainName, 2)
    @test getInnerBoundaryChainContinuity(p, chainName) == 2

    @test_logs (:warn, "Higher continuity constraints can lead to ill-conditioned systems in the optimization procedure.") begin
        setInnerBoundaryChainContinuity!(p, chainName, 3)
    end
    @test getInnerBoundaryChainContinuity(p, chainName) == 3

    oldContinuity = getInnerBoundaryChainContinuity(p, chainName)

    @test_logs (:warn, "The continuity must be non-negative. Try again.") begin
        setInnerBoundaryChainContinuity!(p, chainName, -1)
    end

    @test getInnerBoundaryChainContinuity(p, chainName) == oldContinuity

    # Connect keyword functions

    @test getInnerBoundaryChainConnect(p, chainName) == "[]"

    setInnerBoundaryChainConnect!(p, chainName, "2-3, 5-7")
    @test getInnerBoundaryChainConnect(p, chainName) == "2-3, 5-7"
end

end # module