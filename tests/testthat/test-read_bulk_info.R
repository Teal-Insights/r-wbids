test_that("read_bulk_info returns necessary data structure", {
  result <- read_bulk_info()
  expect_type(result, "list")
  expect_true(all(c("indicators", "resources") %in% names(result)))
})
