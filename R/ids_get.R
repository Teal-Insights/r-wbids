ids_get <- function(
    geographies,  # geographies = "ZMB"
    series, # c("DT.DOD.DPPG.CD", "BM.GSR.TOTL.CD")
    counterparts, # counterparts = c("all")
    start_date = NULL,
    end_date = NULL,
    per_page = 1000,
    progress = TRUE
) {

  # TODO: add support for multiple geographies

  # TODO: add support for multiple counterpart areas

  if (!is.logical(progress)) {
    cli::cli_abort("{.arg progress} must be either TRUE or FALSE.")
  }

  date <- if (!is.null(start_date) & !is.null(end_date)) {
    # TODO: add support for date range, we need to loop over years
    # all works: https://api.worldbank.org/v2/sources/6/country/AGO/series/DT.DOD.BLAT.CD/counterpart-area/701/time/all
    # specific year works: https://api.worldbank.org/v2/sources/6/country/AGO/series/DT.DOD.BLAT.CD/counterpart-area/701/time/YR2020
  } else {
    time <- "all"
  }

  debt_statistics <- list()

  debt_statistics <- map_df(seq_along(series), function(j) {

    progress_req <- if (progress) {
      paste0("Sending requests for series ", series[j])
    } else {
      FALSE
    }

    resource <- paste0(
      "country/", geographies,
      "/series/", series[j],
      "/counterpart-area/", counterparts,
      "/time/", time
    )

    series_raw <- perform_request(resource, per_page, date, progress_req)

    series_raw_rbind <- series_raw |>
      bind_rows()

    # Since the order of list items changes across series, we cannot use hard coded list paths
    series_wide <- series_raw_rbind |>
      select(variable) |>
      tidyr::unnest_wider(variable)

    geography_ids <- series_wide |>
      filter(concept == "Country") |>
      select(geography_id = id)

    series_ids <- series_wide |>
      filter(concept == "Series") |>
      select(series_id = id)

    counterpart_ids <- series_wide |>
      filter(concept == "Counterpart-Area") |>
      select(counterpart_id = id)

    years <- series_wide |>
      filter(concept == "Time") |>
      select(year = value) |>
      mutate(year = as.integer(year))

    values <- extract_values(series_raw, "value", "numeric")

    bind_cols(
      geography_ids,
      series_ids,
      counterpart_ids,
      years,
      value = values
    )
  })

  debt_statistics
}
