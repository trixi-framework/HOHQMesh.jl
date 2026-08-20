# Interactive mesh with reflection on the left over a single symmetry boundary
# as well as a reflection on the right over multiple co-linear symmetry boundaries.
#
# Keywords: outer boundary, reflection, symmetric mesh
using HOHQMesh

# new project
symmetric_mesh = newProject("symmetric_mesh", "out")

# reset the polynomial degree of the mesh
setPolynomialOrder!(symmetric_mesh, 6)

# A background grid is required for the mesh generation
addBackgroundGrid!(symmetric_mesh, [0.25, 0.25, 0.0])

# Create all the outer boundary curves and add them to the mesh project.
# Note: (1) Curve names are those that will be present in the mesh file
#       (2) Boundary named ":symmetry" is where reflection occurs

line1 = newEndPointsLineCurve(":symmetry", [-0.05, 2.0, 0.0],
                                           [-0.05, 0.0, 0.0])

line2 = newEndPointsLineCurve("bottom", [-0.05, 0.0, 0.0],
                                        [1.0, 0.0, 0.0])

line3 = newEndPointsLineCurve("right", [1.0, 0.0, 0.0],
                                       [1.0, 0.5, 0.0])

half_circle = newCircularArcCurve("circle",         # curve name
                                  [1.0, 0.75, 0.0], # circle center
                                  0.25,             # circle radius
                                  270.0,            # start angle
                                  90.0,             # end angle
                                  "degrees")        # angle units

line4 = newEndPointsLineCurve("right", [1.0, 1.0, 0.0],
                                       [1.0, 1.5, 0.0])

line5 = newEndPointsLineCurve("bump", [1.0, 1.5, 0.0],
                                      [0.75, 1.5, 0.0])

line6 = newEndPointsLineCurve("bump", [0.75, 1.5, 0.0],
                                      [0.75, 1.75, 0.0])

line7 = newEndPointsLineCurve("bump", [0.75, 1.75, 0.0],
                                      [1.0, 1.75, 0.0])

line8 = newEndPointsLineCurve("right", [1.0, 1.75, 0.0],
                                       [1.0, 2.0, 0.0])

line9 = newEndPointsLineCurve("top", [1.0, 2.0, 0.0],
                                     [-0.05, 2.0, 0.0])

addCurveToOuterBoundary!(symmetric_mesh, line1)
addCurveToOuterBoundary!(symmetric_mesh, line2)
addCurveToOuterBoundary!(symmetric_mesh, line3)
addCurveToOuterBoundary!(symmetric_mesh, half_circle)
addCurveToOuterBoundary!(symmetric_mesh, line4)
addCurveToOuterBoundary!(symmetric_mesh, line5)
addCurveToOuterBoundary!(symmetric_mesh, line6)
addCurveToOuterBoundary!(symmetric_mesh, line7)
addCurveToOuterBoundary!(symmetric_mesh, line8)
addCurveToOuterBoundary!(symmetric_mesh, line9)

# Plot the project model curves and background grid

if isdefined(Main, :Makie)
    plotProject!(symmetric_mesh, MODEL+GRID; figureSize = (900, 600))
    @info "Press enter to generate the mesh and update the plot."
    readline()
 else # Throw an informational message about plotting to the user
    @info "To visualize the project (boundary curves, background grid, mesh, etc.), include `GLMakie` and run again."
 end

# Generate the mesh. Saves the mesh file to the directory "out".
generate_mesh(symmetric_mesh)

println()
@info "Press enter to remove the mesh and reflect over the right instead."
readline()

# Delete the existing mesh before modifying boundary names.
remove_mesh!(symmetric_mesh)

# Rename the outer boundaries appropriately to set the symmetry boundary
# on the right composed of multiple co-linear segments.
renameCurve!(symmetric_mesh, ":symmetry", # existing curve name
                             "left")     # new curve name
renameCurve!(symmetric_mesh, "right", ":symmetry")

# Generate the mesh. Saves the mesh file to the directory "out".
generate_mesh(symmetric_mesh)
