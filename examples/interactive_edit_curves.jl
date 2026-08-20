# Interactive mesh with modified outer and inner curve chains
#
# Create inner / outer boundary chains composed of the four
# available HOHQMesh curve types.
#
# Keywords: outer boundary, inner boundary, parametric equations,
#           circle arcs, cubic spline, curve removal
using HOHQMesh

# Instantiate the project
sandbox_project = newProject("sandbox", "out")

# Add the background grid
addBackgroundGrid!(sandbox_project, [1.0, 1.0, 0.0])

# Create and add the original outer boundary curves
outer_line1 = newEndPointsLineCurve("Line1", [0.0, -7.0, 0.0], [5.0,  3.0, 0.0])
outer_line2 = newEndPointsLineCurve("Line2", [-5.0, 3.0, 0.0], [0.0, -7.0, 0.0])
outer_arc = newCircularArcCurve("Arc",  [0.0, 3.0, 0.0], 5.0, 0.0, 180.0, "degrees")

addCurveToOuterBoundary!(sandbox_project, outer_line1)
addCurveToOuterBoundary!(sandbox_project, outer_arc)
addCurveToOuterBoundary!(sandbox_project, outer_line2)

# Modify the outer boundary to have a spline instead of a straight line
removeOuterBoundaryCurveWithName!(sandbox_project, "Line2")

spline_data = [ [0.0  -5.0  3.0 0.0]
                [0.25 -2.0  1.0 0.0]
                [0.5  -4.0  0.5 0.0]
                [0.75 -2.0 -3.0 0.0]
                [1.0   0.0 -7.0 0.0] ]
outer_spline = newSplineCurve("Spline", 5, spline_data)
addCurveToOuterBoundary!(sandbox_project, outer_spline)

# Create and add the inner boundary curves
inner_line1 = newEndPointsLineCurve("Line1", [1.0, 3.0, 0.0], [1.0, 5.0, 0.0])
inner_line2 = newEndPointsLineCurve("Line2", [-1.0, 5.0, 0.0], [-1.0, 3.0, 0.0])
inner_bottom_arc = newCircularArcCurve("BottomArc", [0.0, 3.0, 0.0], 1.0, -pi, 0.0, "radians")
inner_top_arc = newCircularArcCurve("TopArc", [0.0, 5.0, 0.0], 1.0, 0.0, 180.0, "degrees")

addCurveToInnerBoundary!(sandbox_project, inner_line1, "inner")
addCurveToInnerBoundary!(sandbox_project, inner_top_arc, "inner")
addCurveToInnerBoundary!(sandbox_project, inner_line2, "inner")
addCurveToInnerBoundary!(sandbox_project, inner_bottom_arc, "inner")

# Plot the project model curves and background grid
if isdefined(Main, :Makie)
   plotProject!(sandbox_project, MODEL+GRID; figureSize = (800, 700))
   @info "Press enter to generate the mesh and update the plot."
   readline()
else # Throw an informational message about plotting to the user
   @info "To visualize the project (boundary curves, background grid, mesh, etc.), include `GLMakie` and run again."
end

# Generate a mesh
generate_mesh(sandbox_project)

println()
@info "Press enter to remove the mesh and modify the boundary curves."
readline()

# Delete the existing mesh before modifying the inner boundary curve chain
remove_mesh!(sandbox_project)

# Modify the inner boundary curve with an oscillatory line and a new circle arc
removeInnerBoundaryCurve!(sandbox_project, "Line1", "inner")
removeInnerBoundaryCurve!(sandbox_project, "BottomArc", "inner")

xEqn = "x(t) = 2 - t"
yEqn = "y(t) = -2 * (1 - t) + 5 - 1.5 * cos(pi * (1 - t)) * sin(pi * (1 - t))"
zEqn = "z(t) = 0.0"
inner_eqn = newParametricEquationCurve("wiggleLine", xEqn, yEqn, zEqn)

new_bottom_arc = newCircularArcCurve("wideBottomArc", [0.5, 3.0, 0.0], 1.5, -pi, 0.0, "radians")

addCurveToInnerBoundary!(sandbox_project, inner_eqn, "inner")
addCurveToInnerBoundary!(sandbox_project, new_bottom_arc, "inner")

# Update the plot of the project model curves and background grid
if isdefined(Main, :Makie)
   updatePlot!(sandbox_project, MODEL+GRID)
   @info "Press enter to generate the mesh and update the plot."
   readline()
else # Throw an informational message about plotting to the user
   @info "To visualize the project (boundary curves, background grid, mesh, etc.), include `GLMakie` and run again."
end

# Regenerate the final mesh
generate_mesh(sandbox_project)
