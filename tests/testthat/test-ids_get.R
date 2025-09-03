test_that("process_time_range correctly validates and formats time ranges", {
  # Test NULL inputs
  expect_equal(process_time_range(NULL, NULL), "all")

  # Test invalid ranges
  expect_error(
    process_time_range(2020, 2019),
    "`start_year` cannot be greater than `end_year`"
  )

  # Test invalid inputs
  expect_error(
    process_time_range("2020", 2021),
    "`start_year` must be a single numeric value"
  )
  expect_error(
    process_time_range(2020, "2021"),
    "`end_year` must be a single numeric value"
  )
  expect_warning(
    process_time_range(1969, 2020),
    "Data only available from 1970 onward"
  )

  # Test single year
  expect_equal(process_time_range(2020, 2020), "YR2020")

  # Test year range
  expect_equal(process_time_range(2015, 2017), "YR2015;YR2016;YR2017")
})

test_that("create_resource_url constructs URL path correctly", {
  # Test basic URL construction
  expect_equal(
    create_resource_url(
      entity = "ZMB",
      series = "DT.DOD.DPPG.CD",
      counterpart = "all",
      time = "all"
    ),
    "country/ZMB/series/DT.DOD.DPPG.CD/counterpart-area/all/time/all"
  )

  # Test with multiple values (semicolon-separated)
  expect_equal(
    create_resource_url(
      entity = "ZMB;CHN",
      series = "DT.DOD.DPPG.CD;BM.GSR.TOTL.CD",
      counterpart = "216;231",
      time = "YR2019;YR2020"
    ),
    "country/ZMB;CHN/series/DT.DOD.DPPG.CD;BM.GSR.TOTL.CD/counterpart-area/216;231/time/YR2019;YR2020" # nolint
  )
})

test_that("validate_character_vector correctly validates character vectors", {
  expect_error(
    validate_character_vector(NA, "entities"),
    "`entities` must be a character vector and cannot contain NA values."
  )
  expect_error(
    validate_character_vector(c("ZMB", NA), "series"),
    "`series` must be a character vector and cannot contain NA values."
  )
  expect_error(
    validate_character_vector(123, "entities"),
    "`entities` must be a character vector and cannot contain NA values."
  )
  expect_silent(validate_character_vector(c("ZMB", "CHN"), "entities"))
})

test_that("process_character_vector correctly processes character vectors", {
  expect_equal(
    process_character_vector(c("ZMB", "CHN"), "entities"),
    "ZMB;CHN"
  )
  expect_equal(process_character_vector("ZMB", "entities"), "ZMB")
  expect_error(
    process_character_vector(NA, "entities"),
    "`entities` must be a character vector and cannot contain NA values."
  )
})

test_that("validate_progress checks logical values for progress", {
  expect_error(
    validate_progress("yes"),
    "`progress` must be either TRUE or FALSE"
  )
  expect_silent(validate_progress(TRUE))
  expect_silent(validate_progress(FALSE))
})

test_that("ids_get returns a tibble with expected columns", {
  result <- ids_get(
    entities = "ZMB",
    series = "DT.DOD.DPPG.CD",
    counterparts = c("216"),
    start_year = 2015,
    end_year = 2016,
    progress = FALSE
  )
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
  expected_columns <- c(
    "entity_id",
    "series_id",
    "counterpart_id",
    "year",
    "value"
  )
  expect_equal(colnames(result), expected_columns)
})

test_that("ids_get returns a large data", {
  result <- ids_get(
    entities = "ZMB",
    series = "DT.DOD.DPPG.CD",
    counterparts = c("all")
  )
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
  expected_columns <- c(
    "entity_id",
    "series_id",
    "counterpart_id",
    "year",
    "value"
  )
  expect_equal(colnames(result), expected_columns)
})

test_that("ids_get handles invalid entity input", {
  expect_error(
    ids_get(
      entities = NA,
      series = "DT.DOD.DPPG.CD"
    ),
    "`entities` must be a character vector and cannot contain NA values"
  )
})

test_that("ids_get handles invalid series input", {
  expect_error(
    ids_get(
      entities = "ZMB",
      series = NA
    ),
    "`series` must be a character vector and cannot contain NA values"
  )
})

test_that("ids_get handles invalid progress input", {
  expect_error(
    ids_get(
      entities = "ZMB",
      series = "DT.DOD.DPPG.CD",
      progress = "yes"
    ),
    "`progress` must be either TRUE or FALSE."
  )
})

