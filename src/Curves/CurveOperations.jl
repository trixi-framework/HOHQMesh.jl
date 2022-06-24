
const argRegex = r"(?<=\().+?(?=\))"

function arcCurvePoints(center::Array{Float64}, r::Float64, thetaStart::Float64, thetaEnd::Float64, units::AbstractString, t::Array{Float64}, points::Array{Float64,2})
    fctr::Float64 = 1.0
    if units == "degrees"
        fctr = pi/180.0
    end

    theta::Float64 = 0.0
    for i = 1:length(t)
        theta = thetaStart + (thetaEnd - thetaStart)*t[i]
        points[i,1] = center[1] + r*cos(theta*fctr)
        points[i,2] = center[2] + r*sin(theta*fctr)
    end
end


function arcCurvePoint(center::Array{Float64}, r::Float64, thetaStart::Float64, thetaEnd::Float64,
                       units::AbstractString, t::Float64, point::Array{Float64})
    fctr::Float64 = 1.0
    if units == "degrees"
        fctr = pi/180.0
    end
    theta = thetaStart + (thetaEnd - thetaStart)*t
    point[1] = center[1] + r*cos(theta*fctr)
    point[2] = center[2] + r*sin(theta*fctr)
end


function endPointsLineCurvePoints(xStart::Array{Float64}, xEnd::Array{Float64}, t::Array{Float64}, points::Array{Float64})
    for i = 1:length(t)
        points[i,1:2] = xStart[1:2] + t[i]*(xEnd[1:2] - xStart[1:2])
    end
end


function endPointsLineCurvePoint(xStart::Array{Float64}, xEnd::Array{Float64}, t::Float64, point::Array{Float64})
        point[1:2] = xStart[1:2] + t*(xEnd[1:2] - xStart[1:2])
end


function peEquationCurvePoints(xEqn, yEqn, t::Array{Float64}, points::Array{Float64,2})

    argPart,eqString = keyAndValueFromString(xEqn)
    xArgM = match(argRegex,argPart)
    xArg  = Symbol(xArgM.match)
    ex    = Meta.parse(eqString)

    argPart,eqString = keyAndValueFromString(yEqn)
    yArgM = match(argRegex,argPart)
    yArg  = Symbol(yArgM.match)
    ey    = Meta.parse(eqString)

    for i = 1:length(t)
        points[i,1] = evalWithDict(ex,Dict(xArg=> t[i]))
        points[i,2] = evalWithDict(ey,Dict(yArg=> t[i]))
    end
end


function  peEquationCurvePoint(xEqn, yEqn, t::Float64, point::Array{Float64})

    argPart,eqString = keyAndValueFromString(xEqn)
    xArgM = match(argRegex,argPart)
    xArg  = Symbol(xArgM.match)
    ex    = Meta.parse(eqString)

    argPart,eqString = keyAndValueFromString(yEqn)
    yArgM = match(argRegex,argPart)
    yArg  = Symbol(yArgM.match)
    ey    = Meta.parse(eqString)

    point[1] = evalWithDict(ex, Dict(xArg=> t))
    point[2] = evalWithDict(ey, Dict(yArg=> t))

end


function splineCurvePoints(nKnots::Int, splineData::Array{Float64,2}, points::Array{Float64,2})

    xSpline = constructSpline(nKnots,splineData[:,1],splineData[:,2])
    ySpline = constructSpline(nKnots,splineData[:,1],splineData[:,3])

    sz   = size(points)
    nPts = sz[1]
    t = 0.0
    for i = 1:nPts
        t = (i-1)/(nPts-1)
        points[i,1] = evalSpline(xSpline,t)
        points[i,2] = evalSpline(ySpline,t)
    end
end


function splineCurvePoint(nKnots::Int, splineData::Array{Float64,2}, t, point::Array{Float64})

    xSpline = constructSpline(nKnots,splineData[:,1],splineData[:,2])
    ySpline = constructSpline(nKnots,splineData[:,1],splineData[:,3])

    point[1] = evalSpline(xSpline,t)
    point[2] = evalSpline(ySpline,t)
end


# This function evaluates a string as an equation, might be redundant code
# function parse_eval_dict(s::AbstractString, locals::Dict{Symbol})
#     ex = Meta.parse(s)
#     assignments = [:($sym = $val) for (sym,val) in locals]
#     eval(:(let $(assignments...); $ex; end))
# end


