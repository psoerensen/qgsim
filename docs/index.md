# qgsim

`qgsim` is a small teaching package for simulating multi-generational
pedigrees.

## Install qgsim

Install the package from GitHub in R:

``` r
install.packages("remotes")
remotes::install_github("psoerensen/qgsim")
```

## Example

``` r
library(qgsim)

ped <- simulate_pedigree(
  generations = 3,
  population_size = 100,
  selected_parents = 20,
  offspring_per_mating = 5
)
```

The result is one data frame with individual IDs, parents, generation,
and sex. Generation 1 contains founders with missing parents. Each later
generation is produced from selected males and females in the previous
generation.

## Gene dropping with R, C++, and Fortran engines

[`gene_drop_generation()`](https://psoerensen.github.io/qgsim/reference/gene_drop_generation.md)
simulates recombination and marker inheritance for one generation from
parental haplotypes and sire/dam row indices.

``` r
library(qgsim)

set.seed(1)
hap1 <- matrix(sample(0:1, 10 * 20, replace = TRUE), nrow = 10)
hap2 <- matrix(sample(0:1, 10 * 20, replace = TRUE), nrow = 10)
map <- seq(0, 1, length.out = 20)

sire <- c(1, 2, 3, 4)
dam <- c(5, 6, 7, 8)

gr <- gene_drop_generation(
  hap1 = hap1,
  hap2 = hap2,
  sire = sire,
  dam = dam,
  map = map,
  seed = 123,
  engine = "C++"
)

dim(gr$genotype)
```

The same call can use any supported engine:

``` r
gr_r <- gene_drop_generation(..., engine = "R")
gr_cpp <- gene_drop_generation(..., engine = "C++")
gr_fortran <- gene_drop_generation(..., engine = "Fortran")
```

R handles validation, random-event generation, and the user-facing
interface. C++ and Fortran apply the deterministic marker-level
inheritance loop. For the same seed, the engines are tested to produce
identical outputs.

Implementation files:

- [R wrapper and
  validation](https://github.com/psoerensen/qgsim/blob/main/R/gene-drop-generation.R)
- [C++
  implementation](https://github.com/psoerensen/qgsim/blob/main/src/gene_drop.cpp)
- [Fortran
  implementation](https://github.com/psoerensen/qgsim/blob/main/src/gene_drop_fortran.f90)
- [Native routine
  registration](https://github.com/psoerensen/qgsim/blob/main/src/init.c)
- [Cross-engine
  tests](https://github.com/psoerensen/qgsim/blob/main/tests/testthat/test-gene-drop-generation.R)

This is a simple single-chromosome teaching example that illustrates
compiled-code integration in an R package, not a complete production
breeding simulator. See the [gene-dropping
article](https://psoerensen.github.io/qgsim/articles/gene-dropping.html)
for more detail.

## Documentation

- [Package website](https://psoerensen.github.io/qgsim/)
- [Gene-dropping
  article](https://psoerensen.github.io/qgsim/articles/gene-dropping.html)
- [GitHub Desktop collaborator
  workflow](https://psoerensen.github.io/qgsim/articles/github-desktop-workflow.html)

This implementation is intentionally simple and intended for teaching.
It is not a scientifically complete breeding simulator.
