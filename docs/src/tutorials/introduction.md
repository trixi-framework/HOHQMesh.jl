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

This tutorial gives an introduction to the main functionality of the interactive meshing HQMtool. In
particular, adding a straight-sided bounding box for the outer domain and two circular inner boundary
chains. It also demonstrates how to adjust some of the mesh parameters as well as the output mesh file
format.

## [Curved outer boundary](@ref)

This tutorial constructs an outer domain boundary using parametric equations. The background grid is then
set and a preliminary mesh is generated. It highlights how a user can manually add a refinement region where
necessary from this visual inspection.

## Spline curves

build spline from file and spline from array. Also small triangular element from straight curves

## Undo/redo

This tutorial shows a user how to create curved outer and inner boundaries piece-by-piece. Additionally,
the tutorial demonstrates the `undo` stack of the interactive tool and how straightforward it is to edit
a boundary curve and regenerate a mesh.

This last one will take the longest to write and has the most figures...