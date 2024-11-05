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
#'
#' @examplesIf curl::has_internet()
#' available_files <- ids_bulk_files()
#' data <- ids_bulk(
#'   available_files$file_url[1]
#' )
#'
ids_bulk <- function(
  file_url, file_path = tempfile(fileext = ".xlsx"), quiet = FALSE
) {

  rlang::check_installed(
    "readxl", reason = "to download bulk files."
  )

  if (!quiet) {
    cli::cli_inform("Downloading file to: {file_path}")
  }

  utils::download.file(file_url, destfile = file_path, quiet = quiet)

  if (!quiet) {
    cli::cli_inform("Reading in file.")
  }

  available_columns <- readxl::read_excel(path = file_path, n_max = 0) |>
    colnames()
  relevant_columns <- tibble(names = available_columns) |>
    mutate(
      type = if_else(grepl(pattern = "[0:9]", .data$names), "numeric", "text")
    ) |>
    filter(!grepl("column", names, ignore.case = TRUE))

  bulk_raw <- readxl::read_excel(
    path = file_path,
    range = readxl::cell_cols(seq_len(nrow(relevant_columns))),
    col_types = relevant_columns$type
  )

  if (!quiet) {
    cli::cli_inform("Processing file.")
  }

  bulk <- bulk_raw |>
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

  if (!quiet) {
    cli::cli_inform("Deleting file.")
  }

  unlink(file_path)

  bulk
}
