# Spline curves

The purpose of this tutorial is to demonstrate how to create an unstructured mesh on
a domain with a curved outer boundary and three inner boundaries.
Two of the inner curves are built from cubic splines. The third inner curve is a
triangular shape built from a chain of three straight line "curves".
The outer boundary, inner boundaries, background grid and mesh
will be visualized for quality inspection.

It provides details and clarification for the script `interactive_spline_curves.jl`
from the [examples](https://github.com/trixi-framework/HOHQMesh.jl/tree/main/examples) folder.

### Synopsis

This tutorial demonstrates how to:
* Create a circular outer boundary curve.
* Add the background grid when an outer boundary curve is present.
* Visualize an interactive mesh project.
* Construct and add parametric spline curves.
* Construct and add an inner boundary chain of straight line segments.

## Initialization

From a Julia REPL we load the HOHQMesh package as well as
[GLMakie](https://github.com/JuliaPlots/GLMakie.jl/), a backend of
[Makie.jl](https://github.com/JuliaPlots/Makie.jl/), to visualize the
curves, mesh, etc. from the interactive tool.
```julia
julia> using GLMakie, HOHQMesh
```
Now we are ready to interactively generate unstructured quadrilateral meshes!

We create a new project with the name `"spline_curves"` and
assign `"out"` to be the folder where any output files from the mesh generation process
will be saved. By default, the output files created by HOHQMesh will carry the same name
as the project. For example, the resulting HOHQMesh control file from this tutorial
will be named `spline_curves.control`.
If the folder `out` does not exist, it will be created automatically in
the current file path.
```julia
spline_project = newProject("spline_curves", "out")
```

## Add the outer boundary

The outer boundary curve for this tutorial is a circle of radius $r=4$ centered at
the point $(0, -1)$.
We define this circular curve with the function `newCircularArcCurve` as follows
```julia
circ = newCircularArcCurve("outerCircle",    # curve name
                           [0.0, -1.0, 0.0], # circle center
                           4.0,              # circle radius
                           0.0,              # start angle
                           360.0,            # end angle
                           "degrees")        # angle units
```
We use `"degrees"` to set the angle bounds, but `"radians"` can also be used.
The name of the curve stored in the dictionary `circ` is assigned to be `"outerCircle"`.
This curve name is also the label that HOHQMesh will give to this boundary curve in the
resulting mesh file.

The new `circ` curve is then added to the `spline_project` as an outer boundary curve with
```julia
addCurveToOuterBoundary!(spline_project, circ)
```

## Add a background grid

HOHQMesh requires a background grid for the mesh generation process. This background grid sets
the base resolution of the desired mesh. HOHQMesh will automatically subdivide from this background
grid near sharp features of any curved boundaries.

For a domain bounded by an outer boundary curve, this background grid is set by indicating the desired
element size in the $x$ and $y$ directions. To start, we set the background grid for `spline_project`
to have elements with side length $0.6$ in each direction
```julia
addBackgroundGrid!(spline_project, [0.6, 0.6, 0.0])
```

We next visualize the outer boundary curve and background grid with the following
```julia
plotProject!(spline_project, MODEL+GRID)
```
Here, we take the sum of the keywords `MODEL` and `GRID` in order to simultaneously visualize
the outer boundary and background grid. The resulting plot is given below. The chain of outer boundary
curves is called `"Outer"` and it contains a single curve `"outerCircle"` labeled in the figure by `O.1`.

![background_grid](https://user-images.githubusercontent.com/25242486/174798948-3a00c5b5-d910-45df-9a9a-088eb3fa360a.png)

## Add the inner boundaries

The domain of this tutorial will contain three inner boundary curves:
1. Cubic spline curve created from data points read in from a file.
2. Cubic spline curve created from points directly given in the code.
3. Triangular shape built from three straight line "curves".

### Cubic spline with data from a file

A parametric cubic spline curve can be constructed from a file of data points. The first line
of this plain text file must indicate the number of nodes. Then line-by-line the file contains
the knots $t_j$, $x_j$, $y_j$, $z_j$ where $j$ indexes the number of nodes.
If the spline curve is to be closed. The last data point must be the same as the first.
For examples, see the
[HOHQMesh documentation](https://trixi-framework.github.io/HOHQMesh/the-model/#the-spline-curve-definition)
or open the file `test_spline_curve_data.txt` in the
[examples](https://github.com/trixi-framework/HOHQMesh.jl/tree/main/examples) folder

We create a parametric spline curve from a file with
```julia
spline1 = newSplineCurve("big_spline", joinpath(@__DIR__, "examples", "test_spline_curve_data.txt"))
```
The name of the curve stored in the dictionary `spline1` is assigned to be `"big_spline"`.
This curve name is also the label that HOHQMesh will give to this boundary curve in the
resulting mesh file.

The new `spline1` curve is then added to the `spline_project` as an inner boundary curve with
```julia
addCurveToInnerBoundary!(spline_project, spline1, "inner1")
```
This inner boundary chain name `"inner1"` is used internally by HOHQMesh. The visualization
of the background grid automatically detects that a curve has been added to the project
and the plot is updated appropriately, as shown below. The chain for the inner boundary
curve is called `inner1` and it contains a single curve `"big_spline"` labeled in the figure by `1.1`.

![one_curve](https://user-images.githubusercontent.com/25242486/174798958-5e4a57b3-ece0-4d11-a004-b39909fccbad.png)

### Cubic spline from data in Julia

Alternatively, a parametric cubic spline curve can be constructed directly from data points
provided in the code. These points take the form `[t, x, y, z]` where `t` is the parameter variable
that varies between $0$ and $1$. For the spline construction, the number of points is included as an
input argument as well as the actual parametric point data.
Again, if the spline curve is to be closed, the first and last data point **must** match.

Below, we construct another parametric spline using this strategy that consists of five data points
```julia
spline_data = [ [0.0  1.75 -1.0 0.0]
                [0.25 2.1  -0.5 0.0]
                [0.5  2.7  -1.0 0.0]
                [0.75 0.6  -2.0 0.0]
                [1.0  1.75 -1.0 0.0] ]

spline2 = newSplineCurve("small_spline", 5, spline_data)
```
The name of the curve stored in the dictionary `spline2` is assigned to be `"small_spline"`.
This curve name is also the label that HOHQMesh will give to this boundary curve in the
resulting mesh file.

The new `spline2` curve is then added to the `spline_project` as an inner boundary curve with
```julia
addCurveToInnerBoundary!(spline_project, spline2, "inner2")
```
This inner boundary chain name `"inner2"` is used internally by HOHQMesh. The visualization
of the background grid automatically detects that a curve has been added to the project
and the plot is updated appropriately, as shown below. The chain for the inner boundary
curve is called `inner2` and it contains a single curve `"small_spline"` labeled in the figure by `2.1`.

![two_curves](https://user-images.githubusercontent.com/25242486/174798962-99e0673d-e0f9-444a-a71d-7dfd9412306e.png)

### Triangular shape

Finally, we build a triangular shaped inner boundary curve built from a chain of three
straight lines. Each line segment is defined using the function `newEndPointsLineCurve`.
We construct the three line segments that define the edges of a triangular shape with
```julia
edge1 = newEndPointsLineCurve("triangle",        # curve name
                              [-2.3, -1.0, 0.0], # start point
                              [-1.7, -1.0, 0.0]) # end point

edge2 = newEndPointsLineCurve("triangle",        # curve name
                              [-1.7, -1.0, 0.0], # start point
                              [-2.0, -0.4, 0.0]) # end point

edge3 = newEndPointsLineCurve("triangle",        # curve name
                              [-2.0, -0.4, 0.0], # start point
                              [-2.3, -1.0, 0.0]) # end point
```
Here, each edge of the curve is given the same name `"triangle"` as this curve name
is also the label that HOHQMesh will give to this boundary curve in the
resulting mesh file.

The three line segments `edge1`, `edge2`, and `edge3` are connected in a
counter-clockwise orientation as required by HOHQMesh.
```julia
addCurveToInnerBoundary!(spline_project, edge1, "inner3")
addCurveToInnerBoundary!(spline_project, edge2, "inner3")
addCurveToInnerBoundary!(spline_project, edge3, "inner3")
```
The inner boundary chain name `"inner3"` is used internally for HOHQMesh. Again,
the active visualization automatically detects that new curves have been added to the project
and the plot is updated appropriately, as shown below. The chain for the inner triangular boundary
is called `inner3` and it contains a three curve segments all called `"triangle"` labeled in the figure
by `3.1`, `3.2`, and `3.3`.

![three_curves](https://user-images.githubusercontent.com/25242486/174798968-d41d7d8e-db1e-466f-a4fa-c36f14dfae98.png)

## Generate the mesh

With the background grid, outer boundary curve, and all inner boundary curves added to the `spline_project` we are ready to generate the mesh.
This will output the following files to the `out` folder:

* `spline_curves.control`: A HOHQMesh control file for the current project.
* `spline_curves.tec`: A TecPlot formatted file to visualize the mesh with other software, e.g., [ParaView](https://www.paraview.org/).
* `spline_curves.mesh`: A mesh file with format `ISM-V2` (the default format).

To do this we execute the command
```julia
generate_mesh(spline_project)
           1  chevron elements removed from mesh.
           1  chevron elements removed from mesh.

 *******************
 2D Mesh Statistics:
 *******************
    Total time             =   0.29613000000000000
    Number of nodes        =         1177
    Number of Edges        =         2225
    Number of Elements     =         1047
    Number of Subdivisions =            4

 Mesh Quality:
         Measure         Minimum         Maximum         Average  Acceptable Low Acceptable High       Reference
     Signed Area      0.00006214      0.15607014      0.04505181      0.00000000    999.99900000      1.00000000
    Aspect Ratio      1.00008989      2.78073390      1.23192911      1.00000000    999.99900000      1.00000000
       Condition      1.00000055      3.81350981      1.15526066      1.00000000      4.00000000      1.00000000
      Edge Ratio      1.00014319      6.76310951      1.46264239      1.00000000      4.00000000      1.00000000
        Jacobian      0.00001495      0.10424741      0.03955903      0.00000000    999.99900000      1.00000000
   Minimum Angle     37.25504203     89.96195708     74.41060580     40.00000000     90.00000000     90.00000000
   Maximum Angle     90.03105286    157.27881545    107.90994073     90.00000000    135.00000000     90.00000000
       Area Sign      1.00000000      1.00000000      1.00000000      1.00000000      1.00000000      1.00000000
```
The call to `generate_mesh` also prints mesh quality statistics to the screen.
HOHQMesh also reports mesh clean-up that occurred during the generation process, in this case the removal of
"bad" chevron shaped elements that were present within the automatic subdivision procedure.
The visualization updates automatically and the background grid is *removed* after when the mesh is generated.

!!! note "Mesh visualization"
    Currently, only the "skeleton" of the mesh is visualized. Thus, the high-order curved boundary information
    is not seen in the plot but this information **is present** in the generated mesh file.

![final_spline](https://user-images.githubusercontent.com/25242486/174798986-6b900fa8-840c-4c04-bc61-00f0749af1be.png)

Inspecting the mesh we see that the automatic subdivision in HOHQMesh does well to capture the fine features
of the curved inner boundaries, particularly near the sharp angles of the `"big_spline"` curve. We decide that we
are satisfied with the overall mesh quality.

## Summary

In this tutorial we demonstrated how to:
* Create a circular outer boundary curve.
* Add the background grid when an outer boundary curve is present.
* Visualize an interactive mesh project.
* Construct and add parametric spline curves.
* Construct and add an inner boundary chain of straight line segments.