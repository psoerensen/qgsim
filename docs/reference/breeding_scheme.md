# Define a minimal breeding scheme

Define a minimal breeding scheme

## Usage

``` r
breeding_scheme(
  generations,
  population_size,
  selected_parents,
  offspring_per_mating
)
```

## Arguments

- generations:

  Number of offspring generations to simulate.

- population_size:

  Number of individuals in each generation.

- selected_parents:

  Number of parents randomly selected each generation.

- offspring_per_mating:

  Number of offspring produced by each mating.

## Value

An object of class `qgsim_scheme`.
