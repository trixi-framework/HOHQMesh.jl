#=
    Some useful getters for a dictionary
=#

const arrayRegex = r"(?<=\[).+?(?=\])"

function realForKeyFromDictionary(key::AbstractString, d::Dict{String,Any})
    v = d[key]
    return parse(Float64,v)
end


function intForKeyFromDictionary(key::AbstractString, d::Dict{String,Any})
    v = d[key]
    return parse(Int64,v)
end


function stringForKeyFromDictionary(key::AbstractString, d::Dict{String,Any})
    v = d[key]
    return v
end


function realArrayForKeyFromDictionary(key::AbstractString, d::Dict{String,Any})
    v = d[key]
    values = match(arrayRegex,v)
    s      = split(values.match,",")
    array = [parse(Float64,s[1]),parse(Float64,s[2]),parse(Float64,s[3])]
    return array
end


function intArrayForKeyFromDictionary(key::AbstractString, d::Dict{String,Any})
    v = d[key]
    values = match(arrayRegex,v)
    s      = split(values.match,",")
    array = [parse(Int64,s[1]),parse(Int64,s[2]),parse(Int64,s[3])]
    return array
end


function keyAndValueFromString(s)
    indxOfEqual = findfirst("=",s)
    if indxOfEqual === nothing
        error("Equal sign = required to distinguish key and value from a string.")
    end
    key   = strip(s[1:indxOfEqual.start-1],[' ','\t'])
    value = strip(s[indxOfEqual.stop+1:end],[' ','\t'])
    return (key,value)
end


function showDescription(d::Dict, pre=1)
    todo = Vector{Tuple}()
    for (k,v) in d
        if typeof(v) <: Dict
            push!(todo, (k,v))
        else
            println(join(fill(" ", pre)) * "$(repr(k)) => $(repr(v))")
        end
    end

    for (k,d) in todo
        s = "$(repr(k)) => "
        println(join(fill(" ", pre)) * s)
        showDescription(d, pre+1+length(s))
    end
    nothing
end
