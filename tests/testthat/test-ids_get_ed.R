test_that("ids_get_ed works with custom table name", {
  skip_if_offline()

  result <- ids_get_ed(table = "counterparts")

  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
})
