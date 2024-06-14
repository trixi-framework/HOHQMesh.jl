# Symmetric mesh

The purpose of this tutorial is to demonstrate how to create an unstructured mesh
that is symmetric with respect to a straight line outer boundary prescribed by the user.
At the end of this tutorial one can find the scripts necessary to generate the meshes
described herein.

### Synopsis

This tutorial demonstrates how to:
* Indicate a symmetry boundary line.
* Construct an outer boundary with several connected curves.
* Add the background grid when an outer boundary curve is present.
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
to have elements with side length $0.2$ in each direction
```julia
addBackgroundGrid!(spline_project, [0.2, 0.2, 0.0])
```

## Add the outer boundary

With the background grid size set, we next build the outer boundary for the present mesh project.
This outer boundary is composed of nine straight line segments and a half circle arc.
The curves are created such that they can be added to the mesh project `symmetric_mesh`
in counter-clockwise order as required by HOHQMesh.
```julia
line1 = newEndPointsLineCurve("B1", [-0.05, 0.0, 0.0],
                                    [1.0, 0.0, 0.0])

line2 = newEndPointsLineCurve("B2", [1.0, 0.0, 0.0],
                                    [1.0, 0.5, 0.0])

half_circle = newCircularArcCurve("circle",         # curve name
                                  [1.0, 0.75, 0.0], # circle center
                                  0.25,             # circle radius
                                  270.0,            # start angle
                                  90.0,             # end angle
                                  "degrees")        # angle units

line3 = newEndPointsLineCurve("B3", [1.0, 1.0, 0.0],
                                    [1.0, 1.5, 0.0])

line4 = newEndPointsLineCurve("B4", [1.0, 1.5, 0.0],
                                    [0.75, 1.5, 0.0])

line5 = newEndPointsLineCurve("B5", [0.75, 1.5, 0.0],
                                    [0.75, 1.75, 0.0])

line6 = newEndPointsLineCurve("B6", [0.75, 1.75, 0.0],
                                    [1.0, 1.75, 0.0])

line7 = newEndPointsLineCurve("B7", [1.0, 1.75, 0.0],
                                    [1.0, 2.0, 0.0])

line8 = newEndPointsLineCurve("B8", [1.0, 2.0, 0.0],
                                    [-0.05, 2.0, 0.0])

line9 = newEndPointsLineCurve("symmetry", [-0.05, 2.0, 0.0],
                                          [-0.05, 0.0, 0.0])
```
The given boundary names will also be the names given in the resulting
mesh file. The only exception is the final boundary curve that is given
the name `"symmetry"`. This outer boundary curve is a special keyword
in HOHQMesh that indicates the prescribed straight line over which
a reflection will occur.

!!! tip "Name of the symmetry boundary"
    As noted above, `"symmetry"` is a keyword for the HOHQMesh generator that
    prescribes over which line a reflection of the mesh occurs. Note
    that Julia is a case sensitive language but Fortran is not. So, within the
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

