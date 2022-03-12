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

using Base: CyclePadding, Int64, Float64, current_logger, parseint_preamble, String, Bool
using Printf
using HOHQMesh
#=
    A program for reading, writing and plotting a model for HOHQMesh
=#
include("Source/Viz/VizMesh.jl")
include("Source/Misc/NotificationCenter.jl")
include("Source/Misc/DictionaryOperations.jl")
include("Source/Curves/Spline.jl")
include("Source/ControlFile/ControlFileOperations.jl")
include("Source/Curves/CurveOperations.jl")
include("Source/Project/Project.jl")
include("Source/Project/CurvesAPI.jl")
include("Source/Viz/VizProject.jl")
include("Source/Project/Undo.jl")
include("Source/Mesh/Meshing.jl")
include("Source/Project/Generics.jl")

#
#---------------- FOR TESTING PURPOSES --------------------------------------
#

function runDemo()
#=
    Reads in an existing control file, plots the boundary curves and generates
    a mesh.
=#
    p = openProject("AllFeatures.control", "Demo")
    plotProject!(p,MODEL+REFINEMENTS+GRID)
    println("Hit any key to continue and generate the mesh")
    readline()
    generateMesh(p)
    return p
end

function iceCreamConeVerbose(folder::String)
#
# Create a project with the name "IceCreamCone", which will be the name of the mesh, plot and stats files,
# written to `folder`.
#
    p = newProject("IceCreamCone",folder)
#
#   Outer boundary
#
    circ = newCircularArcCurve("outerCircle",[0.0,-1.0,0.0],4.0,0.0,360.0,"degrees")
    addCurveToOuterBoundary!(p,circ)
#
#   Inner boundary
#
    cone1    = newEndPointsLineCurve("cone1", [0.0,-3.0,0.0],[1.0,0.0,0.0])
    iceCream = newCircularArcCurve("iceCream",[0.0,0.0,0.0],1.0,0.0,180.0,"degrees")
    cone2    = newEndPointsLineCurve("cone2", [-1.0,0.0,0.0],[0.0,-3.0,0.0])
    addCurveToInnerBoundary!(p,cone1,"IceCreamCone")
    addCurveToInnerBoundary!(p,iceCream,"IceCreamCone")
    addCurveToInnerBoundary!(p,cone2,"IceCreamCone")
#
#   Set some control RunParameters to overwrite the defaults
#
    setPolynomialOrder!(p,4)
    setPlotFileFormat!(p,"sem")
#
#   To mesh, a background grid is needed
#
    addBackgroundGrid!(p, [0.5,0.5,0.0])
#
#   Show the model and grid
#
    plotProject!(p, MODEL+GRID)
#
#   Generate the mesh and plot
#
    println("Press any key to continue and generate the mesh")
    readline()
    generateMesh(p)

    return p
end

function iceCreamCone(folder::String)
    #
    # Create a project with the name "IceCreamCone", which will be the name of the mesh, plot and stats files,
    # written to `path`.
    #
        p = newProject("IceCreamCone",folder)
    #
    #   Outer boundary
    #
        circ = new("outerCircle",[0.0,-1.0,0.0],4.0,0.0,360.0,"degrees")
        add!(p,circ)
    #
    #   Inner boundary
    #
        cone1    = new("cone1", [0.0,-3.0,0.0],[1.0,0.0,0.0])
        iceCream = new("iceCream",[0.0,0.0,0.0],1.0,0.0,180.0,"degrees")
        cone2    = new("cone2", [-1.0,0.0,0.0],[0.0,-3.0,0.0])
        add!(p,cone1,"IceCreamCone")
        add!(p,iceCream,"IceCreamCone")
        add!(p,cone2,"IceCreamCone")
    #
    #   To mesh, a background grid is needed
    #
        addBackgroundGrid!(p, [0.5,0.5,0.0])
        setMeshFileFormat!(p, "ABAQUS")
        meshFileFormat = getMeshFileFormat(p)
        setFileNames!(p, meshFileFormat)
    #
    #   Show the model and grid
    #
        plotProject!(p, MODEL+GRID)
    #
    #   Generate the mesh and plot
    #
        println("Press any key to continue and generate the mesh")
        readline()
        generateMesh(p)

        return p
end
