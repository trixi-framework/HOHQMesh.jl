# Interactive mesh from a HOHQMesh control file
#
# Reads in the `AllFeatures.control` file, creates a `HQMTool` project,
# and generates a mesh file. More details about the outer / inner boundary
# curves, refinement regions, etc. of HOHQMesh can be found in its documentation
# https://trixi-framework.github.io/HOHQMesh/
#
# Keywords: outer boundary chain, inner boundary chain, refinement region, control file read in

using HOHQMesh

# Set the file path of the control file to be read in for this example

all_features_control_file = joinpath( HOHQMesh.examples_dir() , "AllFeatures.control" )

# Read in the HOHQMesh control file and create the project dictionary that stores
# the different components of a mesh, i.e., boundary curves, refinement regions, etc.
# as well as set the output folder where any generated files will be saved.

p = openProject(all_features_control_file, "out")

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