![before_generation](https://github.com/trixi-framework/HOHQMesh.jl/assets/25242486/6712cbe8-d7bf-4142-99af-dc032f26e768)

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
    Total time             =    4.3447999999999987E-002
    Number of nodes        =          422
    Number of Edges        =          773
    Number of Elements     =          352
    Number of Subdivisions =            2

 Mesh Quality:
         Measure         Minimum         Maximum         Average  Acceptable Low Acceptable High       Reference
     Signed Area      0.00147112      0.04240553      0.01102461      0.00000000    999.99900000      1.00000000
    Aspect Ratio      1.00102845      2.37276773      1.22432027      1.00000000    999.99900000      1.00000000
       Condition      1.00000549      2.97426696      1.13908196      1.00000000      4.00000000      1.00000000
      Edge Ratio      1.00185169      4.29126482      1.45727892      1.00000000      4.00000000      1.00000000
        Jacobian      0.00084327      0.03918949      0.00931776      0.00000000    999.99900000      1.00000000
   Minimum Angle     40.68137900     89.81152621     75.30939242     40.00000000     90.00000000     90.00000000
   Maximum Angle     90.10587561    140.86941819    105.72816725     90.00000000    135.00000000     90.00000000
       Area Sign      1.00000000      1.00000000      1.00000000      1.00000000      1.00000000      1.00000000
```
The call to `generate_mesh` also prints mesh quality statistics to the screen
and updates the visualization.
The background grid is *removed* from the visualization when the mesh is generated.

!!! note "Mesh visualization"
    Currently, only the "skeleton" of the mesh is visualized. Thus, the high-order curved boundary information
    is not seen in the plot but this information **is present** in the generated mesh file.

![first_reflect_mesh](https://github.com/trixi-framework/HOHQMesh.jl/assets/25242486/daa915fa-11ac-411e-950c-e31958494df3)

!!! tip "Boundary names in the mesh file"
    The boundary names of the original outer curves will be those defined by the user
    in their construction above. The boundary labeled `"symmetry"` is now internal and
    is marked appropriately as such. The reflected outer boundary names are appended
    with `_R` (for reflected) in the mesh file. For instance, the reflected version
    of the boundary `B2` has the name `B2_R` or the boundary named `circle` has the
    reflected boundary counterpart named `circle_R`.

## Changing the reflection line

As an illustration, we redefine which of the straight lines in the outer boundary
curve chain is used for the reflection. Instead of the left boundary `O.10` in the
above example, we now set the reflection line to be the `O.2` curve on the right.
In doing so, we now label the left boundary curve `O.10` to be `"B9"`.
The redefinition of these two outer boundary curves are
```julia
line2 = newEndPointsLineCurve("symmetry", [1.0, 0.0, 0.0],
                                          [1.0, 0.5, 0.0])
line9 = newEndPointsLineCurve("B9", [-0.05, 2.0, 0.0],
                                    [-0.05, 0.0, 0.0])
```
We then redefine the complete outer boundary in the `symmetric_mesh` project
(again in counter-clockwise order) with
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
We visualize the new version of outer boundary curve chain and background grid with
```julia
plotProject!(symmetric_mesh, MODEL+GRID)
```

![before_generation2](https://github.com/trixi-framework/HOHQMesh.jl/assets/25242486/2672e82d-6512-491a-9ff6-4ce3fd06da88)

We then generate the new mesh from the information contained in `symmetric_mesh`.
This saves the control, tec, and mesh files into the `out` folder and yields
```julia
generate_mesh(symmetric_mesh)

 *******************
 2D Mesh Statistics:
 *******************
    Total time             =    4.4684999999999975E-002
    Number of nodes        =          428
    Number of Edges        =          779
    Number of Elements     =          352
    Number of Subdivisions =            2

 Mesh Quality:
         Measure         Minimum         Maximum         Average  Acceptable Low Acceptable High       Reference
     Signed Area      0.00147112      0.04240553      0.01102461      0.00000000    999.99900000      1.00000000
    Aspect Ratio      1.00102845      2.37276773      1.22432027      1.00000000    999.99900000      1.00000000
       Condition      1.00000549      2.97426696      1.13908196      1.00000000      4.00000000      1.00000000
      Edge Ratio      1.00185169      4.29126482      1.45727892      1.00000000      4.00000000      1.00000000
        Jacobian      0.00084327      0.03918949      0.00931776      0.00000000    999.99900000      1.00000000
   Minimum Angle     40.68137900     89.81152621     75.30939242     40.00000000     90.00000000     90.00000000
   Maximum Angle     90.10587561    140.86941819    105.72816725     90.00000000    135.00000000     90.00000000
       Area Sign      1.00000000      1.00000000      1.00000000      1.00000000      1.00000000      1.00000000
```

![first_reflect_mesh2](https://github.com/trixi-framework/HOHQMesh.jl/assets/25242486/9e416528-dc42-465b-b874-3641bb0d1e7e)

## Summary

In this tutorial we demonstrated how to:
* Indicate a symmetry boundary line.
* Construct an outer boundary with several connected curves.
* Add the background grid when an outer boundary curve is present.
* Visualize an interactive mesh project.

For completeness, we include two scripts with all the commands to generate the meshes displayed
for a reflection about the left boundary line `O.10` and a reflection about the right boundary
line `O.2`. Note, we **do not** include the plotting in these scripts.
```julia
# Interactive mesh with reflection on the left
#
# Keywords: outer boundary, reflection, symmetric mesh
using HOHQMesh

# new project
symmetric_mesh = newProject("symmetric_mesh", "out")

# reset mesh polydeg
setPolynomialOrder!(symmetric_mesh, 6)

# A background grid is required for the mesh generation
addBackgroundGrid!(symmetric_mesh, [0.2, 0.2, 0.0])

# Create all the outer boundary curves and add them to the mesh project.
# Note: (1) Curve names are those that will be present in the mesh file
#       (2) Boundary named "symmetry" is where reflection occurs

line1 = newEndPointsLineCurve("B1", [-0.05, 0.0, 0.0],
                                    [1.0, 0.0, 0.0])

line2 = newEndPointsLineCurve("B2", [1.0, 0.0, 0.0],
                                    [1.0, 0.5, 0.0])

half_circle = newCircularArcCurve("circle",         # curve name
                                  [1.0, 0.75, 0.0], # circle center
                                  0.25,             # circle radius
                                  270.0,            # start angle
                                  90.0,             # end angle
                                  "degrees")        # angle units

line3 = newEndPointsLineCurve("B3", [1.0, 1.0, 0.0],
                                    [1.0, 1.5, 0.0])

line4 = newEndPointsLineCurve("B4", [1.0, 1.5, 0.0],
                                    [0.75, 1.5, 0.0])

line5 = newEndPointsLineCurve("B5", [0.75, 1.5, 0.0],
                                    [0.75, 1.75, 0.0])

line6 = newEndPointsLineCurve("B6", [0.75, 1.75, 0.0],
                                    [1.0, 1.75, 0.0])

line7 = newEndPointsLineCurve("B7", [1.0, 1.75, 0.0],
                                    [1.0, 2.0, 0.0])

line8 = newEndPointsLineCurve("B8", [1.0, 2.0, 0.0],
                                    [-0.05, 2.0, 0.0])

line9 = newEndPointsLineCurve("symmetry", [-0.05, 2.0, 0.0],
                                          [-0.05, 0.0, 0.0])

# Add all of the boundary curves into
# the project in counter-clockwise order
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
```
and
```julia
# Interactive mesh with reflection on the right
#
# Keywords: outer boundary, reflection, symmetric mesh
using HOHQMesh

# new project
symmetric_mesh = newProject("symmetric_mesh", "out")

# reset mesh polydeg
setPolynomialOrder!(symmetric_mesh, 6)

# A background grid is required for the mesh generation
addBackgroundGrid!(symmetric_mesh, [0.2, 0.2, 0.0])

# Create all the outer boundary curves and add them to the mesh project.
# Note: (1) Curve names are those that will be present in the mesh file
#       (2) Boundary named "symmetry" is where reflection occurs

line1 = newEndPointsLineCurve("B1", [-0.05, 0.0, 0.0],
                                    [1.0, 0.0, 0.0])

line2 = newEndPointsLineCurve("symmetry", [1.0, 0.0, 0.0],
                                          [1.0, 0.5, 0.0])

half_circle = newCircularArcCurve("circle",         # curve name
                                  [1.0, 0.75, 0.0], # circle center
                                  0.25,             # circle radius
                                  270.0,            # start angle
                                  90.0,             # end angle
                                  "degrees")        # angle units

line3 = newEndPointsLineCurve("B3", [1.0, 1.0, 0.0],
                                    [1.0, 1.5, 0.0])

line4 = newEndPointsLineCurve("B4", [1.0, 1.5, 0.0],
                                    [0.75, 1.5, 0.0])

line5 = newEndPointsLineCurve("B5", [0.75, 1.5, 0.0],
                                    [0.75, 1.75, 0.0])

line6 = newEndPointsLineCurve("B6", [0.75, 1.75, 0.0],
                                    [1.0, 1.75, 0.0])

line7 = newEndPointsLineCurve("B7", [1.0, 1.75, 0.0],
                                    [1.0, 2.0, 0.0])

line8 = newEndPointsLineCurve("B8", [1.0, 2.0, 0.0],
                                    [-0.05, 2.0, 0.0])

line9 = newEndPointsLineCurve("B9", [-0.05, 2.0, 0.0],
                                    [-0.05, 0.0, 0.0])

# Add all of the boundary curves into
# the project in counter-clockwise order
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
```