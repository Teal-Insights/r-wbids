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
    # TODO: add support for date range, we need to loop...
    # all works: https://api.worldbank.org/v2/sources/6/country/AGO/series/DT.DOD.BLAT.CD/counterpart-area/701/time/all
    # specific year works: https://api.worldbank.org/v2/sources/6/country/AGO/series/DT.DOD.BLAT.CD/counterpart-area/701/time/YR2020
  } else {
    time <- "all"
  }

  debt_statistics <- list()

  debt_statistics <- map(seq_along(series), function(j) {

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

    # TODO: replace the numbers by another strategy because the order changes by series..
    parse_response <- function(x) {
      tibble(
        geography_id = extract_values(x, "variable[[1]]$id", "character"),
        series_id = extract_values(x, "variable[[3]]$id", "character"),
        counterpart_id = extract_values(x, "variable[[2]]$id", "character"),
        year = as.integer(extract_values(x, "variable[[4]]$value", "character")),
        value = extract_values(x, "value", "numeric")
      )
    }

    parse_response(series_raw)
  })

  debt_statistics <- bind_rows(debt_statistics)

  debt_statistics
}
