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

#=
    Some useful getters for a dictionary
=#
arrayRegex = r"(?<=\[).+?(?=\])"

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
    array = [parse(Int,s[1]),parse(Int,s[2]),parse(Int,s[3])]
    return array
end

function keyAndValueFromString(s)
    indxOfEqual = findfirst("=",s)
    if indxOfEqual === nothing
        return nothing
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