function evalWithDict(ex, locals::Dict{Symbol})
    assignments = [:($sym = $val) for (sym,val) in locals]
    eval(:(let $(assignments...); $ex; end))
end


function curvePoints(crvDict::Dict{String,Any}, N::Int)
# N = Number of intervals
    curveType::String = crvDict["TYPE"]

    if curveType == "PARAMETRIC_EQUATION_CURVE"
        xEqn = crvDict["xEqn"]
        yEqn = crvDict["yEqn"]

        x = zeros(Float64,N+1,2)
        t = zeros(Float64,N+1)
        for i = 1:N+1
            t[i] = (i-1)/N
        end
        peEquationCurvePoints(xEqn,yEqn,t,x)
    elseif curveType == "END_POINTS_LINE"
        xStart = realArrayForKeyFromDictionary("xStart",crvDict)
        xEnd   = realArrayForKeyFromDictionary("xEnd",crvDict)
        x = zeros(Float64,3,2)
        t = zeros(Float64,3)
        for i = 1:3
            t[i] = (i-1)/2.0
        end

        endPointsLineCurvePoints(xStart,xEnd,t,x)
    elseif curveType == "CIRCULAR_ARC"
        center     = realArrayForKeyFromDictionary("center",crvDict)
        radius     = realForKeyFromDictionary("radius",crvDict)
        startAngle = realForKeyFromDictionary("start angle",crvDict)
        endAngle   = realForKeyFromDictionary("end angle",crvDict)
        units      = crvDict["units"]

        x = zeros(Float64,N+1,2)
        t = zeros(Float64,N+1)
        for i = 1:N+1
            t[i] = (i-1)/N
        end

        arcCurvePoints(center,radius,startAngle,endAngle,units,t,x)
    elseif curveType == "SPLINE_CURVE"
        nKnots = intForKeyFromDictionary("nKnots",crvDict)
        splineData = crvDict["SPLINE_DATA"]

        M = max(N,nKnots*2)
        x = zeros(Float64,M+1,2)

        splineCurvePoints(nKnots,splineData,x)
    end
    return x
end


function chainPoints(chain::Array{Dict{String,Any}}, N::Int)

    x = Any[]

    for crvDict in chain
        push!(x,curvePoints(crvDict,N))
    end
    return x
end


function curvePoint(crvDict::Dict{String,Any}, t::Float64)

    curveType::String = crvDict["TYPE"]

    if curveType == "PARAMETRIC_EQUATION_CURVE"
        xEqn = crvDict["xEqn"]
        yEqn = crvDict["yEqn"]
        x = zeros(Float64,3)
        peEquationCurvePoint(xEqn, yEqn, t, x)
    elseif curveType == "END_POINTS_LINE"
        xStart = realArrayForKeyFromDictionary("xStart",crvDict)
        xEnd   = realArrayForKeyFromDictionary("xEnd",crvDict)
        x = zeros(Float64,3)
        endPointsLineCurvePoint(xStart,xEnd,t,x)
    elseif curveType == "CIRCULAR_ARC"
        center     = realArrayForKeyFromDictionary("center",crvDict)
        radius     = realForKeyFromDictionary("radius",crvDict)
        startAngle = realForKeyFromDictionary("start angle",crvDict)
        endAngle   = realForKeyFromDictionary("end angle",crvDict)
        units      = crvDict["units"]
        x = zeros(Float64,3)
        arcCurvePoint(center,radius,startAngle,endAngle,units,t,x)
    elseif curveType == "SPLINE_CURVE"
        nKnots = intForKeyFromDictionary("nKnots",crvDict)
        splineData = crvDict["SPLINE_DATA"]
        x = zeros(Float64,3)
        splineCurvePoint(nKnots,splineData,t,x)
    end
    return x
end


function curvesMeet(firstCurve::Dict{String,Any}, secondCurve::Dict{String,Any}; tol=100*eps(Float64))
    xFirst  = curvePoint(firstCurve,1.0)
    xSecond = curvePoint(secondCurve,0.0)
    if maximum(abs.(xFirst - xSecond)) < tol
        return true
    else
        return false
    end
end
