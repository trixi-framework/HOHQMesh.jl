
"""
    newParametricEquationCurve(name::String,
                               xEqn::String,
                               yEqn::String,
                               zEqn::String = "z(t) = 0.0" )

Creates and returns a new parametricEquationCurve in the form of a Dictionary
"""
function newParametricEquationCurve(name::String,
                                    xEqn::String,
                                    yEqn::String,
                                    zEqn::String = "z(t) = 0.0" )

    crv = Dict{String,Any}()
    crv["TYPE"] = "PARAMETRIC_EQUATION_CURVE"
    disableNotifications()
    disableUndo()
    setCurveName!(crv,name)
    setXEqn!(crv,xEqn)
    setYEqn!(crv,yEqn)
    setZEqn!(crv,zEqn)
    enableUndo()
    enableNotifications()
    return crv
end


"""
    newEndPointsLineCurve(name::String, xStart::Array{Float64},xEnd::Array[Float64])

Creates and returns a new curve defined by its end points in the form of a Dictionary
"""
function newEndPointsLineCurve(name::String,
                               xStart::Array{Float64},
                               xEnd::Array{Float64})
    crv = Dict{String,Any}()
    crv["TYPE"] = "END_POINTS_LINE"
    disableNotifications()
    disableUndo()
    setCurveName!(crv,name)
    setStartPoint!(crv,xStart)
    setEndPoint!(crv,xEnd)
    enableNotifications()
    enableUndo()
    return crv
end


"""
    newCircularArcCurve(name::String, center::Array{Float64},
        startAngle::Float64, endAngle::Float64,
        units::String)

Creates and returns a new circular arc curve in the form of a Dictionary
"""
function newCircularArcCurve(name::String,
                             center::Array{Float64},
                             radius::Float64,
                             startAngle::Float64,
                             endAngle::Float64,
                             units::String = "degrees")

    arc = Dict{String,Any}()
    arc["TYPE"] = "CIRCULAR_ARC"
    disableNotifications()
    disableUndo()
    setCurveName!(arc,name)
    setArcUnits!(arc,units)
    setArcCenter!(arc,center)
    setArcStartAngle!(arc,startAngle)
    setArcEndAngle!(arc,endAngle)
    setArcRadius!(arc,radius)
    enableNotifications()
    enableUndo()
    return arc
end


"""
    newSplineCurve(name::String, nKnots::Int, data::Array{Float64,4})

Returns a spline curve given the number of knots and the array of knots.
"""
function newSplineCurve(name::String, nKnots::Int, data::Matrix{Float64})
    spline = Dict{String,Any}()
    spline["TYPE"] = "SPLINE_CURVE"
    disableNotifications()
    disableUndo()
    setCurveName!(spline,name)
    setSplineNKnots!(spline,nKnots)
    setSplinePoints!(spline,data)
    enableNotifications()
    enableUndo()
    return spline
end


"""
    newSplineCurve(name::String, dataFile::String)

Returns a spline curve given a data file that contains the number of knots
on the first line, and the spline data following that.
"""
function newSplineCurve(name::String, dataFile::String)

    spline = Dict{String,Any}()
    open(dataFile,"r") do f
        nKnots          = parse(Int,readline(f))
        splineDataArray = zeros(Float64,nKnots,4)
        for i = 1:nKnots
            currentLine = split(readline(f))
            for j = 1:4
                splineDataArray[i,j] = parse(Float64,currentLine[j])
            end
        end
        spline = newSplineCurve(name, nKnots, splineDataArray)
    end
    return spline
end


#"""
#    duplicateCurve(crv::Dict{String,Any}, newName::String)
#
#Duplicate the given curve giving it the new name.
#"""
# function duplicateCurve(crv::Dict{String,Any}, newName::String)
#     disableNotifications()
#     disableUndo()

#     duplicate = deepcopy(crv)
#     setCurveName!(duplicate,newName)

#     enableNotifications()
#     enableUndo()
#     return duplicate
# end


"""
    setCurveName!(curveDict, name)

Set the name of the curve represented by curveDict.
"""
function setCurveName!(crv::Dict{String,Any}, name::String)
    if haskey(crv,"name")
        oldName = crv["name"]
        registerWithUndoManager(crv,setCurveName!, (oldName,), "Set Curve Name")
        postNotificationWithName(crv,"CURVE_DID_CHANGE_NAME_NOTIFICATION",(oldName,))
    end
    crv["name"] = name
end


"""
    getCurveName(crv::Dict{String,Any})
"""
function getCurveName(crv::Dict{String,Any})
    return crv["name"]
end


"""
    getCurveType(crv::Dic{String,Any})

    Get the type of the curve, `END_POINTSLINE_CURVE`, `PARAMETRIC_EQUATION_CURVE`,
    `SPLINE_CURVE`, or `CIRCULAR_ARC` as a string.
"""
function getCurveType(crv::Dict{String,Any})
    return crv["TYPE"]
