# qgsim

`qgsim` provides a small R-facing specification, validation, backend dispatch,
and standardized result layer for breeding-scheme simulation tools.

Version 0.0.1 includes one pure-R reference backend. It exists to establish and
test the backend contract; it is not intended to be a scientifically complete
breeding simulator.

```r
library(qgsim)

scheme <- breeding_scheme(
  generations = 3,
  population_size = 100,
  selected_parents = 20,
  offspring_per_mating = 5
)

plan <- qgsim_compile(
  scheme = scheme,
  seed = 123,
  outputs = output_spec(
    populations = TRUE,
    metrics = "mean_breeding_value"
  )
)

result <- qgsim_run(plan, backend = "r_reference")

qgsim_metrics(result)
qgsim_populations(result)
```

The execution flow is deliberately explicit:

```text
breeding_scheme() -> qgsim_compile() -> qgsim_validate()
                  -> qgsim_run() -> qgsim_result
```

Future backend packages can translate the same validated plan for C++, Fortran,
Python, or Julia implementations while returning the same result schema.

## Developer examples

Optional, compiler-dependent examples show how a backend can call a small
shared library while preserving the `translate()`, `execute()`, and `collect()`
stages:

- [C++ shared-library backend](inst/examples/cpp_backend/README.md)
- [Fortran shared-library backend](inst/examples/fortran_backend/README.md)

These are developer guidance only. They are not installed backends, are not
scientifically complete simulators, and are not required by package tests.

Collaborators who prefer GitHub Desktop and RStudio can follow the
[GitHub Desktop collaborator workflow](vignettes/articles/github-desktop-workflow.Rmd),
which is also published with the pkgdown articles.
