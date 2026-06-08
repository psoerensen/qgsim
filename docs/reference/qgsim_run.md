# Run a compiled breeding-scheme simulation

Run a compiled breeding-scheme simulation

## Usage

``` r
qgsim_run(plan, backend = "r_reference", workdir = NULL)
```

## Arguments

- plan:

  A validated `qgsim_plan`.

- backend:

  Name of a registered backend.

- workdir:

  Optional working directory. A temporary directory is used by default.

## Value

A standardized `qgsim_result`.
