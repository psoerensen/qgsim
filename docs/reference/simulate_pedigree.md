# Simulate a multi-generational pedigree

Creates a simple pedigree for teaching and small examples. Generation 1
contains founders with missing parents. Each later generation is
produced from selected males and females in the previous generation.

## Usage

``` r
simulate_pedigree(
  generations,
  population_size,
  selected_parents,
  offspring_per_mating,
  seed = NULL
)
```

## Arguments

- generations:

  Number of generations, including the founder generation.

- population_size:

  Number of individuals in each generation.

- selected_parents:

  Number of parents selected from each previous generation.

- offspring_per_mating:

  Number of offspring generated per mating.

- seed:

  Optional integer random seed for reproducible results.

## Value

A data frame with columns `id`, `sire`, `dam`, `generation`, and `sex`.

## Examples

``` r
ped <- simulate_pedigree(
  generations = 3,
  population_size = 100,
  selected_parents = 20,
  offspring_per_mating = 5,
  seed = 123
)
```
