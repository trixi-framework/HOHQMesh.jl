
function generate_mesh(proj::Project)
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
    mesherOutput   = generate_mesh(fileName, output_directory = proj.projectDirectory)
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
