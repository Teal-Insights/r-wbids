test_that("ids_list_series_topics returns a tibbe with expected columns", {
  result <- ids_list_series_topics()
  expect_s3_class(result, "tbl_df")
  expected_columns <- c(
    "series_id", "topic_id", "topic_name"
  )
  expect_equal(colnames(result), expected_columns)
})
