#=
    ImportControlFile(fileName::String)

The control file reader parses the control file and returns a Control file dictionary.

@author: davidkopriva

A Control file dictionary contains the keys
    TYPE
    CONTROL_INPUT
    MODEL

TYPE is a string naming the type (class) of object stored

The CONTROL_INPUT contains the blocks
    RUN_PARAMETERS
    MESH_PARAMETERS
    SPRING_SMOOTHER
    REFINEMENT_REGIONS
        REFINEMENT_REGIONS contains a ["LIST"] of
            REFINEMENT_CENTER
            REFINEMENT_LINE
    SCALE_TRANSFORMATION
    ROTATION_TRANSFORMATION
    SIMPLE_EXTRUSION
    SIMPLE_ROTATION
    SWEEP_ALONG_CURVE

The MODEL dictionary contains the keys
    TYPE
    OUTER_BOUNDARY
        OUTER_BOUNDARY contains a ["LIST"] of
            PARAMETRIC_EQUATION_CURVE
            SPLINE_CURVE
            END_POINTS_LINE
            CIRCULAR_ARC
    INNER_BOUNDARIES
        The INNER_BOUNDARIES block contains a ["LIST"] of
            CHAIN
    SWEEP_CURVE
    SWEEP_SCALE_FACTOR
    TOPOGRAPHY

A CHAIN block contains a ["LIST"] of
     PARAMETRIC_EQUATION_CURVE
     SPLINE_CURVE
     END_POINTS_LINE
     CIRCULAR_ARC

A PARAMETRIC_EQUATION_CURVE dictionary contains the keys
    TYPE
    name
    xEqn
    yEqn
    zEqn

A SPLINE_CURVE block contains the keys
   TYPE
   name
   SPLINE_DATA

SPLINE_DATA block contains keys and data
   nKnots
   t_1 x_1 y_1 z_1
   t_2 x_2 y_2 z_2
   ...
   t_nKnots x_nKnots y_nKnots z_nKnots

An END_POINTS_LINE has the following keys
   TYPE
   name
   xStart
   xEnd

A CIRCULAR_ARC block contains
   TYPE
   name
   units
   center
   radius
   start angle
   end angle

REFINEMENT_REGIONS dictionary contains the keys
   TYPE
   LIST
      LIST is a list of
          REFINEMENT_CENTER
          REFINEMENT_LINE

A REFINEMENT_CENTER contains the keys
   TYPE
   center
   h
   w

A REFINEMENT_LINE contains the keys
   TYPE
   xStart
   xEnd
   h
   w

A ROTATION_TRANSFORMATION contains the keys
   TYPE
   direction
   rotationPoint

A SCALE_TRANSFORMATION contains the keys
   TYPE
   origin
   scaleFactor

The SWEEP_CURVE dictionary contains the keys
   TYPE
   LIST
     The list contains dictionaries describing
         PARAMETRIC_EQUATION_CURVE
         SPLINE_CURVE
         END_POINTS_LINE

The SWEEP_SCALE_FACTOR dictionary contains the keys
   TYPE
   LIST
     The list contains dictionaries describing
         PARAMETRIC_EQUATION

  But the equation definitions contain only one equation r(t) = ...

The TOPOGRAPHY dictionary contains the keys
   TYPE
   eqn (for equation defined topography)
   sizing

The SIMPLE_EXTRUSION block contains the keys
   TYPE
   direction
   height
   subdivisions
   start surface name
   end surface name

The SIMPLE_ROTATION block contains the keys
   TYPE
   direction
   rotation angle factor
   subdivisions
   start surface name
   end surface name

The SWEEP_ALONG_CURVE block contains the keys
   TYPE
   algorithm   (optional)
   subdivisions per segment
   start surface name
   end surface name

=#

# Four objects store their members as lists rather than
# as dictionaries (See above)

const blocksThatStoreLists = Set(["OUTER_BOUNDARY",
                                  "REFINEMENT_REGIONS" ,
                                  "INNER_BOUNDARIES",
                                  "CHAIN"])

