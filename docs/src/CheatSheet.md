# Commands Cheat Sheet

This provides a quick reference for the syntax
of the interactive construction of boundary curves, background grid, etc.
When possible, the commands presented below give
generic versions of the function calls, e.g., for creating a new curve or
adding the curve to a boundary chain. The script
`interactive_outer_boundary_generic.jl` in the `examples` folder
constructs an identical example mesh as shown in the [Guided tour](@ref)
using generic function calls.

A thorough description of the functions can be found in the [API](@ref) section.

The general workflow of the interactive mesh functionality within a REPL session is

1. Create a project
2. Add boundary curves
3. Add a background grid
4. Add manual refinement (if desired)
5. Generate mesh

## Project

```
   p = newProject(<projectName>, <folder>)
```

## [Plotting](@id cs-plotting)

```
   plotProject!(p, options)
   updatePlot!(p, options)
```

The `options` are any sum of `MODEL`, `GRID`, `REFINEMENTS`, and `MESH`.
## Curves

```
   c = new(name, startLocation [x,y,z],endLocation [x,y,z])  *Straight Line*
   c = new(name,center [x,y,z],radius, startAngle, endAngle) *Circular Arc*
   c = new(name, xEqn, yEqn, zEqn)                           *Parametric equation*
   c = new(name, dataFile)                                   *Spline with data from a file*
   c = new(name, nKnots, knotsMatrix)                        *Spline with given knot values*
```

Shown here is the use of the function `new`, which is a shortcut to the full functions, e.g. `newCircularArcCurve`, etc. which have the same arguments.

## [Manual Refinement](@id cs-manual-refinement)

```
   r = newRefinementCenter(name, center, gridSize, radius)
   r = newRefinementLine(name, type, startPoint, endPoint, gridSize, width)
```

## Adding to a Project

```
   add!(p, c)                        *Add outer boundary curve*
   add!(p, c, <InnerBoundaryName>)   *Add curve to an inner boundary*
   add!(p, r)                        *Add refinement region*

   addBackgroundGrid!(p, [top, left, bottom, right], [nX, nY, nZ]) *No outer boundary*
   addBackgroundGrid!(p, [dx, dy, dz])                             *If an outer boundary is present*
```
Shown here is the use of the function `add!`, which is a shortcut to the full functions, e.g. `addOuterBoundaryCurve`, etc. which have the same arguments.

## Accessing items

```
   crv         = getCurve(p, curveName)               *Get a curve in the outer boundary*
   crv         = getCurve(p, curveName, boundaryName) *Get a curve in an inner boundary*
   indx, chain = getChain(p, boundaryName)            *Get a complete inner boundary curve*
   r           = getRefinementRegion(p, name)
```

## Removing from Project

```
   removeOuterboundary!(p)                    *Entire outer boundary curve*
   removeInnerBoundary!(p, innerBoundaryName) *Entire inner boundary curve*
   remove!(p, name)                           *Curve in outer boundary*
   remove!(p, name, innerBoundaryName)        *Curve in inner boundary*
   removeRefinementRegion!(p, name)
```

## Editing items

All items have set/get methods to edit them. Most actions have `undo()` and `redo()`.
To find out what the next undo/redo actions are, use `undoActionName()` and `redoActionName()`
to print them to the screen.

## Meshing

```
   generate_mesh(p)
   remove_mesh!(p)
```
