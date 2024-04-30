
"""
    generate_mesh(proj::Project; verbose=false, subdivision_maximum=8)

Generate a mesh from the information stored in a `Project` created using the
interactive mesh functionality. First a check is made
if a background grid exists and all inner/outer boundary curves are valid.

This function will then make a HOHQMesh control file from the control dictionary `proj.controlDict`
and use it to call the wrapper function that interfaces with HOHQMesh. The resulting mesh and control files
will be saved to `proj.projectDirectory`. Also, if there is an active plot of the mesh project it
will update to display the generated mesh.

With the optional argument `verbose` one can activate verbose output from HOHQMesh
that prints additional messages and debugging mesh information.

To override the maximum number of allowable subdivisions in the quad tree during meshing
adjust the value of `subdivision_maximum`. The default value of `subdivision_maximum` is 8,
meaning that elements can be up to a factor of `2^8` smaller than the background grid.
Note, think before doing this! It could be adjusting the boundary curves, background grid size,
adding local refinement regions, or some combination may remove the need to adjust
the subdivision depth.

This function returns the output to `stdout` of the HOHQMesh binary when generating the mesh.
"""
function generate_mesh(proj::Project; verbose=false, subdivision_maximum::Int=8)
#
#   Check to be sure background grid has been created (everything else is defaults)
#
    controlDict = getControlDict(proj)
    if !haskey(controlDict,"BACKGROUND_GRID")
        @warn "A background grid is needed before meshing. Add one and try again."
        return nothing
    end

    if !modelCurvesAreOK(proj)
        @warn "Meshing aborted: Ensure boundary curve segments are in order and boundary curves are closed and try again."
        return nothing
    end

    saveProject(proj)
    fileName       = joinpath(proj.projectDirectory,proj.name)*".control"
    mesherOutput   = generate_mesh(fileName; output_directory = proj.projectDirectory,
                                   verbose, subdivision_maximum)
    println(mesherOutput)
    postNotificationWithName(proj,"MESH_WAS_GENERATED_NOTIFICATION",(nothing,))
    return nothing
end


"""
    remove_mesh!(proj::Project)

Remove the mesh file from `proj.projectDirectory` and delete the mesh from the plot
"""
function remove_mesh!(proj::Project)
    meshFile = getMeshFileName(proj)
    rm(meshFile)
    proj.xMesh = Float64[]
    proj.yMesh = Float64[]
    postNotificationWithName(proj,"MESH_WAS_DELETED_NOTIFICATION",(nothing,))
end
