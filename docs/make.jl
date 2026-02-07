using Documenter
import Pkg
using HOHQMesh
using Changelog: Changelog

# Define module-wide setups such that the respective modules are available in doctests
DocMeta.setdocmeta!(HOHQMesh,     :DocTestSetup, :(using HOHQMesh);     recursive=true)

# Get HOHQMesh root directory
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
write(joinpath(@__DIR__, "src", "index.md"), readme_text)

# Create changelog
Changelog.generate(Changelog.Documenter(),                        # output type
                   joinpath(@__DIR__, "..", "NEWS.md"),           # input file
                   joinpath(@__DIR__, "src", "changelog_tmp.md"); # output file
                   repo = "trixi-framework/HOHQMesh.jl",          # default repository for links
                   branch = "main",)
# Fix edit URL of changelog
open(joinpath(@__DIR__, "src", "changelog.md"), "w") do io
    for line in eachline(joinpath(@__DIR__, "src", "changelog_tmp.md"))
        if startswith(line, "EditURL")
            line = "EditURL = \"https://github.com/trixi-framework/HOHQMesh.jl/blob/main/NEWS.md\""
        end
        println(io, line)
    end
end
# Remove temporary file
rm(joinpath(@__DIR__, "src", "changelog_tmp.md"))

# Make documentation
makedocs(;
    # Specify modules for which docstrings should be shown
    modules = [HOHQMesh],
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
        "Changelog" => "changelog.md",
        "Authors" => "authors.md",
        "Contributing" => "contributing.md",
        "Code of Conduct" => "code_of_conduct.md",
        "License" => "license.md"])

deploydocs(
    repo = "github.com/trixi-framework/HOHQMesh.jl",
    devbranch = "main",
    # Only push previews if all the relevant environment variables are non-empty.
    push_preview = all(!isempty,
                       (get(ENV, "GITHUB_TOKEN", ""),
                        get(ENV, "DOCUMENTER_KEY", "")))
)
