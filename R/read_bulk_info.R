#' @keywords internal
#' @noRd
#'
read_bulk_info <- function() {

  rlang::check_installed(
    "jsonlite", reason = "to retrieve available series via bulk download."
  )

  jsonlite::fromJSON(
    txt = paste0(
      "https://datacatalogapi.worldbank.org/ddhxext/DatasetDownload",
      "?dataset_unique_id=0038015&version_id="
    )
  )
}
