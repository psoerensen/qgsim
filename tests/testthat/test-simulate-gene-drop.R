gene_drop_base <- function() {
  list(
    hap1 = matrix(
      c(
        0, 0, 0, 0,
        0, 1, 0, 1,
        1, 0, 1, 0,
        1, 1, 1, 1,
        0, 0, 1, 1,
        1, 1, 0, 0
      ),
      nrow = 6,
      byrow = TRUE
    ),
    hap2 = matrix(
      c(
        1, 1, 1, 1,
        1, 0, 1, 0,
        0, 1, 0, 1,
        0, 0, 0, 0,
        1, 1, 0, 0,
        0, 0, 1, 1
      ),
      nrow = 6,
      byrow = TRUE
    )
  )
}

test_that("simulate_gene_drop returns expected sample output", {
  result <- simulate_gene_drop(
    base_haplotypes = gene_drop_base(),
    map = c(0, 0.2, 0.7, 1),
    generations = 3,
    population_size = 6,
    selected_parents = 4,
    offspring_per_mating = 2,
    sample_size = 3,
    seed = 123
  )

  expect_s3_class(result, "qgsim_gene_drop")
  expect_identical(
    names(result$pedigree),
    c("id", "sire", "dam", "generation", "sex")
  )
  expect_equal(sum(result$pedigree$generation == 3L), 6)
  expect_equal(nrow(result$sample), 3)
  expect_equal(dim(result$haplotypes$hap1), c(3, 4))
  expect_equal(dim(result$haplotypes$hap2), c(3, 4))
  expect_true(all(result$haplotypes$hap1 %in% c(0, 1)))
  expect_true(all(result$haplotypes$hap2 %in% c(0, 1)))
})

test_that("keep all returns all simulated haplotypes", {
  result <- simulate_gene_drop(
    gene_drop_base(),
    c(0, 0.2, 0.7, 1),
    generations = 2,
    population_size = 6,
    selected_parents = 4,
    offspring_per_mating = 2,
    sample_size = 2,
    seed = 123,
    keep = "all"
  )

  expect_equal(nrow(result$pedigree), 18)
  expect_equal(dim(result$haplotypes$hap1), c(18, 4))
  expect_identical(
    result$pedigree$id[result$sample$haplotype_row],
    result$sample$id
  )
})

test_that("simulate_gene_drop is reproducible with a seed", {
  first <- simulate_gene_drop(
    gene_drop_base(), c(0, 0.2, 0.7, 1), 2, 6, 4, 2, 3, seed = 456
  )
  second <- simulate_gene_drop(
    gene_drop_base(), c(0, 0.2, 0.7, 1), 2, 6, 4, 2, 3, seed = 456
  )

  expect_identical(first, second)
})

test_that("simulate_gene_drop validates haplotypes", {
  bad_values <- gene_drop_base()
  bad_values$hap1[1, 1] <- 2
  expect_error(
    simulate_gene_drop(bad_values, c(0, 0.2, 0.7, 1), 2, 6, 4, 2),
    "only 0/1"
  )

  bad_dimensions <- gene_drop_base()
  bad_dimensions$hap2 <- bad_dimensions$hap2[, -1]
  expect_error(
    simulate_gene_drop(bad_dimensions, c(0, 0.2, 0.7, 1), 2, 6, 4, 2),
    "same dimensions"
  )
})

test_that("simulate_gene_drop validates map and sample size", {
  expect_error(
    simulate_gene_drop(gene_drop_base(), c(0, 0.2, 0.7), 2, 6, 4, 2),
    "`map`"
  )
  expect_error(
    simulate_gene_drop(gene_drop_base(), c(0, 0.7, 0.2, 1), 2, 6, 4, 2),
    "non-decreasing"
  )
  expect_error(
    simulate_gene_drop(gene_drop_base(), rep(0, 4), 2, 6, 4, 2),
    "greater than 0"
  )
  expect_error(
    simulate_gene_drop(gene_drop_base(), c(0, 0.2, 0.7, 1), 2, 6, 4, 2, 7),
    "`sample_size`"
  )
})
