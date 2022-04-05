# HQMTool
HQMTool is currently an API to generate a quad (Future:Hex) mesh using Julia.

## Contents

1. [Introduction](@ref)
2. [Basic Moves](@ref)
3. [HQMTool API](@ref)
  1. [Project Creation and Saving](@ref)
  2. [Plotting](@ref)
  3. [Modifying/Editing a Project](@ref)
  4. [Controlling the Mesh Generation Process](@ref)
    1. [Editing the Run Parameters](@ref)
    2. [Changing the output file names](@ref)
    3. [Adding the background grid](@ref)
    4. [Smoothing Operations](@ref)
    5. [Manual Refinement](@ref)
  5. [Boundary Curves](@ref)
    1. [Adding and Removing Outer and Inner Boundaries](@ref)
    2. [Defining Curves](@ref)
    3. [Editing Curves](@ref)
  6. [Undo/Redo](@ref)
4. [Advanced](@ref)

## Introduction

HQMTool is an API to build quad/hex meshes. Three examples are included to get you started.
The first reads in an existing control file from the HOHQMesh examples collection.
To see that example, run

		run_demo("out")

where `out` specifies the folder where the resulting mesh and TecPlot files will be saved.

The second example builds a new project consisting of an outer, circular boundary, and an inner
boundary in the shape of an ice cream cone. The "verbose" version of the script is given below.

    function ice_cream_cone_verbose_demo(folder::String; called_by_user=true)
    #
    # Create a project with the name "IceCreamCone", which will be the name of the mesh, plot and stats files,
    # written to `folder`. The keyword arguement `called_by_user` is there for testing purposes.
    #
        p = newProject("IceCreamCone", folder)
    #
    #   Outer boundary
    #
        circ = newCircularArcCurve("outerCircle", [0.0,-1.0,0.0], 4.0, 0.0, 360.0, "degrees")
        addCurveToOuterBoundary!(p, circ)
    #
    #   Inner boundary
    #
        cone1    = newEndPointsLineCurve("cone1", [0.0,-3.0,0.0], [1.0,0.0,0.0])
        iceCream = newCircularArcCurve("iceCream", [0.0,0.0,0.0], 1.0, 0.0, 180.0, "degrees")
        cone2    = newEndPointsLineCurve("cone2", [-1.0,0.0,0.0], [0.0,-3.0,0.0])
        addCurveToInnerBoundary!(p, cone1, "IceCreamCone")
        addCurveToInnerBoundary!(p, iceCream, "IceCreamCone")
        addCurveToInnerBoundary!(p, cone2, "IceCreamCone")
    #
    #   Set some control RunParameters to overwrite the defaults
    #
        setPolynomialOrder!(p, 4)
        setPlotFileFormat!(p, "sem")
    #
    #   To mesh, a background grid is needed
    #
        addBackgroundGrid!(p, [0.5,0.5,0.0])

        if called_by_user
    #
    #   Show the model and grid
    #
          plotProject!(p, MODEL+GRID)
          println("Press enter to continue and generate the mesh")
          readline()
        end
    #
    #   Generate the mesh and plot
    #
        generate_mesh(p)

        return p
    end

The first line creates a new project, where the mesh and plot file names will be derived from the project name, "IceCreamCone" written to the specified folder.

To develop the model, one adds curves to the outer boundary or to multiple inner boundaries, if desired. As in HOHQMesh, there are four curve classes currently operational:

- Parametric equations
- Splines
- Lines defined by their end points
- Circular arcs

In the example, the outer boundary is a closed circular arc with center at [0.0, 0.0, 0.0] with radius 4, starting at zero and ending at 360 degrees. It is added to the project with `addCurveToOuterBoundary!` through the generic name `add!`. You can add any number of curves, but they must be added in order, counter-clockwise.

Similarly, you create curves and add them to as many inner boundaries that you want to have. In the example, there is one inner boundary, "IceCreamCone" made up of two lines and a half circular arc. Again, add them in order, counter-clockwise.

For convenience, `newProject` will generate default run parameters, like the plot file format and the smoother. The parameters can be edited with setter commands. For example, the script sets the polynomial order (default = 5) and the plot file format (default = "skeleton").

One run parameter that must be set manually is the background grid. Since there is an outer boundary, that determines the extent of the domain to be meshed, so only the mesh size needs to be specified using

		addBackgroundGrid!(proj::Project, bgSize::Array{Float64})

