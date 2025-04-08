using Documenter
import Pkg
using HOHQMesh

# Define module-wide setups such that the respective modules are available in doctests
DocMeta.setdocmeta!(HOHQMesh,     :DocTestSetup, :(using HOHQMesh);     recursive=true)

# Get Trixi root directory
hohqmesh_root_dir = dirname(@__DIR__)

# Copy list of authors to not need to synchronize it manually.
# Since the authors header exists twice we create a unique identifier for the docs section.
authors_text = read(joinpath(dirname(@__DIR__), "AUTHORS.md"), String)
authors_text = replace(authors_text,
                       "# Authors" => "# [Authors](@id hohqmesh_authors)")
write(joinpath(@__DIR__, "src", "authors.md"), authors_text)

# Copy code of conduct to not need to synchronize it manually
code_of_conduct_text = read(joinpath(dirname(@__DIR__), "CODE_OF_CONDUCT.md"), String)
code_of_conduct_text = replace(code_of_conduct_text,
                               "[AUTHORS.md](AUTHORS.md)" => "[Authors](@ref hohqmesh_authors)")
write(joinpath(@__DIR__, "src", "code_of_conduct.md"), code_of_conduct_text)

# Copy contributing information to not need to synchronize it manually
contributing_text = read(joinpath(dirname(@__DIR__), "CONTRIBUTING.md"), String)
contributing_text = replace(contributing_text,
                            "[LICENSE.md](LICENSE.md)" => "[License](@ref)",
                            "[AUTHORS.md](AUTHORS.md)" => "[Authors](@ref hohqmesh_authors)")
write(joinpath(@__DIR__, "src", "contributing.md"), contributing_text)

# Copy contents form README to the starting page to not need to synchronize it manually
readme_text = read(joinpath(dirname(@__DIR__), "README.md"), String)
readme_text = replace(readme_text,
                      "[LICENSE.md](LICENSE.md)" => "[License](@ref)",
                      "[CONTRIBUTING.md](CONTRIBUTING.md)" => "[Contributing](@ref)",
                      "[AUTHORS.md](AUTHORS.md)" => "[Authors](@ref hohqmesh_authors)",
                      "<p" => "```@raw html\n<p",
                      "p>" => "p>\n```",
                      r"\[comment\].*\n" => "")    # remove comments
write(joinpath(@__DIR__, "src", "home.md"), readme_text)

# Make documentation
makedocs(;
    # Specify modules for which docstrings should be shown
    modules = [HOHQMesh],
    repo = "https://github.com/trixi-framework/HOHQMesh.jl/blob/{commit}{path}#{line}",
    # Set sitename to HOHQMesh
    sitename="HOHQMesh.jl",
    # Provide additional formatting options
    format = Documenter.HTML(;
                             # Disable pretty URLs during manual testing
                             prettyurls = get(ENV, "CI", "false") == "true",
                             # Set canonical URL to GitHub pages URL
                             canonical = "https://trixi-framework.github.io/HOHQMesh.jl/stable",
                             edit_link = "main",
                             size_threshold_ignore = ["index.md"],),
    # Explicitly specify documentation structure
    pages = [
        "Home" => "index.md",
        "Interactive mesh generation" => [
            "interactive_overview.md",
            "guided-tour.md",
            "interactive-api.md",
            "CheatSheet.md",
        ],
        "Tutorials" => [
            "Overview" => joinpath("tutorials", "introduction.md"),
            joinpath("tutorials", "straight_outer_boundary.md"),
            joinpath("tutorials", "curved_outer_boundary.md"),
            joinpath("tutorials", "spline_curves.md"),
            joinpath("tutorials", "create_edit_curves.md"),
            joinpath("tutorials", "symmetric_mesh.md"),
        ],
        "Advanced topics & developers" => [
            "Development" => "development.md",
            "GitHub & Git" => "github-git.md",
            "Testing" => "testing.md",
        ],
        "Reference" => "reference.md",
        "Authors" => "authors.md",
        "Contributing" => "contributing.md",
        "License" => "license.md"],
        )

deploydocs(
    repo = "github.com/trixi-framework/HOHQMesh.jl",
    devbranch = "main",
    push_preview = true
)
