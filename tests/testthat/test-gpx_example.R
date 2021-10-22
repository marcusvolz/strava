test_that("gpx_example works properly", {
  x <- gpx_example()
  expect_true(
    grepl("gpx", x[1])
  )
  x <- gpx_example("trail_roche_doetre")
  expect_true(
    grepl("gpx", x)
  )
})
