# Interactive mesh with spline curves
#
# Create a mesh with a circular outer boundary and three inner boundaries.
# Two inner boundaries are parametric splines, on econstructred from file data and
# the other from given data points. The third curve is a triangular object built from
# three internal straight-sided "curves".
#
# Keywords: spline from file, spline construction, outer boundary, inner boundary

projectName = "spline_boundary"
projectPath = "out"

# Create a new project with the name "spline_boundary", which will also be the
# name of the mesh, plot and stats files, written to output folder `out`.

p = newProject(projectName, projectPath)

# A background grid is required for the mesh generation. In this example we lay a
# background grid of Cartesian boxes with size 0.6 in each direction.

addBackgroundGrid!(p, [0.6, 0.6, 0.0])

# Outer boundary for this example mesh is a complete circle. Add it into the project.

circ = newCircularArcCurve("outerCircle", [0.0, -1.0, 0.0], 4.0, 0.0, 360.0, "degrees")
addCurveToOuterBoundary!(p, circ)

# Inner boundaries will have three curves:
#     (i) Cubic spline curve created from data points read in from a file.
#    (ii) Cubic spline curve created from points directly given in the code.
#   (iii) Triangle shape built from three straight line "curves".

# Create the three interior curves. The curve name are those that are output as the
# given boundary names in the mesh file.

# First inner boundary is a parametric cubic spline read in from a file. For information
# on formatting cubic spline data files see the HOHQMesh documentation:
#   https://trixi-framework.github.io/HOHQMesh/the-model/#the-spline-curve-definition

spline1 = newSplineCurve("big_spline", joinpath(@__DIR__, "test_spline_curve_data.txt"))
addCurveToInnerBoundary!(p, spline1, "inner1")

# Second inner boundary is a parametric cubic spline with data points directly provided
# in the code. These points take the form [t, x, y, z] where `t` is the parameter variable.
# For the spline construction the number of points is included as an input argument as well as
# the actual parametric point data.

spline_data = [ [0.0  1.75 -1.0 0.0]
                [0.25 2.1  -0.5 0.0]
                [0.5  2.7  -1.0 0.0]
                [0.75 0.6  -2.0 0.0]
                [1.0  1.75 -1.0 0.0] ]

spline2 = newSplineCurve("small_spline", 5, spline_data)
addCurveToInnerBoundary!(p, spline2, "inner2")

# Third inner boundary is a triangular shape built from three straight lines "curves".
# The three lines are connected in a counter-clockwise orientation as required by HOHQMesh.
# Note that we give the three inner curves the same name "triangle" that will be the
# boundary name given in the mesh file. The inner boundary chain name `inner3` is used
# internally for HOHQMesh but is not known to the mesh file naming.

edge1 = newEndPointsLineCurve("triangle", [-2.3, -1.0, 0.0], [-1.7, -1.0, 0.0])
edge2 = newEndPointsLineCurve("triangle", [-1.7, -1.0, 0.0], [-2.0, -0.4, 0.0])
edge3 = newEndPointsLineCurve("triangle", [-2.0, -0.4, 0.0], [-2.3, -1.0, 0.0])
addCurveToInnerBoundary!(p, edge1, "inner3")
addCurveToInnerBoundary!(p, edge2, "inner3")
addCurveToInnerBoundary!(p, edge3, "inner3")

# Plot the project model curves and background grid

if isdefined(Main, :Makie)
    plotProject!(p, MODEL+GRID)
    @info "Press enter to generate the mesh and update the plot."
    readline()
 else # Throw an informational message about plotting to the user
    @info "To visualize the project (boundary curves, background grid, mesh, etc.), include `GLMakie` and run again."
 end

# Generate the mesh. This produces the mesh and TecPlot files `IceCreamCone.mesh` and `IceCreamCone.tec`
# and saves them to the `out` folder. Also, if there is an active plot in the project `p` it is
# updated with the mesh that was generated.

generate_mesh(p)

# After the mesh successfully generates mesh statistics, such as the number of corner nodes,
# the number of elements etc., are printed to the REPL.