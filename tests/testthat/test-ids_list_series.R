test_that("ids_list_series returns a tibble with expected columns", {
  result <- ids_list_series()
  expect_s3_class(result, "tbl_df")
  expected_columns <- c(
    "series_id", "series_name",
    "source_id", "source_name", "source_note", "source_organization"
  )
  expect_equal(colnames(result), expected_columns)
})