end


"""
    setXEqn!(parametricEquationCurve, eqn)

For a parametric equation, set the x-equation.
"""
function setXEqn!(crv::Dict{String,Any}, eqn::String)
    if haskey(crv,"xEqn")
        oldEqn = crv["xEqn"]
        registerWithUndoManager(crv,setXEqn!, (eqn,), "Set X Equation")
    end
    crv["xEqn"] = eqn
    postNotificationWithName(crv,"CURVE_DID_CHANGE_NOTIFICATION",(nothing,))
end


"""
    getXEqn(crv::Dict{String,Any})
"""
function getXEqn(crv::Dict{String,Any})
    if(haskey(crv,"xEqn"))
        return crv["xEqn"]
    end
    return nothing
end


"""
    setYEqn!(parametricEquationCurve, eqn)

For a parametric equation, set the y-equation.
"""
function setYEqn!(crv::Dict{String,Any}, eqn::String)
    if haskey(crv,"yEqn")
        oldEqn = crv["yEqn"]
        registerWithUndoManager(crv,setYEqn!, (eqn,), "Set Y Equation")
    end
    crv["yEqn"] = eqn
    postNotificationWithName(crv,"CURVE_DID_CHANGE_NOTIFICATION",(nothing,))
end


"""
    getYEqn(crv::Dict{String,Any})
"""
function getYEqn(crv::Dict{String,Any})
    if(haskey(crv,"yEqn"))
        return crv["yEqn"]
    end
    return nothing
end


"""
    setZEqn!(parametricEquationCurve, eqn)

For a parametric equation, set the zEqn-equation.
"""
function setZEqn!(crv::Dict{String,Any}, eqn::String)
    if haskey(crv,"zEqn")
        oldEqn = crv["zEqn"]
        registerWithUndoManager(crv,setZEqn!, (eqn,), "Set Z Equation")
    end
    crv["zEqn"] = eqn
    postNotificationWithName(crv,"CURVE_DID_CHANGE_NOTIFICATION",(nothing,))
end


"""
    getZEqn(crv::Dict{String,Any})
"""
function getZEqn(crv::Dict{String,Any})
    if(haskey(crv,"zEqn"))
        return crv["zEqn"]
    end
    return nothing
end


"""
    setStartPoint!(crv::Dict{String,Any}, point::Array{Float64})

Set the start point for a line curve.
"""
function setStartPoint!(crv::Dict{String,Any}, point::Array{Float64})
    pStr = "[$(point[1]),$(point[2]),$(point[3])]"
    setStartPoint!(crv,pStr)
end


function setStartPoint!(crv::Dict{String,Any}, pointAsString::String)
    key = "xStart"
    if haskey(crv,key)
        oldPt = crv[key]
        registerWithUndoManager(crv,setStartPoint!, (oldPt,), "Set Start Point")
    end
    crv[key] = pointAsString
    postNotificationWithName(crv,"CURVE_DID_CHANGE_NOTIFICATION",(nothing,))
end


"""
    getStartPoint(crv::Dict{String,Any}, point::Array{Float64})

Get the start point for a line curve as an array
"""
function getStartPoint(crv::Dict{String,Any})
    return realArrayForKeyFromDictionary("xStart",crv)
end


"""
    setEndPoint!(crv::Dict{String,Any}, point::Array{Float64})

Set the end point for a line curve.
"""
function setEndPoint!(crv::Dict{String,Any}, point::Array{Float64})
    pStr = "[$(point[1]),$(point[2]),$(point[3])]"
    setEndPoint!(crv,pStr)
end


function setEndPoint!(crv::Dict{String,Any}, pointAsString::String)
    key = "xEnd"
    if haskey(crv,key)
        oldPt = crv[key]
        registerWithUndoManager(crv,setEndPoint!, (oldPt,), "Set End Point")
    end
    crv[key] = pointAsString
    postNotificationWithName(crv,"CURVE_DID_CHANGE_NOTIFICATION",(nothing,))
end


"""
    getEndPoint(crv::Dict{String,Any}, point::Array{Float64})

Get the end point for a line curve as an array.
"""
function getEndPoint(crv::Dict{String,Any})
    return realArrayForKeyFromDictionary("xEnd",crv)
end


"""
    setArcUnits(crv::Dict{String,Any}, units::String)

Set the units for the start and end angles of a circular arc curve.
"""
function setArcUnits!(arc::Dict{String,Any}, units::String)
    if units == "degrees" || units == "radians"
        key = "units"
        if haskey(arc,key)
            oldUnits = arc[key]
            registerWithUndoManager(arc,setArcUnits!, (oldUnits,), "Set Arc Units")
        end
        arc[key] = units
        postNotificationWithName(arc,"CURVE_DID_CHANGE_NOTIFICATION",(nothing,))
    else
        @warn "Units must either be `degrees` or `radians`. Try setting `units` again."
    end
