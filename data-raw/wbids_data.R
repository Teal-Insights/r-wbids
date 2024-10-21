
library(wbwdi)
library(tidyr)
library(usethis)
library(devtools)

load_all()

# Prepare geography data -------------------------------------------------------

geographies_raw <- perform_request("country")

geographies_ids <- geographies_raw[[1]]$concept[[1]]$variable |>
  bind_rows() |>
  select(geography_id = id,
         geography_name = value)

geographies_wdi <- wdi_get_geographies() |>
  select(-c(geography_name, longitude, latitude))

geographies <- geographies_ids |>
  left_join(geographies_wdi, join_by(geography_id))

# Prepare series data ----------------------------------------------------------

series_raw <- perform_request("series")

series_ids <- series_raw[[1]]$concept[[1]]$variable |>
  bind_rows() |>
  select(
    series_id = "id",
    series_name = "value"
  )

indicators_wdi <- wdi_get_indicators()

series_extended <- series_ids |>
  left_join(indicators_wdi, join_by(series_id == indicator_id))

series <- series_extended |>
  select(series_id, series_name, source_id, source_name,
         source_note, source_organization)

# Prepare counterpart data -----------------------------------------------------


# Prepare series-topics data ---------------------------------------------------

series_topics <- series_extended |>
  select(series_id, topics) |>
  unnest(topics)

# Store all data in single rda file --------------------------------------------

usethis::use_data(
  geographies, series, series_topics,
  overwrite = TRUE, internal = TRUE
)
