.example_plan <- function(seed = 123L) {
  qgsim_compile(
    scheme = breeding_scheme(
      generations = 3,
      population_size = 30,
      selected_parents = 8,
      offspring_per_mating = 4
    ),
    seed = seed,
    outputs = output_spec()
  )
}

test_that("qgsim_run returns a strict result", {
  result <- qgsim_run(.example_plan())

  expect_s3_class(result, "qgsim_result")
  expect_identical(result$status, "success")
  expect_identical(result$backend$name, "r_reference")
  expect_equal(nrow(qgsim_metrics(result)), 4)
  expect_equal(nrow(qgsim_populations(result)), 120)
})

test_that("same seed produces identical metrics", {
  first <- qgsim_run(.example_plan(456L))
  second <- qgsim_run(.example_plan(456L))

  expect_identical(qgsim_metrics(first), qgsim_metrics(second))
})

test_that("result accessors return data frames", {
  result <- qgsim_run(.example_plan())

  expect_s3_class(qgsim_metrics(result), "data.frame")
  expect_s3_class(qgsim_populations(result), "data.frame")
})