const blockRegex = r"(?<=\{).+?(?=\})"
blockNameStack = []

# Control file components order to force
# CONTROL_INPUT to come first in the file
# followed by the MODEL
const projectOrder = ["CONTROL_INPUT", "MODEL"]

# Order on the CONTROL_INPUT to match the HOHQMesh
# documentation.
const controlInputOrder = ["RUN_PARAMETERS",
                           "BACKGROUND_GRID",
                           "SPRING_SMOOTHER",
                           "REFINEMENT_REGIONS"]

# Boundary curve optimization keyword order
const bndryOptKeywordOrder = ["name",
                              "optimize",
                              "tolerance",
                              "continuity",
                              "connect"]

#
#--------------- MAIN ENTRY -----------------------------------------------
#
function ImportControlFile(fileName::String)
    controlDict = Dict{String,Any}()
    open(fileName,"r") do controlFile
        performImport(controlDict, controlFile)
    end
    return controlDict
end


function WriteControlFile(controlDict::Dict{String,Any}, fileName::String)
    open(fileName,"w") do controlFile
        indent = ""
        WriteDictionary(controlDict, controlFile, indent)
        println(controlFile,"\\end{FILE}")
    end
end
#
#------------- END MAIN ENTRY ------------------------------------------
#

function performImport(collection, f::IOStream)

    for line in eachline(f)
        line = rstrip(line)
#
#       ----------------
#       Start of a block
#       ----------------
#
        if occursin("begin{",line)
            blockNameMatch = match(blockRegex,line)
            if blockNameMatch === nothing
                error("Block name not found in string: " * line)
            else # Start new collection
                blockName = blockNameMatch.match
                push!(blockNameStack, blockName)
#
#               A SPLINE_DATA block is special and is read in separately
#               into an array and saved in the spline curve dictionary
#
                if blockName == "SPLINE_DATA"
                    ImportSplineData( collection, f)
                    continue
                end

                newBlock = Dict{String,Any}()
                newBlock["TYPE"] = blockName
                addToCollection(collection, blockName, newBlock)
#
#               Some blocks store items in a list
#
                if in(blockName, blocksThatStoreLists)
                    newBlock["LIST"] = Dict{String,Any}[]
#
#                   If the block defines a chain, get its name
#
                    if blockName == "CHAIN"
                        nextLine = readline(f)
                        kvp      = keyAndValueOnLine(nextLine)
                        if kvp === nothing
                            error("Key-value pair not found in string: " * nextLine)
                        end
                        addToCollection(newBlock,kvp[1],kvp[2])
                    end
                    performImport(newBlock["LIST"],f)
                else
                    performImport(newBlock,f)
                end
            end
#
#       --------------
#       End of a block
#       --------------
#
        elseif occursin("end{",line)
            blockNameMatch = match(blockRegex,line)
            blockName      = blockNameMatch.match
            if blockName == "FILE"
                return
            end
            if length(blockNameStack) == 0
                error("Extra end statement found: " * line)
            end
            if blockNameMatch === nothing
                error("Block name not found in string: " * line)
            else
                stackValue::String = blockNameStack[end]
                if cmp(blockName,stackValue) == 0
                    pop!(blockNameStack)
                else
                    error("Block name end $blockName does not match current block $stackValue")
                end
                if blockName == "SPLINE_DATA"
                    continue
                else
                    return
                end
            end
#
#       ----------------------
#       Comment or blank lines
#       ----------------------
#
        elseif isempty(line)
            continue
        elseif line[1] == '%'
            continue
#
#       -------------------------
#       Block body key-value pair
#       -------------------------
#
        else
            kvp = keyAndValueOnLine(line)
            if kvp === nothing
                error("Key-value pair not found in string: " * line)
            end
            addToCollection(collection,kvp[1],kvp[2])
        end
    end
end


