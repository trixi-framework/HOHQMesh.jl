module TestCurve
#=
    Curve Tests tests the "CurvesAPI.jl" functions

Functions: @ = tested
    @(as new)   newParametricEquationCurve(name::String,
                                    xEqn::String,
                                    yEqn::String,
                                    zEqn::String = "z(t) = 0.0" )
    @(as new)   newEndPointsLineCurve(name::String,
                               xStart::Array{Float64},
                               xEnd::Array{Float64})
    @(as new)   newCircularArcCurve(name::String,
                             center::Array{Float64},
                             radius::Float64,
                             startAngle::Float64,
                             endAngle::Float64,
                             units::String = "degrees")
    @   newSplineCurve(name::String, nKnots::Int, data::Matrix{Float64})
    newSplineCurve(name::String, dataFile::String)
    @   setCurveName!(crv::Dict{String,Any}, name::String)
    @   getCurveName(crv::Dict{String,Any})
    @   getCurveType(crv::Dict{String,Any})
    @   setXEqn!(crv::Dict{String,Any}, eqn::String)
    @   getXEqn(crv::Dict{String,Any})
    @   setYEqn!(crv::Dict{String,Any}, eqn::String)
    @   getYEqn(crv::Dict{String,Any})
    @   setZEqn!(crv::Dict{String,Any}, eqn::String)
    @   getZEqn(crv::Dict{String,Any})
    @   setStartPoint!(crv::Dict{String,Any}, point::Array{Float64})
    @   setStartPoint!(crv::Dict{String,Any}, pointAsString::String)
    @   getStartPoint(crv::Dict{String,Any})
    @   setEndPoint!(crv::Dict{String,Any}, point::Array{Float64})
    @   setEndPoint!(crv::Dict{String,Any}, pointAsString::String)
    @   getEndPoint(crv::Dict{String,Any})
    @   setArcUnits!(arc::Dict{String,Any}, units::String)
    @   getArcUnits(arc::Dict{String,Any})
    @   setArcCenter!(arc::Dict{String,Any}, point::Array{Float64})
    @   setArcCenter!(arc::Dict{String,Any}, pointAsString::String)
    @   getArcCenter(arc::Dict{String,Any})
    @   setArcStartAngle!(arc::Dict{String,Any}, angle::Float64)
    @   getArcStartAngle(arc::Dict{String,Any})
    @   setArcEndAngle!(arc::Dict{String,Any}, angle::Float64)
    @   getArcEndAngle(arc::Dict{String,Any})
    @   setArcRadius!(arc::Dict{String,Any}, radius::Float64)
    @   getArcRadius(arc::Dict{String,Any})
    @   setSplineNKnots!(spline::Dict{String,Any}, nKnots::Int)
    @   getSplineNKnots(spline::Dict{String,Any})
    @   setSplinePoints!(spline::Dict{String,Any},points::Matrix{Float64})
    @   getSplinePoints(spline::Dict{String,Any})
=#
using HOHQMesh
using Test

