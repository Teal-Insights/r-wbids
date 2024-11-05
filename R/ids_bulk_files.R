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
#' @examplesIf curl::has_internet()
#' ids_bulk_files()
#'
ids_bulk_files <- function() {

  rlang::check_installed(
    "jsonlite", reason = "to download bulk files."
  )

  ids_meta <- jsonlite::fromJSON(
    txt = paste0(
      "https://datacatalogapi.worldbank.org/ddhxext/DatasetDownload",
      "?dataset_unique_id=0038015&version_id="
    )
  )

  bulk_files <- ids_meta$resources |>
    as_tibble() |>
    select("name", "distribution", "last_updated_date") |>
    unnest("distribution") |>
    filter(.data$distribution_format == "xlsx") |>
    select(file_name = "name", file_url = "url", "last_updated_date") |>
    mutate(last_updated_date = as.Date(.data$last_updated_date))

  bulk_files

}
