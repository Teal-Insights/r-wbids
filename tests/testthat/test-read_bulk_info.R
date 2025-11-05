test_that("read_bulk_info returns necessary data structure", {
  skip_if_not_installed("jsonlite")

  local_mocked_bindings(
    fromJSON = function(...) {
      readRDS(test_path("data/read_bulk_info_output.rds"))
    },
    .package = "jsonlite"
  )

  result <- read_bulk_info()
  expect_type(result, "list")
  expect_true(all(c("indicators", "resources") %in% names(result)))
})
