# [Overview](@id InteractiveTool)

The interactive functionality is an API to generate a quadrilateral (future: hexahedral)
mesh using Julia.
It serves as a front end to the HOHQMesh program, and is designed to let one build a
meshing project interactively while graphically displaying the results.

Several scripts are available in the `examples/` folder
to get you started. These example scripts follow the naming convention of `interactive_*` where
the phrase interactive indicates their association with this API and then trailing information
will indicate what that script demonstrates. For instance, the file `interactive_spline_curves.jl`
provides an interactive project that creates an manipulates splines for the inner boundaries before
generating the mesh.

Below we provide a broad overview of the interactive mesh workflow. Further clarification on
this workflow is provided in the [Guided tour](@ref). Several [Tutorials](@ref)
are also available to demonstrate this functionality.

## Workflow and basic moves

The order of the workflow and basic moves follow a logical pattern: The project must be created first.
Curves can be added at any time. The background grid can be added any time to the project.
A mesh is usually generated after the model (curves) and background grid are completed.

To generate a mesh interactively you

1. Create a project with a user given `projectName` and `folder` where any generated files are to be saved

   ```
   p = newProject(<projectName>, <folder>)
   ```

   Both of these input arguments are strings.

2. Create inner and outer boundary curves from the available types

   ```
   c = newEndPointsLineCurve(<name>, startLocation [x, y, z], endLocation [x, y, z])                               *Straight Line*
   c = newCircularArcCurve(<name>, center [x, y, z], radius, startAngle, endAngle, units = "degrees" or "radians") *Circular Arc*
   c = newParametricEquationCurve(<name>, xEqn, yEqn, zEqn)                                                        *Parametric equation*
   c = newSplineCurve(<name>, dataFile)                                                                            *Spline with data from a file*
   c = newSpline(<name>, nKnots, knotsMatrix)                                                                      *Spline with given knot values*
   ```

   See [Defining curves](@ref) for further details on the different curve type currently supported by HOHQMesh.

   The generic name for each of these curve creation methods is `new!`. The generic can be used instead of the longer descriptive name to save typing during interactive sessions, if desired.

3. Add curves to build the model to see what you have added,

   ```
   addOuterBoundaryCurve!(p, <curveName>)                      *Add outer boundary curve*
   addInnerBoundaryCurve!(p, <curveName>, <InnerBoundaryName>) *Add curve to an inner boundary*
   ```

   For a single inner / outer boundary curve the command above directly adds the curve into the `Project`.
   If the inner / outer boundary curve is a chain of multiple curves then they must be added to the `Project`
   in an order which yields a closed curves with counter-clockwise orientation.
   See the [Guided tour](@ref) for an example of a chain of curves.

   Curves can be added by using the generic `add!` function instead of the longer descriptive
   name to save typing during interactive sessions, if desired.

