test_that("ids_bulk_files returns a tibble", {
  ids_meta_mock <- list(
    resources = list(
      name = "Debt Data",
      last_updated_date = "2024-01-01",
      distribution = data.frame(
        "distribution_format" = "xlsx",
        "url" = "http://example.com/file.xlsx"
      )
    )
  )

  with_mocked_bindings(
    read_file_list = function(...) ids_meta_mock,
    {
      result <- ids_bulk_files()
      expect_s3_class(result, "tbl_df")
    }
  )
})

test_that("ids_bulk_files returns expected columns", {
  ids_meta_mock <- list(
    resources = list(
      name = "Debt Data",
      last_updated_date = "2024-01-01",
      distribution = data.frame(
        "distribution_format" = "xlsx",
        "url" = "http://example.com/file.xlsx"
      )
    )
  )

  with_mocked_bindings(
    read_file_list = function(...) ids_meta_mock,
    {
      result <- ids_bulk_files()
      expected_columns <- c("file_name", "file_url", "last_updated_date")
      expect_equal(colnames(result), expected_columns)  # Check column names
    }
  )
})

test_that("ids_bulk_files filters by xlsx format", {
  ids_meta_mock <- list(
    resources = list(
      name = c("Debt Data 1", "Debt Data 2"),
      last_updated_date = c("2024-01-02", "2024-01-01"),
      distribution = list(
        data.frame(distribution_format = "xlsx",
                   url = "http://example.com/file1.xlsx"),
        data.frame(distribution_format = "csv",
                   url = "http://example.com/file2.csv")
      )
    )
  )

  with_mocked_bindings(
    read_file_list = function(...) ids_meta_mock,
    {
      result <- ids_bulk_files()
      expect_equal(nrow(result), 1)
      expect_equal(result$file_name, "Debt Data 1")
      expect_equal(result$file_url, "http://example.com/file1.xlsx")
    }
  )
})
