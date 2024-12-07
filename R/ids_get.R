#' Fetch Data from the World Bank International Debt Statistics (IDS) API
#'
#' Retrieves standardized debt statistics from the World Bank's International
#' Debt Statistics (IDS) database, which provides comprehensive data on the
#' external debt of low and middle-income countries. The function handles
#' country identification, data validation, and unit standardization, making it
#' easier to conduct cross-country debt analysis and monitoring.
#'
#' @param geographies A character vector of geography identifiers representing
#'   debtor countries and aggregates. Must use `geography_id` from
#'   `ids_list_geographies()`:
#'   * For individual countries, use ISO3C codes (e.g., "GHA" for Ghana)
#'   * For aggregates, use World Bank codes (e.g., "LIC" for low income
#'     countries)
#'   The IDS database covers low and middle-income countries and related
#'   aggregates only. Cannot contain NA values.
#'
#' @param series A character vector of debt statistics series identifiers that
#'   must match the `series_id` column from `ids_list_series()`. Each series
#'   represents a specific debt statistic (e.g., "DT.DOD.DECT.CD" for total
#'   external debt stocks, "DT.TDS.DECT.CD" for debt service payments). Cannot
#'   contain NA values.
#'
#' @param counterparts A character vector of creditor identifiers that must
#'   match the `counterpart_id` column from `ids_list_counterparts()`. The
#'   default "WLD" returns aggregated global totals across all creditors.
#'   Common options:
#'   * "WLD" - World total (aggregated across all creditors)
#'   * "all" - Retrieve data broken down by all creditors
#'   * Individual creditors use numeric codes (e.g., "730" for China)
#'   * Special creditors have text codes (e.g., "907" for IMF, "BND" for
#'     bondholders)
#'   Cannot contain NA values.
#'
#' @param start_date A numeric value representing the starting year (default:
#'   2000). Must be >= 1970. The default focuses on modern data while reducing
#'   data volume. For historical analysis, explicitly set to 1970.
#'
#' @param end_date A numeric value representing the ending year (default: NULL).
#'   Must be >= 1970 and cannot be earlier than start_date. If NULL, returns
#'   data through the most recent available year. Some debt service related
#'   series include projections of debt service.  For the 2024 data release,
#'   debt service projections available through 2031.
#'
#' @param progress A logical value indicating whether to display progress
#'   messages during data retrieval (default: FALSE).
#'
#' @return A tibble containing debt statistics with the following columns:
#' \describe{
#'   \item{geography_id}{The identifier for the debtor geography (e.g., "GHA"
#'     for Ghana, "LIC" for low income countries)}
#'   \item{series_id}{The identifier for the debt statistic series (e.g.,
#'     "DT.DOD.DECT.CD" for total external debt stocks)}
#'   \item{counterpart_id}{The identifier for the creditor (e.g., "WLD" for
#'     world total, "730" for China)}
#'   \item{year}{The year of the observation}
#'   \item{value}{The numeric value of the debt statistic, standardized to the
#'     units specified in the series definition (typically current US dollars)}
#' }
#'
#' @section Data Coverage and Validation:
#' The IDS database provides detailed debt statistics for low and middle-income
#' countries, including:
#' * Debt stocks and flows
#' * Debt service and interest payments
#' * Creditor composition
#' * Terms and conditions of new commitments
#'
#' To ensure valid queries:
#' * Use `ids_list_geographies()` to find valid debtor geography codes
#' * Use `ids_list_series()` to explore available debt statistics
#' * Use `ids_list_counterparts()` to see available creditor codes
#'
#' @examples
#' \donttest{
#' # Get total external debt stocks for a single country from 2000 onward
#' ghana_debt <- ids_get(
#'   geographies = "GHA",
#'   series = "DT.DOD.DECT.CD"  # External debt stocks, total
#' )
#'
#' # Compare debt service metrics across income groups
#' income_groups <- ids_get(
#'   geographies = c("LIC", "LMC", "UMC"),  # Income group aggregates
#'   series = "DT.TDS.DECT.CD",  # Total debt service
#'   start_date = 2010
#' )
#'
#' # Analyze debt composition by major creditors
#' creditor_analysis <- ids_get(
#'   geographies = c("KEN", "ETH"),  # Kenya and Ethiopia
#'   series = c(
#'     "DT.DOD.DECT.CD",  # Total external debt
#'     "DT.TDS.DECT.CD"   # Total debt service
#'   ),
#'   counterparts = c(
#'     "WLD",  # World total
#'     "730",  # China
#'     "907",  # IMF
#'     "BND"   # Bondholders
#'   ),
#'   start_date = 2015
#' )
#' }
#'
#' @seealso
#' * `ids_list_geographies()` for available debtor geography codes
#' * `ids_list_series()` for available debt statistics series codes
#' * `ids_list_counterparts()` for available creditor codes
#'
#' @export
ids_get <- function(
  geographies,
  series,
  counterparts = "WLD",
  start_date = 2000,
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


  # Apply specific filtering logic for years beyond latest actual data
  debt_statistics <- filter_post_actual_na(debt_statistics)

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


# to be updated manually with each release
# for the 2024-12 IDS release:
latest_year_observed <- 2023
latest_year_projections <- 2031

create_time <- function(start_date, end_date) {
  if (!is.null(start_date) && !is.null(end_date)) {
    if (start_date > end_date) {
      cli::cli_abort(
        "{.arg start_date} cannot be greater than {.arg end_date}."
      )
    }
    paste0("YR", seq(start_date, end_date, by = 1))
  } else if (!is.null(start_date)) {
    paste0("YR", seq(start_date, latest_year_projections, by = 1))
  } else {
    "all"
  }
}

filter_post_actual_na <- function(data) {
  # Identify rows after the latest actual year
  data_after_actual <- data |>
    filter(.data$year > latest_year_observed)

  # Check if all rows for these years have NA in `value`
  if (all(is.na(data_after_actual$value))) {
    # Remove these rows from the data
    data <- data |>
      filter(.data$year <= latest_year_observed)
  }

  data
}
