using Test
include("../HQMTool.jl")
#=
    Background Grid Tests tests the "BackgroundGrid.jl" functions

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
@testset "Background Grid Tests" begin

    projectName = "TestProject"
    projectPath = "./Test/TestData"

    p = newProject(projectName, projectPath)
#
#   Add with method 1 (when outer boundary is present): [dx,dy,dz]
#
    @test hasBackgroundGrid(p) == false
    addBackgroundGrid!(p,[0.1,0.2,0.0])
    @test hasBackgroundGrid(p) == true
    bgs = getBackgroundGridSize(p)
    @test isapprox(bgs,[0.1,0.2,0.0])
    removeBackgroundGrid!(p)
    @test hasBackgroundGrid(p) == false
#
#   Add with method 2: lower left, dx, nPts
#
    addBackgroundGrid!(p,[-1.0,-1.0,0.0],[0.1,0.1,0.0], [10,10,0])
    @test hasBackgroundGrid(p) == true
    @test getBackgroundGridSteps(p) == [10,10,0]
    @test isapprox(getBackgroundGridSize(p),[0.1,0.1,0.0])
    @test isapprox(getBackgroundGridLowerLeft(p),[-1.0,-1.0,0.0])
#
#   Test undo, redo
#
    undo()
    @test hasBackgroundGrid(p) == false
    redo()
    @test hasBackgroundGrid(p) == true
    removeBackgroundGrid!(p)
    @test hasBackgroundGrid(p) == false
#
#   Add with method 3 (No outer bounday, preferred): bounding box + nPts
#
    addBackgroundGrid!(p, [10.0,-10.0,-5.0,5.0], [10,10,0])
    @test hasBackgroundGrid(p) == true
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
    @test hasBackgroundGrid(p) == false

end