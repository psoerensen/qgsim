test_that("reference backend is registered and inspectable", {
  expect_true("r_reference" %in% qgsim_list_backends())

  info <- qgsim_backend_info("r_reference")
  expect_identical(info$name, "r_reference")
  expect_true(info$available)
})

test_that("backend registry rejects unknown backends", {
  plan <- qgsim_compile(breeding_scheme(1, 10, 4, 2))
  expect_error(qgsim_run(plan, backend = "missing"), "Unknown backend")
})
