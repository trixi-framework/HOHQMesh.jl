module HOHQMesh

# Include other packages that are used in HOHQMesh
# (standard library packages first, other packages next, all of them sorted alphabetically)

using HOHQMesh_jll: HOHQMesh_jll
using Requires: @require

function __init__()
  # Enable features that depend on the availability of the Makie package
  @require Makie="ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a" begin
    using .Makie
    include("Viz/VizProject.jl")
    include("Viz/VizMesh.jl")
    # Make the actual plotting routines available
    export plotProject!, updatePlot!
    # Make plotting constants available for easier use
    export MODEL, GRID, MESH, EMPTY, REFINEMENTS, ALL
  end
end

# Main wrapper to generate a mesh from a control file
export generate_mesh

# Make the examples directory available to the user
export examples_dir

# Functions useful to demonstrate the interactive HQMTool
#export run_demo, ice_cream_cone_verbose_demo, ice_cream_cone_demo
export ice_cream_cone_verbose_demo, ice_cream_cone_demo

# Generic functions for the HQMTool interface
export new,
       add!,
       getCurve,
       getInnerBoundary,
       remove!

#
#  TODO: Go through and cleanup this exporting.
#
# Functions from `BackgroundGridAPI.jl`
export addBackgroundGrid!,
       removeBackgroundGrid!,
       setBackgroundGridSize!,
       getBackgroundGridSize,
       getBackgroundGridLowerLeft,
       getBackgroundGridSteps,
       setBackgroundGridLowerLeft!,
       setBackgroundGridSteps!

# Functions from `ControlInputAPI.jl`
export getControlDict,
       getDictInControlDictNamed,
       getListInControlDictNamed

# Functions from `CurvesAPI.jl`
export newParametricEquationCurve,
       newEndPointsLineCurve,
       newCircularArcCurve,
       newSplineCurve,
       setCurveName!,
       getCurveName,
       getCurveType,
       setXEqn!, getXEqn,
       setYEqn!, getYEqn,
       setZEqn!, getZEqn,
       setStartPoint!,
       getStartPoint,
       setEndPoint!,
       getEndPoint,
       setArcUnits!,
       getArcUnits,
       setArcCenter!,
       getArcCenter,
       setArcStartAngle!,
       getArcStartAngle,
       setArcEndAngle!,
       getArcEndAngle,
       setArcRadius!,
       getArcRadius,
       setSplineNKnots!,
       getSplineNKnots,
       setSplinePoints!,
       getSplinePoints,
       curvePoint,
       curvePoints,
       peEquationCurvePoints,
       peEquationCurvePoint

# Functions from `ModelAPI.jl`
export addCurveToOuterBoundary!,
       removeOuterBoundaryCurveWithName!,
       getOuterBoundaryCurveWithName,
       insertOuterBoundaryCurveAtIndex!,
       removeOuterBoundaryCurveAtIndex!,
       addOuterBoundary!,
       removeOuterBoundary!,
       getOuterBoundaryChainList,
       addCurveToInnerBoundary!,
       removeInnerBoundaryCurve!,
       insertInnerBoundaryCurveAtIndex!,
       removeInnerBoundaryCurveAtIndex!,
       removeInnerBoundary!,
       addInnerBoundaryWithName!,
       getChainIndex,
       getAllInnerBoundaries,
       getInnerBoundaryChainWithName,
       getInnerBoundaryCurve,
       innerBoundaryIndices,
       getModelDict,
       getDictInModelDictNamed

# Functions from `Project.jl`
export openProject,
       saveProject,
       newProject,
       hasBackgroundGrid,
       assemblePlotArrays,
       projectBounds,
       projectGrid,
       curveDidChange,
       modelDidChange,
       backgroundGridDidChange,
       refinementWasAdded,
       refinementDidChange,
       meshWasGenerated,
       meshWasDeleted

# Functions from `RefinementRegionsAPI.jl`
export newRefinementCenter,
       addRefinementRegion!,
       addRefinementRegionPoints!,
       refinementRegionPoints,
       getRefinementRegionCenter,
       removeRefinementRegion!,
       insertRefinementRegion!,
       newRefinementLine,
       getRefinementRegion,
       getAllRefinementRegions,
       getRefinementRegion,
       setRefinementType!,
       getRefinementType,
       setRefinementName!,
       getRefinementName,
       setRefinementLocation!,
       getRefinementLocation,
       setRefinementGridSize!,
       getRefinementGridSize,
       setRefinementWidth!,
       getRefinementWidth,
       setRefinementStart!,
       getRefinementStart,
       setRefinementEnd!,
       getRefinementEnd

# Functions from `RunParametersAPI.jl`
export addRunParameters!,
       removeRunParameters!,
       setName!,
       getName,
       setPolynomialOrder!,
       getPolynomialOrder,
       setMeshFileFormat!,
       getMeshFileFormat,
       setPlotFileFormat!,
       getPlotFileFormat,
       setFileNames!,
       getMeshFileName,
       getPlotFileName,
       getStatsFileName

