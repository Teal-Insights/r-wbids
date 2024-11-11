test_that("ids_list_geographies returns a tibble with expected columns", {
  result <- ids_list_geographies()
  expect_s3_class(result, "tbl_df")
  expected_columns <- c(
    "geography_id", "geography_iso2code", "geography_type", "capital_city",
    "geography_name", "region_id", "region_iso2code", "region_name",
    "admin_region_id", "admin_region_iso2code", "admin_region_name",
    "income_level_id", "income_level_iso2code", "income_level_name",
    "lending_type_id", "lending_type_iso2code", "lending_type_name"
  )
  expect_equal(colnames(result), expected_columns)
})
