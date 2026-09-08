
# Interactive mesh with a curved outer boundary
#
# Create an outer boundary from a set of parametric equations.
# Add manual refinement in a small region around the point (-4, -0.5).
#
# Keywords: outer boundary, parametric equations, refinement center
using HOHQMesh

# Instantiate the project
blob_project = newProject("TheBlob", "out")

# Create and add the outer boundary curve
xEqn = "x(t) = 4 * cos(2 * pi * t) - 0.6 * cos(8 * pi * t)^3"
yEqn = "y(t) = 4 * sin(2 * pi * t) - 0.5 * sin(11* pi * t)^2"
zEqn = "z(t) = 0.0"
blob = newParametricEquationCurve("Blob", xEqn, yEqn, zEqn)
addCurveToOuterBoundary!(blob_project, blob)

# Add the background grid
addBackgroundGrid!(blob_project, [0.5, 0.5, 0.0])

# Create and add the refinement region
center = newRefinementCenter("region", "smooth", [-4.0, -0.5, 0.0], 0.4, 1.0)
addRefinementRegion!(blob_project, center)

# Plot the project model curves and background grid
if isdefined(Main, :Makie)
   plotProject!(blob_project, MODEL+GRID+REFINEMENTS; figureSize = (900, 700))
   @info "Press enter to generate the mesh and update the plot."
   readline()
else # Throw an informational message about plotting to the user
   @info "To visualize the project (boundary curves, background grid, mesh, etc.), include `GLMakie` and run again."
end

# Generate the mesh. This produces the mesh and TecPlot files `TheBlob.mesh` and `TheBlob.tec`
# and saves them to the `out` folder. It also creates a control file `TheBlob.control`.
# If there is an active plot in the project `blob_project` it is updated with the mesh that was generated.
generate_mesh(blob_project)
