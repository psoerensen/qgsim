test_that("compile creates a validated qgsim_plan", {
  plan <- qgsim_compile(
    breeding_scheme(2, 20, 6, 3),
    seed = 123
  )

  expect_s3_class(plan, "qgsim_plan")
  expect_true(qgsim_validate(plan))
})

test_that("invalid and unknown plan fields fail validation", {
  plan <- qgsim_compile(breeding_scheme(2, 20, 6, 3))

  plan$unknown <- TRUE
  expect_error(qgsim_validate(plan), "unknown field")

  plan <- qgsim_compile(breeding_scheme(2, 20, 6, 3))
  plan$scheme$generations <- 0L
  expect_error(qgsim_validate(plan), "positive integer")
})
