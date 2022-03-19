using Test
include("../HQMTool.jl")

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

        # pt = zeros(Float64,2)
        # peEquationCurvePoint(xEqn,yEqn,0.5,pt)
        # pts = curvePoints(crv,2)
        # @test isapprox(pts[1,:],[0.0,0.0])
        # @test isapprox(pts[2,:],[0.5,1.0])
        # @test isapprox(pts[3,:],[1.0,2.0])

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

        pts = curvePoints(crv,2)
        @test isapprox(pts[1,:],[0.0,0.0])
        @test isapprox(pts[2,:],[0.5,0.5])
        @test isapprox(pts[3,:],[1.0,1.0])
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
        
        pt = curvePoint(crv, 0.5)
        @test isapprox(pt,[0.5^3,0.5^3 + 0.5^2,0.0])
        pt = curvePoint(crv, 0.0)
        @test isapprox(pt,[0.0,0.0,0.0])
#
#       The curvePoints for the spline has M = max(N,nKnots*2) values
#
        M = max(nPts,nKnots*2)
        pts = curvePoints(crv,M)
        d   = 1.0/M
        for j in 1:M+1
            tj = (j-1)*d
            @test isapprox(pts[j,:],[tj^3,tj^3 + tj^2])
        end 
      
    end

end
