# [Tutorials for HOHQMesh.jl](@id Tutorials)

The tutorial section for [HOHQMesh.jl](https://github.com/trixi-framework/HOHQMesh.jl)
provides step-by-step commands and accompanying explanations for the major features of the
[interactive mesh generation tools](@ref InteractiveTool).

For a general overview of the capabilities and features of HOHQMesh to generate quadrilateral
and hexahedral meshes we refer to the
[Pre-made Examples](https://trixi-framework.github.io/HOHQMesh/examples/) of the HOHQMesh
documentation.

For more information on how an unstructured mesh generated with HOHQMesh.jl can be used in
the simulation framework [Trixi.jl](https://github.com/trixi-framework/Trixi.jl) see the
[relevant tutorial](https://trixi-framework.github.io/Trixi.jl/stable/tutorials/hohqmesh_tutorial/).

## [Straight-sided outer boundary](@ref)

This tutorial gives an introduction to the main functionality of the interactive meshing. In
particular, adding a straight-sided bounding box for the outer domain and two circular inner boundary
chains. It also demonstrates how to adjust some of the mesh parameters as well as the output mesh file
format.

### Synopsis

Demonstrates how to:
* Query and adjust the `RunParameters` of a project.
* Define a rectangular outer boundary and set the background grid.
* Visualize an interactive mesh project.
* Add circular inner boundary curves.

## [Curved outer boundary](@ref)

This tutorial constructs an outer domain boundary using parametric equations. The background grid is then
set and a preliminary mesh is generated. It highlights how a user can manually add a refinement region where
necessary from this visual inspection.

### Synopsis

Demonstrates how to:
* Define a curved outer boundary using parametric equations.
* Add and adjust the background grid.
* Visualize an interactive mesh project.
* Add manual refinement to a local region of the domain.

## [Spline curves](@ref)

This tutorial constructs a circular outer domain and three inner boundary curves. Two of the inner curves
are constructed using cubic splines and the third inner boundary is a triangular shape built from
three straight line "curves".

### Synopsis

Demonstrates how to:
* Create a circular outer boundary curve.
* Add the background grid when an outer boundary curve is present.
* Visualize an interactive mesh project.
* Construct and add parametric spline curves.
* Construct and add an inner boundary chain of straight line segments.

## [Creating and editing curves](@ref)

This tutorial demonstrates how to construct and edit curve segments defined in inner / outer boundary
chains. A curve "chain" in the HOHQMesh context means a closed curve that is
composed of an arbitrary number of pieces.
Each curve segment of a chain can be a different curve type, e.g., a circular
arc can connect to a spline that connects to a parametric equation curve.
There are details for the removal and replacement of a portion of a chain.

### Synopsis

Demonstrates how to:
* Create and edit an outer boundary chain.
* Create and edit an inner boundary chain.
* Add the background grid when an outer boundary curve is present.
* Visualize an interactive mesh project.
* Discuss undo / redo capabilities.
* Construct and add parametric spline curves.
* Construct and add a curve from parametric equations.
* Construct and add straight line segments.
* Construct and add circular arc segments.