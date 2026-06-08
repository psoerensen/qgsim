# Compile a breeding-scheme specification

Compile a breeding-scheme specification

## Usage

``` r
qgsim_compile(scheme, seed = 1L, outputs = output_spec())
```

## Arguments

- scheme:

  A `qgsim_scheme` created by
  [`breeding_scheme()`](https://psoerensen.github.io/qgsim/reference/breeding_scheme.md).

- seed:

  Integer random seed.

- outputs:

  A `qgsim_outputs` created by
  [`output_spec()`](https://psoerensen.github.io/qgsim/reference/output_spec.md).

## Value

A validated object of class `qgsim_plan`.
