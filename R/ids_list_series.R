#' List Available Series from the World Bank International Debt Statistics API
#'
#' This function returns a tibble with available series from the World Bank International Debt Statistics
#' (IDS) API. Each series provides data on various debt-related indicators.
#'
#' @return A tibble with two columns:
#' \describe{
#'   \item{series_id}{The unique identifier for the series (e.g., "BN.CAB.XOKA.CD").}
#'   \item{series_name}{The name of the series (e.g., "Current account balance (current US$)").}
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
