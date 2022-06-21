# [Tutorials for HOHQMesh.jl](@id Tutorials)

The tutorial section for [HOHQMesh.jl](https://github.com/trixi-framework/HOHQMesh.jl)
provides step-by-step commands and accompanying explanations for the major features of the
interactive mesh generation tools provided by [HQMTool](@ref HQMTool).

For a general overview of the capabilities and features of HOHQMesh to generate quadrilateral
and hexahedral meshes we refer to the
[Pre-made Examples](https://trixi-framework.github.io/HOHQMesh/examples/) of the HOHQMesh
documentation.

For more information on how an unstructured mesh generated with HOHQMesh.jl can be used in
the simulation framework [Trixi.jl](https://github.com/trixi-framework/Trixi.jl) see the
[relevant tutorial](https://trixi-framework.github.io/Trixi.jl/stable/tutorials/hohqmesh_tutorial/).

## [Straight-sided outer boundary](@ref)

This tutorial gives an introduction to the main functionality of the interactive meshing HQMTool. In
particular, adding a straight-sided bounding box for the outer domain and two circular inner boundary
chains. It also demonstrates how to adjust some of the mesh parameters as well as the output mesh file
format.

## [Curved outer boundary](@ref)

This tutorial constructs an outer domain boundary using parametric equations. The background grid is then
set and a preliminary mesh is generated. It highlights how a user can manually add a refinement region where
necessary from this visual inspection.

## [Spline curves](@ref)

This tutorial constructs a circular outer domain and three inner boundary curves. Two of the inner curves
are constructed using cubic splines and the third inner boundary is a triangular shape built from
three straight line "curves".

## [Creating and editing curves](@ref)

This tutorial demonstrates how to construct and edit curve segments defined in inner / outer boundary
chains. There is also the removal and replacement of a portion of an inner boundary chain. The tutorial
highlights the capability of the `undo` / `redo` stack in the interactive HQMTool.