@testset "Curve Tests" begin
    @testset "ParametricCurve Tests" begin
        xEqn = "x(t) = t"
        yEqn = "y(t) = 2.0*t"
        zEqn = "z(t) = 0.0"
        name = "TestParametricCurve"

        crv = new(name, xEqn, yEqn, zEqn)

        @test typeof(crv)       == Dict{String,Any}
        @test getCurveType(crv) == "PARAMETRIC_EQUATION_CURVE"
        @test getCurveName(crv) == name
        @test getXEqn(crv)      == xEqn
        @test getYEqn(crv)      == yEqn
        @test getZEqn(crv)      == zEqn
    end

    @testset "EndPointLine Tests" begin
        xStart = [0.0,0.0,0.0]
        xEnd   = [1.0,1.0,0.0]
        name = "EndPointLineCurve"

        crv = new(name,xStart,xEnd)

        @test typeof(crv)        == Dict{String,Any}
        @test getCurveType(crv)  == "END_POINTS_LINE"
        @test getCurveName(crv)  == name
        @test getStartPoint(crv) == xStart
        @test getEndPoint(crv)   == xEnd

        pt = curvePoint(crv, 0.5)
        @test isapprox(pt,[0.5,0.5,0.0])

        pts = curvePoints(crv, 2)
        @test isapprox(pts[1,:],[0.0,0.0])
        @test isapprox(pts[2,:],[0.5,0.5])
        @test isapprox(pts[3,:],[1.0,1.0])

        setStartPoint!(crv,[2.0,3.0,0.0])
        @test getStartPoint(crv) == [2.0,3.0,0.0]
        undo()
        @test getStartPoint(crv) == xStart
        redo()
        @test getStartPoint(crv) == [2.0,3.0,0.0]

        setEndPoint!(crv,[2.0,3.0,0.0])
        @test getEndPoint(crv) == [2.0,3.0,0.0]
        undo()
        @test getEndPoint(crv) == xEnd
        redo()
        @test getEndPoint(crv) == [2.0,3.0,0.0]
    end

    @testset "CircularArc Tests" begin
        center      = [0.0,0.0,0.0]
        radius      = 2.0
        startAngleD = 0.0
        endAngleD   = 180.0
        name        = "CircularArcCurve"

        crv = new(name, center, radius, startAngleD, endAngleD, "degrees")

        @test typeof(crv)           == Dict{String,Any}
        @test getCurveType(crv)     == "CIRCULAR_ARC"
        @test getCurveName(crv)     == name
        @test getArcCenter(crv)     == center
        @test getArcRadius(crv)     == radius
        @test getArcStartAngle(crv) == startAngleD
        @test getArcUnits(crv)      == "degrees"

        pt = curvePoint(crv, 0.5)
        @test isapprox(pt,[0.0,2.0,0.0])

        pts = curvePoints(crv,2)
        @test isapprox(pts[1,:],[2.0,0.0])
        @test isapprox(pts[2,:],[0.0,2.0])
        @test isapprox(pts[3,:],[-2.0,0.0])

        setArcUnits!(crv,"radians")
        @test getArcUnits(crv) == "radians"
        undo()
        @test getArcUnits(crv) == "degrees"
        redo()
        @test getArcUnits(crv) == "radians"

        setArcCenter!(crv,[1.0,2.0,0.0])
        @test getArcCenter(crv) == [1.0,2.0,0.0]
        undo()
        @test getArcCenter(crv) == center
        redo()
        @test getArcCenter(crv) == [1.0,2.0,0.0]
    end

    @testset "Spline Tests" begin
        nKnots = 5
        nPts   = 3
        data = zeros(Float64,nKnots,4)
        for j in 1:5
            tj = 0.25*(j-1)
            xj = tj^3
            yj = tj^3 + tj^2
            zj = 0.0
            data[j,:] = [tj,xj,yj,zj]
        end

        name = "Spline Curve"
        crv = newSplineCurve(name, nKnots, data)

        @test typeof(crv)           == Dict{String,Any}
        @test getCurveType(crv)     == "SPLINE_CURVE"
        @test getCurveName(crv)     == name
        @test getSplineNKnots(crv)  == nKnots

        pt = curvePoint(crv, 0.5)
        @test isapprox(pt, [0.5^3, 0.5^3 + 0.5^2, 0.0])
        pt = curvePoint(crv, 0.0)
        @test isapprox(pt, [0.0, 0.0, 0.0])
#
#       The curvePoints for the spline has M = max(N,nKnots*2) values
#
        M = max(nPts, nKnots*2)
        pts = curvePoints(crv, M)
        d   = 1.0 / M
        for j in 1:M+1
            tj = (j-1) * d
            @test isapprox(pts[j, :], [tj^3, tj^3 + tj^2])
        end

        gPts = getSplinePoints(crv)
        @test isapprox(data, gPts)
#
#   Get spline data from a file
#
        fSpline = newSplineCurve("fromFile", joinpath(@__DIR__, "test_spline_curve_data.txt"))
        fPts = getSplinePoints(fSpline)
        # Use point value 11 from the file as the test point
        control_pt = [0.131578947368421, -0.657970237227418, 0.051342865473934, 0.0]
        @test isapprox(control_pt, fPts[11, :])
    end

end

end # module