test_that("ids_bulk_files returns a tibble with expected columns", {
  skip_if_not_installed("jsonlite")

  local_mocked_bindings(
    read_bulk_info = function() {
      readRDS(test_path("data/read_bulk_info_output.rds"))
    }
  )

  result <- ids_bulk_files()
  expected_columns <- c("file_name", "file_url", "last_updated_date")

  expect_equal(colnames(result), expected_columns)
  expect_s3_class(result, "tbl_df")
})
