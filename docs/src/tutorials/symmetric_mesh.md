# Symmetric mesh

The purpose of this tutorial is to demonstrate how to create an unstructured mesh
that is symmetric with respect to a straight line outer boundary as prescribed by the user.
At the end of this tutorial one can find the script necessary to generate the meshes
described herein.

### Synopsis

This tutorial demonstrates how to:
* Indicate a symmetry boundary line.
* Construct an outer boundary with several connected curves.
* Add the background grid when an outer boundary curve is present.
* Rename boundaries in an existing interactive mesh project.
* Visualize an interactive mesh project.

## Initialization

From a Julia REPL we load the HOHQMesh package as well as
[GLMakie](https://github.com/JuliaPlots/GLMakie.jl/), a backend of
[Makie.jl](https://github.com/JuliaPlots/Makie.jl/), to visualize the
curves, mesh, etc. from the interactive tool.
```julia
julia> using GLMakie, HOHQMesh
```
Now we are ready to interactively generate unstructured quadrilateral meshes!

We create a new project with the name `"symmetric_mesh"` and
assign `"out"` to be the folder where any output files from the mesh generation process
will be saved. By default, the output files created by HOHQMesh will carry the same name
as the project. For example, the resulting HOHQMesh control file from this tutorial
will be named `symmetric_mesh.control`.
If the folder `out` does not exist, it will be created automatically in
the current file path.
```julia
symmetric_mesh = newProject("symmetric_mesh", "out")
```

## Adjusting project parameters

When a new project is created it is filled with several default
`RunParameters` such as the polynomial order used to represent curved boundaries
or the mesh file format. These `RunParameters` can be queried and adjusted with
appropriate getter/setter pairs, see [Controlling the mesh generation](@ref)
for more details.

For the `symmetric_mesh` project we query the current values for the polynomial
order and the mesh output format
```julia
julia> getPolynomialOrder(symmetric_mesh)
5

julia> getMeshFileFormat(symmetric_mesh)
"ISM-V2"
```

We change the default polynomial order in the `symmetric_mesh` to be $6$ with a corresponding
setter function
```julia
setPolynomialOrder!(symmetric_mesh, 6)
```

## Add a background grid

HOHQMesh requires a background grid for the mesh generation process. This background grid sets
the base resolution of the desired mesh. HOHQMesh will automatically subdivide from this background
grid near sharp features of any curved boundaries.

For a domain bounded by an outer boundary curve, this background grid is set by indicating the desired
element size in the $x$ and $y$ directions. To start, we set the background grid for `symmetric_mesh`
to have elements with side length $0.25$ in each direction
```julia
addBackgroundGrid!(spline_project, [0.25, 0.25, 0.0])
```

## Add the outer boundary

With the background grid size set, we next build the outer boundary for the present mesh project.
This outer boundary is composed of nine straight line segments and a half circle arc.
The curves will afterwards be added to the mesh project `symmetric_mesh`
in counter-clockwise order as required by HOHQMesh.
```julia
line1 = newEndPointsLineCurve("symmetry", [-0.05, 2.0, 0.0],
                                          [-0.05, 0.0, 0.0])

line2 = newEndPointsLineCurve("bottom", [-0.05, 0.0, 0.0],
                                        [1.0, 0.0, 0.0])

line3 = newEndPointsLineCurve("right", [1.0, 0.0, 0.0],
                                       [1.0, 0.5, 0.0])

half_circle = newCircularArcCurve("circle",         # curve name
                                  [1.0, 0.75, 0.0], # circle center
                                  0.25,             # circle radius
                                  270.0,            # start angle
                                  90.0,             # end angle
                                  "degrees")        # angle units

line4 = newEndPointsLineCurve("right", [1.0, 1.0, 0.0],
                                       [1.0, 1.5, 0.0])

line5 = newEndPointsLineCurve("bump", [1.0, 1.5, 0.0],
                                      [0.75, 1.5, 0.0])

line6 = newEndPointsLineCurve("bump", [0.75, 1.5, 0.0],
                                      [0.75, 1.75, 0.0])

line7 = newEndPointsLineCurve("bump", [0.75, 1.75, 0.0],
                                      [1.0, 1.75, 0.0])

line8 = newEndPointsLineCurve("right", [1.0, 1.75, 0.0],
                                       [1.0, 2.0, 0.0])

line9 = newEndPointsLineCurve("top", [1.0, 2.0, 0.0],
                                     [-0.05, 2.0, 0.0])
```
The given boundary names will also be the element boundary names written to the mesh file. The only exception is the first boundary curve that is given
the name `"symmetry"`. The name of this outer boundary curve is a special keyword
in HOHQMesh that says it is the straight line across which
a reflection will occur.

!!! tip: "Name of the symmetry boundary"
    As noted above, `"symmetry"` is a keyword for the HOHQMesh generator that
    prescribes over which line a reflection of the mesh occurs. The Fortran implementation
    for this keyword in HOHQMesh is not case sensitive. So, within the
    Julia script one can name this reflection boundary line `"symmetry"` or `"Symmetry"`
    or `"SYMMETRY"` or even something strange like `"sYmMeTrY"` and the mesh will still
    generate successfully.

Now that all the outer boundary curves are defined we add them to the `symmetric_mesh`
project in counter-clockwise order
```julia
addCurveToOuterBoundary!(symmetric_mesh, line1)
addCurveToOuterBoundary!(symmetric_mesh, line2)
addCurveToOuterBoundary!(symmetric_mesh, half_circle)
addCurveToOuterBoundary!(symmetric_mesh, line3)
addCurveToOuterBoundary!(symmetric_mesh, line4)
addCurveToOuterBoundary!(symmetric_mesh, line5)
addCurveToOuterBoundary!(symmetric_mesh, line6)
addCurveToOuterBoundary!(symmetric_mesh, line7)
addCurveToOuterBoundary!(symmetric_mesh, line8)
addCurveToOuterBoundary!(symmetric_mesh, line9)
```

We visualize the outer boundary curve chain and background grid with the following
```julia
plotProject!(symmetric_mesh, MODEL+GRID)
```
Here, we take the sum of the keywords `MODEL` and `GRID` in order to simultaneously visualize
the outer boundary and background grid. The resulting plot is given below. The chain of outer boundary
curves is called `"Outer"` and its constituent curve segments are labeled accordingly with the names
prescribed in the curve construction above.

![before_generation](https://github.com/trixi-framework/HOHQMesh.jl/assets/25242486/d332e86a-f958-4362-81b9-2ad40a408d94)

## Generate the mesh

We next generate the mesh from the information contained in `symmetric_mesh`.
This will output the following files to the `out` folder:

* `symmetric_mesh.control`: A HOHQMesh control file for the current project.
* `symmetric_mesh.tec`: A TecPlot formatted file to visualize the mesh with other software, e.g., [ParaView](https://www.paraview.org/).
* `symmetric_mesh.mesh`: A mesh file with format `ISM-V2` (the default format).

To do this we execute the command
```julia
generate_mesh(symmetric_mesh)

 *******************
 2D Mesh Statistics:
 *******************
    Total time             =    4.0154999999999996E-002
    Number of nodes        =          343
    Number of Edges        =          626
    Number of Elements     =          284
    Number of Subdivisions =            2

 Mesh Quality:
         Measure         Minimum         Maximum         Average  Acceptable Low Acceptable High       Reference
     Signed Area      0.00227157      0.06552808      0.01366911      0.00000000    999.99900000      1.00000000
    Aspect Ratio      1.00389317      2.07480912      1.22443835      1.00000000    999.99900000      1.00000000
       Condition      1.00048947      1.93007666      1.12853177      1.00000000      4.00000000      1.00000000
      Edge Ratio      1.00607156      3.56541719      1.44892631      1.00000000      4.00000000      1.00000000
        Jacobian      0.00158627      0.06202757      0.01120120      0.00000000    999.99900000      1.00000000
   Minimum Angle     48.35050023     89.33703938     75.39251039     40.00000000     90.00000000     90.00000000
   Maximum Angle     90.94150752    129.91539960    106.20679399     90.00000000    135.00000000     90.00000000
       Area Sign      1.00000000      1.00000000      1.00000000      1.00000000      1.00000000      1.00000000
```
Note that the call to `generate_mesh` prints mesh quality statistics to the screen
and updates the visualization.
The background grid is *removed* from the visualization when the mesh is generated.

!!! note "Mesh visualization"
    Currently, only the "skeleton" of the mesh is visualized. Thus, the high-order curved boundary information
    is not seen in the plot but this information **is present** in the mesh file generated.

![first_reflect_mesh](https://github.com/trixi-framework/HOHQMesh.jl/assets/25242486/1afd159e-e8c4-459f-ba7d-a31057b0c135)

!!! tip "Boundary names in the mesh file"
    The boundary names of the original outer curves will be those defined by the user
    in their construction above. The boundary labeled `"symmetry"` is now internal and
    is marked appropriately as such. The reflected boundary names are appended
    with `_R` (for reflected) in the mesh file. For instance, the reflected version
    of the boundary `bottom` has the name `bottom_R` or the boundary named `circle` has the
    reflected boundary counterpart named `circle_R`. These can be changed as desired by editing the mesh file.

## Changing the reflection line

It is also possible to create a symmetry boundary composed of multiple be co-linear segments.

To change the line along which the mesh is reflected, we remove the current mesh that was just generated and re-plot the model curves
and background grid.
```julia
remove_mesh!(symmetric_mesh)
updatePlot!(symmetric_mesh, MODEL+GRID)
```
Additionally, the `remove_mesh!` command deletes the mesh information from
the interactive mesh project `symmetric_mesh` and the mesh file `symmetric_mesh.mesh`
from the `out` folder. However, the `symmetric_mesh.control`
and `symmetric_mesh.tec` files are still present in `out` directory.


To illustrate the reflection about multiple boundary curves (which must be co-linear!), we first rename the current symmetry boundary curve `O.1` to have the name `"left"`.
Next, we rename the co-linear boundary curves `O.3`, `O.5`, and `O.9` to have the name `"symmetry"`.
This is done with the function `renameCurve!`
```julia
renameCurve!(symmetric_mesh, "symmetry", # existing curve name
                             "left")     # new curve name
renameCurve!(symmetric_mesh, "right", "symmetry")
```
After the boundary names are adjusted the plot updates automatically to give the figure below.

![before_generation2](https://github.com/trixi-framework/HOHQMesh.jl/assets/25242486/314a7bc7-0cb1-4708-bbb9-98ca85798d5b)

We then generate the new mesh from the information contained in `symmetric_mesh`.
This saves the control, tec, and mesh files into the `out` folder and yields
```julia
generate_mesh(symmetric_mesh)

 *******************
 2D Mesh Statistics:
 *******************
    Total time             =    3.7763000000000019E-002
    Number of nodes        =          337
    Number of Edges        =          622
    Number of Elements     =          284
    Number of Subdivisions =            2

 Mesh Quality:
         Measure         Minimum         Maximum         Average  Acceptable Low Acceptable High       Reference
     Signed Area      0.00227157      0.06552808      0.01366911      0.00000000    999.99900000      1.00000000
    Aspect Ratio      1.00389317      2.07480912      1.22443835      1.00000000    999.99900000      1.00000000
       Condition      1.00048947      1.93007666      1.12853177      1.00000000      4.00000000      1.00000000
      Edge Ratio      1.00607156      3.56541719      1.44892631      1.00000000      4.00000000      1.00000000
        Jacobian      0.00158627      0.06202757      0.01120120      0.00000000    999.99900000      1.00000000
   Minimum Angle     48.35050023     89.33703938     75.39251039     40.00000000     90.00000000     90.00000000
   Maximum Angle     90.94150752    129.91539960    106.20679399     90.00000000    135.00000000     90.00000000
       Area Sign      1.00000000      1.00000000      1.00000000      1.00000000      1.00000000      1.00000000
```
The updated visualization is given below. Note, the flexibility to define multiple
co-linear symmetric boundaries creates a symmetric mesh with closed internal boundaries.
In this example, a circle and a rectangle.

![first_reflect_mesh2](https://github.com/trixi-framework/HOHQMesh.jl/assets/25242486/2476b6fe-79a4-4d3a-98b1-089714c76ade)

## Summary

In this tutorial we demonstrated how to:
* Indicate a symmetry boundary line.
* Construct an outer boundary with several connected curves.
* Add the background grid when an outer boundary curve is present.
* Rename boundaries in an existing interactive mesh project.
* Visualize an interactive mesh project.

For completeness, we include two scripts with all the commands to generate the meshes displayed
for a reflection about the left boundary line `O.1` as well as a reflection about
the right boundary composed of the three co-linear segments `O.3`, `O.5`, and `O.9`.
Note, we **do not** include the plotting in these scripts.
```julia
# Interactive mesh with reflection on the left over a single symmetry boundary
# as well as a reflection on the right over multiple co-linear symmetry boundaries.
#
# Keywords: outer boundary, reflection, symmetric mesh
using HOHQMesh

# new project
symmetric_mesh = newProject("symmetric_mesh", "out")

# reset mesh polydeg
setPolynomialOrder!(symmetric_mesh, 6)

# A background grid is required for the mesh generation
addBackgroundGrid!(symmetric_mesh, [0.25, 0.25, 0.0])

# Create all the outer boundary curves and add them to the mesh project.
# Note: (1) Curve names are those that will be present in the mesh file
#       (2) Boundary named "symmetry" is where reflection occurs

line1 = newEndPointsLineCurve("symmetry", [-0.05, 2.0, 0.0],
                                          [-0.05, 0.0, 0.0])

line2 = newEndPointsLineCurve("bottom", [-0.05, 0.0, 0.0],
                                        [1.0, 0.0, 0.0])

line3 = newEndPointsLineCurve("right", [1.0, 0.0, 0.0],
                                       [1.0, 0.5, 0.0])

half_circle = newCircularArcCurve("circle",         # curve name
                                  [1.0, 0.75, 0.0], # circle center
                                  0.25,             # circle radius
                                  270.0,            # start angle
                                  90.0,             # end angle
                                  "degrees")        # angle units

line4 = newEndPointsLineCurve("right", [1.0, 1.0, 0.0],
                                       [1.0, 1.5, 0.0])

line5 = newEndPointsLineCurve("bump", [1.0, 1.5, 0.0],
                                      [0.75, 1.5, 0.0])

line6 = newEndPointsLineCurve("bump", [0.75, 1.5, 0.0],
                                      [0.75, 1.75, 0.0])

line7 = newEndPointsLineCurve("bump", [0.75, 1.75, 0.0],
                                      [1.0, 1.75, 0.0])

line8 = newEndPointsLineCurve("right", [1.0, 1.75, 0.0],
                                       [1.0, 2.0, 0.0])

line9 = newEndPointsLineCurve("top", [1.0, 2.0, 0.0],
                                     [-0.05, 2.0, 0.0])

addCurveToOuterBoundary!(symmetric_mesh, line1)
addCurveToOuterBoundary!(symmetric_mesh, line2)
addCurveToOuterBoundary!(symmetric_mesh, half_circle)
addCurveToOuterBoundary!(symmetric_mesh, line3)
addCurveToOuterBoundary!(symmetric_mesh, line4)
addCurveToOuterBoundary!(symmetric_mesh, line5)
addCurveToOuterBoundary!(symmetric_mesh, line6)
addCurveToOuterBoundary!(symmetric_mesh, line7)
addCurveToOuterBoundary!(symmetric_mesh, line8)
addCurveToOuterBoundary!(symmetric_mesh, line9)

# Generate the mesh. Saves the mesh file to the directory "out".
generate_mesh(symmetric_mesh)

# Delete the existing mesh before modifying boundary names.
remove_mesh!(symmetric_mesh)

# Rename the outer boundaries appropriately to set the symmetry boundary
# on the right composed of multiple co-linear segments.
renameCurve!(symmetric_mesh, "symmetry", # existing curve name
                             "left")     # new curve name
renameCurve!(symmetric_mesh, "right", "symmetry")

# Generate the mesh. Saves the mesh file to the directory "out".
generate_mesh(symmetric_mesh)
```