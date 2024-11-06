# Set timeout for testing
options(timeout = 60)

test_that("ids_bulk handles custom file paths", {
  skip_if_offline()

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

  # Check that file is cleaned up when we're done
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

test_that("quiet parameter controls message output", {
  test_url <- ids_bulk_files()$file_url[1]

  # Create a small mock dataset that read_excel would return
  mock_data <- tibble::tibble(
    "Country Code" = "ABC",
    "Country Name" = "Test Country",
    "Classification Name" = "Test Class",
    "Series Code" = "TEST.1",
    "Series Name" = "Test Series",
    "2020" = 100
  )

  # Set up mocked bindings
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

  # Should show messages
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

  # Should not show messages
  expect_no_message(
    ids_bulk(test_url, quiet = TRUE, warn_size = FALSE)
  )
})

test_that("ids_bulk handles timeout parameter correctly", {
  skip_if_offline()
  skip_on_cran()

  # Mock a slow URL that will definitely timeout
  mock_url <- "http://httpbin.org/delay/10"

  # Mock interactive to return FALSE
  local_mocked_bindings(
    check_interactive = function() FALSE
  )

  # Test with short timeout (1 second)
  expect_warning(
    expect_error(
      ids_bulk(mock_url, timeout = 1, warn_size = FALSE),
      "cannot open URL|Download timed out"
    ),
    "Timeout of 1 seconds was reached"
  )
})

test_that("ids_bulk handles warn_size parameter", {
  skip_if_offline()
  skip_on_cran()

  # Get a real file URL to test with
  test_url <- ids_bulk_files()$file_url[1]

  # Mock download_file with mocked_bindings
  local_mocked_bindings(
    download_file = function(...) TRUE
  )

  # Mock validate_file with mocked_bindings
  local_mocked_bindings(
    validate_file = function(...) TRUE
  )

  # Mock interactive to return FALSE
  local_mocked_bindings(
    check_interactive = function() FALSE
  )

  # Should show warning with warn_size = TRUE
  expect_warning(
    download_bulk_file(
      test_url, tempfile(), 60, warn_size = TRUE, quiet = TRUE
    ),
    "This file is 125.8 MB and may take several minutes to download",
    fixed = FALSE
  )

  # Should not show warning with warn_size = FALSE
  expect_no_warning(
    download_bulk_file(
      test_url, tempfile(), 60, warn_size = FALSE, quiet = TRUE
    )
  )
})

test_that("ids_bulk validates downloaded files", {
  # Mock an empty file
  temp_file <- tempfile()
  file.create(temp_file)

  expect_error(
    validate_file(temp_file),
    "Download failed: Empty file"
  )

  # Mock a non-existent file
  expect_error(
    validate_file("nonexistent.xlsx"),
    "Download failed: File not created"
  )
})

test_that("download_bulk_file downloads files correctly", {
  skip_if_offline()
  skip_on_cran()

  # Get a real file URL to test with
  test_url <- ids_bulk_files()$file_url[1]
  test_path <- tempfile(fileext = ".xlsx")

  # Mock interactive check to avoid prompts
  local_mocked_bindings(
    check_interactive = function() FALSE
  )

  # Test successful download
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

  # Verify file exists and has content
  expect_true(file.exists(test_path))
  expect_gt(file.size(test_path), 0)

  # Clean up
  unlink(test_path)
})

test_that("read_bulk_file reads files correctly", {
  # Loading the sample file is slow, so skip on CRAN
  skip_on_cran()

  test_path <- test_path("data/sample.xlsx")
  result <- read_bulk_file(test_path)
  expect_s3_class(result, "tbl_df")
})

test_that("process_bulk_data processes data correctly", {
  test_path <- test_path("data/sample.rds")
  result <- process_bulk_data(readRDS(test_path))

  # Check structure
  expect_s3_class(result, "tbl_df")
  expect_named(
    result,
    c("geography_id", "series_id", "counterpart_id", "year", "value")
  )

  # Check data types
  expect_type(result$geography_id, "character")
  expect_type(result$series_id, "character")
  expect_type(result$counterpart_id, "character")
  expect_type(result$year, "integer")
  expect_type(result$value, "double")

  # Check for non-empty result
  expect_gt(nrow(result), 0)

  # Check that all values in required columns are non-NA
  expect_false(any(is.na(result$geography_id)))
  expect_false(any(is.na(result$series_id)))
  expect_false(any(is.na(result$counterpart_id)))
  expect_false(any(is.na(result$year)))
})

test_that("ids_bulk downloads and processes data correctly", {
  skip_if_offline()
  skip_on_cran()

  # Get a real file URL to test with
  test_url <- ids_bulk_files()$file_url[1]

  # Mock slow-running functions
  local_mocked_bindings(
    check_interactive = function() FALSE,
    download_bulk_file = function(...) TRUE,
    read_bulk_file = function(...) readRDS(test_path("data/sample.rds"))
  )

  # Check that output is a tibble (add more assertions here)
  result <- ids_bulk(
    test_url, file_path = test_path, quiet = TRUE, warn_size = FALSE
  )
  expect_s3_class(result, "tbl_df")
})
