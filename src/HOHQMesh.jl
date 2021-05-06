module HOHQMesh

import HOHQMesh_jll

export generate_mesh


"""
    generate_mesh(control_file;
                  output_directory="out",
                  mesh_filename=nothing, plot_filename=nothing, stats_filename=nothing)

Generate a mesh based on the `control_file` with the HOHQMesh mesh generator and store resulting
files in `output_directory`.

You can set the mesh filename, the plot filename, and the statistics filename using the keyword
arguments `mesh_filename`, `plot_filename`, and `stats_filename`, respectively. If set to `nothing`,
the filenames for the mesh file, plot file, and statistics file are generated automatically from the
control file name. For example, `path/to/ControlFile.control` will result in output files
`ControlFile.mesh`, `ControlFile.tec`, and `ControlFile.txt`.

This function returns the output to `stdout` of the HOHQMesh binary when generating the mesh.
"""
function generate_mesh(control_file;
                       output_directory="out",
                       mesh_filename=nothing, plot_filename=nothing, stats_filename=nothing)
  @assert isfile(control_file) "'$control_file' is not a valid path to an existing file"

  # Determine output filenames
  filebase = splitext(basename(control_file))[1]
  if isnothing(mesh_filename)
    mesh_filename = filebase * ".mesh"
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
    readchomp(`$(HOHQMesh_jll.HOHQMesh()) -f $tmppath`)
  end

  String(output)
end


"""
    examples_dir()

Return the path to the directory with some example mesh setups.
"""
examples_dir() = joinpath(pathof(HOHQMesh) |> dirname |> dirname, "examples")


end # module
