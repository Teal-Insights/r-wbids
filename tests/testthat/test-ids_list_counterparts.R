test_that("ids_list_counterparts returns a tibble with expected columns", {
  result <- ids_list_counterparts()
  expected_columns <- c(
    "counterpart_id", "counterpart_name",
    "counterpart_iso2code", "counterpart_iso3code",
    "counterpart_type"
  )
  expect_equal(colnames(result), expected_columns)
  expect_s3_class(result, "tbl_df")
})
