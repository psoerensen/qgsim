test_that("simulate_pedigree returns the expected pedigree", {
  ped <- simulate_pedigree(
    generations = 3,
    population_size = 20,
    selected_parents = 6,
    offspring_per_mating = 4,
    seed = 123
  )

  expect_s3_class(ped, "data.frame")
  expect_identical(names(ped), c("id", "sire", "dam", "generation", "sex"))
  expect_identical(sort(unique(ped$generation)), 1:3)
  expect_equal(as.integer(table(ped$generation)), rep.int(20L, 3))
})

test_that("founders and offspring have the expected parents", {
  ped <- simulate_pedigree(
    generations = 3,
    population_size = 20,
    selected_parents = 6,
    offspring_per_mating = 4,
    seed = 123
  )

  founders <- ped$generation == 1L
  expect_true(all(is.na(ped$sire[founders])))
  expect_true(all(is.na(ped$dam[founders])))
  expect_true(all(!is.na(ped$sire[!founders])))
  expect_true(all(!is.na(ped$dam[!founders])))
})

test_that("offspring parents come from the previous generation", {
  ped <- simulate_pedigree(
    generations = 3,
    population_size = 20,
    selected_parents = 6,
    offspring_per_mating = 4,
    seed = 123
  )

  for (generation in 2:3) {
    previous <- ped[ped$generation == generation - 1L, ]
    offspring <- ped[ped$generation == generation, ]

    expect_true(all(offspring$sire %in% previous$id[previous$sex == "M"]))
    expect_true(all(offspring$dam %in% previous$id[previous$sex == "F"]))
  }
})

test_that("seed makes simulation reproducible", {
  first <- simulate_pedigree(3, 20, 6, 4, seed = 456)
  second <- simulate_pedigree(3, 20, 6, 4, seed = 456)

  expect_identical(first, second)
})

test_that("simulate_pedigree validates inputs", {
  expect_error(simulate_pedigree(0, 20, 6, 4), "`generations`")
  expect_error(simulate_pedigree(2, 0, 6, 4), "`population_size`")
  expect_error(simulate_pedigree(2, 20, 1, 4), "`selected_parents`")
  expect_error(simulate_pedigree(2, 20, 6, 0), "`offspring_per_mating`")
  expect_error(simulate_pedigree(2, 20, 21, 4), "must not exceed")
})
