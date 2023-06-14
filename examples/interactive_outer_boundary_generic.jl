# Interactive mesh with an outer boundary constructed by a user
# using generic function calls
#
# Create a circular outer boundary and an inner ice cream cone shaped boundary
# chain consisting of three curves, lay a background grid and generate a HOHQMesh
# directly from the project object.
#
# In particular, this example highligths available generic functionality for creating
# and adding new curves to a project.
#
# Keywords: outer boundary chain, inner boundary chain, generic functions

using HOHQMesh

# Create a new project with the name "IceCreamCone", which will also be the
# name of the mesh, plot and stats files, written to output folder `out`.

p = newProject("IceCreamCone", "out")

# Outer boundary for this example mesh is a complete circle. Add it into the project.

circ = new("outerCircle", [0.0, -1.0, 0.0], 4.0, 0.0, 2.0 * pi, "radians")
add!(p, circ)

# Inner boundary is three curves. Two straight lines and a circular arc.
# Note the three curve are connected to ensure a counter-clockwise orientation
# as required by HOHQMesh

# Create the three interior curves. The individual names of each curve in the inner
# chain are used internally by HOHQMesh and are output as the given boundary names in
# the mesh file.

cone1    = new("cone1", [0.0,-3.0,0.0], [1.0,0.0,0.0])
iceCream = new("iceCream", [0.0,0.0,0.0], 1.0, 0.0, 180.0, "degrees")
cone2    = new("cone2", [-1.0,0.0,0.0], [0.0,-3.0,0.0])

# Assemble the three curve in a closed chain oriented counter-clockwise. The chain
# name `IceCreamCone` is only used internally by HOHQMesh.

add!(p, cone1, "IceCreamCone")
add!(p, iceCream, "IceCreamCone")
add!(p, cone2, "IceCreamCone")

# A background grid is required for the mesh generation. In this example we lay a
# background grid of Cartesian boxes with size 0.5.

addBackgroundGrid!(p, [0.5,0.5,0.0])

# To plot the project model curves and the background grid, type `using GLMakie`
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