test_that("ids_get handles valid progress input", {
  expect_silent(
    ids_get(
      entities = "ZMB",
      series = "DT.DOD.DPPG.CD",
      counterparts = "265",
      start_year = 2015,
      end_year = 2016,
      progress = TRUE
    )
  )
})

test_that("get_debt_statistics returns raw API response", {
  mock_perform_request <- list(
    list(
      variable = list(
        list(concept = "Country", id = "ZMB"),
        list(concept = "Series", id = "DT.DOD.DPPG.CD"),
        list(concept = "Counterpart-Area", id = "216"),
        list(concept = "Time", value = "2020")
      ),
      value = 100
    ),
    list(
      variable = list(
        list(concept = "Country", id = "ZMB"),
        list(concept = "Series", id = "DT.DOD.DPPG.CD"),
        list(concept = "Counterpart-Area", id = "216"),
        list(concept = "Time", value = "2021")
      ),
      value = 200
    )
  )

  with_mocked_bindings(
    perform_request = function(...) mock_perform_request,
    {
      result <- get_debt_statistics(
        entity = "ZMB",
        series = "DT.DOD.DPPG.CD",
        counterpart = "216",
        time = "YR2020;YR2021",
        progress = FALSE
      )

      expect_equal(result, mock_perform_request)
    }
  )
})

test_that("process_debt_statistics correctly transforms raw data", {
  mock_data <- list(
    list(
      variable = list(
        list(concept = "Country", id = "ZMB"),
        list(concept = "Series", id = "DT.DOD.DPPG.CD"),
        list(concept = "Counterpart-Area", id = "216"),
        list(concept = "Time", value = "2020")
      ),
      value = 100
    ),
    list(
      variable = list(
        list(concept = "Country", id = "ZMB"),
        list(concept = "Series", id = "DT.DOD.DPPG.CD"),
        list(concept = "Counterpart-Area", id = "216"),
        list(concept = "Time", value = "2021")
      ),
      value = 200
    )
  )

  result <- process_debt_statistics(mock_data)

  expect_s3_class(result, "tbl_df")
  expected_columns <- c(
    "entity_id",
    "series_id",
    "counterpart_id",
    "year",
    "value"
  )
  expect_equal(colnames(result), expected_columns)
  expect_equal(nrow(result), 2)
  expect_equal(result$entity_id, c("ZMB", "ZMB"))
  expect_equal(result$series_id, c("DT.DOD.DPPG.CD", "DT.DOD.DPPG.CD"))
  expect_equal(result$counterpart_id, c("216", "216"))
  expect_equal(result$year, c(2020, 2021))
  expect_equal(result$value, c(100, 200))
})

test_that("ids_get handles empty data gracefully", {
  mock_data <- list(
    list(
      "variable" = list(
        list(
          "concept" = character(),
          "id" = character(),
          "value" = character()
        ),
        list(
          "concept" = character(),
          "id" = character(),
          "value" = character()
        ),
        list(
          "concept" = character(),
          "id" = character(),
          "value" = character()
        ),
        list(
          "concept" = character(),
          "id" = character(),
          "value" = character()
        )
      ),
      "value" = numeric()
    )
  )

  with_mocked_bindings(
    perform_request = function(...) mock_data,
    {
      result <- ids_get("ZMB", "DT.DOD.DPPG.CD")
      expect_equal(nrow(result), 0)
    }
  )
})

test_that("ids_get handles empty or incomplete data gracefully", {
  incomplete_data_mock <- list(
    list(
      "variable" = list(
        list("concept" = "Country", "id" = "ZMB"),
        list("concept" = "Series", "id" = NA),
        list("concept" = "Counterpart-Area", "id" = "all"),
        list("concept" = "Time", "value" = "2020")
      ),
      "value" = NULL
    )
  )

  with_mocked_bindings(
    perform_request = function(...) incomplete_data_mock,
    {
      result <- ids_get(
        entities = "ZMB",
        series = "DT.DOD.DPPG.CD",
        counterparts = "all",
        start_year = 2020,
        end_year = 2020,
        progress = FALSE
      )
      expect_equal(nrow(result), 1)
      expect_true(is.na(result$series_id[1]))
      expect_equal(result$value, NA_real_)
    }
  )
})

