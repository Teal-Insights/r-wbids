test_that("ids_bulk_series returns a tibble with expected columns", {
  skip_if_not_installed("jsonlite")

  result <- ids_bulk_series()
  expected_columns <- c(
    "series_id", "series_name",
    "source_id", "source_name", "source_note", "source_organization"
  )

  expect_equal(colnames(result), expected_columns)
  expect_s3_class(result, "tbl_df")
})