function WriteDictionary(controlDict::Dict{String,Any}, f::IOStream, indent::String)

    deepIndent = "   " * indent

    # Ensure that CONTROL_INPUT comes first
    # followed by the MODEL
    for key in projectOrder
        if haskey(controlDict, key)
            value = controlDict[key]

            println(f, "\\begin{$key}")
            WriteDictionary(value, f, deepIndent)
            println(f, "\\end{$key}")
            println(f, "")
        end
    end

    # Ensure that CONTROL_INPUT components
    # match the order from the HOHQMesh docs
    for key in controlInputOrder
        if haskey(controlDict, key)
            value = controlDict[key]

            println(f, indent, "\\begin{$key}")
            WriteDictionary(value, f, deepIndent)
            println(f, indent, "\\end{$key}")
            println(f, "")
        end
    end

    # Write the optimization keywords in order
    # to match the HOHQMesh documentation
    for key in bndryOptKeywordOrder
        if haskey(controlDict, key)
            value = controlDict[key]

#            # TODO: do we want this skip?
#            # Don't write an empty connect
#            if key == "connect" && value == "[]"
#                continue
#            end

            if isa(value, AbstractString)
                if key != "TYPE"
                    println(f, indent, "$key = $value")
                end
            end
        end
    end

    # Write everything else where ordering doesn't matter
    for (key, value) in controlDict
        # Already handled above
        if key in union(bndryOptKeywordOrder, projectOrder, controlInputOrder)
            continue
        end
        if isa(value, AbstractDict)
            println(f, indent, "\\begin{$key}")
            WriteDictionary(value, f, deepIndent)
            println(f, indent, "\\end{$key}")
            println(f, "")
        elseif isa(value, AbstractString)
            if key != "TYPE"
                println(f, indent, "$key = $value")
            end
        elseif isa(value, AbstractArray)
            if key == "LIST"
                StepThroughList(value, f, deepIndent)
            elseif key == "SPLINE_DATA"
                println(f, indent, "\\begin{$key}")
                arraySize = size(value)
                for j = 1:arraySize[1]
                    println(f, deepIndent, " ",
                               value[j,1], " ",
                               value[j,2], " ",
                               value[j,3], " ",
                               value[j,4])
                end
                println(f, indent, "\\end{$key}")
                println(f, "")
            end
        end
    end
end


function StepThroughList(lst::AbstractArray,f::IOStream, indent::String)
    deepIndent = "   " * indent
    for dict in lst
        dtype = dict["TYPE"]
        println(f,indent, "\\begin{$dtype}")
        WriteDictionary(dict,f, deepIndent)
        println(f,indent, "\\end{$dtype}")
    end
end


function keyAndValueOnLine(s)
    indexOfEqual = findfirst("=",s)
    if indexOfEqual === nothing
        return nothing
    end
    key = strip(s[1:indexOfEqual.start-1],[' ','\t'])
    value = strip(s[indexOfEqual.stop+1:end],[' ','\t'])
    return (key,value)
end


function addToCollection(dict::Dict{String,Any}, k::AbstractString, v::AbstractString)
    dict[k] = v
end


function addToCollection(c::Array, k::AbstractString, v::Any)
    push!(c,v)
end


function addToCollection(dict::Dict{String,Any}, k::AbstractString, v::Dict{String,Any})
    dict[k] = v
end


function ImportSplineData( splineDict::Dict{String,Any}, f::IOStream)

    if !haskey(splineDict, "nKnots")
        error("Spline block must define nKnots before SPLINE_DATA. Try again.")
    end

    knotString = splineDict["nKnots"]
    nKnots = parse(Int64, knotString)
    splineDataArray = zeros(Float64, nKnots, 4)
    for i = 1:nKnots
        currentLine = split(readline(f))
        for j = 1:4
            splineDataArray[i,j] = parse(Float64, currentLine[j])
        end
    end
    splineDict["SPLINE_DATA"] = splineDataArray
end
