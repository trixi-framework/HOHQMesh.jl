#
# Creating curves
#
"""
    new(name::String,
        xEqn::String,
        yEqn::String,
        zEqn::String = "z(t) = 0.0" )

Create a new parametric equation curve.
"""
function new(name::String,
             xEqn::String,
             yEqn::String,
             zEqn::String = "z(t) = 0.0" )
    return newParametricEquationCurve(name, xEqn, yEqn, zEqn)
end


"""
    new(name::String,
             xStart::Array{Float64},
             xEnd::Array{Float64})

Create a new line defined by its end points.
"""
function new(name::String,
             xStart::Array{Float64},
             xEnd::Array{Float64})
    return newEndPointsLineCurve(name, xStart, xEnd)
end


"""
    new(name::String,
        center::Array{Float64},
        radius::Float64,
        startAngle::Float64,
        endAngle::Float64,
        units::String)

Create a new circular arc.
"""
function new(name::String,
            center::Array{Float64},
            radius::Float64,
            startAngle::Float64,
            endAngle::Float64,
            units::String = "degrees")
    return newCircularArcCurve(name,center,radius,startAngle,endAngle,units)
end


"""
    new(name::String, dataFile::String)

Create a spline curve from the contents of a data file.
"""
function new(name::String, dataFile::String)
    return newSplineCurve(name, dataFile)
end


"""
    new(name::String, nKnots::Int, data::Matrix{Float64})

Create a spline curve from an array of knots
"""
function new(name::String, nKnots::Int, data::Matrix{Float64})
    return newSplineCurve(name, nKnots, data)
end


#
# Adding curves to a model
#
"""
    add!(proj::Project, obj::Dict{String,Any})

Add a curve to the outer boundary or a refinement reion to
the project
"""
function add!(proj::Project, obj::Dict{String,Any})
    if obj["TYPE"] == "REFINEMENT_CENTER" || obj["TYPE"] == "REFINEMENT_LINE"
        addRefinementRegion!(proj, obj)
    else
        addCurveToOuterBoundary!(proj, obj)
    end
end


"""
    add!(proj::Project, crv::Dict{String,Any}, boundaryName::String)

Add a curve to the inner boundary named `boundaryName`.
"""
function add!(proj::Project, crv::Dict{String,Any}, boundaryName::String)
    addCurveToInnerBoundary!(proj, crv, boundaryName)
end


"""
getCurve(proj::Project, curveName::String)

Get the curve with name `curveName` from the outer boundary.
"""
function getCurve(proj::Project, curveName::String)
    return getOuterBoundaryCurveWithName(proj, curveName)
end


"""
getCurve(proj::Project, curveName::String, boundaryName::String)

Get the curve named `curveName` from the inner boundary named `boundaryName`
"""
function getCurve(proj::Project, curveName::String, boundaryName::String)
    return  getInnerBoundaryCurve(proj, curveName, boundaryName)
end


"""
    getInnerBoundary(proj::Project, name::String)

Get the chain of curves from the inner boundary with name `name`.
"""
function getInnerBoundary(proj::Project, name::String)
    return getInnerBoundaryChainWithName(proj, name)
end


"""
    remove!(proj::Project, curveName::String)

Delete the curve named curveName from the outer boundary
"""
function remove!(proj::Project, curveName::String)
    removeOuterBoundaryCurveWithName!(proj, curveName)
end


"""
    remove!(proj::Project, curveName::String, innerBoundaryName::String)

Delete the curve named curveName from the inner boundary named innerBoundaryName
"""
function remove!(proj::Project, curveName::String, innerBoundaryName::String)
    removeInnerBoundaryCurve!(proj, curveName, innerBoundaryName)
end

