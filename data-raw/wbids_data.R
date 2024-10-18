
# Prepare geography data ----------------------------------------------------------------------


# Prepare series data -------------------------------------------------------------------------

series_raw <- perform_request("series")

series <- series_raw[[1]]$concept[[1]]$variable |>
  bind_rows() |>
  select(
    series_id = "id",
    series_name = "value"
  )

ids_list_series <- function() {
  series
}

# Prepare counterpart data --------------------------------------------------------------------


# Prepare series-topics data ------------------------------------------------------------------


# Store all data in single rda file -----------------------------------------------------------

# TODO: add other data sources later here as well

usethis::use_data(
  series,
  overwrite = TRUE, internal = TRUE
)
