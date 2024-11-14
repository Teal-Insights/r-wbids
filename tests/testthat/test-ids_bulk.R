# Set timeout for testing
options(timeout = 60)

test_that("ids_bulk handles custom file paths", {
  skip_if_offline()
  skip_on_cran()
  skip_if_not_installed("jsonlite")
  skip_if_not_installed("readxl")

  test_url <- ids_bulk_files()$file_url[1]
  temp_path <- tempfile(fileext = ".xlsx")

  local_mocked_bindings(
    check_interactive = function() FALSE,
    download_file = function(url, destfile, quiet) {
      file.create(destfile)
    },
    read_bulk_file = function(...) {
      tibble::tibble()
    },
    process_bulk_data = function(...) {
      tibble::tibble()
    }
  )

  # This acts like an expect statement to verify that the file exists at the
  # destination path when we expect it to
  local_mocked_bindings(
    validate_file = function(...) file.exists(temp_path)
  )

  result <- ids_bulk(
    test_url, file_path = temp_path, quiet = TRUE, warn_size = FALSE
  )

  expect_false(file.exists(temp_path))
})

test_that("ids_bulk fails gracefully with invalid URL", {
  expect_error(
    ids_bulk("https://invalid-url.com/file.xlsx"),
    "cannot open URL|download failed|Could not resolve host"
  )
})

test_that("ids_bulk requires readxl package", {
  local_mocked_bindings(
    check_installed = function(...) stop("Package not installed"),
    .package = "rlang"
  )
  expect_error(
    ids_bulk("https://example.com/file.xlsx"),
    "Package not installed"
  )
})

test_that("ids_bulk handles message parameter correctly", {
  skip_if_offline()
  skip_on_cran()
  skip_if_not_installed("jsonlite")
  skip_if_not_installed("readxl")

  test_url <- ids_bulk_files()$file_url[1]

  mock_data <- tibble::tibble(
    "Country Code" = "ABC",
    "Country Name" = "Test Country",
    "Classification Name" = "Test Class",
    "Series Code" = "TEST.1",
    "Series Name" = "Test Series",
    "2020" = 100
  )

  local_mocked_bindings(
    download_file = function(...) TRUE
  )
  local_mocked_bindings(
    validate_file = function(...) TRUE
  )
  local_mocked_bindings(
    read_excel = function(...) mock_data,
    .package = "readxl"
  )
  local_mocked_bindings(
    check_interactive = function() FALSE
  )

  expect_message(
    ids_bulk(test_url, quiet = FALSE, warn_size = FALSE),
    "Downloading file"
  )
  expect_message(
    ids_bulk(test_url, quiet = FALSE, warn_size = FALSE),
    "Reading in file"
  )
  expect_message(
    ids_bulk(test_url, quiet = FALSE, warn_size = FALSE),
    "Processing file"
  )
  expect_no_message(
    ids_bulk(test_url, quiet = TRUE, warn_size = FALSE)
  )
})

test_that("ids_bulk handles timeout parameter correctly", {
  skip_if_offline()
  skip_on_cran()
  skip_if_not_installed("jsonlite")
  skip_if_not_installed("readxl")

  mock_url <- "http://httpbin.org/delay/10"

  local_mocked_bindings(
    check_interactive = function() FALSE
  )

  # Retry logic to handle occasional 504 errors
  attempt <- 1
  max_attempts <- 5
  success <- FALSE

  while (!success && attempt <= max_attempts) {
    attempt <- attempt + 1

    result <- tryCatch({
      expect_warning(
        expect_error(
          ids_bulk(mock_url, timeout = 1, warn_size = FALSE),
          "cannot open URL|Download timed out"
        ),
        "Timeout of 1 seconds was reached"
      )
      success <- TRUE
    }, error = function(e) {
      if (grepl("HTTP 504 Gateway Timeout",
                e$message) && attempt <= max_attempts) {
        message("Retrying due to 504 Gateway Timeout...")
      } else {
        stop(e)
      }
    })
  }
  expect_true(success,
              info = "Test failed due to repeated 504 Gateway Timeout errors.")
})

test_that("ids_bulk handles warn_size parameter", {
  skip_if_offline()
  skip_on_cran()
  skip_if_not_installed("jsonlite")
  skip_if_not_installed("readxl")

  test_url <- ids_bulk_files()$file_url[1]

  local_mocked_bindings(
    download_file = function(...) TRUE
  )

  local_mocked_bindings(
    validate_file = function(...) TRUE
  )

  local_mocked_bindings(
    check_interactive = function() FALSE
  )

  expect_warning(
    download_bulk_file(
      test_url, tempfile(), 60, warn_size = TRUE, quiet = TRUE
    ),
    "This file is 125.8 MB and may take several minutes to download",
    fixed = FALSE
  )

  expect_no_warning(
    download_bulk_file(
      test_url, tempfile(), 60, warn_size = FALSE, quiet = TRUE
    )
  )
})

