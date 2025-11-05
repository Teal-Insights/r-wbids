test_that("read_bulk_info returns necessary data structure", {
  skip_if_offline()
  skip_on_cran()

  result <- read_bulk_info()
  expect_type(result, "list")
  expect_true(all(c("indicators", "resources") %in% names(result)))
})
