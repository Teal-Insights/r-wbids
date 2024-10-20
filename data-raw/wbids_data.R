devtools::load_all()

# Prepare geography data -------------------------------------------------------


# Prepare series data ----------------------------------------------------------

series_raw <- perform_request("series")

series_processed <- series_raw[[1]]$concept[[1]]$variable |>
  bind_rows() |>
  select(
    series_id = "id",
    series_name = "value"
  )

# Download package via: pak::pak("tidy-intelligence/r-wbwdi")
indicators <- wbwdi::wdi_get_indicators()

series_extended <- series_processed |>
  left_join(indicators, join_by(series_id == indicator_id))

series <- series_extended |>
  select(series_id, series_name, source_id, source_name,
         source_note, source_organization)

# Prepare counterpart data -----------------------------------------------------


# Prepare series-topics data ---------------------------------------------------

series_topics <- series_extended |>
  select(series_id, topics) |>
  tidyr::unnest(topics)

# Store all data in single rda file --------------------------------------------

usethis::use_data(
  series, series_topics,
  overwrite = TRUE, internal = TRUE
)