4. Visualize the project's model, if desired

   ```
   plotProject!(p, MODEL)
   ```

   Plots are updated in response to user interactions. However, to update the plot at any time, use

   ```
   updatePlot!(p, options)
   ```

   Options are `MODEL`, `GRID`, `MESH`, and `REFINEMENTS`. To plot combinations, sum the options, e.g.
   `MODEL`+`GRID` or `MODEL`+`MESH`. You normally are not interested in the background grid once
   the mesh is generated.

   !!! note "Visualization requirement"
       The interactive functionality uses [Makie.jl](https://github.com/JuliaPlots/Makie.jl/)
       to visualize the `Project` information. Therefore, in addition to HOHQMesh.jl a user must
       load a Makie backend (for example, [GLMakie](https://github.com/JuliaPlots/GLMakie.jl/) or
       [CairoMakie](https://github.com/JuliaPlots/CairoMakie.jl)) if visualization is desired.

5. Set the background grid

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
   [top value, left value, bottom value, right value] and the number of elements in each direction.
   The first exists for historical reasons; the second is probably the easiest to use.

   When an outer boundary is present the background grid can be set as

   ```
   addBackgroundGrid!(p, [dx, dy, dz])
   ```

   where the spacing controls the number of elements in each direction.

   !!! note "Background grid"
       A background grid is required by HOHQMesh. If one is not present in the `Project`
       and a user attempts to generate the mesh a warning is thrown.

6. Adjust meshing parameters, if desired. For instance, one can adjust the polynomial
   `order` in the `Project` for any curved boundaries by

   ```
   setPolynomialOrder!(p, order)
   ```

   The background grid size can be adjusted where we can set the grid size in the x and y directions,
   `dx` and `dy`, can be set separately

   ```
   setBackgroundGridSize!(p, 0.5, 0.25)
   ```

   See [Controlling the mesh generation](@ref) for details on adjusting parameters already present
   in the `Project`.

7. Generate the mesh

   ```
   generate_mesh(p)
   ```

   The mesh file will be saved in `<folder>` with the name `<projectName>.mesh`. A HOHQMesh control file
   is automatically created from the contents of the `Project` and is also saved in that folder
   with the name `<projectName>.control`. This control file can be read in again later and modified,
   remeshed, etc. The function `generate_mesh` will print the mesh information and statistics, and will
   plot the mesh as in the figure above, if a plot is otherwise visible.
   If not, it can always be plotted with the `plotProject!` command.

## Advanced features

### Optional arguments for mesh generation

The `generate_mesh` function has two optional arguments. The first is the Boolean `verbose`
argument. One can pass `verbose=true` to output additional messages and information during
the meshing process. The second is the integer `subdivision_maximum` argument.
The default value is `subdivision_maximum=8`, meaning that elements can be up
to a factor of `2^8` smaller than the existing background grid.
Note, think before adjusting the `subdivision_maximum` level! It is often the case that
adjusting the boundary curves, background grid size, adding local refinement regions,
or some combination of these adjustments removes the need to adjust the subdivision depth.

### Error controlled mesh adaptation

HOHQMesh automatically sizes elements according to a number of criteria,
including the local radius of curvature of the boundary curves,
the distance between curves, and user-defined refinement regions.

A new experimental feature allows HOHQMesh to adaptively mesh a model
to provide optimal boundary approximations to the model curves with
user-specified smoothness to within a user-defined tolerance.
Refer to the HOHQMesh documentation for an [overview](https://trixi-framework.org/HOHQMesh/error-controlled-adaptive-meshing/)
and [technical details](https://trixi-framework.org/HOHQMesh/boundary-curve-optimization-details/)
of this strategy.

Error control of the boundary curves is done chain-by-chain and can be performed in
the `"OUTER_BOUNDARY"` chain and any one of the `"INNER_BOUNDARIES"`.
This is done by telling HOHQMesh what norm to optimize ($L^2$ or $H^1$), the error tolerance, and to what derivatives the resulting boundary approximation will be smooth.
The keywords (together with their default values) that control this optimization
are given below.
They are present in any `"CHAIN"` dictionary created in HOHQMesh.jl
```julia
   "optimize" = "none"  # options are "L2Norm", "H1Norm" or "none"
   "tolerance" = "1e-3" # accuracy tolerance
   "continuity" = "0"   # highest derivative to be made smooth
   "connect" = "[]"     # see description below
```
More details on the options are:

1. `"optimize"`: Specifies the norm to be minimized. For convenience, `"none"` is provided to deactivate the optimization.
2. `"tolerance"`: The accuracy to which the boundaries are to be approximated.
3. `"continuity"`: The derivatives to which the approximation will be constrained. For example, if second derivative continuity is to be enforced, choose `"continuity" = "2"`. If zero, then the approximation is simply continuous.
4. `"connect"`: This *optional* parameter allows one to optimize across segments of a chain. By default, optimization is done curve by curve within the chain, since usually there will be discontinuities (e.g. corners) between the curves. If it is desired to define a more global approximation across multiple curves, include the `"connect"` key.

 The syntax is the following:
 ```julia
    "connect" = "crv_1-crv_2,crv_3-crv_4,..."
 ```
 where the `crv_n` are the index of the curves in the chain. For example, if a chain contains ten curves and optimization is requested across the third and fourth curves in the list and across the sixth through ninth in the list, then
 ```julia
    "connect" = "3-4,6-9"
 ```

When active, HOHQMesh will then find the best polynomial approximation of each curve
in the chain to the order defined by `polynomial order` in the `"RUN_PARAMETERS"`
of the project (the default polynomial order is `5`).

## Final note

All objects and information contained in the variable type `Project` are actually dictionaries
of type `Dict{String, Any}`.
Since Julia is not an object oriented language, the parameters and other parts of these internal dictionaries
can be accessed and edited directly by key and value.
However, if you do that, then certain features like `undo`/`redo` and automatic plot updating **will not work**.