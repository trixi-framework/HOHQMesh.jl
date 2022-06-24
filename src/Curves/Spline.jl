
mutable struct Spline
    N::Int
    x::Array{Float64}
    y::Array{Float64}
    b::Array{Float64}
    c::Array{Float64}
    d::Array{Float64}
    last::Int
end

function constructSpline(N::Int, x::Array{Float64},y::Array{Float64})
    b = zeros(Float64,N)
    c = zeros(Float64,N)
    d = zeros(Float64,N)

    Nm1 = N - 1
#
#   Set up tri-diagonal system for a cubic spline
#
    d[1] = x[2] - x[1]
    c[2] = (y[2] - y[1])/d[1]
    for i = 2:Nm1
        d[i]   = x[i+1] - x[i]
        b[i]   = 2.0*(d[i-1] + d[i])
        c[i+1] = (y[i+1] - y[i])/d[i]
        c[i]   = c[i+1] - c[i]
    end
#
#   "not-a-knot" end conditions where third derivatives are approximated
#   with divided differences
#
    b[1] = -d[1]
    b[N] = -d[N-1]
    c[1] = c[3]/(x[4] - x[2]) - c[2]/(x[3] - x[1])
    c[N] = c[N-1]/(x[N] - x[N-2]) - c[N-2]/(x[N-1] - x[N-3])
    c[1] = c[1]*d[1]^2/(x[4] - x[1])
    c[N] = -c[N]*d[N-1]^2/(x[N] - x[N-3])
#
#   Forward elimination
#
    t = 0.0
    for i = 2:N
        t    = d[i-1]/b[i-1]
        b[i] = b[i] - t*d[i-1]
        c[i] = c[i] - t*c[i-1]
    end
#
#   Back substitution
#
    c[N] = c[N]/b[N]
    for ib = 1:Nm1
        i = N - ib
        c[i] = (c[i] - d[i]*c[i+1])/b[i]
    end
#
#   Compute polynomial coefficients
#
    b[N] = (y[N] - y[Nm1])/d[Nm1] + d[Nm1]*(c[Nm1] + 2.0*c[N])
    for i = 1: Nm1
        b[i] = (y[i+1] - y[i])/d[i] - d[i]*(c[i+1] + 2.0*c[i])
        d[i] = (c[i+1] - c[i])/d[i]
        c[i] = 3.0*c[i]
    end
    c[N] = 3.0*c[N]
    d[N] = d[N-1]

    spl = Spline(N,x,y,b,c,d,1)
    return spl
end


function evalSpline(spl::Spline, u::Float64)
    N = spl.N
    s = 0.0
    i = spl.last

    if i >= N
        i = 1
    end

    if spl.x[i] < u <=  spl.x[i+1]
        dx      = u - spl.x[i]
        s       = spl.y[i] + dx*(spl.b[i]+ dx*(spl.c[i] + dx*spl.d[i]))
        spl.last = i
        return s
    end

    i = 1
    j = N+1

    for ii = 1:N
        k = div(i+j,2)
        if u < spl.x[k]
            j = k
        end
        if u >= spl.x[k]
            i = k
        end
        if j <= i+1
            break
        end
    end
    dx      = u - spl.x[i]
    s       = spl.y[i] + dx*(spl.b[i]+ dx*(spl.c[i] + dx*spl.d[i]))
    spl.last = i
    return s
end
