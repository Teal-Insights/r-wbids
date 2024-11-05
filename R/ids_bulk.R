ids_bulk <- function(file_url, file_path = tempfile(fileext = ".xlsx")) {

  rlang::check_installed(
    "readxl", reason = "to download bulk files."
  )

  cli::cli_inform("Downloading file to: {file_path}")
  utils::download.file(file_url, destfile = file_path, quiet = TRUE)

  cli::cli_inform("Reading in file.")
  available_columns <- readxl::read_excel(path = file_path, n_max = 0) |>
    colnames()
  relevant_columns <- tibble(names = available_columns) |>
    mutate(type = if_else(grepl(pattern = "[0:9]", names), "numeric", "text")) |>
    filter(!grepl("column", names, ignore.case = TRUE))

  bulk_raw <- readxl::read_excel(
    path = file_path,
    range = readxl::cell_cols(1:nrow(relevant_columns)),
    col_types = relevant_columns$type
  )

  cli::cli_inform("Processing file.")
  bulk <- bulk_raw |>
    select(-c(`Country Name`, `Classification Name`)) |>
    select(
      geography_id = `Country Code`,
      series_id = `Series Code`,
      counterpart_id = `Series Name`,
      everything()
    ) |>
    tidyr::pivot_longer(
      cols = -c(geography_id, series_id, counterpart_id),
      names_to = "year"
    ) |>
    mutate(year = as.integer(year)) |>
    tidyr::drop_na()

  cli::cli_inform("Deleting file.")
  unlink(file_path)

  bulk
}

