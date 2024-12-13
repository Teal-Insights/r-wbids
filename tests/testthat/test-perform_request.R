test_that("perform_request handles error responses", {
  mock_error_response <- list(
    list(
      message = list(
        list(id = "120", value = "Invalid indicator")
      )
    )
  )

  with_mocked_bindings(
    req_perform = function(...) mock_error_response,
    is_request_error = function(...) TRUE,
    handle_request_error = function(resp) stop("API error: Invalid indicator"),
    {
      expect_error(perform_request("indicators"),
                   "API error: Invalid indicator")
    }
  )
})

test_that("perform_request validates per_page parameter", {
  expect_error(perform_request("series", per_page = 50000))
  expect_silent(perform_request("series", per_page = 1000))
})

test_that("validate_per_page handles valid per_page values", {
  expect_silent(validate_per_page(1000))
  expect_silent(validate_per_page(1))
  expect_silent(validate_per_page(32500))
})

test_that("validate_per_page throws an error for invalid per_page values", {
  expect_error(validate_per_page(0),
               "must be an integer between 1 and 32,500")
  expect_error(validate_per_page(32501),
               "must be an integer between 1 and 32,500")
  expect_error(validate_per_page("1000"),
               "must be an integer between 1 and 32,500")
  expect_error(validate_per_page(1000.5),
               "must be an integer between 1 and 32,500")
})

test_that("create_request constructs a request with default parameters", {
  req <- create_request(
    "https://api.worldbank.org/v2/sources/6/", "series", 1000
  )
  expect_equal(
    req$url,
    "https://api.worldbank.org/v2/sources/6/series?format=json&per_page=1000"
  )
})

test_that("is_request_error identifies error responses correctly", {
  mock_resp <- httr2::response(
    status_code = 400,
    headers = list("Content-Type" = "application/json"),
    body = charToRaw('{"message": "Bad Request"}')
  )
  expect_true(is_request_error(mock_resp))
})

test_that("perform_request handles API errors gracefully", {
  expect_error(perform_request("nonexistent"), "HTTP 400 Bad Request.")
})

test_that("perform_request handles wrong requests gracefully", {

  mocked_request <- request(paste0(
    "https://api.worldbank.org/v2/sources/6/",
    "country/ZMB/series/DT.DOD.DPPG.CD/counterpart-area/XXX/time/all",
    "?format=json&per_page=1000"
  ))

  with_mocked_bindings(
    create_request = function(...) mocked_request,
    {
      expect_error(
        perform_request("country"),
        paste0(
          "API Error Code 160 : Data not found. ",
          "The provided parameter value is not valid or data not found."
        )
      )
    }
  )
})

test_that("validate_max_tries handles valid and invalid inputs", {
  expect_silent(validate_max_tries(1))
  expect_silent(validate_max_tries(10))

  expect_error(validate_max_tries(0), "must be a positive integer")
  expect_error(validate_max_tries(-1), "must be a positive integer")
  expect_error(validate_max_tries(2.5), "must be a positive integer")
  expect_error(validate_max_tries("3"), "must be a positive integer")
})

test_that("perform_request errors on too long URLs", {
  set.seed(123)
  random_resource <- paste0(
    sample(letters, 4000, replace = TRUE), collapse = ""
  )
  expect_error(
    perform_request(random_resource),
    "must be have less than 4000 characters"
  )
})

test_that("perform_request handles pagination correctly", {
  result <- perform_request(
    "country/ZMB/series/DT.DOD.DPPG.CD/counterpart-area/WLD/time/YR2020;YR2021",
    per_page = 1L
  )
  expect_equal(length(result), 2)
})
