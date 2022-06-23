# Development

## Text editors
When writing code, the choice of text editor can have a significant impact on
productivity and developer satisfaction. While using the default text editor
of the operating system has its own benefits (specifically the lack of an explicit
installation procure), usually it makes sense to switch to a more
programming-friendly tool. In the following, a few of the many options are
listed and discussed:

### VS Code
[Visual Studio Code](https://code.visualstudio.com/) is a modern open source
editor with [good support for Julia](https://github.com/julia-vscode/julia-vscode).
While [Juno](#Juno) had some better support in the past, the developers of Juno
and the Julia VS Code plugin are joining forces and concentrating on VS Code
since support of Atom has been suspended. Basically, all comments on [Juno](#Juno)
below also apply to VS Code.

### Juno
If you are new to programming or do not have a preference for a text editor
yet, [Juno](https://junolab.org) is a good choice for developing Julia code.
It is based on *Atom*, a sophisticated and widely used editor for software
developers, and is enhanced with several Julia-specific features. Furthermore
and especially helpful for novice programmers, it has a MATLAB-like
appearance with easy and interactive access to the current variables, the
help system, and a debugger.

### Vim or Emacs
Vim and Emacs are both very popular editors that work great with Julia. One
of their advantages is that they are text editors without a GUI and as such
are available for almost any operating system. They also are preinstalled on
virtually all Unix-like systems.  However, Vim and Emacs come with their own,
steep learning curve if they have never been used before. Therefore, if in doubt, it
is probably easier to get started with a classic GUI-based text editor (like
Juno). If you decide to use Vim or Emacs, make sure that you install the
corresponding Vim plugin
[julia-vim](https://github.com/JuliaEditorSupport/julia-vim) or Emacs major
mode [julia-emacs](https://github.com/JuliaEditorSupport/julia-emacs).



## Releasing a new version of HOHQMesh

- Check whether everything is okay, tests pass etc.
- Set the new version number in `Project.toml` according to the Julian version of semver.
  Commit and push.
- Comment `@JuliaRegistrator register` on the commit setting the version number.
- `JuliaRegistrator` will create a PR with the new version in the General registry.
  Wait for it to be merged.
- Increment the version number in `Project.toml` again with suffix `-pre`. For example,
  if you have released version `v0.2.0`, use `v0.2.1-pre` as new version number.



## Preview the documentation

You can build the documentation of HOHQMesh.jl locally by running
```bash
julia --project=docs -e 'using Pkg; Pkg.instantiate(); include("docs/make.jl")'
```
from the HOHQMesh.jl main directory. Then, you can look at the html files generated in
`docs/build`.
For PRs triggered from branches inside the HOHQMesh.jl main repository previews of
the new documentation are generated at `https://trixi-framework.github.io/HOHQMesh.jl/previews/PRXXX`,
where `XXX` is the number of the PR.
Note, this does not work for PRs from forks for security reasons (since anyone could otherwise push
arbitrary stuff, including malicious code).