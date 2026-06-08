# qgsim

`qgsim` provides a small R-facing specification, validation, backend dispatch,
and standardized result layer for breeding-scheme simulation tools.

Version 0.0.1 includes one pure-R reference backend. It exists to establish and
test the backend contract; it is not intended to be a scientifically complete
breeding simulator.

## Install qgsim

If you only want to use `qgsim`, install it from GitHub in R:

```r
install.packages("remotes")
remotes::install_github("psoerensen/qgsim")
library(qgsim)
```

## Example

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

## Documentation

The package website is available at:

<https://psoerensen.github.io/qgsim/>

Useful articles:

- [GitHub Desktop collaborator workflow](https://psoerensen.github.io/qgsim/articles/github-desktop-workflow.html)
- [Shared-library backend guide](https://psoerensen.github.io/qgsim/articles/shared-library-backends.html)

## Contributing to development

If you want to contribute to `qgsim` development, clone the repository rather
than only installing the package.

On Linux or macOS, for example:

```bash
mkdir -p ~/GitHub
cd ~/GitHub
git clone https://github.com/psoerensen/qgsim.git
cd qgsim
```

After `cd qgsim`, you are in the repository root. This is the folder that
contains files and folders such as:

```text
DESCRIPTION
README.md
qgsim.Rproj
R/
tests/
vignettes/
```

Run Git commands from this folder.

On Windows, collaborators who prefer GitHub Desktop and RStudio can follow the
[GitHub Desktop collaborator workflow](https://psoerensen.github.io/qgsim/articles/github-desktop-workflow.html).

For command-line Git workflows, the same article includes a short section with
standard Git commands.

## Developer examples

Optional, compiler-dependent examples show how a backend can call a small
shared library while preserving the `translate()`, `execute()`, and `collect()`
stages:

- [Shared-library backend guide](https://psoerensen.github.io/qgsim/articles/shared-library-backends.html)

These are developer guidance only. They are not installed backends, are not
scientifically complete simulators, and are not required by package tests.
