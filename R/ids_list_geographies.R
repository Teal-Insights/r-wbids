#' List Available Geographies from the World Bank International Debt Statistics
#' API
#'
#' This function returns a tibble with available geographies from the World Bank
#' International Debt Statistics (IDS) API. Each row provides details on
#' geographies, including their unique identifiers, names, and types.
#'
#' @return A tibble containing the available geographies and their attributes:
#' \describe{
#'   \item{geography_id}{ISO 3166-1 alpha-3 code of the geography (e.g.,
#'                       "ZMB").}
#'   \item{geography_name}{The standardized name of the geography (e.g.,
#'                         "Zambia").}
#'   \item{geography_iso2code}{ISO 3166-1 alpha-2 code of the geography (e.g.,
#'                             "ZM").}
#'   \item{geography_type}{The type of geography (e.g., "Country", "Region").}
#'   \item{capital_city}{The capital city of the geography (e.g., "Lusaka").}
#'   \item{region_id}{The unique identifier for the region (e.g., "SSF").}
#'   \item{region_iso2code}{ISO 3166-1 alpha-2 code of the region (e.g., "ZG").}
#'   \item{region_name}{The name of the region (e.g., "Sub-Saharan Africa").}
#'   \item{admin_region_id}{The unique identifier for the administrative region
#'                          (e.g., "SSA").}
#'   \item{admin_region_iso2code}{The ISO 3166-1 alpha-2 code for the
#'                                administrative region (e.g., "ZF").}
#'   \item{admin_region_name}{The name of the administrative region (e.g.,
#'                            "Sub-Saharan Africa (excluding high income)").}
#'   \item{lending_type_id}{The unique identifier for the lending type (e.g.,
#'                          "IDX").}
#'   \item{lending_type_iso2code}{ISO code for the lending type (e.g., "XI").}
#'   \item{lending_type_name}{The name of the lending type (e.g., "IDA").}
#' }
#'
#' @export
#'
#' @examples
#' ids_list_geographies()
#'
ids_list_geographies <- function() {
  geographies
}
