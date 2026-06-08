# Gene drop one generation

Simulates Mendelian inheritance with recombination for a complete
generation. Each offspring receives one gamete from its sire and one
from its dam. Random inheritance events are generated in R, then applied
by the selected R, C++, or Fortran marker loop.

## Usage

``` r
gene_drop_generation(
  hap1,
  hap2,
  sire,
  dam,
  map,
  seed = NULL,
  engine = c("R", "C++", "Fortran"),
  return_haplotypes = TRUE
)
```

## Arguments

- hap1, hap2:

  Numeric or integer 0/1 matrices containing the two parental
  haplotypes. Rows are parents and columns are markers.

- sire, dam:

  Integer-like vectors giving the parental row indices for each
  offspring.

- map:

  Numeric vector of marker positions in Morgans. Positions must be
  finite, non-missing, non-decreasing, and span a positive chromosome
  length.

- seed:

  `NULL` or a single integer-like random seed.

- engine:

  Implementation used to apply inheritance events.

- return_haplotypes:

  Whether to include transmitted paternal and maternal haplotypes in the
  result.

## Value

A list containing the offspring `genotype`, mating design, map, and
selected engine. When `return_haplotypes = TRUE`, the list also contains
transmitted paternal `hap1` and maternal `hap2` matrices.

## Details

This is a simple single-chromosome teaching example, not a
scientifically complete breeding simulator.

## Examples

``` r
hap1 <- matrix(c(0, 0, 1, 1, 0, 1, 0, 1), nrow = 2, byrow = TRUE)
hap2 <- 1L - hap1

gene_drop_generation(
  hap1,
  hap2,
  sire = c(1, 2),
  dam = c(2, 1),
  map = c(0, 0.5, 0.8, 1),
  seed = 123
)
#> $genotype
#>      [,1] [,2] [,3] [,4]
#> [1,]    0    1    2    0
#> [2,]    1    2    0    1
#> 
#> $sire
#> [1] 1 2
#> 
#> $dam
#> [1] 2 1
#> 
#> $map
#> [1] 0.0 0.5 0.8 1.0
#> 
#> $engine
#> [1] "R"
#> 
#> $hap1
#>      [,1] [,2] [,3] [,4]
#> [1,]    0    1    1    0
#> [2,]    0    1    0    1
#> 
#> $hap2
#>      [,1] [,2] [,3] [,4]
#> [1,]    0    0    1    0
#> [2,]    1    1    0    0
#> 
```
