test_that("ids_get returns a tibble with expected columns", {
  result <- ids_get(
    geographies = "ZMB",
    series = "DT.DOD.DPPG.CD",
    counterparts = c("216"),
    start_date = 2015,
    end_date = 2016,
    progress = FALSE
  )
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
  expected_columns <- c(
    "geography_id", "series_id", "counterpart_id", "year", "value"
  )
  expect_equal(colnames(result), expected_columns)
})

test_that("ids_get returns a large data", {
  result <- ids_get(
    geographies = "ZMB",
    series = "DT.DOD.DPPG.CD",
    counterparts = c("all")
  )
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
  expected_columns <- c(
    "geography_id", "series_id", "counterpart_id", "year", "value"
  )
  expect_equal(colnames(result), expected_columns)
})

test_that("ids_get handels invalid geography input", {
  expect_error(
    ids_get(
      geographies = NA,
      series = "DT.DOD.DPPG.CD"
    ),
    "`geographies` must be a character vector and cannot contain NA values"
  )
})

test_that("ids_get handels invalid series input", {
  expect_error(
    ids_get(
      geographies = "ZMB",
      series = NA
    ),
    "`series` must be a character vector and cannot contain NA values"
  )
})

test_that("ids_get handels invalid progress input", {
  expect_error(
    ids_get(
      geographies = "ZMB", series = "DT.DOD.DPPG.CD", progress = "yes"
    ),
    "`progress` must be either TRUE or FALSE."
  )
})

test_that("ids_get handels valid progress input", {
  expect_silent(
    ids_get(
      geographies = "ZMB", series = "DT.DOD.DPPG.CD", counterparts = "265",
      start_date = 2015, end_date = 2016,
      progress = TRUE
    )
  )
})

test_that("validate_character_vector correctly validates character vectors", {
  expect_error(
    validate_character_vector(NA, "geographies"),
    "`geographies` must be a character vector and cannot contain NA values"
  )
  expect_error(
    validate_character_vector(c("ZMB", NA), "series"),
    "`series` must be a character vector and cannot contain NA values"
  )
  expect_error(
    validate_character_vector(123, "geographies"),
    "`geographies` must be a character vector and cannot contain NA values"
  )
  expect_silent(validate_character_vector(c("ZMB", "CHN"), "geographies"))
})

test_that("validate_date correctly validates date values", {
  expect_error(
    validate_date(1969, "start_date"),
    "`start_date` must be a single numeric value representing a year >= 1970"
  )
  expect_error(
    validate_date("2020", "end_date"),
    "`end_date` must be a single numeric value representing a year >= 1970"
  )
  expect_silent(validate_date(1970, "start_date"))
  expect_silent(validate_date(2020, "end_date"))
  expect_silent(validate_date(NULL, "end_date"))
  expect_silent(validate_date(NULL, "start_date"))
  expect_equal(create_time(NULL, NULL), "all")
})

test_that("validate_progress checks logical values for progress", {
  expect_error(validate_progress("yes"),
               "`progress` must be either TRUE or FALSE")
  expect_silent(validate_progress(TRUE))
  expect_silent(validate_progress(FALSE))
})

test_that("create_time generates correct time sequence", {
  expect_equal(create_time(2015, 2017), c("YR2015", "YR2016", "YR2017"))
  expect_equal(create_time(1970, 1970), "YR1970")
  expect_equal(create_time(NULL, NULL), "all")
  expect_error(
    create_time(2020, 2019),
    "`start_date` cannot be greater than `end_date`"
  )
})

test_that("get_debt_statistics returns correctly structured tibble", {
  mock_perform_request <- list(
    list(variable = list(
      list(concept = "Country", id = "ZMB"),
      list(concept = "Series", id = "DT.DOD.DPPG.CD"),
      list(concept = "Counterpart-Area", id = "216"),
      list(concept = "Time", value = "2020")
    ), value = 100),
    list(variable = list(
      list(concept = "Country", id = "ZMB"),
      list(concept = "Series", id = "DT.DOD.DPPG.CD"),
      list(concept = "Counterpart-Area", id = "216"),
      list(concept = "Time", value = "2021")
    ), value = 200)
  )

  with_mocked_bindings(
    perform_request = function(...) mock_perform_request,
    {
      result <- get_debt_statistics(
        geography = "ZMB",
        series = "DT.DOD.DPPG.CD",
        counterpart = "216",
        time = "YR2020",
        progress = FALSE
      )

      expect_s3_class(result, "tbl_df")
      expected_columns <- c(
        "geography_id", "series_id", "counterpart_id", "year", "value"
      )
      expect_equal(colnames(result), expected_columns)
      expect_equal(nrow(result), 2)
      expect_equal(result$geography_id, c("ZMB", "ZMB"))
      expect_equal(result$series_id, c("DT.DOD.DPPG.CD", "DT.DOD.DPPG.CD"))
      expect_equal(result$counterpart_id, c("216", "216"))
      expect_equal(result$year, c(2020, 2021))
      expect_equal(result$value, c(100, 200))
    }
  )
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
      result <- get_debt_statistics(
        "ZMB", "DT.DOD.DPPG.CD", "all", "YR2020", FALSE
      )
      expect_equal(nrow(result), 1)
      expect_true(is.na(result$series_id[1]))
      expect_equal(result$value, NA_real_)
    }
  )
})
