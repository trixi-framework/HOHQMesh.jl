# Interactive mesh with an outer boundary constructed by a user
#
# Create a circular outer boundary and an inner ice cream cone shaped boundary
# consisting of three curves, lay a background grid and generate a HOHQMesh
# directly from the project object.
#
# Keywords: outer boundary chain, inner boundary chain, verbose commands

using HOHQMesh

# Create a new project with the name "IceCreamCone", which will also be the
# name of the mesh, plot and stats files, written to output folder `out`.

p = newProject("IceCreamCone", "out")

# Outer boundary for this example mesh is a complete circle. Add it into the project.

circ = newCircularArcCurve("outerCircle", [0.0, -1.0, 0.0], 4.0, 0.0, 360.0, "degrees")
addCurveToOuterBoundary!(p, circ)

# Inner boundary is three curves. Two straight lines and a circular arc.
# Note the three curve are connected to ensure a counter-clockwise orientation
# as required by HOHQMesh

cone1    = newEndPointsLineCurve("cone1", [0.0, -3.0, 0.0], [1.0, 0.0, 0.0])
iceCream = newCircularArcCurve("iceCream", [0.0, 0.0, 0.0], 1.0, 0.0, 180.0, "degrees")
cone2    = newEndPointsLineCurve("cone2", [-1.0, 0.0, 0.0], [0.0, -3.0, 0.0])
addCurveToInnerBoundary!(p, cone1, "IceCreamCone")
addCurveToInnerBoundary!(p, iceCream, "IceCreamCone")
addCurveToInnerBoundary!(p, cone2, "IceCreamCone")

# Adjust some `RunParameters` and overwrite the defaults values. In this case, we
# set a new value for the boundary order polynomial representation and adjust the
# output mesh file format to be `sem`

setPolynomialOrder!(p, 4)
setPlotFileFormat!(p, "sem")

# A background grid is required for the mesh generation. In this example we lay a
# background grid of Cartesian boxes with size 0.5.

addBackgroundGrid!(p, [0.5, 0.5, 0.0])

# To plot the project model curves and the background grid, type `using GLMakie`
# in the REPL session, uncomment this line, and rerun this script

# plotProject!(p, MODEL+GRID)

# Generate the mesh. This produces the mesh and TecPlot files `AllFeatures.mesh` and `AllFeatures.tec`
# and save them to the `out` folder. Also, if there is an active plot in the project `p` it is
# updated with the mesh that was generated.

generate_mesh(p)

# After the mesh sucessfully generates mesh statistics, such as the number of corner nodes,
# the number of elements etc., are printed to the REPL