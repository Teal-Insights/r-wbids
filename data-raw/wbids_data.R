
library(wbwdi)
library(tidyr)
library(usethis)
library(devtools)
library(econid)

load_all()

# Prepare geography data -------------------------------------------------------

geographies_raw <- perform_request("country")

geographies_ids <- geographies_raw[[1]]$concept[[1]]$variable |>
  bind_rows() |>
  select(geography_id = id,
         geography_name = value)

geographies_wdi <- wdi_get_geographies()

# TODO: geographies_name needs to be enriched with micropackage later
geographies <- geographies_ids |>
  left_join(geographies_wdi |>
              select(-c(geography_name, longitude, latitude)),
            join_by(geography_id))

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

counterparts_raw <- perform_request("counterpart-area")

counterparts_ids <- counterparts_raw[[1]]$concept[[1]]$variable |>
  bind_rows() |>
  select(counterpart_id = id,
         counterpart_name = value)

global_ifis <- c(
  "International Monetary Fund",
  "Bank for International Settlements (BIS)"
)

global_mdbs <- c(
  "World Bank-IDA",
  "World Bank-IBRD",
  "World Bank-MIGA",
  "International Finance Corporation",
  "International Fund for Agricultural Dev.",
  "European Bank for Reconstruction and Dev. (EBRD)",
  "African Dev. Bank",
  "Asian Dev. Bank",
  "Inter-American Dev. Bank",
  "Asian Infrastructure Investment Bank"
)

# TODO: counterpart data needs to be updated with geography micropackage later

counterparts <- counterparts_ids |>
  left_join(geographies_wdi |>
              select(geography_name,
                     counterpart_iso2code = geography_iso2code,
                     counterpart_iso3code = geography_id,
                     geography_type),
            join_by(counterpart_name == geography_name)) |>
  mutate(
    counterpart_type = case_when(
      counterpart_name %in% global_ifis ~ "Global IFIs",
      counterpart_name %in% global_mdbs ~ "Global MDBs",
      counterpart_name %in% c("Bondholders") ~ "Bondholders",
      counterpart_name %in% c("World") ~ "All Creditors",
      geography_type == "Country" ~ "Country",
      geography_type == "Region" ~ "Region",
      .default = "Other"
    )
  ) |>
  select(-geography_type)

# Prepare series-topics data ---------------------------------------------------

series_topics <- series_extended |>
  select(series_id, topics) |>
  unnest(topics)

# Store all data in single rda file --------------------------------------------

usethis::use_data(
  geographies, series, counterparts, series_topics,
  overwrite = TRUE, internal = TRUE
)
