
const TOP = 1; const LEFT = 2; const BOTTOM = 3; const RIGHT = 4

"""
curveBounds(crvPoints::Array{Float64,2})

Find the bounds of a single curve, discretized as an array
"""
function curveBounds(crvPoints::Array{Float64,2})

    s       =  size(crvPoints)
    top     = -Inf64
    left    =  Inf64
    bottom  =  Inf64
    right   =  -Inf64

    for i = 1:s[1]
        right  = max(right,crvPoints[i,1])
        left   = min(left,crvPoints[i,1])
        top    = max(top,crvPoints[i,2])
        bottom = min(bottom,crvPoints[i,2])
    end

    bounds         = zeros(Float64,4)
    bounds[TOP]    = top
    bounds[LEFT]   = left
    bounds[BOTTOM] = bottom
    bounds[RIGHT]  = right

    return bounds
end


function chainBounds(chain::Array{Any})
    bounds = emptyBounds()
    for crv in chain
        crvBounds = curveBounds(crv)
        bounds    = bboxUnion(bounds,crvBounds)
    end
    return bounds
end


"""
    bboxUnion(box1::Array{Float64}, box2::Array{Float64})

Returns the union of two bounding boxes
"""
function bboxUnion(box1::Array{Float64}, box2::Array{Float64})
    union = zeros(Float64,4)
    union[TOP]    = max(box1[TOP]   ,box2[TOP])
    union[LEFT]   = min(box1[LEFT]  ,box2[LEFT])
    union[BOTTOM] = min(box1[BOTTOM],box2[BOTTOM])
    union[RIGHT]  = max(box1[RIGHT] ,box2[RIGHT])

    return union
end


"""
    emptyBounds()

Returns an array that will always be ignored when unioned with
another bounding box.
"""
function emptyBounds()
    emptee         = zeros(Float64,4)
    emptee[TOP]    = -Inf64
    emptee[LEFT]   =  Inf64
    emptee[BOTTOM] =  Inf64
    emptee[RIGHT]  = -Inf64
    return emptee
end
