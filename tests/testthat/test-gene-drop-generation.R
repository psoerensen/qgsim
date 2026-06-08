generation_haplotypes <- function() {
  list(
    hap1 = matrix(
      c(
        0, 0, 0, 0,
        0, 1, 0, 1,
        1, 0, 1, 0,
        1, 1, 1, 1
      ),
      nrow = 4,
      byrow = TRUE
    ),
    hap2 = matrix(
      c(
        1, 1, 1, 1,
        1, 0, 1, 0,
        0, 1, 0, 1,
        0, 0, 0, 0
      ),
      nrow = 4,
      byrow = TRUE
    )
  )
}

generation_arguments <- function() {
  haplotypes <- generation_haplotypes()
  list(
    hap1 = haplotypes$hap1,
    hap2 = haplotypes$hap2,
    sire = c(1, 2, 1, 4, 3),
    dam = c(3, 4, 2, 1, 4),
    map = c(0, 0.2, 0.7, 1.5),
    seed = 123
  )
}

test_that("gene_drop_generation returns genotypes and haplotypes", {
  result <- do.call(gene_drop_generation, generation_arguments())

  expect_identical(dim(result$genotype), c(5L, 4L))
  expect_true(all(result$genotype %in% 0:2))
  expect_identical(dim(result$hap1), c(5L, 4L))
  expect_identical(dim(result$hap2), c(5L, 4L))
  expect_true(all(result$hap1 %in% 0:1))
  expect_true(all(result$hap2 %in% 0:1))
  expect_identical(result$genotype, result$hap1 + result$hap2)
})

test_that("gene_drop_generation can omit haplotypes", {
  arguments <- c(generation_arguments(), list(return_haplotypes = FALSE))
  result <- do.call(gene_drop_generation, arguments)

  expect_false("hap1" %in% names(result))
  expect_false("hap2" %in% names(result))
  expect_true("genotype" %in% names(result))
})

test_that("gene_drop_generation is reproducible", {
  first <- do.call(gene_drop_generation, generation_arguments())
  second <- do.call(gene_drop_generation, generation_arguments())

  expect_identical(first, second)
})

test_that("gene_drop_generation engines give identical inheritance", {
  arguments <- generation_arguments()
  results <- lapply(c("R", "C++", "Fortran"), function(engine) {
    do.call(gene_drop_generation, c(arguments, list(engine = engine)))
  })

  for (component in c("genotype", "hap1", "hap2")) {
    expect_identical(results[[1L]][[component]], results[[2L]][[component]])
    expect_identical(results[[1L]][[component]], results[[3L]][[component]])
  }
})

test_that("gene_drop_generation validates haplotypes", {
  arguments <- generation_arguments()
  arguments$hap1[1, 1] <- 2

  expect_error(do.call(gene_drop_generation, arguments), "only 0/1")
})

test_that("gene_drop_generation validates parent indices", {
  arguments <- generation_arguments()
  arguments$sire[1] <- 0
  expect_error(do.call(gene_drop_generation, arguments), "parent row indices")

  arguments <- generation_arguments()
  arguments$dam[1] <- 5
  expect_error(do.call(gene_drop_generation, arguments), "parent row indices")

  arguments <- generation_arguments()
  arguments$dam <- arguments$dam[-1]
  expect_error(do.call(gene_drop_generation, arguments), "same positive length")
})

test_that("gene_drop_generation validates map", {
  arguments <- generation_arguments()
  arguments$map <- c(0, 0.7, 0.2, 1.5)
  expect_error(do.call(gene_drop_generation, arguments), "non-decreasing")

  arguments <- generation_arguments()
  arguments$map <- rep(0, 4)
  expect_error(do.call(gene_drop_generation, arguments), "greater than 0")

  arguments <- generation_arguments()
  arguments$map <- c(0, 0.2, 0.7)
  expect_error(do.call(gene_drop_generation, arguments), "`map`")
})
