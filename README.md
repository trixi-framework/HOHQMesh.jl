# HOHQMesh.jl

[![Docs-stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://trixi-framework.github.io/HOHQMesh.jl/stable)
[![Docs-dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://trixi-framework.github.io/HOHQMesh.jl/dev)
[![Build Status](https://github.com/trixi-framework/HOHQMesh.jl/workflows/CI/badge.svg)](https://github.com/trixi-framework/HOHQMesh.jl/actions?query=workflow%3ACI)
[![Coveralls](https://coveralls.io/repos/github/trixi-framework/HOHQMesh.jl/badge.svg?branch=main)](https://coveralls.io/github/trixi-framework/HOHQMesh.jl?branch=main)
[![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/licenses/MIT)

This package is a thin Julia wrapper around the *High Order Hex-Quad Mesher*
(a.k.a. [**HOHQMesh**](https://github.com/trixi-framework/HOHQMesh)) created and developed by
[David A. Kopriva](https://www.math.fsu.edu/~kopriva/).
HOHQMesh.jl is available on Linux, MacOS, and Windows.


## Installation
If you have not yet installed Julia, please [follow the instructions for your
operating system](https://julialang.org/downloads/platform/). HOHQMesh.jl works
with Julia v1.6.

HOHQMesh.jl is a registered Julia package. Hence, you can install it by executing
the following commands in the Julia REPL:
```julia
julia> import Pkg; Pkg.add("HOHQMesh")
```
HOHQMesh.jl depends on the binary distribution of the
[HOHQMesh](https://github.com/trixi-framework/HOHQMesh)
mesh generator, which is available via the Julia package
[HOHQMesh_jll.jl](https://github.com/JuliaBinaryWrappers/HOHQMesh_jll.jl)
and which is automatically installed as a dependency.

## Usage
In the Julia REPL, you can load HOHQMesh with
```julia
julia> using HOHQMesh
```
and then happily generate away!

Two 2D examples `GingerbreadMan` and `NACA0012` and a 3D example `Snake` (all
from HOHQMesh itself) come delivered with this package. You can generate a
mesh for them by executing
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
HOHQMesh.jl is maintained by the
[Trixi authors](https://github.com/trixi-framework/Trixi.jl/blob/main/AUTHORS.md).
Its principal developers are [Andrew Winters](https://liu.se/en/employee/andwi94)
(Linköping University, Sweden) and
[David A. Kopriva](https://www.math.fsu.edu/~kopriva/).
The *HOHQMesh* mesh generator itself is developed by David A. Kopriva.


## License and contributing
HOHQMesh.jl is licensed under the MIT license (see [LICENSE.md](LICENSE.md)).
*HOHQMesh* itself is also available under the MIT license.


## Acknowledgements
The authors would like to thank David A. Kopriva for making the sources of
*HOHQMesh* available as open source, and for assisting with making it work with
Julia.
