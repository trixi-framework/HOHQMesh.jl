# Curved outer boundary

The purpose of this tutorial is to demonstrate how to create an unstructured mesh on
a domain with a curved outer boundary. This outer boundary curve is defined by
parametric equations and contains fine features as well as smooth regions.

The outer boundary, background grid and mesh
are visualized for quality inspection. The tutorial also shows how to adjust the
background and add a local refinement region in order to better resolve a portion
of the curved boundary.

### Synopsis

This tutorial demonstrates how to:
* Define a curved outer boundary using parametric equations.
* Add and adjust the background grid.
* Visualize an interactive mesh project.
* Add manual refinement to a local region of the domain.

## Initialization

From a Julia REPL we load the HOHQMesh package as well as
[GLMakie](https://github.com/JuliaPlots/GLMakie.jl/), a backend of
[Makie.jl](https://github.com/JuliaPlots/Makie.jl/), to visualize the
boundary curve, mesh, etc. from the interactive tool.
```julia
julia> using GLMakie, HOHQMesh
```
Now we are ready to interactively generate unstructured quadrilateral meshes!

We create a new project with the name `"TheBlob"` and
assign `"out"` to be the folder where any output files from the mesh generation process
will be saved. By default, the output files created by HOHQMesh will carry the same name
as the project. For example, the resulting mesh file from this tutorial will be named
`TheBlob.mesh`.
If the folder `out` does not exist, it will be created automatically in
the current file path.
```julia
blob_project = newProject("TheBlob", "out")
```

## Add the outer boundary

The outer boundary curve for the domain of interest in this tutorial is given by the
parametric equations
```math
  \begin{aligned}
    x(t) &= 4\cos(2 \pi t) - \frac{3}{5}\cos^3(8 \pi t),\\[0.2cm]
    y(t) &= 4\sin(2 \pi t) - \frac{1}{2}\sin^2(11 \pi t),\\[0.2cm]
    z(t) &= 0
  \end{aligned}
  \qquad
  t\in[0,1]
```
Parametric equations in HOHQMesh can be any legitimate equation and use intrinsic functions
available in Fortran, e.g., $\sin$, $\cos$, exp.
The constant `pi` is available for use. Exponentiation is done with `^`.
All number literals are interpreted as floating point numbers.

The following commands create a new curve for the parametric equations above
```julia
xEqn = "x(t) = 4 * cos(2 * pi * t) - 0.6 * cos(8 * pi * t)^3"
yEqn = "y(t) = 4 * sin(2 * pi * t) - 0.5 * sin(11* pi * t)^2"
zEqn = "z(t) = 0.0"
blob = newParametricEquationCurve("Blob", xEqn, yEqn, zEqn)
```
The name of this curve is assigned to be `"Blob"`. This name is also the label that HOHQMesh
will give to this boundary curve in the resulting mesh file.

Now that we have created the boundary curve it must be added as an outer boundary
in the `blob_project`.
```julia
addCurveToOuterBoundary!(blob_project, blob)
```

## Add a background grid

HOHQMesh requires a background grid for the mesh generation process. This background grid sets
the base resolution of the desired mesh. HOHQMesh will automatically subdivide from this background
grid near sharp features of any curved boundaries.

For a domain bounded by an outer boundary curve, this background grid is set by indicating the desired
element size in the $x$ and $y$ directions. To start, we set the background grid for `blob_project` to
have elements with side length two in each direction
```julia
addBackgroundGrid!(blob_project, [2.0, 2.0, 0.0])
```

We next visualize the outer boundary curve and background grid with the following
```julia
plotProject!(blob_project, MODEL+GRID)
```
Here, we take the sum of the keywords `MODEL` and `GRID` in order to simultaneously visualize
the curves and background grid. The resulting plot is given below. The chain of outer boundary
curves is called `"Outer"` and it contains a single curve `"Blob"` labeled in the figure by `O.1`.

![coarse_grid](https://user-images.githubusercontent.com/25242486/174747035-f21bb8d1-386f-4036-b2e8-59e264c071d1.png)

From the visualization we see that the background grid is likely too coarse to produce a "good"
quadrilateral mesh for this domain. We reset the background grid size to have elements with
size one half in each direction
```julia
setBackgroundGridSize!(blob_project, 0.5, 0.5)
```
Note, that after we execute the command above the visualization updates automatically with the
outer boundary curve and the new background grid.

![fine_grid](https://user-images.githubusercontent.com/25242486/174747046-f1bc9734-ef4e-4e4c-9055-c54ebe1537e7.png)

The new background grid that gives a finer initial resolution looks suitable to continue
to the mesh generation.

## Initial mesh and user adjustments

We next generate the mesh from the information contained in the `blob_project`.
This will output the following files to the `out` folder:

* `TheBlob.control`: A HOHQMesh control file for the current project.
* `TheBlob.tec`: A TecPlot formatted file to visualize the mesh with other software, e.g., [ParaView](https://www.paraview.org/).
* `TheBlob.mesh`: A mesh file with format `ISM-V2` (the default format).

To do this we execute the command
```julia
generate_mesh(blob_project)

 *******************
 2D Mesh Statistics:
 *******************
    Total time             =   0.10612399999999998
    Number of nodes        =          481
    Number of Edges        =          895
    Number of Elements     =          417
    Number of Subdivisions =            5

 Mesh Quality:
         Measure         Minimum         Maximum         Average  Acceptable Low Acceptable High       Reference
     Signed Area      0.00025346      0.36181966      0.11936327      0.00000000    999.99900000      1.00000000
    Aspect Ratio      1.00002883      2.58066393      1.26340310      1.00000000    999.99900000      1.00000000
       Condition      1.00000000      3.11480166      1.18583253      1.00000000      4.00000000      1.00000000
      Edge Ratio      1.00006177      4.80707901      1.51313656      1.00000000      4.00000000      1.00000000
        Jacobian      0.00011326      0.28172540      0.10292251      0.00000000    999.99900000      1.00000000
   Minimum Angle     29.30873612     89.99827738     73.08079323     40.00000000     90.00000000     90.00000000
   Maximum Angle     90.00132792    156.87642432    109.37004979     90.00000000    135.00000000     90.00000000
       Area Sign      1.00000000      1.00000000      1.00000000      1.00000000      1.00000000      1.00000000
```
The call to `generate_mesh` also prints mesh quality statistics to the screen and updates the
visualization. The background grid is *removed* from the visualization when the mesh is generated.

!!! note "Mesh visualization"
    Currently, only the "skeleton" of the mesh is visualized. Thus, the high-order curved boundary information
    is not seen in the plot but this information **is present** in the generated mesh file.

![initial_blob](https://user-images.githubusercontent.com/25242486/174747052-d0776ca6-5451-4d9f-accb-8d97b2db1c26.png)

Inspecting the mesh we see that the automatic subdivision in HOHQMesh does well to capture the fine features
of the curved outer boundary. Although, we see that the mesh near the point $(-4, 0)$ is still quite coarse.
To remedy this we manually add a `RefinementCenter` near this region of the domain to force HOHQMesh to increase
the resolution in this area. We create and add this refinement region to the current project with
```julia
center = newRefinementCenter("region", "smooth", [-4.0, -0.5, 0.0], 0.4, 1.0)
addRefinementRegion!(blob_project, center)
```
Above we create a circular refinement region centered at the point $(-4, -0.5)$ with a desired resolution size
$0.4$ and a radius of $1.0$. Upon adding this refinement region to `blob_project`, the visualization will
update to indicate the location and size of the manual refinement region.

![refinement_blob](https://user-images.githubusercontent.com/25242486/174747059-1f58ae14-aeec-48d5-afb3-6a0614a8e29d.png)

## Final mesh

With the refinement region added to the project we can regenerate the mesh. Note, this will create
and save new output files `TheBlob.control`, `TheBlob.tec`, `TheBlob.mesh` and update the figure.
```julia
generate_mesh(blob_project)

 *******************
 2D Mesh Statistics:
 *******************
    Total time             =   0.11373499999999999
    Number of nodes        =          505
    Number of Edges        =          940
    Number of Elements     =          438
    Number of Subdivisions =            5

 Mesh Quality:
         Measure         Minimum         Maximum         Average  Acceptable Low Acceptable High       Reference
     Signed Area      0.00025346      0.36181966      0.11412658      0.00000000    999.99900000      1.00000000
    Aspect Ratio      1.00002884      2.47585614      1.26424390      1.00000000    999.99900000      1.00000000
       Condition      1.00000000      3.11480166      1.18425870      1.00000000      4.00000000      1.00000000
      Edge Ratio      1.00006177      4.80707901      1.51413601      1.00000000      4.00000000      1.00000000
        Jacobian      0.00011326      0.28172540      0.09814547      0.00000000    999.99900000      1.00000000
   Minimum Angle     29.30873612     89.99827901     72.79596483     40.00000000     90.00000000     90.00000000
   Maximum Angle     90.00132782    156.87642433    109.63912468     90.00000000    135.00000000     90.00000000
       Area Sign      1.00000000      1.00000000      1.00000000      1.00000000      1.00000000      1.00000000
```
Note, the circular region indicating the refinement center is removed from the plot when the mesh is generated.

![final_blob](https://user-images.githubusercontent.com/25242486/174747066-a804bf1d-508a-480d-bde3-47687b402604.png)

Now we decide that we are satisfied with the mesh quality and resolution of the outer boundary curve.

## Summary

In this tutorial we demonstrated how to:
* Define a curved outer boundary using parametric equations.
* Add and adjust the background grid.
* Visualize an interactive mesh project.
* Add manual refinement to a local region of the domain.

For completeness, we include a script with all the commands to generate the mesh displayed in the final image.
Note, we **do not** include the plotting in this script.
```julia
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

# Generate the mesh
generate_mesh(blob_project)
```