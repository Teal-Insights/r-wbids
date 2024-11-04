ids_bulk_series <- function() {

  ids_meta <- jsonlite::fromJSON(
    txt = paste0(
      "https://datacatalogapi.worldbank.org/ddhxext/DatasetDownload",
      "?dataset_unique_id=0038015&version_id="
    )
  )

  bulk_series <- ids_meta$indicators |>
    as_tibble() |>
    select(lineage) |>
    unnest(lineage) |>
    select(series_id = harvest_system_reference)

  api_series <- ids_list_series()

  bulk_series <- bulk_series |>
    inner_join(api_series, join_by(series_id))

  bulk_series

}
