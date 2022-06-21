# Creating and editing curves

The purpose of this tutorial is to demonstrate how to inner and outer boundary
curve chains. By a "chain" we mean a closed curve that is composed of multiple
pieces. It also shows how to modify, remove, and add new pieces to an existing
curve chain. In doing so, the `undo` and `redo` capabilities of the HQMTool are
highlighted. The outer and inner boundary curves, background grid as well as the mesh
will be visualized for quality inspection.

<!-- ## Initialization

From a Julia REPL we load the HOHQMesh package as well as
[GLMakie](https://github.com/JuliaPlots/GLMakie.jl/), a backend of
[Makie.jl](https://github.com/JuliaPlots/Makie.jl/), to visualize the
curves, mesh, etc. from the interactive tool.
```julia
julia> using GLMakie, HOHQMesh
```
Now we are ready to interactively generate unstructured quadrilateral meshes!

We create a new HQMTool project dictionary with the name `"sandbox"` and
assign `"out"` to be the folder where any output files from the mesh generation process
will be saved. By default, the output files created by HOHQMesh will carry the same name
as the project. For example, the resulting HOHQMesh control file from this tutorial
will be named `sandbox.control`.
If the folder `out` does not exist, it will be created automatically in
the current file path.
```julia
sandbox_project = newProject("sandbox", "out")
```

## Add the outer boundary chain

The outer boundary curve chain for this tutorial is composed of three pieces
1. A straight line segment from blah to blah
2. A half-circle arc
3. A straight line segment from blah to blah

 circle of radius $r=4$ centered at
the point $(0, -1 ,0)$.
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

For a domain bounded by an outer boundary curve, this background grid is set by indicating
the desired element size in the $x$ and $y$ directions.
To start, we set the background grid for `sandbox_project`
to have elements with side length one in each direction
```julia
addBackgroundGrid!(sandbox_project, [1.0, 1.0, 0.0])
```

We visualize the outer boundary curve chain and background grid with the following
```julia
plotProject!(sandbox_project, MODEL+GRID)
```
Here, we take the sum of the keywords `MODEL` and `GRID` in order to simultaneously visualize
the outer boundary and background grid. The resulting plot is given below. The chain of outer boundary
curves is called `Outer` and it contains three curve segments `outerLine1`, `outerArc`, and `outerLine2` labeled in the figure by `O.1`, `O.2`, and `O.3`, respectively.

![background_grid](/src/figs/undo-background.png)

## Add an inner boundary chain

## Generate the mesh

## Modify a model curve chain

## Final mesh

## Summary -->