# Functions from `SmootherAPI.jl`
export addSpringSmoother!,
       setSmoothingStatus!,
       getSmoothingStatus,
       setSmoothingType!,
       getSmoothingType,
       setSmoothingIterations!,
       getSmoothingIterations,
       removeSpringSmoother!

# Functions from `Undo.jl`
export undo,
       redo,
       registerUndo,
       registerWithUndoManager,
       registerRedo,
       clearUndoRedo,
       undoActionName,
       redoActionName,
       disableUndo,
       enableUndo

# Functions from `Meshing.jl`, generate_mesh is already exported
export remove_mesh!


"""
    generate_mesh(control_file;
                  output_directory="out",
                  mesh_filename=nothing, plot_filename=nothing, stats_filename=nothing,
                  verbose=false)

Generate a mesh based on the `control_file` with the HOHQMesh mesh generator and store resulting
files in `output_directory`.

You can set the mesh filename, the plot filename, and the statistics filename using the keyword
arguments `mesh_filename`, `plot_filename`, and `stats_filename`, respectively. If set to `nothing`,
the filenames for the mesh file, plot file, and statistics file are generated automatically from the
control file name. For example, `path/to/ControlFile.control` will result in output files
`ControlFile.mesh`, `ControlFile.tec`, and `ControlFile.txt`.

You can activate verbose output from HOHQMesh that prints additional messages and debugging
mesh information with the keyword argument `verbose`.

This function returns the output to `stdout` of the HOHQMesh binary when generating the mesh.
"""
function generate_mesh(control_file;
                       output_directory="out",
                       mesh_filename=nothing, plot_filename=nothing, stats_filename=nothing,
                       verbose=false)
  @assert isfile(control_file) "'$control_file' is not a valid path to an existing file"

  # Determine output filenames
  filebase = splitext(basename(control_file))[1]
  if isnothing(mesh_filename)
    mesh_file_format = extract_mesh_file_format(control_file)
    if mesh_file_format == "ISM" || mesh_file_format == "ISM-V2" || mesh_file_format == "ISM-v2"
      mesh_filename = filebase * ".mesh"
    elseif mesh_file_format == "ABAQUS"
      mesh_filename = filebase * ".inp"
    else
      error("Unknown mesh file format: ", mesh_file_format, " (must be one of ISM, ISM-V2, or ABAQUS)")
    end
  end
  if isnothing(plot_filename)
    plot_filename = filebase * ".tec"
  end
  if isnothing(stats_filename)
    stats_filename = filebase * ".txt"
  end

  # Determine output filepaths
  mesh_filepath = joinpath(output_directory, mesh_filename)
  plot_filepath = joinpath(output_directory, plot_filename)
  stats_filepath = joinpath(output_directory, stats_filename)

  # Create output directory if it does not exist
  if !isdir(output_directory)
    mkdir(output_directory)
  end

  # Create temporary copy of mesh file to replace paths
  output = mktemp() do tmppath, tmpio
    # Update paths of output files
    lines = readlines(control_file, keep=true)
    for line in lines
      if occursin("mesh file name", line)
        write(tmpio, "      mesh file name   = " * mesh_filepath * "\n")
      elseif occursin("plot file name", line)
        write(tmpio, "      plot file name   = " * plot_filepath * "\n")
      elseif occursin("stats file name", line)
        write(tmpio, "      stats file name  = " * stats_filepath * "\n")
      else
        write(tmpio, line)
      end
    end
    flush(tmpio)

    # Run HOHQMesh and store output
    if verbose
      readchomp(`$(HOHQMesh_jll.HOHQMesh()) -verbose -f $tmppath`)
    else
      readchomp(`$(HOHQMesh_jll.HOHQMesh()) -f $tmppath`)
    end
  end

  String(output)
end


"""
    extract_mesh_file_format(control_file)

Return a string with the desired output format of the HOHQMesh generated mesh file.
This information is given within the `RUN_PARAMETERS` of the `CONTROL_INPUT` block
of the control file.
See the [`HOHQMesh` documentation](https://trixi-framework.github.io/HOHQMesh/) for details.
"""
function extract_mesh_file_format(control_file)
  # Find the file line that gives the mesh file format
  file_lines = readlines(open(control_file))
  line_index = findfirst(contains("mesh file format"), file_lines)
  # Extract the mesh file format keyword
  file_format = split(file_lines[line_index])[5]

  return file_format
end


"""
    examples_dir()

Return the path to the directory with some example mesh setups.
"""
examples_dir() = joinpath(pathof(HOHQMesh) |> dirname |> dirname, "examples")


#
# Include functionality for interactive reading and writing a model for HOHQMesh
# Note, The visualzation routines are included above in the `__init__` because
# Makie is required
#

