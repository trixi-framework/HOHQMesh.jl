#=
 MIT License

 Copyright (c) 2010-present David A. Kopriva and other contributors: AUTHORS.md

 Permission is hereby granted, free of charge, to any person obtaining a copy  
 of this software and associated documentation files (the "Software"), to deal  
 in the Software without restriction, including without limitation the rights  
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell  
 copies of the Software, and to permit persons to whom the Software is  
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all  
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER  
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  
 SOFTWARE.
 
 --- End License
=#

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