test_that("validate_year correctly validates year values", {
  # Test non-numeric input
  expect_error(
    validate_year("2020", "start_year"),
    "`start_year` must be a single numeric value"
  )

  # Test multiple values
  expect_error(
    validate_year(c(2020, 2021), "start_year"),
    "`start_year` must be a single numeric value"
  )

  # Test pre-1970 dates (should warn and return 1970)
  expect_warning(
    result <- validate_year(1969, "start_year"),
    "Data only available from 1970 onward"
  )
  expect_equal(result, 1970)

  # Test valid years (should pass silently and return original value)
  expect_silent(result <- validate_year(1970, "start_year"))
  expect_equal(result, 1970)
  expect_silent(result <- validate_year(2020, "start_year"))
  expect_equal(result, 2020)
})

test_that("process_debt_statistics handles empty/incomplete data gracefully", {
  incomplete_data <- list(
    list(
      "variable" = list(
        list("concept" = "Country", "id" = "ZMB"),
        list("concept" = "Series", "id" = NA),
        list("concept" = "Counterpart-Area", "id" = "all"),
        list("concept" = "Time", "value" = "2020")
      ),
      "value" = NULL
    )
  )

  result <- process_debt_statistics(incomplete_data)
  expect_equal(nrow(result), 1)
  expect_true(is.na(result$series_id[1]))
  expect_equal(result$value, NA_real_)
})

test_that("validate_string correctly validates string lengths", {
  # Test strings under the limit
  expect_silent(validate_string("short string", 100, "test_string"))
  expect_silent(validate_string("", 10, "test_string"))

  # Test strings at or over the limit
  long_string <- paste(rep("a", 100), collapse = "")
  expect_error(
    validate_string(long_string, 100, "test_string"),
    "Concatenated `test_string` string must be less than 100 characters"
  )

  very_long_string <- paste(rep("a", 4000), collapse = "")
  expect_error(
    validate_string(very_long_string, 4000, "test_string"),
    "Concatenated `test_string` string must be less than 4000 characters"
  )
})

test_that("validate_character_vector correctly handles vector length limits", {
  # Test vector with exactly 60 items (should pass)
  exactly_60 <- rep("A", 60)
  expect_silent(validate_character_vector(exactly_60, "test_vector"))

  # Test vector with more than 60 items (should fail)
  too_many <- rep("A", 61)
  expect_error(
    validate_character_vector(too_many, "test_vector"),
    "`test_vector` must be a character vector with 60 or fewer values"
  )

  # Test single string with more than 60 characters (should pass)
  long_string <- paste(rep("A", 100), collapse = "")
  expect_silent(validate_character_vector(long_string, "test_vector"))
})

test_that("ids_get enforces vector length limits", {
  # Create test vectors with 61 items
  too_many_entities <- rep("ZMB", 61)
  too_many_series <- rep("DT.DOD.DPPG.CD", 61)
  too_many_counterparts <- rep("all", 61)

  # Test entities limit
  expect_error(
    ids_get(
      entities = too_many_entities,
      series = "DT.DOD.DPPG.CD"
    ),
    "`entities` must be a character vector with 60 or fewer values"
  )

  # Test series limit
  expect_error(
    ids_get(
      entities = "ZMB",
      series = too_many_series
    ),
    "`series` must be a character vector with 60 or fewer values"
  )

  # Test counterparts limit
  expect_error(
    ids_get(
      entities = "ZMB",
      series = "DT.DOD.DPPG.CD",
      counterparts = too_many_counterparts
    ),
    "`counterparts` must be a character vector with 60 or fewer values"
  )

  # Test that exactly 60 items works for each parameter
  exactly_60 <- rep("ZMB", 60)
  expect_error(
    ids_get(
      entities = exactly_60,
      series = "DT.DOD.DPPG.CD"
    ),
    NA
  )
})

test_that("ids_get uses new default parameters correctly", {
  # Test that default counterparts = "WLD"
  default_result <- ids_get(
    entities = "GHA",
    series = "DT.DOD.DECT.CD"
  )

  # All records should have counterpart_id = "WLD"
  expect_true(all(default_result$counterpart_id == "WLD"))

  # All years should be >= 2000 (the new default start_year)
  expect_true(all(default_result$year >= 2000))
})

test_that("ids_get filters post-observed-year NAs correctly", {
  result <- ids_get(
    entities = "GHA",
    series = "DT.DOD.DECT.CD"
  )

  # Ensure no rows exist beyond current year if all values are NA
  expect_true(all(
    result$year <= as.numeric(format(Sys.Date(), "%Y")) | !is.na(result$value)
  ))
})

