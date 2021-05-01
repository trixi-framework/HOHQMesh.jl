# HOHQMesh.jl

This package is a *thin* Julia wrapper around the *High Order Hex-Quad Mesher*
(a.k.a. **HOHQMesh**) created and developed by
[David A.  Kopriva](https://www.math.fsu.edu/~kopriva/).

**Note: This package is still _highly_ experimental!**


## Getting started

This package is still in proof-of-concept stage. Thus many things will not work
as convenient as they do for properly registered packages.

To install HOHQMesh.jl, you need to manually install it *and its dependency* by
executing the following lines in your Julia REPL:
```julia
julia> import Pkg

julia> Pkg.add(url="git@github.com:trixi-framework/HOHQMESH_jll.jl")

julia> Pkg.add(url="git@github.com:trixi-framework/HOHQMESH.jl")
```

Afterwards, you can just load HOHQMesh with
```julia
julia> using HOHQMesh
```
and then happily generate away!

Two examples from HOHQMesh itself (`GingerbreadMan` or `NACA0012`) come
delivered with this package. You can generate a mesh for them by executing
```julia
julia> control_file = joinpath(HOHQMesh.examples_dir(), "GingerbreadMan", "GingerbreadMan.control")

julia> output = generate_mesh(control_file)
```

You will then find the resulting output files (mesh, plot file, statistics) in
the designated output directory, which defaults to `out`.
