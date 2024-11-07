#' List Available Counterparts from the World Bank International Debt Statistics
#' API
#'
#' This function returns a tibble with available counterparts from the World
#' Bank International Debt Statistics (IDS) API. Each row provides details on
#' counterparts, including their unique identifiers, names, and types.
#'
#' @return A tibble containing the available counterparts and their attributes:
#' \describe{
#'   \item{counterpart_id}{The unique identifier for the counterpart (e.g.,
#'                         "730").}
#'   \item{counterpart_name}{The standardized name of the counterpart (e.g.,
#'                           "China").}
#'   \item{counterpart_iso2code}{ISO 3166-1 alpha-2 code of the counterpart
#'                               (e.g., "CN").}
#'   \item{counterpart_iso3code}{ISO 3166-1 alpha-3 code of the counterpart
#'                               (e.g., "CHN").}
#'   \item{counterpart_type}{The type of counterpart (e.g., "Country",
#'                           "Institution", "Region").}
#' }
#'
#' @export
#'
#' @examples
#' ids_list_counterparts()
#'
ids_list_counterparts <- function() {
  counterparts
}