# Core interactive tool routines for control file readin, curve evaluation, etc.
include("ControlFile/ControlFileOperations.jl")
include("Curves/CurveOperations.jl")
include("Curves/Spline.jl")
include("Misc/DictionaryOperations.jl")
include("Misc/NotificationCenter.jl")
include("Model/Geometry.jl")

# Project itself and some helper generic and undo functionality
include("Project/Project.jl")
include("Project/Generics.jl")
include("Project/Undo.jl")

# Front facing API of the interactive tool for the `Project`
include("Project/BackgroundGridAPI.jl")
include("Project/ControlInputAPI.jl")
include("Project/CurvesAPI.jl")
include("Project/ModelAPI.jl")
include("Project/RefinementRegionsAPI.jl")
include("Project/RunParametersAPI.jl")
include("Project/SmootherAPI.jl")

# Main routine that uses HOHQMesh to generate a mesh from an interactive `Project`
include("Mesh/Meshing.jl")

#
#---------------- Routines for demonstrating the HQMTool ---------------------------------
#

# function run_demo(folder::String; called_by_user=true)
# #
# # Reads in an existing control file, plots the boundary curves and generates
# # a mesh.
# #
#     all_features_control_file = joinpath( examples_dir() , "AllFeatures.control" )
#     p = openProject(all_features_control_file, folder)

#     plotProject!(p, MODEL+REFINEMENTS+GRID)
#     println("Press enter to continue and generate the mesh")
#     if called_by_user
#       readline()
#     end
#     generate_mesh(p)
#     return p
# end


# function ice_cream_cone_verbose_demo(folder::String; called_by_user=true)
# #
# # Create a project with the name "IceCreamCone", which will be the name of the mesh, plot and stats files,
# # written to `folder`.
# #
#     p = newProject("IceCreamCone", folder)
# #
# #   Outer boundary
# #
#     circ = newCircularArcCurve("outerCircle", [0.0,-1.0,0.0], 4.0, 0.0, 360.0, "degrees")
#     addCurveToOuterBoundary!(p, circ)
# #
# #   Inner boundary
# #
#     cone1    = newEndPointsLineCurve("cone1", [0.0,-3.0,0.0], [1.0,0.0,0.0])
#     iceCream = newCircularArcCurve("iceCream", [0.0,0.0,0.0], 1.0, 0.0, 180.0, "degrees")
#     cone2    = newEndPointsLineCurve("cone2", [-1.0,0.0,0.0], [0.0,-3.0,0.0])
#     addCurveToInnerBoundary!(p, cone1, "IceCreamCone")
#     addCurveToInnerBoundary!(p, iceCream, "IceCreamCone")
#     addCurveToInnerBoundary!(p, cone2, "IceCreamCone")
# #
# #   Set some control RunParameters to overwrite the defaults
# #
#     setPolynomialOrder!(p, 4)
#     setPlotFileFormat!(p, "sem")
# #
# #   To mesh, a background grid is needed
# #
#     addBackgroundGrid!(p, [0.5,0.5,0.0])
# #
# #   Show the model and grid
# #
#     plotProject!(p, MODEL+GRID)
#     println("Press enter to continue and generate the mesh")
#     if called_by_user
#       readline()
#     end
# #
# #   Generate the mesh and plot
# #
#     generate_mesh(p)

#     return p
# end


function ice_cream_cone_demo(folder::String; called_by_user=true)
#
# Create a project with the name "IceCreamCone", which will be the name of the mesh, plot and stats files,
# written to `path`.
#
    p = newProject("IceCreamCone", folder)
#
#   Outer boundary
#
    circ = new("outerCircle", [0.0,-1.0,0.0],4.0,0.0,360.0,"degrees")
    add!(p,circ)
#
#   Inner boundary
#
    cone1    = new("cone1", [0.0,-3.0,0.0], [1.0,0.0,0.0])
    iceCream = new("iceCream", [0.0,0.0,0.0], 1.0, 0.0, 180.0, "degrees")
    cone2    = new("cone2", [-1.0,0.0,0.0], [0.0,-3.0,0.0])
    add!(p, cone1, "IceCreamCone")
    add!(p, iceCream, "IceCreamCone")
    add!(p, cone2, "IceCreamCone")
#
#   To mesh, a background grid is needed
#
    addBackgroundGrid!(p, [0.5,0.5,0.0])
#
#   Set alternative file format and corresponding output file names
#
    setMeshFileFormat!(p, "ABAQUS")
    meshFileFormat = getMeshFileFormat(p)
    setFileNames!(p, meshFileFormat)
#
#   Show the model and grid
#
    plotProject!(p, MODEL+GRID)
    println("Press enter to continue and generate the mesh")
    if called_by_user
      readline()
    end
#
#   Generate the mesh and plot
#
    generate_mesh(p)

    return p
end


end # module
