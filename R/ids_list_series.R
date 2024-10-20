#' List Available Series from the World Bank International Debt Statistics API
#'
#' This function returns a tibble with available series from the World Bank
#' International Debt Statistics (IDS) API. Each series provides data on various
#' debt-related indicators.
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
#' @examples
#' ids_list_series()
#'
ids_list_series <- function() {
  series
}
