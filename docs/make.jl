using Documenter
import Pkg
using HOHQMesh

# Define module-wide setups such that the respective modules are available in doctests
DocMeta.setdocmeta!(HOHQMesh,     :DocTestSetup, :(using HOHQMesh);     recursive=true)

# Get Trixi root directory
hohqmesh_root_dir = dirname(@__DIR__)

# Copy list of authors to not need to synchronize it manually
authors_text = read(joinpath(hohqmesh_root_dir, "AUTHORS.md"), String)
write(joinpath(@__DIR__, "src", "authors.md"), authors_text)

# Make documentation
makedocs(
    # Specify modules for which docstrings should be shown
    modules = [HOHQMesh],
    # Set sitename to HOHQMesh
    sitename="HOHQMesh.jl",
    # Provide additional formatting options
    format = Documenter.HTML(
        # Disable pretty URLs during manual testing
        prettyurls = get(ENV, "CI", nothing) == "true",
        # Explicitly add favicon as asset
        # assets = ["assets/favicon.ico"],
        # Set canonical URL to GitHub pages URL
        canonical = "https://trixi-framework.github.io/HOHQMesh.jl/stable"
    ),
    # Explicitly specify documentation structure
    pages = [
        "Home" => "index.md",
        "HQMTool" => [
            "HQMTool.md",
            "HQMTool_Tour.md",
            "HQMTool_API.md",
            "CheatSheet.md",
            ],
        "Topics for developers" => [
            "Development" => "development.md",
            "GitHub & Git" => "github-git.md",
            "Testing" => "testing.md",
        ],
        "Reference" => "reference.md",
        "Authors" => "authors.md",
        "Contributing" => "contributing.md",
        "License" => "license.md"
    ],
    strict = true # to make the GitHub action fail when doctests fail, see https://github.com/neuropsychology/Psycho.jl/issues/34
)

deploydocs(
    repo = "github.com/trixi-framework/HOHQMesh.jl",
    devbranch = "main",
    push_preview = true
)
