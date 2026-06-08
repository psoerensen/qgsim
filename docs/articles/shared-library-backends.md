# Optional shared-library backend examples

qgsim can orchestrate simulation engines implemented outside R while
keeping the common workflow:

``` text
breeding_scheme() -> qgsim_compile() -> qgsim_validate()
                  -> qgsim_run() -> qgsim_result
```

The repository includes two small developer examples:

- [C++ shared-library
  backend](https://github.com/psoerensen/qgsim/blob/main/inst/examples/cpp_backend/README.md)
- [Fortran shared-library
  backend](https://github.com/psoerensen/qgsim/blob/main/inst/examples/fortran_backend/README.md)

Each example demonstrates the backend stages `translate()`, `execute()`,
and `collect()`, calls a toy native function from a shared library, and
converts the output into a valid `qgsim_result`.

These examples are optional, compiler-dependent developer guidance. They
are not scientifically complete simulators, are not built during qgsim
installation, and are not required by the package test suite. Building
them requires a compatible C++ or Fortran compiler configured for
`R CMD SHLIB`.
