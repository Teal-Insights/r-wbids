test_that("ids_list_counterparts returns a tibble", {
  result <- ids_list_counterparts()
  expect_s3_class(result, "tbl_df")
})

test_that("ids_list_counterparts returns expected columns", {
  result <- ids_list_counterparts()
  expected_columns <- c(
    "counterpart_id", "counterpart_name",
    "counterpart_iso2code", "counterpart_iso3code",
    "counterpart_type"
  )
  expect_equal(colnames(result), expected_columns)
})
