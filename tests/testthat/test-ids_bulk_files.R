test_that("ids_bulk_files returns a tibble with expected columns", {
  skip_if_not_installed("jsonlite")

  result <- ids_bulk_files()
  expected_columns <- c("file_name", "file_url", "last_updated_date")

  expect_equal(colnames(result), expected_columns)
  expect_s3_class(result, "tbl_df")
})
