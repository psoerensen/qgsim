# Optional C++ shared-library backend example

This developer example shows the shape of a qgsim backend that calls a native
C++ function through `.Call()`. The native function only adds a generation-
specific increment to a numeric vector. It is intentionally a toy calculation,
not a scientifically complete breeding-scheme simulator.

The R script keeps backend responsibilities separate:

- `cpp_translate()` converts a validated `qgsim_plan` to simple native input.
- `cpp_execute()` calls the shared-library function for each generation.
- `cpp_collect()` converts native output to a validated `qgsim_result`.

From this directory, build and run the example with:

```r
Rscript build.R
Rscript test_cpp_backend.R
```

Building requires the C++ toolchain used by `R CMD SHLIB`. The example is
optional: qgsim installation and package tests do not build or run it.
Generated object files and shared libraries are ignored by git.

The script uses the internal `.new_qgsim_backend()` and `.new_qgsim_result()`
constructors because qgsim currently exposes backend registration, but not
those strict constructors, as public API. A production backend package should
pin compatible qgsim versions and keep this adapter code isolated.
