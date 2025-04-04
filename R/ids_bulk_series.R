#' Retrieve Bulk Series Metadata for International Debt Statistics
#'
#' This function retrieves a tibble with metadata for series available via
#' bulk download of the World Bank International Debt Statistics (IDS).
#'
#' @return A tibble containing the available series and their metadata:
#' \describe{
#'   \item{series_id}{The unique identifier for the series (e.g.,
#'                    "BN.CAB.XOKA.CD").}
#'   \item{series_name}{The name of the series (e.g., "Current account balance
#'                      (current US$)").}
#'   \item{source_id}{The ID of the data source providing the indicator.}
#'   \item{source_name}{The name or description of the source of the indicator
#'                      data.}
#'   \item{source_note}{Additional notes or descriptions about the data source.}
#'   \item{source_organization}{The organization responsible for the data
#'                              source.}
#' }
#'
#' @export
#'
#' @examplesIf curl::has_internet() && rlang::is_installed("jsonlite")
#' ids_bulk_series()
#'
ids_bulk_series <- function() {
  ids_meta <- read_bulk_info()

  bulk_series <- ids_meta$indicators |>
    as_tibble() |>
    select("lineage") |>
    tidyr::unnest("lineage") |>
    select(series_id = "harvest_system_reference")

  api_series <- ids_list_series()

  bulk_series <- bulk_series |>
    left_join(api_series, join_by("series_id"))

  bulk_series
}
