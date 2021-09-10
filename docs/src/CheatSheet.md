# HQMTool CheatSheet

Workflow:

1. Create a project
2. Add boundary curves
4. Add a background grid
3. Add manual refinement (if desired)
5. Generate mesh

## Project

		p = newProject(<projectName>,<folder>)

## Plotting

		plotProject!(p,options)
		updatePlot!(p,options)
		
## Curves

		c = new(name, startLocation [x,y,z],endLocation [x,y,z])  *Straight Line*
		c = new(name,center [x,y,z],radius, startAngle, endAngle) *Circular Arc*
		c = new(name, xEqn, yEqn, zEqn )                          *Parametric equation*
		c = new(name, dataFile) 			                      *Spline*
		c = new(name, nKnots, knotsMatrix)                        *also Spline*

## Manual Refinement

		r = newRefinementCenter(name, center, gridSize, radius )
		r = newRefinementLine(name,type, startPoint, endPoint, gridSize, width )
## Adding to a Project

		add!(p, c) 						  *Add outer boundary curve*
		add!(p, c, <InnerBoundaryName>)   *add curve to an inner boundary*
		add!(p, r) 						  *Add refinement region*

		addBackgroundGrid!(p, [top, left, bottom, right], [nX,nY,nZ]) *No outer boundary*
		addBackgroundGrid!(p, [dx,dy,dz])                             *If an outer boundary is present*
		
## Accessing items

		crv         = get(p,curveName)	             *Get a curve in the outer boundary*
		crv         = get(p,curveName, boundaryName) *Get a curve in an inner boundary*
		indx, chain = getChain(p,boundaryName)       *Get a complete inner boundary curve*
		r           = getRefinementRegion(p, name)
		
## Removing from Project

		removeOuterboundary!(p) 			       *Entire outer boundary curve*
		removeInnerBoundary!(p, innerBoundaryName) *Entire inner boundary curve
		remove!(p, name) 					       *Curve in outer boundary*
		remove!(p, name, innerBoundaryName)        *Curve in inner boundary*
		removeRefinementRegion!(p,  name)
		
## Editing items

All items have set/get methods to edit them. Most actions have undo() and redo(). To find out what the next undo/redo actions are, use undoActionName() and redoActionName() to print them out.

## Meshing

		generateMesh(p)
		removeMesh!(p)
	
