
# Convenience constants to make plotting easier
const MODEL = 1; const GRID = 2; const MESH = 4; const EMPTY = 0
const REFINEMENTS = 8; const ALL = 15

# Add function definitions here such that they can be exported from HOHQMesh.jl
# and extended in the HOHQMeshMakieExt package extension or by the
# Makie-specific code loaded by Requires.jl
function plotProject! end
function updatePlot! end