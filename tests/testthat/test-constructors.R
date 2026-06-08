test_that("constructors validate their inputs", {
  expect_s3_class(
    breeding_scheme(2, 20, 6, 3),
    "qgsim_scheme"
  )
  expect_s3_class(output_spec(), "qgsim_outputs")

  expect_error(breeding_scheme(0, 20, 6, 3), "positive integer")
  expect_error(breeding_scheme(2, 20, 21, 3), "must not exceed")
  expect_error(output_spec(metrics = "unsupported"), "Unsupported")
})
