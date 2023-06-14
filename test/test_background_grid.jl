module TestBackgroundGrid
#=
    Background Grid Tests exercises routines found in "src/Project/BackgroundGridAPI.jl" functions

Functions: @ = tested
    @   addBackgroundGrid!(proj::Project, bgSize::Array{Float64})
    @   addBackgroundGrid!(proj::Project, box::Array{Float64}, N::Array{Int})
    @   addBackgroundGrid!(proj::Project, x0::Array{Float64}, dx::Array{Float64}, N::Array{Int})
    @   removeBackgroundGrid!(proj::Project)
    @   setBackgroundGridSize!(proj::Project, dx::Float64, dy::Float64, dz::Float64 = 0.0)
    @   getBackgroundGridSize(proj::Project)
    @   getBackgroundGridLowerLeft(proj::Project)
    @   getBackgroundGridSteps(proj::Project)
    @   setBackgroundGridLowerLeft!(proj::Project, x0::Array{Float64})
    @   setBackgroundGridSteps!(proj::Project, N::Array{Int})
    @   setBackgroundGridSize!(proj::Project, dx::Array{Float64}, key::String)
    @   addBackgroundGrid!(proj::Project, dict::Dict{String,Any})
=#
using HOHQMesh
using Test

@testset "Background Grid Tests" begin

    projectName = "TestProject"
    projectPath = "out"

    p = newProject(projectName, projectPath)
#
#   Add with method 1 (when outer boundary is present): [dx,dy,dz]
#
    @test HOHQMesh.hasBackgroundGrid(p) == false
    addBackgroundGrid!(p,[0.1,0.2,0.0])
    @test HOHQMesh.hasBackgroundGrid(p) == true
    bgs = getBackgroundGridSize(p)
    @test isapprox(bgs,[0.1,0.2,0.0])
    removeBackgroundGrid!(p)
    @test HOHQMesh.hasBackgroundGrid(p) == false
#
#   Add with method 2: lower left, dx, nPts
#
    addBackgroundGrid!(p,[-1.0,-1.0,0.0],[0.1,0.1,0.0], [10,10,0])
    @test HOHQMesh.hasBackgroundGrid(p) == true
    @test getBackgroundGridSteps(p) == [10,10,0]
    @test isapprox(getBackgroundGridSize(p),[0.1,0.1,0.0])
    @test isapprox(getBackgroundGridLowerLeft(p),[-1.0,-1.0,0.0])
#
#   Test undo, redo
#
    undo()
    @test HOHQMesh.hasBackgroundGrid(p) == false
    redo()
    @test HOHQMesh.hasBackgroundGrid(p) == true
    removeBackgroundGrid!(p)
    @test HOHQMesh.hasBackgroundGrid(p) == false
#
#   Add with method 3 (No outer boundary, preferred): bounding box + nPts
#
    addBackgroundGrid!(p, [10.0,-10.0,-5.0,5.0], [10,10,0])
    @test HOHQMesh.hasBackgroundGrid(p) == true
    @test getBackgroundGridSteps(p) == [10,10,0]
    @test isapprox(getBackgroundGridSize(p),[1.5,1.5,0.0])
    @test isapprox(getBackgroundGridLowerLeft(p),[-10.0,-5.0,0.0])
#
#   Editing functions
#
    setBackgroundGridSize!(p, 1.0, 1.0)
    @test isapprox(getBackgroundGridSize(p), [1.0,1.0,0.0])
    @test getBackgroundGridSteps(p) == [15,15,0]

    removeBackgroundGrid!(p)
    @test HOHQMesh.hasBackgroundGrid(p) == false
#
#   There are no longer any background grid. Delete the notification center piece as well.
#   Note that the notification center is global and can have multiple observers. So we test
#   this notification center removal before other observers, e.g. other projects in the
#   testing runs, are created that will add in the background grid again.
#
    HOHQMesh.unRegisterForNotification(p, "BGRID_DID_CHANGE_NOTIFICATION")
    @test haskey( HOHQMesh.HQMNotificationCenter , "BGRID_DID_CHANGE_NOTIFICATION" ) == false

end

end # module