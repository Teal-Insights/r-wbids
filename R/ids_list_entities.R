#' List Available Entities from the World Bank International Debt Statistics
#' API
#'
#' This function returns a tibble with available entities from the World Bank
#' International Debt Statistics (IDS) API. Each row provides details on
#' entities, including their unique identifiers, names, and types.
#'
#' @return A tibble containing the available entities and their attributes:
#' \describe{
#'   \item{entity_id}{ISO 3166-1 alpha-3 code of the entity (e.g.,
#'                       "ZMB").}
#'   \item{entity_name}{The standardized name of the entity (e.g.,
#'                         "Zambia").}
#'   \item{entity_iso2code}{ISO 3166-1 alpha-2 code of the entity (e.g.,
#'                             "ZM").}
#'   \item{entity_type}{The type of entity (e.g., "Country", "Region").}
#'   \item{capital_city}{The capital city of the entity (e.g., "Lusaka").}
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
#' ids_list_entities()
#'
ids_list_entities <- function() {
  entities
}

#' @title Superseded: List Available Geographies
#'
#' @description
#' `r lifecycle::badge("superseded")`
#'
#' `ids_list_geographies()` has been superseded in favor of
#' [ids_list_entities()]. It still works, but will be retired in a future
#' release. Please use [ids_list_entities()] instead.
#'
#' @inherit ids_list_entities return
#'
#' @seealso [ids_list_entities()]
#' @keywords internal
#' @export
ids_list_geographies <- function() {
  #nocov start
  lifecycle::deprecate_warn(
    when = "1.1.0",
    what = "ids_list_geographies()",
    with = "ids_list_entities()"
  )
  ids_list_entities()
  #nocov end
}
