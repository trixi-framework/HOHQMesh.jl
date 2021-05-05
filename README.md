# HOHQMesh.jl

[![Build Status](https://github.com/trixi-framework/HOHQMesh.jl/workflows/CI/badge.svg)](https://github.com/trixi-framework/HOHQMesh.jl/actions?query=workflow%3ACI)

This package is a thin Julia wrapper around the *High Order Hex-Quad Mesher*
(a.k.a. **HOHQMesh**) created and developed by
[David A. Kopriva](https://www.math.fsu.edu/~kopriva/).

**Note: This package is currently _highly_ experimental!**


## Getting started

This package is still in proof-of-concept stage. Thus many things will not work
as convenient as they do for properly registered packages.

To install HOHQMesh.jl, you need to manually install it *and its dependency*
[HOHQMesh_jll](https://github.com/trixi-framework/HOHQMESH_jll.jl)
by executing the following lines in your Julia REPL:
```julia
julia> import Pkg

julia> Pkg.add(url="https://github.com/trixi-framework/HOHQMESH_jll.jl")

julia> Pkg.add(url="https://github.com/trixi-framework/HOHQMESH.jl")
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


## Authors
HOHQMesh.jl was initiated by
[Michael Schlottke-Lakemper](https://www.mi.uni-koeln.de/NumSim/schlottke-lakemper)
(University of Cologne, Germany), who is also the principal developer of HOHQMesh.jl.
The *HOHQMesh* mesh generator itself is developed by
[David A. Kopriva](https://www.math.fsu.edu/~kopriva/).


## License and contributing
HOHQMesh.jl is licensed under the MIT license (see [LICENSE.md](LICENSE.md)).
*HOHQMesh* itself is not available as open source.


## Acknowledgements
The authors would like to thank David A. Kopriva for making the sources of
*HOHQMesh* available to them, and for assisting with making it work with Julia.
