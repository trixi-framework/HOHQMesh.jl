
# Convenience constants to make plotting easier
const MODEL = 1; const GRID = 2; const MESH = 4; const EMPTY = 0
const REFINEMENTS = 8; const ALL = 15

# Add function definitions here such that they can be exported from HOHQMesh.jl
# and extended in the HOHQMeshMakieExt package extension or by the
# Makie-specific code loaded by Requires.jl

"""
    plotProject!(proj::Project, plotOptions::Int = 0)

Plot objects specified by the `plotOptions`. Construct the `plotOptions` by the sum
of what is to be drawn from the choices `MODEL`, `GRID`, `MESH`, `REFINEMENTS`.

Example: To plot the model and the grid, `plotOptions = MODEL + GRID`. To plot
just the mesh, `plotOptions = MESH`.

To plot everything, `plotOptions = MODEL + GRID + MESH + REFINEMENTS`

Contents are overlaid in the order: `GRID`, `MESH`, `MODEL`, `REFINEMENTS`

!!! note "Requires Makie.jl"
    Please note that for this function to work, you need to load Makie.jl
    in your REPL (e.g., by calling `using GLMakie`).
"""
function plotProject! end
# Note: The function implementation is found in `ext/VizProject.jl`.


"""
    updatePlot!(proj::Project, plotOptions::Int)

Replot with the new plotOptions = combinations (sums) of

    GRID, MESH, MODEL, REFINEMENTS

Example: `updatePlot!(p, MESH + MODEL)`

!!! note "Requires Makie.jl"
    Please note that for this function to work, you need to load Makie.jl
    in your REPL (e.g., by calling `using GLMakie`).
"""
function updatePlot! end
# Note: The function implementation is found in `ext/VizProject.jl`.