# HQMTool

HQMTool is an API to generate a quadrilateral (Future: hexahedral) mesh using Julia.
It serves as a front end to the HOHQMesh program, and is designed to let one build a
meshing project interactively while graphically displaying the results.

## [Introduction](@id HQMTool-Introduction)

Several examples are available in the `examples` folder
to get you started. These example scripts follow the naming convention of `interactive_*` where
the phrase interactive indicates their association with HQMTool and then trailing information
will indicate what that interactive demonstrates. For instance, the file `interactive_splines.jl`
provides an interactive project that creates an manipulates splines for the inner boundaries before
generating the mesh.

Below we highlight three fundamental scripts that demonstrate the functionality of HQMTool. More in depth
explanations of the functionality is provided in the tutuorials TODO: ADD LINK

First is a basic example script that reads in an existing control file from the HOHQMesh examples collection.
To run that example, execute
```julia
   include(joinpath(HOHQMesh.examples_dir(), "interactive_from_control_file.jl"))
```
This command will create mesh and plot files in the `out` directory.

The second example `interactive_outer_boundary.jl` builds a new project consisting of an outer,
circular boundary, and an inner boundary in the shape of an ice cream cone.
The "verbose" example script, where all functions arevalled with their full name, is given below.
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
where outFile is the name of the control file (traditionally with a .control extension).
`saveProject` is automatically called when a mesh is generated.

The third example `ice_cream_cone_demo` is identical to that which was explained above
except that the function calls use the generic versions of functions, e.g., `new` or `add!`.

Methods are available to edit a model. For example to move the center of the outer boundary.

## Basic Moves

To generate a mesh using HQMTool you

1. [Create a project](#newProject)

   ```
   p = newProject(<projectName>,<folder>)
   ```

2. [Create inner and outer boundary curves](#DefiningCurves)

   ```
   c = newEndPointsLineCurve(<name>, startLocation [x, y, z], endLocation [x, y, z])                               *Straight Line*
   c = newCircularArcCurve(<name>, center [x, y, z], radius, startAngle, endAngle, units = "degrees" or "radians") *Circular Arc*
   c = newParametricEquationCurve(<name>, xEqn, yEqn, zEqn)                                                        *Parametric equation*
   c = newSplineCurve(<name>, dataFile)                                                                            *Spline with data from a file*
   c = newSpline(<name>, nKnots, knotsMatrix)                                                                      *Spline with given knot values*
   ```

The generic name for each of these curve creation methods is `new!. The generic can be used instead of the longer descriptive name to save typing during interactive sessions, if desired.


3. [Add curves](#AddingCurves) to build the model to see what you have added,

   ```
   addOuterBoundaryCurve!(p, <curveName>)                      *Add outer boundary curve*
   addInnerBoundaryCurve!(p, <curveName>, <InnerBoundaryName>) *Add curve to an inner boundary*
   ```
Curves can be added by using the generic `add!` function instead of the longer descriptive name to save typing during interactive sessions, if desired.

4. To [visualize](#Plotting) the project's model,

   ```
   plotProject!(p, MODEL)
   ```

   Plots are updated in response to user interactions. However, to update the plot at any time, use

   ```
   updatePlot!(p, options)
   ```

   Options are `MODEL`, `GRID`, `MESH`, and `REFINEMENTS`. To plot combinations, sum the options, e.g.
   `MODEL`+`GRID` or `MODEL`+`MESH`. (You normally are not interested in the background grid once
   the mesh is generated.)

5. Set the [background grid](#(#BackgroundGrid))

   When no outer boundary curve is present, the background grid can be set with

   ```
   addBackgroundGrid!(p, lower left [x,y,z], spacing [dx,dy,dz], num Intervals [nX,nY,nZ])
   ```

   Or

   ```
   addBackgroundGrid!(p, [top value, left value, bottom value, right value], num Intervals [nX,nY,nZ])
   ```

   The first method creates the rectangular boundary with extent `[x0[1], x0[1] + N*dx[1]]` by
   `[x0[2], x0[2] + N*dx[2]]`. The second method sets a rectangular bounding box with extent
   [top value, left value, bottom value, right value] and the number of elements in each direction. The first exists for historical reasons; the second is probably the easiest to use.

   When an outer boundary is present the background grid can be set as

   ```
   addBackgroundGrid!(p,[dx,dy,dz])
   ```

   where the spacing controls the number of elements in each direction.

6. [Adjust parameters](#RunParameters), if desired

   ```
   setPolynomialOrder!(p,order)
   ```

7. Generate the mesh

   ```
   generate_mesh(p)
   ```

The mesh will be stored in `<folder>` with the name `<projectName>.mesh`. The control file will also be
saved in that folder with the name `<projectName>.control`, which you can read in again later and modify,
remesh, etc. The function will print the mesh information and statistics, and will plot the mesh as in
the figure above, if a plot is otherwise visible. If not, it can always be plotted with the `plotProject!`
command.

The ordering of the basic moves follows a logical pattern: The project must be created first.
Curves can be added at any time. The background grid can be added any time to the project.
A mesh is ususally generated after the model (curves) and background grid are completed.

## Advanced

All curves are actually dictionaries of type `Dict{String, Any}`, and since Julia is not a particularly object oriented language,
the parameters can be accessed and edited directly by key and value. In fact, all objects except for the Project,
are of type `Dict{String, Any}`. The project holds all the control and model objects in its `projectDirectory`.
However, if you do that, then undo/redo and plot updating won't happen.