#' Download and Process Bulk Data File for International Debt Statistics
#'
#' This function downloads a data file from the World Bank International Debt
#' Statistics (IDS), reads and processes the data into a tidy format.
#'
#' @param file_url A character string specifying the URL of the Excel file to
#' download. This parameter is required (see \link{ids_bulk_files}).
#' @param file_path An optional character string specifying the file path where
#' the downloaded file will be saved. Defaults to a temporary file with `.xlsx`
#' extension. The file will automatically be deleted after processing.
#' @param quiet A logical parameter indicating whether messages should be
#' printed to the console.
#' @param timeout An integer specifying the timeout in seconds for downloading
#' the file. Defaults to the current R timeout setting.
#' @param warn_size A logical parameter indicating whether to warn about large
#' downloads. Defaults to TRUE.
#'
#' @return A tibble containing processed debt statistics data with the following
#' columns:
#' \describe{
#'   \item{geography_id}{The unique identifier for the geography (e.g., "ZMB").}
#'   \item{series_id}{The unique identifier for the series (e.g.,
#'                    "DT.DOD.DPPG.CD").}
#'   \item{counterpart_id}{The unique identifier for the counterpart series.}
#'   \item{year}{The year corresponding to the data (as an integer).}
#'   \item{value}{The numeric value representing the statistic for the given
#'                geography, series, counterpart, and year.}
#' }
#'
#' @export
#' @examplesIf curl::has_internet() && rlang::is_installed("readxl")
#' \donttest{
#' available_files <- ids_bulk_files()
#' data <- ids_bulk(
#'   available_files$file_url[1]
#' )
#' }
#'
ids_bulk <- function(
  file_url,
  file_path = tempfile(fileext = ".xlsx"),
  quiet = FALSE,
  timeout = getOption("timeout", 60),
  warn_size = TRUE
) {

  rlang::check_installed("readxl", reason = "to download bulk files.")

  on.exit(unlink(file_path))

  download_bulk_file(file_url, file_path, timeout, warn_size, quiet)

  if (!quiet) cli::cli_progress_message("Reading in file.")
  bulk_data <- read_bulk_file(file_path)

  if (!quiet) cli::cli_progress_message("Processing file.")
  bulk_data <- process_bulk_data(bulk_data)

  bulk_data
}

#' Get response headers from a URL
#'
#' @param file_url URL to request headers from
#' @return List of response headers
#'
#' @keywords internal
#' @noRd
get_response_headers <- function(file_url) {
  httr2::request(file_url) |>
    httr2::req_headers("Accept" = "*/*") |>
    httr2::req_perform() |>
    httr2::resp_headers()
}

#' Download bulk data file with validation
#'
#' @param file_url URL of the file to download
#' @param file_path Path where file should be saved
#' @param timeout Timeout in seconds
#' @param warn_size Whether to warn about large files
#' @param quiet Whether to suppress messages
#'
#' @keywords internal
#' @noRd
#'
download_bulk_file <- function(file_url, file_path, timeout, warn_size, quiet) {

  response_headers <- get_response_headers(file_url)
  size_mb <- as.numeric(response_headers$`content-length`) / 1024^2
  formatted_size <- format(round(size_mb, 1), nsmall = 1) # nolint

  if (warn_size && size_mb > 100) {
    cli::cli_warn(paste0(
      "This file is {formatted_size} MB and may take several minutes to ",
      "download. Current timeout setting: {timeout} seconds. Use ",
      "{.code warn_size = FALSE} to disable this warning."
    ))

    if (warn_size && check_interactive()) {
      response <- prompt_user(
        "Do you want to continue with the download? (y/N): "
      )
      if (!tolower(response) %in% c("y", "yes")) {
        cli::cli_abort("Download cancelled by user")
      }
    }
  }

  if (!quiet) {
    cli::cli_progress_message("Downloading file to: {file_path}")
  }

  # nocov start
  withr::with_options(
    list(timeout = timeout),
    tryCatch({
      download_file(file_url, destfile = file_path, quiet = quiet)
    },
    error = function(e) {
      if (grepl("timeout|cannot open URL", e$message, ignore.case = TRUE)) {
        cli::cli_abort(
          paste0(
            "Download timed out after ", timeout, " seconds.\n",
            "Try increasing the timeout parameter",
            " (e.g., timeout=600 for 10 minutes)"
          )
        )
      }
      cli::cli_abort(e$message)
    })
  )
  # nocov end
  validate_file(file_path)
}

#' Validate that downloaded file exists and is not empty
#'
#' @param file_path Path to file to validate
#' @noRd
#'
validate_file <- function(file_path) {
  if (!file.exists(file_path)) {
    cli::cli_abort("Download failed: File not created")
  }
  if (file.size(file_path) == 0) {
    unlink(file_path)
    cli::cli_abort("Download failed: Empty file")
  }
}

#' Read bulk file and determine column types
#'
#' @param file_path Path to Excel file
#' @return Raw data frame from Excel file
#' @noRd
#'
read_bulk_file <- function(file_path) {
  available_columns <- readxl::read_excel(path = file_path, n_max = 0) |>
    colnames()
  relevant_columns <- tibble(names = available_columns) |>
    mutate(
      type = if_else(grepl(pattern = "[0:9]", .data$names), "numeric", "text")
    ) |>
    filter(!grepl("column", names, ignore.case = TRUE))

  readxl::read_excel(
    path = file_path,
    range = readxl::cell_cols(seq_len(nrow(relevant_columns))),
    col_types = relevant_columns$type
  )
}

#' Process bulk data into tidy format
#'
#' @param bulk_raw Raw data frame from Excel file
#' @return Processed tibble in tidy format
#' @noRd
#'
process_bulk_data <- function(bulk_raw) {
  bulk_raw |>
    select(-c("Country Name", "Classification Name")) |>
    select(
      geography_id = "Country Code",
      series_id = "Series Code",
      counterpart_id = "Series Name",
      everything()
    ) |>
    tidyr::pivot_longer(
      cols = -c("geography_id", "series_id", "counterpart_id"),
      names_to = "year"
    ) |>
    mutate(year = as.integer(.data$year)) |>
    tidyr::drop_na()
}

#' Check if R is running interactively
#'
#' Wrapper around base::interactive() to make the function testable.
#' This function exists primarily to facilitate testing of interactive features.
#'
#' @return Logical indicating whether R is running interactively
#' @keywords internal
#' @noRd
#'
check_interactive <- function() {
  interactive()
}

#' Download a file using utils::download.file
#'
#' Wrapper around utils::download.file to facilitate testing.
#'
#' @param url URL of file to download
#' @param destfile Destination file path
#' @param quiet Whether to suppress messages
#' @return Invisibly returns the status code from download.file
#' @keywords internal
#' @noRd
#'
download_file <- function(url, destfile, quiet) {
  utils::download.file(url, destfile = destfile, quiet = quiet, mode = "wb")
}

#' Prompt a user with a question
#'
#' Wrapper around base::readline to facilitate testing. Cannot be tested
#' because of the base binding.
#'
#' @keywords internal
#' @noRd
#'
prompt_user <- function(prompt) {
  readline(prompt) # nocov
}
