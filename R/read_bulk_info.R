#' Read Bulk Information from World Bank Data Catalog API
#'
#' Internal function to retrieve bulk download information for International
#' Debt Statistics (IDS) from the World Bank Data Catalog API.
#'
#' @return A list containing metadata about available bulk downloads
#' @keywords internal
#'
read_bulk_info <- function() {
  rlang::check_installed(
    "jsonlite",
    reason = "to retrieve available series via bulk download."
  )

  jsonlite::fromJSON(
    txt = paste0(
      "https://datacatalogapi.worldbank.org/ddhxext/DatasetDownload",
      "?dataset_unique_id=0038015&version_id="
    )
  )
}
