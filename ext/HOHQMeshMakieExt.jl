# Package extension for adding Makie-based features to HOHQMesh.jl
module HOHQMeshMakieExt

# Required for visualization code
if isdefined(Base, :get_extension)
    using Makie
else
    # Until Julia v1.9 is the minimum required version for HOHQMesh.jl, we still support Requires.jl
    using ..Makie
end

# Use all exported symbols to avoid having to rewrite all the visualization routines
using HOHQMesh

# Use additional symbols that are not exported
using HOHQMesh: Project, hasBackgroundGrid, projectBounds, projectGrid

# Import functions such that they can be extended with new methods
import HOHQMesh: plotProject!, updatePlot!

include("VizMesh.jl")
include("VizProject.jl")

end