The example sets the background mesh size to be 0.1 in the x and y directions. The z component is ignored.

The script finishes by generating the quad mesh and plotting the results, as shown below

![iceCreamCone](https://user-images.githubusercontent.com/3637659/132798939-218a3379-7d50-4f3e-9bec-e75e6cd79031.png)

It also returns the project so that it can be edited further, if desired.

To save a control file for HOHQMesh, simply invoke

		saveProject(proj::Project,outFile::String)

where outFile is the name of the control file (traditionally with a .control extension). `saveProject` is automatically called when a mesh is generated.

The third example `ice_cream_cone_demo` is identical to that which was explained above except that the function calls
use the generic version of, e.g., `new` or `add!`.

Methods are available to edit a model. For example to move the center of the outer boundary.

## Basic Moves

To create generate a mesh you

- [Create a project](#newProject)

		p = newProject(<projectName>,<folder>)

- [Create inner and outer boundary curves](#DefiningCurves)

		c = new(<name>, startLocation [x,y,z],endLocation [x,y,z])     (Straight Line)
		c = new(<name>,center [x,y,z],radius,startAngle,endAngle,units = "degrees" or "radians") (Circular Arc)
		c = new(<name>, xEqn, yEqn, zEqn ) (Parametric equation)
		c = new(<name>, dataFile) (Spline)
		c = new(<name>, nKnots, knotsMatrix) (also Spline)

- [Add curves](#AddingCurves) to build the model to see what you have added,

		add!(p, <curveName>) (Add outer boundary curve)
		add!(p, <curveName>, <InnerBoundaryName>) (add curve to an inner boundary)

- To [visualize](#Plotting) the project's model,

		plotProject!(p,MODEL)

	To update the plot at any time, use

		updatePlot!(p, options)

	Options are MODEL, GRID, MESH, and REFINEMENTS. To plot combinations, sum the options, e.g. MODEL+GRID or MODEL+MESH. (You normally are not intersted in the background grid once the mesh is generated.)

- Set the [background grid](#(#BackgroundGrid))

		 addBackgroundGrid!(p, lower left [x,y,z], spacing [dx,dy,dz], num Intervals [nX,nY,nZ]) (No outer boundary)
		 *OR*
		 addBackgroundGrid!(p, [top, left, bottom, right], num Intervals [nX,nY,nZ]) (No outer boundary)

		 addBackgroundGrid!(p, grid size [dx,dy,dz]) (If an outer boundary is present)

- [Adjust parameters](#RunParameters), if desired (e.g.)

		setPolynomialOrder!(p,order)

- Generate the mesh

		generateMesh(p)

The mesh will be stored in `<folder>` with the name `<projectName>.mesh`. The control file will also be saved in that folder with the name `<projectName>.control`, which you can read in again later and modify, remesh, etc. The function will print grid information, and will plot the grid as in the figure above, if a plot is otherwise visible. If not, it can always be plotted with the `plotProject!` command.


## HQMTool API

### Project Creation and Saving

#### New Project

		(Return:Project) proj = newProject(name::String, folder::String)

The supplied name will be the default name of the mesh and plot files generated by HOHQMesh. The folder is the directory in which those files will be placed. The empty project will include default `RunParameters` and a default `SpringSmoother`, both of which can be modified later, if desired. The only thing required to add is the [background grid](#BackgroundGrid).

#### Opening an existing project file

		(Return:Project) proj = openProject(fileName::String, folder::String)

#### Saving a project

		saveProject(proj::Project)

writes a control file to the folder designated when creating the new project. It can be read in again with OpenProject.

### Plotting

#### Plotting a Project

		plotProject!(proj::Project, options)

The options are any combination of `MODEL`, `GRID`, `MESH`, and `REFINEMENTS`. `GRID` refers to the background grid, which you an view to make sure that it can resolve the boundary curves in the model. Before meshing one probably wants to view `MODEL+GRID`, and afterwards, `MODEL+MESH`. `REFINEMENTS` will show where [manual refinement](#ManualRefinement) is added.

If the model is modified and you want to re-plot with the new values, invoke

		updatePlot!(proj::Project, options)

but genrally the plot will be updated automatically as you build the model.


### Modifying/Editing a Project

#### Setting the name of a project

The project name is the name under which the mesh, plot, statistics and control files will be written.

		setName!(proj::Project,name::String)


#### Getting the current name of a Project

		[Return:String]	getName(proj::Project)

### Controlling the Mesh Generation Process

#### Editing the Run Parameters

The run parameters can be enquired and set with these getter/setter pairs:

		[Return:nothing] setPolynomialOrder!(proj::Project, p::Int)
		[Return:Int]     getPolynomialOrder(proj::Project)
		[Return:nothing] setMeshFileFormat!(proj::Project, meshFileFormat::String)
		[Return:String]  getMeshFileFormat(proj::Project)
		[Return:nothing] setPlotFileFormat!(proj::Project, plotFileFormat::String)
		[Return:String]  getPlotFileFormat(proj::Project)

The available mesh file formats are `ISM`, `ISM-V2`, or `ABAQUS`. The plot file (which can be viewed with something like VisIt or Paraview) format is either `skeleton` or `sem`. The former is just a low order finite element represntation of the mesh. The latter (which is a much bigger file) includes the interior degrees of freedom.

#### Changing the output file names

By default, the mesh, plot and stats files will be written with the name and path supplied when newProject is called. They can be changed/enquired with

		[Return:nothing] setName!(proj::Project,name::String)
		[Return:String]  getName(proj::Project)
		[Return:nothing] setFolder!(proj::Project,folder::String)
		[Return:String]  getFolder(proj::Project)

#### Adding the background grid

There are three forms for the background grid definition, one for when there is an outer boundary, and two for when there is not. One or the other has to be specified after a new project has been created.

		[Return:nothing] addBackgroundGrid!(proj::Project, x0::Array{Float64}, dx::Array{Float64}, N::Array{Int})
		[Return:nothing] addBackgroundGrid!(proj::Project, box::Array{Float64}, N::Array{Int})
		[Return:nothing] addBackgroundGrid!(proj::Project, bgSize::Array{Float64})

Use one of the first two if there is no outer boundary. With the first, a rectangular outer boundary will be created of extent [x0[1], x0[1]+N dx[1]]X[x0[2], x0[2]+N*dx[2]]. The second lets you set the bounding box = [top, left, bottom, right], and the number of points in each direction. The arrays `x0`, `dx`, `N`, `bgSize` are all vectors [ *, \*, \*] giving the x, y, and z components.

#### Smoothing Operations

A default smoother is created when newProject is called, which sets the status to `ON`, type to `LinearAndCrossbarSpring`, and number of iterations = 25. These are generally good enough for most purposes. The most likely parameter to change is the number of iterations.

To change the defaults, the smoother parameters can be set/enquired with the functions

		[Return:nothing] setSmoothingStatus!(proj::Project, status::String)
		[Return:String]  getSmoothingStatus(proj::Project)
		[Return:nothing] setSmoothingType!(proj::Project, type::String)
		[Return:String]  getSmoothingType(proj::Project)
		[Return:nothing] setSmoothingIterations!(proj::Project, iterations::Int)
		[Return:Int]     getSmoothingIterations(proj::Project)

`status` is either "ON" or "OFF".

To remove the smoother altogether,

		[Return:nothing] removeSpringSmoother!(proj::Project)

#### Manual Refinement

Refinement can be specified either at a point, using the `RefinementCenter`, or along a line, using a `RefinementLine`. You can have as many of these as you want. They are useful if you know regions of the solution where refinement is needed (e.g. a wake) or in problematic areas in the geometry.

To create a refinement center,

		[Return:Dict{String,Any}] newRefinementCenter!(proj::Project, type::String,
                          	 				           x0::Array{Float64}, h::Float64,
                          	 				           w::Float64 )

where the type is either `smooth` or `sharp`, `x0` = [x,y,z] is the location of the center, `h` is the mesh size, and `w` is the extent of the refinement region.

Similarly, one can create a `RefinementLine`,

		[Return:Dict{String,Any}] newRefinementLine!(proj::Project, type::String,
                            				         x0::Array{Float64}, x1::Array{Float64},
                           				             h::Float64,
                                                     w::Float64 )

where `x0` is the start postition and `x1` is the end of the line.

To add a refinement region to the project,

		[Return:nothing] addRefinementRegion!(proj::Project,r::Dict{String,Any})

To get the indx'th refinement region from the project, or to get
 a refinement region with a given name, use

		[Return:Dict{String,Any}] getRefinementRegion(proj::Project, indx::Int)
		[Return:Dict{String,Any}] getRefinementRegion(proj::Project, name::String)

Finally, to get a list of all the refinement regions,

		[Return:Array{Dict{String,Any}}] array = allRefinementRegions(proj::Project)

A refinement region can be edited by using the following

		[Return:nothing] 		 setRefinementType!(r::Dict{String,Any}, type::String)
		[Return:String]  		 getRefinementType(r::Dict{String,Any})
		[Return:nothing] 		 setRefinementLocation!(r::Dict{String,Any}, x::Array{Float64})
		[Return:Array{Float64}]  getRefinementLocation(r::Dict{String,Any})
		[Return:nothing] 		 setRefinementGridSize!(r::Dict{String,Any},h::Float64)
		[Return:float64] 		 getRefinementGridSize(r::Dict{String,Any})
		[Return:nothing] 		 setRefinementWidth!(r::Dict{String,Any},w::Float64)
		[Return:float64] 		 getRefinementWidth(r::Dict{String,Any})

where `r` is a dictionary returned by `newRefinementCenter!`, `newRefinementLine!`, or `getRefinementRegion`.

To further edit a `RefinementLine`, use the methods

		[Return:nothing] 		 setRefinementStart!(r::Dict{String,Any}, x::Array{Float64})
		[Return:Array{Float64}]  getRefinementStart(r::Dict{String,Any})
		[Return:nothing] 		 setRefinementEnd!(r::Dict{String,Any}, x::Array{Float64})
		[Return:Array{Float64}]  getRefinementEnd(r::Dict{String,Any})

### Boundary Curves

#### Adding and Removing Outer and Inner Boundaries

- Adding an outer boundary curve

	Using the curve creation routines, described in the next section below, create curves in sucessive order counter-clockwise along the outer boundary and add them to the outer boundary curve using

		[Return:nothing] addCurveToOuterBoundary!(proj::Project, crv::Dict{String,Any})
        Generic: add!(...)

	`crv` is the dictionary that represents the curve.

Example:

		add!(p,circ)

- Adding an inner boundary curve

		[Return:nothing] addCurveToInnerBoundary!(proj::Project, crv::Dict{String,Any}, boundaryName::String)
        Generic: add!(...)

Example:

		add!(p,cone1,"IceCreamCone")

To edit curves they can be accessed by name:

		[Return:Dict{String,Any}] getInnerBoundaryCurve(proj::Project, curveName::String, boundaryName::String)
        Generic: getCurve(...)
		[Return:Dict{String,Any}] getOuterBoundaryCurveWithName(proj::Project, name::String)
        Generic: getCurve(...)

- Deleting boundary curves

		[Return:nothing] removeOuterBoundaryCurveWithName!(proj::Project, name::String)
		Generic: remove!(...)
		[Return:nothing] removeInnerBoundaryCurve!(proj::Project, name::String, chainName::String)
		Generic: remove!(...)

#### Defining Curves

Four curve types can be added to the outer and inner boundary curve chains. They are

- parametricEquation
- endPointsLine
- circularArc
- spline


##### Parametric Equations

- Creating new

		[Return:Dict{String,Any}] newParametricEquationCurve(name::String,
        										             xEqn::String,
        										             yEqn::String,
        										             zEqn::String = "z(t) = 0.0" )
        Generic: new(...)

	Returns a new parametric equation. Equations must be of the form

		<function name>(<argument>) = ...

	The name of the function, and the argument are arbitrary. The equation 	can be any legitimate equation. The constant `pi` is defined for use. 	Exponention is done with `^`. All number literals are interpreted as 	floating point numbers.

	Example:

		x(s) = 2.0 + 3*cos(2*pi*s)^2

	The z-Equation is optional, but for now must define zero for z.

##### Line Defined by End Points

		[Return:Dict{String,Any}]  newEndPointsLineCurve(name::String,
                                       	                 xStart::Array{Float64},
                                                         xEnd::Array{Float64})
        Generic: new(...)

The `xStart` and `xEnd` are arrays of the form [x,y,z]. The `z` component should be zero and for now is ignored.

Example:

			cone1    = new("cone1", [0.0, -3.0, 0.0], [1.0, 0.0, 0.0])
##### Circular Arc

	[Return:Dict{String,Any}] newCircularArcCurve(name::String,
                        					      center::Array{Float64},
                        					      radius::Float64,
                        					      startAngle::Float64,
                        					      endAngle::Float64,
                        					      units::String)
        Generic: new(...)

 The center is an array of the form [x,y,z]. The units argument defines the start and end angle units, and is either "degrees" or "radians". That argument is optional, and defaults to "degrees".

Example:

		iceCream = new("iceCream", [0.0, 0.0, 0.0], 1.0, 0.0, 180.0, "degrees")

##### Spline Curve

A spline is defined by an array of knots,  t<sub>j</sub>,x<sub>j</sub>,y<sub>j</sub>,z<sub>j</sub>. It can either be supplied by a data file whose first line is the number of knots, and succeeding lines define the t,x,y,z values, e.g.

			9
			0.000000000000000 -3.50000000000000  3.50000000000000 0.0
			3.846153846153846E-002 -3.20000000000000  5.00000000000 0.0
			7.692307692307693E-002 -2.00000000000000  6.00000000000 0.0
			0.769230769230769  0.000000000000000 -1.00000000000000 0.0
			0.807692307692308 -1.00000000000000 -1.00000000000000 0.0
			0.846153846153846 -2.00000000000000 -0.800000000000000 0.0
			0.884615384615385 -2.50000000000000  0.000000000000000 0.0
			0.923076923076923 -3.00000000000000  1.00000000000000 0.0
			1.00000000000000 -3.50000000000000  3.50000000000000 0.0

or by constructing the Nx4 array supplying it to the new procedure. The constructors are

	[Return:Dict{String,Any}] newSplineCurve(name::String, nKnots::Int, data::Matrix{Float64})
	Generic: new(...)
	[Return:Dict{String,Any}] newSplineCurve(name::String, dataFile::String)
	Generic: new(...)

If the curve is to be closed. The last point must be the same as the first.

#### Editing Curves

You can determine the type of a curve by

		[Return:String] getCurveType(crv::Dict{String,Any})

For any of the curves, their name can be changed by

		setCurveName!(crv::Dict{String,Any}, name::String)

and checked by

		getCurveName(crv::Dict{String,Any})

Otherwise there are special functions to change the parameters of curves

		[Return:nothing] setXEqn!(crv::Dict{String,Any}, eqn::String)
		[Return:nothing] setYEqn!(crv::Dict{String,Any}, eqn::String)
		[Return:nothing] setZEqn!(crv::Dict{String,Any}, eqn::String)
		[Return:nothing] setStartPoint!(crv::Dict{String,Any}, point::Array{Float64})
		[Return:nothing] setEndPoint!(crv::Dict{String,Any}, point::Array{Float64})
		[Return:nothing] setArcUnits!(arc::Dict{String,Any}, units::String)
		[Return:nothing] setArcCenter!(arc::Dict{String,Any}, point::Array{Float64})
		[Return:nothing] setArcStartAngle!(arc::Dict{String,Any}, angle::Float64)
		[Return:nothing] setArcEndAngle!(arc::Dict{String,Any}, angle::Float64)
		[Return:nothing] setArcRadius!(arc::Dict{String,Any}, radius::Float64)

		[Return:String] 		getXEqn(crv::Dict{String,Any})
		[Return:String] 		getYEqn(crv::Dict{String,Any})
		[Return:String] 		getZEqn(crv::Dict{String,Any})
		[Return:Array{Float64}] getStartPoint(crv::Dict{String,Any})
		[Return:Array{Float64}] getEndPoint(crv::Dict{String,Any})
		[Return:String] 		getArcUnits(arc::Dict{String,Any})
		[Return:Array{Float64}] getArcCenter(arc::Dict{String,Any})
		[Return:Float64]		getArcStartAngle(arc::Dict{String,Any})
		[Return:Float64] 		getArcEndAngle(arc::Dict{String,Any})
		[Return:Float64] 		getArcRadius(arc::Dict{String,Any})

### Undo/Redo

The HQMTool has unlimited undo/redo for most actions.

In interactive mode, actions can be undone by the commands

		[Return:String] undo()
		[Return:String] redo()

where the return string contains the name of the action performed.

To find out what the next actions are, use

		[Return:String] undoName()
		[Return:String] redoName()

Finally, to clear the undo stack, use

		[Return:nothing] clearUndoRedo()

## Advanced

All curves are actually dictionaries of type `Dict{String,Any}`, and since Julia is not a particularly object oriented language, the parameters can be accessed and edited directly by key and value. In fact, all objects except for the Project, are of type `Dict{String,Any}`. The project holds all the control and model objects in its `projectDirectory`. However, if you do that, then undo/redo and plot updating won't happen.