end


"""
    getArcUnits(crv::Dict{String,Any}, units::String)

Get the units for the start and end angles of a circular arc curve.
"""
function getArcUnits(arc::Dict{String,Any})
    return arc["units"]
end


"""
    setArcCenter!(crv::Dict{String,Any}, point::Array{Float64})

Set the center of a circular arc.
"""
function setArcCenter!(arc::Dict{String,Any}, point::Array{Float64})
    pStr = "[$(point[1]),$(point[2]),$(point[3])]"
    setArcCenter!(arc,pStr)
end
function setArcCenter!(arc::Dict{String,Any}, pointAsString::String)
    key = "center"
    if haskey(arc,key)
        oldVal = arc[key]
        registerWithUndoManager(arc,setArcCenter!, (oldVal,), "Set Arc Center")
    end

    arc[key] = pointAsString
    postNotificationWithName(arc,"CURVE_DID_CHANGE_NOTIFICATION",(nothing,))
end


"""
    getArcCenter(crv::Dict{String,Any}, point::Array{Float64})

Get the center of a circular arc as an array
"""
function getArcCenter(arc::Dict{String,Any})
    return realArrayForKeyFromDictionary("center",arc)
end


"""
    setArcStartAngle!(arc::Dict{String,Any}, angle::Float64)
"""
function setArcStartAngle!(arc::Dict{String,Any}, angle::Float64)
    key = "start angle"
    if haskey(arc,key)
        oldVal = parse(Float64,arc[key])
        registerWithUndoManager(arc,setArcStartAngle!, (oldVal,), "Set Arc Start Angle")
    end
    arc[key] = string(angle)
    postNotificationWithName(arc,"CURVE_DID_CHANGE_NOTIFICATION",(nothing,))
end


"""
    getArcStartAngle(arc::Dict{String,Any}, angle::Float64)
"""
function getArcStartAngle(arc::Dict{String,Any})
    return parse(Float64,arc["start angle"])
end


"""
    setArcEndAngle!(arc::Dict{String,Any}, angle::Float64)
"""
function setArcEndAngle!(arc::Dict{String,Any}, angle::Float64)
    key = "end angle"
    if haskey(arc,key)
        oldVal = parse(Float64,arc[key])
        registerWithUndoManager(arc,setArcEndAngle!, (oldVal,), "Set Arc Start Angle")
    end
    arc[key] = string(angle)
    postNotificationWithName(arc,"CURVE_DID_CHANGE_NOTIFICATION",(nothing,))
end


"""
    getArcEndAngle(arc::Dict{String,Any}, angle::Float64)
"""
function getArcEndAngle(arc::Dict{String,Any})
    return parse(Float64,arc["end angle"])
end


"""
    setArcRadius!(arc::Dict{String,Any}, radius::Float64)
"""
function setArcRadius!(arc::Dict{String,Any}, radius::Float64)
    key = "radius"
    if haskey(arc,key)
        oldVal = parse(Float64,arc[key])
        registerWithUndoManager(arc,setArcRadius!, (oldVal,), "Set Arc Radius")
    end
    arc[key] = string(radius)
    postNotificationWithName(arc,"CURVE_DID_CHANGE_NOTIFICATION",(nothing,))
end


"""
    getArcRadius(arc::Dict{String,Any}, radius::Float64)
"""
function getArcRadius(arc::Dict{String,Any})
    return parse(Float64,arc["radius"])
end


"""
    setSplineNKnots!(spline::Dict{String,Any}, nKnots::Int)
"""
function setSplineNKnots!(spline::Dict{String,Any}, nKnots::Int)
    key = "nKnots"
    if haskey(spline,key)
        oldVal = parse(Int,spline[key])
        registerWithUndoManager(spline,setSplineNKnots!, (oldVal,), "Set Spline Knots")
    end
    spline["nKnots"] = string(nKnots)
    postNotificationWithName(spline,"CURVE_DID_CHANGE_NOTIFICATION",(nothing,))
end


"""
    getSplineNKnots(spline::Dict{String,Any})
"""
function getSplineNKnots(spline::Dict{String,Any})
    return parse(Int,spline["nKnots"])
end


"""
    setSplinePoints!(spline::Dict{String,Any},points::Array{Float64,4})
"""
function setSplinePoints!(spline::Dict{String,Any},points::Matrix{Float64})
    key = "SPLINE_DATA"
    if haskey(spline,key)
        registerWithUndoManager(spline,setSplinePoints!, (spline["SPLINE_DATA"],), "Set Spline Points")
    end
    spline["SPLINE_DATA"] = points
    postNotificationWithName(spline,"CURVE_DID_CHANGE_NOTIFICATION",(nothing,))
end


"""
    getSplinePoints(spline::Dict{String,Any})
"""
function getSplinePoints(spline::Dict{String,Any})
    return spline["SPLINE_DATA"]
end
