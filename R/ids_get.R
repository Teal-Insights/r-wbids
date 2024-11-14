#' Fetch Debt Statistics from the World Bank International Debt Statistics API
#'
#' This function returns a tibble with debt statistics data fetched from the
#' World Bank International Debt Statistics (IDS) API. The data can be filtered
#' by geographies, series, counterparts, and time periods.
#'
#' @param geographies A character vector representing the geographic codes
#'  (e.g., "ZMB" for Zambia). This argument is required and cannot contain NA
#'  values.
#' @param series A character vector representing the series codes (e.g.,
#'  "DT.DOD.DPPG.CD"). This argument is required and cannot contain NA values.
#' @param counterparts A character vector representing counterpart areas (e.g.,
#'  "all", "001"). This argument is required and cannot contain NA values
#'  (default: "all").
#' @param start_date An optional numeric value representing the starting year
#'  (e.g., 2015). It must be greater than or equal to 1970. If not provided, the
#'  entire time range is used.
#' @param end_date An optional numeric value representing the ending year (e.g.,
#'  2020). It must be greater than or equal to 1970 and cannot be earlier than
#'  `start_date`. If not provided, the entire available time range is used.
#' @param progress A logical value indicating whether to display a progress
#'  message during the request process (default: `FALSE`). Must be either `TRUE`
#'  or `FALSE`.
#'
#' @return A tibble containing debt statistics with the following columns:
#' \describe{
#'   \item{geography_id}{The unique identifier for the geography (e.g., "ZMB").}
#'   \item{series_id}{The unique identifier for the series (e.g.,
#'                    "DT.DOD.DPPG.CD").}
#'   \item{counterpart_id}{The unique identifier for the counterpart (e.g.,
#'                         "all").}
#'   \item{year}{The year corresponding to the data (e.g., 2020).}
#'   \item{value}{The numeric value representing the statistic for the given
#'                geography, series, counterpart, and year.}
#' }
#'
#' @export
#'
#' @examplesIf curl::has_internet()
#' \donttest{
#' # Fetch data for a series without specifying a time range or counterpart
#' ids_get(
#'   geographies = "ZMB",
#'   series = "DT.DOD.DPPG.CD",
#' )
#'
#' # Fetch specific debt statistics for Zambia from 2015 to 2020
#' ids_get(
#'   geographies = "ZMB",
#'   series = c("DT.DOD.DPPG.CD", "BM.GSR.TOTL.CD"),
#'   start_date = 2015,
#'   end_date = 2020
#' )
#'
#' # Fetch data for specific counterparts
#' ids_get(
#'   geographies = "ZMB",
#'   series = "DT.DOD.DPPG.CD",
#'   counterparts = c("216", "231")
#' )
#'
#' # Fetch data for multiple geographies and counterparts
#' ids_get(
#'   geographies = c("ZMB", "CHN"),
#'   series = "DT.DOD.DPPG.CD",
#'   counterparts = c("216", "231"),
#'   start_date = 2019,
#'   end_date = 2020
#' )
#' }
#'
ids_get <- function(
  geographies,
  series,
  counterparts = "all",
  start_date = NULL,
  end_date = NULL,
  progress = FALSE
) {

  validate_character_vector(geographies, "geographies")
  validate_character_vector(series, "series")
  validate_character_vector(counterparts, "counterparts")
  validate_date(start_date, "start_date")
  validate_date(end_date, "end_date")
  validate_progress(progress)

  time <- create_time(start_date, end_date)

  debt_statistics <- tidyr::crossing(
    "geographies" = geographies,
    "series" = series,
    "counterparts" = counterparts,
    "time" = time
  ) |> purrr::pmap_df(
    ~ get_debt_statistics(..1, ..2, ..3, ..4, progress = progress),
    .progress = progress
  )

  debt_statistics
}

get_debt_statistics <- function(
  geography, series, counterpart, time, progress
) {

  if (progress) {
    progress_message <- paste(
      "Fetching series", series,
      "for geography", geography,
      ", counterpart", counterpart,
      ", and time", time
    )
  } else {
    progress_message <- FALSE
  }

  resource <- paste0(
    "country/", geography,
    "/series/", series,
    "/counterpart-area/", counterpart,
    "/time/", time
  )

  series_raw <- perform_request(resource, progress = progress_message)

  if (length(series_raw[[1]]$variable[[1]]$concept) == 0) {
    tibble(
      "geography_id" = character(),
      "series_id" = character(),
      "counterpart_id" = character(),
      "year" = integer(),
      "value" = numeric()
    )
  } else {
    series_raw_rbind <- series_raw |>
      bind_rows()

    # Since the order of list items changes across series, we cannot use
    # hard-coded list paths
    series_wide <- series_raw_rbind |>
      select("variable") |>
      tidyr::unnest_wider("variable")

    geography_ids <- series_wide |>
      filter(.data$concept == "Country") |>
      select(geography_id = "id")

    series_ids <- series_wide |>
      filter(.data$concept == "Series") |>
      select(series_id = "id")

    counterpart_ids <- series_wide |>
      filter(.data$concept == "Counterpart-Area") |>
      select(counterpart_id = "id")

    years <- series_wide |>
      filter(.data$concept == "Time") |>
      select(year = "value") |>
      mutate(year = as.integer(.data$year))

    values <- series_raw |>
      purrr::map_df(
        \(x) tibble(value = if (is.null(x$value)) NA_real_ else x$value)
      )

    bind_cols(
      geography_ids,
      series_ids,
      counterpart_ids,
      years,
      values
    )
  }
}

validate_character_vector <- function(arg, arg_name) {
  if (!is.character(arg) || any(is.na(arg))) {
    cli::cli_abort(paste(
      "{.arg {arg_name}} must be a character vector and cannot contain ",
      "NA values."
    ))
  }
}

validate_date <- function(date, date_name) {
  if (!is.null(date) &&
        (!is.numeric(date) || length(date) != 1 || date < 1970)) {
    cli::cli_abort(paste(
      "{.arg {date_name}} must be a single numeric value representing ",
      "a year >= 1970."
    ))
  }
}

validate_progress <- function(progress) {
  if (!is.logical(progress)) {
    cli::cli_abort(
      "{.arg progress} must be either TRUE or FALSE."
    )
  }
}

create_time <- function(start_date, end_date) {
  if (!is.null(start_date) && !is.null(end_date)) {
    if (start_date > end_date) {
      cli::cli_abort(
        "{.arg start_date} cannot be greater than {.arg end_date}."
      )
    }
    paste0("YR", seq(start_date, end_date, by = 1))
  } else {
    "all"
  }
}
