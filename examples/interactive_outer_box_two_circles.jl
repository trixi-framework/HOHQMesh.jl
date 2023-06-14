# Interactive mesh with a rectangular outer boundary and two circular inner boundaries
#
# Create a domain with two circular inner boundaries and a rectangular outer boundary
# that is straight-sided. Set the output mesh file format to be ABAQUS.
#
# Keywords: Straight-sided outer boundary, inner boundary chain, ABAQUS file format

using HOHQMesh

# Create a new project with the name "box_two_circles", which will also be the
# name of the mesh, plot and stats files, written to output folder `out`.

p = newProject("box_two_circles", "out")

# Adjust some `RunParameters` and overwrite the defaults values. In this case, we
# set a new value for the boundary order polynomial representation and adjust the
# output mesh file format to be `ABAQUS`, which will produce a mesh file
# `box_two_circles.inp`

setPolynomialOrder!(p, 4)
setMeshFileFormat!(p, "ABAQUS")

# Outer boundary for this example mesh will be a rectangular box. For this the user
# can set the lower left most point of the box, the spacing size in each coordinate
# direction `[Δx, Δy, Δz]`, and the number of intervals taken.

lower_left = [0.0, 0.0, 0.0]
spacing = [1.0, 1.0, 0.0]
num_intervals = [30, 15, 0]

# These three quantities set the background grid that is required by HOHQMesh for a given domain.

addBackgroundGrid!(p, lower_left, spacing, num_intervals)

# Inner boundaries for this example will be two circles with different radii.

# A circle with radius 2.0, centered at [4.0, 4.0, 0.0]. Note, we use degrees to set the angle.
# This inner boundary curve name will be written to the mesh file.

circle1 = newCircularArcCurve("circle1", [4.0, 4.0, 0.0], 2.0, 0.0, 360.0, "degrees")

# Add `circle1` into the project as an inner boundary
# This chian name in only used internally by HOHQMesh.

addCurveToInnerBoundary!(p, circle1, "inner1")

# A circle with radius 4.0, centered at [20.0, 9.0, 0.0]. Note, the user can use radians to set the angle.
# This inner boundary curve name will be written to the mesh file.

circle2 = newCircularArcCurve("circle2", [20.0, 9.0, 0.0], 4.0, 0.0, 2.0 * pi, "radians")

# Add `circle2` into the project as an inner boundary
# This chian name in only used internally by HOHQMesh.

addCurveToInnerBoundary!(p, circle2, "inner2")

# Plot the project model curves and background grid

if isdefined(Main, :Makie)
   plotProject!(p, MODEL+GRID)
   @info "Press enter to generate the mesh and update the plot."
   readline()
else # Throw an informational message about plotting to the user
   @info "To visualize the project (boundary curves, background grid, mesh, etc.), include `GLMakie` and run again."
end

# Generate the mesh. This produces the mesh and TecPlot files `AllFeatures.mesh` and `AllFeatures.tec`
# and save them to the `out` folder. Also, if there is an active plot in the project `p` it is
# updated with the mesh that was generated.

generate_mesh(p)

# After the mesh successfully generates mesh statistics, such as the number of corner nodes,
# the number of elements etc., are printed to the REPL.