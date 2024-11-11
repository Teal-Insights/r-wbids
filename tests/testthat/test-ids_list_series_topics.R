test_that("ids_list_series_topics returns a tibble", {
  result <- ids_list_series_topics()
  expect_s3_class(result, "tbl_df")
})

test_that("ids_list_series_topics returns expected columns", {
  result <- ids_list_series_topics()
  expected_columns <- c(
    "series_id", "topic_id", "topic_name"
  )
  expect_equal(colnames(result), expected_columns)
})
