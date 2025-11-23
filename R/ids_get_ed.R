#' Get full IDS tables from EconDataverse datasets
#'
#' A convenience wrapper around `econdatasets::ed_get()` that retrieves
#' tables from the World Bank International Debt Statistics (IDS) dataset
#' hosted on EconDataverse Hugging Face repositories.
#'
#' @param table Character string naming the table from the IDS dataset.
#'   Default: `"debt_statistics"`.
#' @param columns Character vector naming the columns. Defaults to `NULL`.
#' @param quiet A logical parameter indicating whether messages should be
#' printed to the console.
#'
#' @return A `data.frame` containing the requested IDS table, or `NULL` if
#'   the download fails.
#'
#' @seealso [econdatasets::ed_get()] for the underlying function that
#'   downloads data from EconDataverse repositories.
#'
#' @examplesIf curl::has_internet()
#' \donttest{
#' # Get the default debt statistics table
#' debt_statitics <- ids_get_ed()
#'
#' # Get a different table from IDS
#' series_data <- ids_get_ed("series")
#' }
#'
#' @export
ids_get_ed <- function(
  table = "debt_statistics",
  columns = NULL,
  quiet = FALSE
) {
  econdatasets::ed_get(
    dataset = "wbids",
    table = table,
    columns = columns,
    quiet = quiet
  ) |>
    tibble::as_tibble()
}