test_that("ids_bulk validates downloaded files", {
  temp_file <- tempfile()
  file.create(temp_file)

  expect_error(
    validate_file(temp_file),
    "Download failed: Empty file"
  )

  expect_error(
    validate_file("nonexistent.xlsx"),
    "Download failed: File not created"
  )
})

test_that("download_bulk_file downloads files correctly", {
  skip_if_offline()
  skip_on_cran()

  test_url <- ids_bulk_files()$file_url[1]
  test_path <- tempfile(fileext = ".xlsx")

  local_mocked_bindings(
    check_interactive = function() FALSE
  )

  withr::with_options(
    list(timeout = 300),
    expect_no_error(
      download_bulk_file(
        test_url,
        test_path,
        timeout = 300,
        warn_size = FALSE,
        quiet = TRUE
      )
    )
  )

  expect_true(file.exists(test_path))
  expect_gt(file.size(test_path), 0)

  unlink(test_path)
})

test_that("read_bulk_file reads files correctly", {
  skip_on_cran()

  test_path <- test_path("data/sample.xlsx")
  result <- read_bulk_file(test_path)
  expect_s3_class(result, "tbl_df")
})

test_that("process_bulk_data processes data correctly", {
  test_path <- test_path("data/sample.rds")
  result <- process_bulk_data(readRDS(test_path))

  expect_s3_class(result, "tbl_df")
  expect_named(
    result,
    c("geography_id", "series_id", "counterpart_id", "year", "value")
  )

  expect_type(result$geography_id, "character")
  expect_type(result$series_id, "character")
  expect_type(result$counterpart_id, "character")
  expect_type(result$year, "integer")
  expect_type(result$value, "double")

  expect_gt(nrow(result), 0)

  expect_false(any(is.na(result$geography_id)))
  expect_false(any(is.na(result$series_id)))
  expect_false(any(is.na(result$counterpart_id)))
  expect_false(any(is.na(result$year)))
})

test_that("ids_bulk downloads and processes data correctly", {
  skip_if_offline()
  skip_on_cran()
  skip_if_not_installed("jsonlite")
  skip_if_not_installed("readxl")

  test_url <- paste0(
    "https://datacatalogfiles.worldbank.org/ddh-published/0038015/DR0092201/",
    "A_D.xlsx?versionId=2024-10-08T01:35:39.3946879Z"
  )
  test_path <- tempfile(fileext = ".xlsx")

  local_mocked_bindings(
    check_interactive = function() FALSE,
    download_bulk_file = function(...) TRUE,
    read_bulk_file = function(...) readRDS(test_path("data/sample.rds"))
  )

  result <- ids_bulk(
    test_url, file_path = test_path, quiet = TRUE, warn_size = FALSE
  )

  expect_s3_class(result, "tbl_df")

  expected_columns <- c(
    "geography_id", "series_id", "counterpart_id", "year", "value"
  )
  expect_equal(colnames(result), expected_columns)

  expected_types <- c(
    "character", "character", "character", "integer", "numeric"
  )
  expect_true(all(lapply(result, class) == expected_types))
})

test_that("check_interactive returns expected results", {
  if (interactive()) {
    expect_true(check_interactive())
  } else {
    expect_false(check_interactive())
  }
})

test_that("download_file downloads a file correctly", {
  url <- "https://example.com"
  destfile <- tempfile(fileext = ".txt")
  if (file.exists(destfile)) {
    file.remove(destfile)
  }
  download_file(url, destfile, quiet = TRUE)
  expect_true(file.exists(destfile))
  file.remove(destfile)
})

test_that("warn_size warning is triggered & user prompt is handled correctly", {
  skip_if_offline()
  skip_on_cran()
  skip_if_not_installed("jsonlite")
  skip_if_not_installed("readxl")

  test_url <- paste0(
    "https://datacatalogfiles.worldbank.org/ddh-published/0038015/DR0092201/",
    "A_D.xlsx?versionId=2024-10-08T01:35:39.3946879Z"
  )

  with_mocked_bindings(
    get_response_headers = function(...) list(`content-length` = 150 * 1024^2),
    check_interactive = function(...) TRUE,
    prompt_user = function(...) "y",
    {
      expect_warning(
        download_bulk_file(
          test_url, tempfile(fileext = ".xlsx"),
          timeout = 30, warn_size = TRUE, quiet = TRUE
        ),
        regexp = "may take several minutes to download."
      )
    }
  )

  with_mocked_bindings(
    get_response_headers = function(...) list(`content-length` = 150 * 1024^2),
    check_interactive = function(...) TRUE,
    prompt_user = function(...) "n",
    {
      expect_error(
        suppressWarnings(download_bulk_file(
          test_url, tempfile(fileext = ".xlsx"),
          timeout = 30, warn_size = TRUE, quiet = TRUE
        )),
        regexp = "Download cancelled."
      )
    }
  )
})
