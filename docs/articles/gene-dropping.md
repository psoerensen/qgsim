# Simple gene dropping

Gene dropping follows alleles from a base population through a simulated
pedigree. Each offspring receives one recombined haplotype from its sire
and one from its dam. This provides a small teaching example of
inheritance over multiple generations.

## Base haplotypes

[`simulate_gene_drop()`](https://psoerensen.github.io/qgsim/reference/simulate_gene_drop.md)
represents a diploid base population with two matrices, `hap1` and
`hap2`. Rows are individuals, columns are markers, and values are 0/1
alleles.

``` r
library(qgsim)

base_haplotypes <- list(
  hap1 = matrix(
    c(0, 0, 1, 1,
      0, 1, 0, 1,
      1, 0, 1, 0,
      1, 1, 0, 0),
    nrow = 4,
    byrow = TRUE
  ),
  hap2 = matrix(
    c(1, 1, 0, 0,
      1, 0, 1, 0,
      0, 1, 0, 1,
      0, 0, 1, 1),
    nrow = 4,
    byrow = TRUE
  )
)

map <- c(0, 0.2, 0.7, 1)
```

The map gives marker positions in Morgans on one chromosome. This first
version models only a single chromosome.

## Drop one complete generation

[`gene_drop_generation()`](https://psoerensen.github.io/qgsim/reference/gene_drop_generation.md)
applies a supplied mating design to a parental population. The `sire`
and `dam` vectors contain parental row indices, with one pair for each
offspring. This makes the generation-level function useful when the
mating design has already been selected by another part of a simulation.

``` r
generation <- gene_drop_generation(
  hap1 = base_haplotypes$hap1,
  hap2 = base_haplotypes$hap2,
  sire = c(1, 2, 1, 4),
  dam = c(3, 4, 2, 1),
  map = map,
  seed = 123,
  engine = "R"
)

generation$genotype
```

    ##      [,1] [,2] [,3] [,4]
    ## [1,]    1    0    0    1
    ## [2,]    0    0    2    0
    ## [3,]    1    0    1    0
    ## [4,]    1    1    1    0

``` r
generation$hap1
```

    ##      [,1] [,2] [,3] [,4]
    ## [1,]    0    0    0    0
    ## [2,]    0    0    1    0
    ## [3,]    0    0    0    0
    ## [4,]    0    0    0    0

``` r
generation$hap2
```

    ##      [,1] [,2] [,3] [,4]
    ## [1,]    1    0    0    1
    ## [2,]    0    0    1    0
    ## [3,]    1    0    1    0
    ## [4,]    1    1    1    0

For every offspring, the function creates one recombined gamete from the
sire and one from the dam. Their sum is the offspring genotype, coded 0,
1, or 2 at each marker.

All random starting haplotypes, crossover counts, and crossover
positions are generated in R before an engine is called. The R, C++, and
Fortran engines therefore apply exactly the same deterministic
inheritance events and can be compared directly.

``` r
engines <- lapply(c("R", "C++", "Fortran"), function(engine) {
  gene_drop_generation(
    base_haplotypes$hap1,
    base_haplotypes$hap2,
    sire = c(1, 2, 1, 4),
    dam = c(3, 4, 2, 1),
    map = map,
    seed = 456,
    engine = engine
  )
})

identical(engines[[1]]$genotype, engines[[2]]$genotype)
```

    ## [1] TRUE

``` r
identical(engines[[1]]$genotype, engines[[3]]$genotype)
```

    ## [1] TRUE

## Simulate and sample

The base population is generation 0. Selected sires and dams from each
generation produce the next generation. Crossovers are drawn from a
Poisson distribution based on chromosome length, and crossover locations
determine which parental haplotype is transmitted along the chromosome.

``` r
result <- simulate_gene_drop(
  base_haplotypes = base_haplotypes,
  map = map,
  generations = 3,
  population_size = 4,
  selected_parents = 4,
  offspring_per_mating = 2,
  sample_size = 2,
  seed = 123,
  keep = "sample"
)

result
```

    ## <qgsim_gene_drop>
    ##   generations: 3 
    ##   pedigree individuals: 16 
    ##   sampled individuals: 2 
    ##   retained haplotypes: 2

``` r
result$sample
```

    ##         id generation haplotype_row
    ## 1 g3_i0004          3             1
    ## 2 g3_i0003          3             2

``` r
result$haplotypes$hap1
```

    ##      [,1] [,2] [,3] [,4]
    ## [1,]    1    0    1    1
    ## [2,]    1    1    1    1

The pedigree always contains the base population and all simulated
generations. With `keep = "sample"`, the haplotype matrices contain only
the sampled final-generation individuals. With `keep = "all"`, they
contain every individual in pedigree order. The `haplotype_row` column
maps sampled IDs to the returned haplotype matrices.

## Scope

These are deliberately simple, single-chromosome teaching examples. They
do not represent a complete breeding simulator. The generation-level
function demonstrates how the same inheritance calculation can be
implemented in R, C++, and Fortran while preserving one user-facing
result structure.
