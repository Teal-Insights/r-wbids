test_that("ids_get_ed works with custom table name", {
  local_mocked_bindings(
    ed_get = function(dataset, table, columns, quiet) {
      data.frame(
        counterpart_id = c("216", "218"),
        counterpart_name = c("Japan", "Germany")
      )
    },
    .package = "econdatasets"
  )

  httptest2::without_internet({
    result <- ids_get_ed(table = "counterparts")

    expect_s3_class(result, "data.frame")
    expect_gt(nrow(result), 0)
  })
})
