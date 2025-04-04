#' Retrieve Available Bulk Download Files for International Debt Statistics
#'
#' This function returns a tibble with metadata for files available for bulk
#' download via the World Bank International Debt Statistics (IDS). It includes
#' information such as file names, URLs, and the last update dates for each file
#' in Excel (xlsx) format.
#'
#' @return A tibble containing the available files and their metadata:
#' \describe{
#'   \item{file_name}{The name of the file available for download.}
#'   \item{file_url}{The URL to download the file in Excel format.}
#'   \item{last_updated_date}{The date when the file was last updated.}
#' }
#'
#' @export
#'
#' @examplesIf curl::has_internet() && rlang::is_installed("jsonlite")
#' ids_bulk_files()
#'
ids_bulk_files <- function() {
  ids_meta <- read_bulk_info()

  bulk_files <- ids_meta$resources |>
    as_tibble() |>
    select("name", "distribution", "last_updated_date") |>
    tidyr::unnest("distribution") |>
    filter(
      grepl("Bulk Download File - Debtor Countries:", .data$name) &
        !is.na(.data$url)
    ) |>
    select(file_name = "name", file_url = "url", "last_updated_date") |>
    mutate(
      file_url = sub("\\?.*$", "", .data$file_url),
      last_updated_date = as.Date(.data$last_updated_date)
    ) |>
    arrange("file_url")

  bulk_files
}