test_that("ids_get correctly applies default years for projection series", {
  result <- ids_get(
    entities = "GHA",
    series = "DT.TDS.DECT.CD" # Projection series
  )

  # Verify the years in the result
  expect_true(all(
    result$year >= 2000 & result$year <= times$time_year[nrow(times)]
  ))
})

test_that("ids_get retains post-actual-year data with values", {
  start_year <- times$time_year[nrow(times)] - 11
  end_year <- times$time_year[nrow(times)]

  result <- tibble(
    entity_id = rep("GHA", 12),
    series_id = rep("DT.DOD.DECT.CD", 12),
    counterpart_id = rep("WLD", 12),
    year = start_year:end_year,
    value = rep(c(1, NA), 6)
  )

  filtered_result <- filter_post_actual_na(result)

  # Rows with years <= last year of projections should remain
  expect_equal(filtered_result$year, start_year:end_year)
})

test_that("ids_get handles valid entity codes correctly", {
  # Test individual country code (ISO3C)
  expect_silent(ids_get(
    entities = "GHA",
    series = "DT.DOD.DECT.CD",
    start_year = 2020,
    end_year = 2020
  ))

  # Test income group aggregate code
  expect_silent(ids_get(
    entities = "LIC",
    series = "DT.DOD.DECT.CD",
    start_year = 2020,
    end_year = 2020
  ))

  # Test multiple entity types together
  expect_silent(ids_get(
    entities = c("GHA", "LIC"),
    series = "DT.DOD.DECT.CD",
    start_year = 2020,
    end_year = 2020
  ))
})

test_that("ids_get handles valid counterpart codes correctly", {
  # Test default world aggregate
  expect_silent(ids_get(
    entities = "GHA",
    series = "DT.DOD.DECT.CD",
    counterparts = "WLD",
    start_year = 2020,
    end_year = 2020
  ))

  # Test numeric country code
  expect_silent(ids_get(
    entities = "GHA",
    series = "DT.DOD.DECT.CD",
    counterparts = "730", # China
    start_year = 2020,
    end_year = 2020
  ))

  # Test special text codes
  expect_silent(ids_get(
    entities = "GHA",
    series = "DT.DOD.DECT.CD",
    counterparts = c("907", "BND"), # IMF and bondholders
    start_year = 2020,
    end_year = 2020
  ))

  # Test requesting all counterparts
  expect_silent(ids_get(
    entities = "GHA",
    series = "DT.DOD.DECT.CD",
    counterparts = "all",
    start_year = 2020,
    end_year = 2020
  ))
})

test_that("ids_get returns expected data structure", {
  result <- ids_get(
    entities = "GHA",
    series = "DT.DOD.DECT.CD",
    start_year = 2020,
    end_year = 2020
  )

  # Check tibble structure
  expect_s3_class(result, "tbl_df")

  # Verify column names
  expected_columns <- c(
    "entity_id",
    "series_id",
    "counterpart_id",
    "year",
    "value"
  )
  expect_named(result, expected_columns)

  # Check data types
  expect_type(result$entity_id, "character")
  expect_type(result$series_id, "character")
  expect_type(result$counterpart_id, "character")
  expect_type(result$year, "integer")
  expect_type(result$value, "double")
})

test_that("process_time_range handles pre-1970 dates correctly", {
  # Test start_year before 1970
  expect_warning(
    result <- process_time_range(1960, 2020),
    "Data only available from 1970 onward"
  )
  expect_equal(
    result,
    paste(
      times$time_id[
        times$time_year >= 1970 & times$time_year <= 2020
      ],
      collapse = ";"
    )
  )

  # Test end_year before 1970
  expect_error(
    process_time_range(1960, 1965),
    "Data only available from 1970 onward"
  )
})

test_that("ids_get handles pre-1970 dates correctly", {
  # Test with start_year before 1970
  expect_warning(
    result <- ids_get(
      entities = "GHA",
      series = "DT.DOD.DECT.CD",
      start_year = 1960,
      end_year = 1975
    ),
    "Data only available from 1970 onward"
  )
  expect_true(min(result$year) >= 1970)

  # Test with end_year before 1970
  expect_error(
    ids_get(
      entities = "GHA",
      series = "DT.DOD.DECT.CD",
      start_year = 1960,
      end_year = 1965
    ),
    "Data only available from 1970 onward"
  )
})
