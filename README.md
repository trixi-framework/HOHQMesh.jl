# HOHQMesh.jl

<!-- [![Docs-stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://trixi-framework.github.io/HOHQMesh.jl/stable) -->
[![Docs-dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://trixi-framework.github.io/HOHQMesh.jl/dev)
[![Build Status](https://github.com/trixi-framework/HOHQMesh.jl/workflows/CI/badge.svg)](https://github.com/trixi-framework/HOHQMesh.jl/actions?query=workflow%3ACI)
[![Coveralls](https://coveralls.io/repos/github/trixi-framework/HOHQMesh.jl/badge.svg?branch=main)](https://coveralls.io/github/trixi-framework/HOHQMesh.jl?branch=main)
[![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/licenses/MIT)

This package is a thin Julia wrapper around the *High Order Hex-Quad Mesher*
(a.k.a. **HOHQMesh**) created and developed by
[David A. Kopriva](https://www.math.fsu.edu/~kopriva/).
HOHQMesh.jl is available on Linux, MacOS, and Windows.

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

Two 2D examples from HOHQMesh itself (`GingerbreadMan` or `NACA0012`) and a 3D
example (`Snake`) come delivered with this package. You can generate a mesh for
them by executing
```julia
julia> control_file = joinpath(HOHQMesh.examples_dir(), "GingerbreadMan.control")

julia> output = generate_mesh(control_file)
```
You will then find the resulting output files (mesh, plot file, statistics) in
the designated output directory, which defaults to `out`. The
`GingerbreadMan.control` file will yield the following mesh,

![gingerbreadman_with_edges_400px](https://user-images.githubusercontent.com/3637659/117241938-80f4ee80-ae34-11eb-854a-ebebcd0b9d88.png)

while the 3D file `Snake.control` produces this mesh:

![snake_400px](https://user-images.githubusercontent.com/3637659/117241963-8ce0b080-ae34-11eb-9b79-d091807d9a23.png)


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
