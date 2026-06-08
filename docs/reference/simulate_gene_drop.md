# Simulate gene dropping through a pedigree

Simulates a simple single-chromosome gene-dropping example. The supplied
base haplotypes form generation 0. In each subsequent generation,
selected parents produce offspring whose paternal and maternal
haplotypes are formed by recombination.

## Usage

``` r
simulate_gene_drop(
  base_haplotypes,
  map,
  generations,
  population_size,
  selected_parents,
  offspring_per_mating,
  sample_size = population_size,
  seed = NULL,
  keep = c("sample", "all")
)
```

## Arguments

- base_haplotypes:

  A list containing `hap1` and `hap2`, both 0/1 matrices with
  individuals in rows and markers in columns.

- map:

  Numeric vector of marker positions in Morgans. Positions must be
  finite, non-missing, non-decreasing, and span a positive chromosome
  length.

- generations:

  Number of generations to simulate after generation 0.

- population_size:

  Number of offspring in each simulated generation.

- selected_parents:

  Total number of parents selected from each previous generation. At
  least two parents are required.

- offspring_per_mating:

  Number of offspring generated per mating.

- sample_size:

  Number of individuals sampled from the final generation.

- seed:

  Optional non-negative integer random seed.

- keep:

  Whether returned haplotypes should contain only sampled individuals
  (`"sample"`) or all simulated individuals (`"all"`).

## Value

An object of class `qgsim_gene_drop`, containing the pedigree, retained
haplotypes, sampled individuals, map, and simulation parameters.

## Details

This function is intended for teaching and small examples. It is not a
scientifically complete breeding simulator.

## Examples

``` r
base <- list(
  hap1 = matrix(c(0, 0, 1, 1, 0, 1, 0, 1), nrow = 4, byrow = TRUE),
  hap2 = matrix(c(1, 1, 0, 0, 1, 0, 1, 0), nrow = 4, byrow = TRUE)
)

result <- simulate_gene_drop(
  base_haplotypes = base,
  map = c(0, 0.5),
  generations = 2,
  population_size = 4,
  selected_parents = 4,
  offspring_per_mating = 2,
  sample_size = 2,
  seed = 123
)
```
