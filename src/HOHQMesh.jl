module HOHQMesh

# Include other packages that are used in HOHQMesh
# (standard library packages first, other packages next, all of them sorted alphabetically)

using HOHQMesh_jll: HOHQMesh_jll
using Requires: @require

export generate_mesh


function __init__()
  # Enable features that depend on the availability of the Makie package
  @require Makie="ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a" begin
    using .Makie
  end
end


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


# FIXME: Include this in a proper way
include("HQMTool.jl")

end # module
