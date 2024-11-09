library(dplyr)
library(wbwdi)
library(econid)
library(devtools)

load_all()

# Prepare geography data -------------------------------------------------------

# TODO: once econid is on CRAN, directly call this in id_list_geographies()
#       and add econid to Imports
geographies <- econid::geographies

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

# TODO: once econid is on CRAN, directly call this in id_list_geographies()
#       and add econid to Imports
counterparts <- econid::counterparts

# Prepare series-topics data ---------------------------------------------------

series_topics <- series_extended |>
  select(series_id, topics) |>
  unnest(topics)

# Store all data in single rda file --------------------------------------------

use_data(
  geographies, series, counterparts, series_topics,
  overwrite = TRUE, internal = TRUE
)
