# Guided tour

In this brief overview, we highlight two scripts from the `examples` folder
that demonstrate the interactive mesh functionality of HOHQMesh.jl. In depth
explanations of the functionality are provided in the [Tutorials](@ref).

See the [HOHQMesh documentation](https://trixi-framework.github.io/HOHQMesh/)
for more details about its terminology and capabilities.

## Mesh from a control file

A first example script reads in an existing control file from the HOHQMesh examples collection
and makes it into a `Project`.
To run this example, execute
```julia
julia> include(joinpath(HOHQMesh.examples_dir(), "interactive_from_control_file.jl"))
```
This command will create mesh and plot files in the `out` directory.

## Build a mesh from scratch

A second example script `interactive_outer_boundary.jl` makes a new project consisting
of an outer, circular boundary, and an inner boundary in the shape of an ice cream cone.
To run this example, execute
```julia
julia> include(joinpath(HOHQMesh.examples_dir(), "interactive_outer_boundary.jl"))
```

For completeness, we provide the example script and walk-through each step in the construction
of the `Project` below.
```julia
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

# Create the three interior curves. The individual names of each curve in the inner
# chain are used internally by HOHQMesh and are output as the given boundary names in
# the mesh file.

cone1    = newEndPointsLineCurve("cone1", [0.0, -3.0, 0.0], [1.0, 0.0, 0.0])
iceCream = newCircularArcCurve("iceCream", [0.0, 0.0, 0.0], 1.0, 0.0, 180.0, "degrees")
cone2    = newEndPointsLineCurve("cone2", [-1.0, 0.0, 0.0], [0.0, -3.0, 0.0])

# Assemble the three curve in a closed chain oriented counter-clockwise. The chain
# name `IceCreamCone` is only used internally by HOHQMesh.

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
# the number of elements etc., are printed to the REPL
```
The first line creates a new project, where the mesh and plot file names will be derived
from the project name, "IceCreamCone" written to the specified folder.

To develop the model, one adds curves to the outer boundary or to multiple inner boundaries,
if desired. As in HOHQMesh, there are four curve classes currently available:

- Parametric equations
- Cubic Splines
- Lines defined by their end points
- Circular arcs

In the example, the outer boundary is a closed circular arc with center at [0.0, 0.0, 0.0]
with radius 4, starting at zero and ending at 360 degrees. It is added to the project with
`addCurveToOuterBoundary!`. You can add any number of curves to the outer boundary.

Similarly, you create curves and add them to as many inner boundaries that you want to have.
In the example, there is one inner boundary, "IceCreamCone" made up of two straight lines and a half
circular arc. Again, they are defined counter-clockwise.

For convenience, `newProject` will generate default run parameters used by HOHQMesh, like the plot file format
and the smoother. The parameters can be edited with setter commands. For example, the script
sets the polynomial order (default = 5) and the plot file format (default = "skeleton").

One run parameter that must be set manually is the background grid. Since there is an outer
boundary, that determines the extent of the domain to be meshed, so only the mesh size needs
to be specified using
```
addBackgroundGrid!(proj::Project, bgSize::Array{Float64})
```

The example sets the background mesh size to be 0.1 in the x and y directions.
The z component is ignored.

The script finishes by generating the quad mesh and plotting the results, as shown below

![iceCreamCone](https://user-images.githubusercontent.com/25242486/162193980-b80fb92c-2851-4809-af01-be856152514f.png)

Finally, the script returns the project so that it can be edited further, if desired.

To save a control file for HOHQMesh, simply invoke
```
saveProject(proj::Project, outFile::String)
```
where `outFile` is the name of the control file (traditionally with a .control extension).
`saveProject` is automatically called when a mesh is generated.

Note, a third example script `interactive_outer_boundary_generic.jl` is identical to that
which was explained above except that the function calls use the generic versions of
functions, e.g., `new` or `add!`.
