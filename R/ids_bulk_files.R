ids_bulk_files <- function() {

  ids_meta <- jsonlite::fromJSON(
    txt = paste0(
      "https://datacatalogapi.worldbank.org/ddhxext/DatasetDownload",
      "?dataset_unique_id=0038015&version_id="
    )
  )

  bulk_files <- ids_meta$resources |>
    as_tibble() |>
    View()
    select(name, distribution, last_updated_date) |>
    unnest(distribution) |>
    filter(distribution_format == "xlsx") |>
    select(file_name = name, file_url = url, last_updated_date) |>
    mutate(last_updated_date = as.Date(last_updated_date))

  bulk_files

}
