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
#'   \link{ids_list_geographies}:
#'   * For individual countries, use ISO3C codes (e.g., "GHA" for Ghana)
#'   * For aggregates, use World Bank codes (e.g., "LIC" for low income
#'     countries)
#'   The IDS database covers low and middle-income countries and related
#'   aggregates only. Cannot contain NA values.
#'
#' @param series A character vector of debt statistics series identifiers that
#'   must match the `series_id` column from \link{ids_list_series}. Each
#'   series represents a specific debt statistic (e.g., "DT.DOD.DECT.CD" for
#'   total external debt stocks, "DT.TDS.DECT.CD" for debt service payments).
#'   Cannot contain NA values.
#
#' @param counterparts A character vector of creditor identifiers that must
#'   match the `counterpart_id` column from \link{ids_list_counterparts}. The
#'   default "WLD" returns aggregated global totals across all creditors.
#'   Common options:
#'   * "WLD" - World total (aggregated across all creditors)
#'   * "all" - Retrieve data broken down by all creditors
#'   * All identifiers are strings, but some are string-formatted numbers
#'     (e.g., "730" for China, "907" for IMF), while others are alphabetic
#'     codes (e.g., "BND" for bondholders)
#'   Cannot contain NA values.
#
#' @param start_year A numeric value representing the starting year (default:
#'   2000). This default is intended to reduce data volume. For historical
#'   analysis, explicitly set to 1970 (the earliest year of data available).
#'
#' @param end_year A numeric value representing the ending year (default: NULL).
#'   Must be >= 1970 and cannot be earlier than start_year. If NULL, returns
#'   data through the most recent available year. Some debt service-related
#'   series include projections of debt service. For the 2024 data release,
#'   debt service projections are available through 2031.
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
#' * Use \link{ids_list_geographies} to find valid debtor geography codes
#' * Use \link{ids_list_series} to explore available debt statistics
#' * Use \link{ids_list_counterparts} to see available creditor codes
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
#'   start_year = 2010
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
#'   start_year = 2015
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
  start_year = 2000,
  end_year = NULL,
  progress = FALSE
) {
  # Validate arguments
  validate_progress(progress)

  # Process character vectors and dates into semicolon-separated strings
  geographies <- process_character_vector(geographies, "geographies")
  series <- process_character_vector(series, "series")
  counterparts <- process_character_vector(counterparts, "counterparts")
  time <- process_time_range(start_year, end_year)

  # Fetch debt statistics
  debt_statistics_raw <- get_debt_statistics(
    geographies, series, counterparts, time, progress
  )

  # Process debt statistics
  debt_statistics <- process_debt_statistics(debt_statistics_raw)

  # Apply specific filtering logic for years beyond latest actual data
  debt_statistics <- filter_post_actual_na(debt_statistics)

  debt_statistics
}

#' Fetch Debt Statistics from the World Bank International Debt Statistics API
#'
#' This function is a helper function for `ids_get()`. It constructs the API
#' request URL, performs the request, and returns the raw data.
#'
#' @param geography A character string representing the geographic code
#'  (e.g., "ZMB" for Zambia).
#' @param series A character string representing the series code (e.g.,
#'  "DT.DOD.DPPG.CD").
#' @param counterpart A character string representing the counterpart area
#'  (e.g., "all", "001").
#' @param time A character string representing the time range for the request
#'  (e.g., "YR2015;YR2016;YR2017").
#' @param progress A logical value or a character string. If `TRUE`, a default
#'  progress message is displayed. If a character string, it is used as the
#'  progress message. If `FALSE`, no progress message is displayed.
#'
#' @return A list containing the raw debt statistics data returned by the API.
#'
#' @noRd
#' @keywords internal
get_debt_statistics <- function(
  geography, series, counterpart, time, progress
) {
  # Create progress message if progress is TRUE
  progress_message <- create_progress_message(
    progress, series, geography, counterpart, time
  )

  # Create resource URL
  resource <- create_resource_url(geography, series, counterpart, time)

  # Perform API request
  perform_request(resource, progress = progress_message)
}

#' Create Progress Message
#'
#' Creates a progress message for API requests if progress tracking is enabled.
#'
#' @param progress A logical value indicating whether to show progress
#' @param series The series code
#' @param geography The geography code
#' @param counterpart The counterpart code
#' @param time The time period
#'
#' @return Character string with progress message or FALSE
#'
#' @noRd
#' @keywords internal
create_progress_message <- function(
  progress, series, geography, counterpart, time
) {
  if (!progress) {
    return(FALSE)
  }

  paste(
    "Fetching series", series,
    "for geography", geography,
    ", counterpart", counterpart,
    ", and time", time
  )
}

#' Create Resource URL
#'
#' Creates the resource URL path for the API request.
#'
#' @param geography The semicolon-separated geography codes
#' @param series The semicolon-separated series codes
#' @param counterpart The semicolon-separated counterpart codes
#' @param time The semicolon-separated time periods
#'
#' @return Character string containing the resource URL path
#'
#' @noRd
#' @keywords internal
create_resource_url <- function(geography, series, counterpart, time) {
  url <- paste0(
    "country/", geography,
    "/series/", series,
    "/counterpart-area/", counterpart,
    "/time/", time
  )

  validate_string(url, 4000, "resource URL")

  url
}

#' Process Raw Debt Statistics Data
#'
#' This function processes the raw debt statistics data returned by the API
#' and transforms it into a tidy tibble.
#'
#' @param series_raw A list containing the raw debt statistics data.
#'
#' @return A tibble with the following columns:
#'   \describe{
#'     \item{geography_id}{The unique identifier for the geography.}
#'     \item{series_id}{The unique identifier for the series.}
#'     \item{counterpart_id}{The unique identifier for the counterpart.}
#'     \item{year}{The year corresponding to the data.}
#'     \item{value}{The numeric value representing the statistic.}
#'   }
#'
#' @noRd
#' @keywords internal
process_debt_statistics <- function(series_raw) {
  if (length(series_raw[[1]]$variable[[1]]$concept) == 0) {
    tibble(
      "geography_id" = character(),
      "series_id" = character(),
      "counterpart_id" = character(),
      "year" = integer(),
      "value" = numeric()
    )
  } else {
    series_df <- series_raw |>
      bind_rows() |>
      unnest_wider("variable", names_sep = "_")

    tibble(
      geography_id = series_df$variable_id[
        series_df$variable_concept == "Country"
      ],
      series_id = series_df$variable_id[
        series_df$variable_concept == "Series"
      ],
      counterpart_id = series_df$variable_id[
        series_df$variable_concept == "Counterpart-Area"
      ],
      year = as.integer(series_df$variable_value[
        series_df$variable_concept == "Time"
      ]),
      value = purrr::map_dbl(
        series_raw,
        \(x) ifelse(is.null(x$value), NA_real_, x$value)
      )
    )
  }
}

#' Process Character Vector to String
#'
#' Validates and converts a character vector into a semicolon-separated string
#' for API requests.
#'
#' @param arg The character vector to process
#' @param arg_name The name of the argument (for error messages)
#'
#' @return A semicolon-separated string
#'
#' @noRd
#' @keywords internal
process_character_vector <- function(arg, arg_name) {
  validate_character_vector(arg, arg_name)
  semicolon_separated <- paste(arg, collapse = ";")
  validate_string(semicolon_separated, 1500L, arg_name)
  semicolon_separated
}

#' Validate Character Vector
#'
#' This function validates that the input argument is a character vector and
#' does not contain any NA values.
#'
#' @param arg The argument to validate.
#' @param arg_name The name of the argument (used in error messages).
#'
#' @return This function does not return a value. It throws an error if the
#'   argument is invalid.
#'
#' @noRd
#' @keywords internal
validate_character_vector <- function(arg, arg_name) {
  if (!is.character(arg) || any(is.na(arg))) {
    cli::cli_abort(paste(
      "{.arg {arg_name}} must be a character vector and cannot contain ",
      "NA values."
    ))
  }
  if (length(arg) > 60L) {
    cli::cli_abort(c(
      paste(
        "{.arg {arg_name}} must be a character vector with 60 or fewer values."
      ),
      "i" = paste(
        "For larger requests, consider using {.fn ids_bulk} to download the",
        "complete dataset. See {.fn ids_bulk_files} for available files."
      )
    ))
  }
}

#' Validate String Length
#'
#' This function validates that the input string is shorter than a specified
#' length.
#'
#' @param str The string to validate
#' @param length The maximum length allowed for the string
#' @param arg_name The name of the argument (used in error messages)
#'
#' @return This function does not return a value. It throws an error if the
#'   string is too long.
#'
#' @noRd
#' @keywords internal
validate_string <- function(str, length, arg_name) {
  if (nchar(str) >= length) {
    cli::cli_abort(c(
      paste(
        "Concatenated {.arg {arg_name}} string must be less than {length}",
        "characters."
      ),
      "i" = paste(
        "For large data requests, consider using {.fn ids_bulk} to download",
        "the complete dataset. See {.fn ids_bulk_files} for available files."
      )
    ))
  }
}

#' Validate Progress Argument
#'
#' This function validates that the progress argument is a logical value
#' (`TRUE` or `FALSE`).
#'
#' @param progress The progress argument to validate.
#'
#' @return This function does not return a value. It throws an error if the
#'   progress argument is invalid.
#'
#' @noRd
#' @keywords internal
validate_progress <- function(progress) {
  if (!is.logical(progress)) {
    cli::cli_abort(
      "{.arg progress} must be either TRUE or FALSE."
    )
  }
}

#' Validate Year Input
#'
#' Helper function to validate a year input is numeric and single value.
#' If year < 1970, issues a warning and returns 1970.
#'
#' @param year The year to validate
#' @param arg_name The argument name for error messages
#'
#' @return The validated year
#'
#' @noRd
#' @keywords internal
validate_year <- function(year, arg_name) {
  if (!is.numeric(year) || length(year) != 1) {
    cli::cli_abort(paste(
      "{.arg {arg_name}} must be a single numeric value."
    ))
  }

  if (year < times$time_year[1] && arg_name == "start_year") {
    cli::cli_warn(c(
      "!" = "Data only available from {times$time_year[1]} onward.",
      "i" = "Setting {.arg {arg_name}} to {times$time_year[1]}."
    ))
    return(times$time_year[1])
  } else if (year < times$time_year[1] && arg_name == "end_year") {
    # Raise an error if end_year is before 1970
    cli::cli_abort(c(
      "!" = "Data only available from {times$time_year[1]} onward."
    ))
  }

  year
}

#' Process Time Range
#'
#' Validates and converts start and end dates into a semicolon-separated string
#' of years for API requests.
#'
#' @param start_year The starting year (optional).
#' @param end_year The ending year (optional).
#'
#' @return A character string representing the time range for the API request.
#'
#' @noRd
#' @keywords internal
process_time_range <- function(start_year, end_year) {
  if (!is.null(end_year)) {
    end_year <- validate_year(end_year, "end_year")
  }
  if (!is.null(start_year)) {
    start_year <- validate_year(start_year, "start_year")
  }

  # Create time string
  if (!is.null(start_year) && !is.null(end_year)) {
    if (start_year > end_year) {
      cli::cli_abort(
        "{.arg start_year} cannot be greater than {.arg end_year}."
      )
    }
    paste(
      times$time_id[
        times$time_year >= start_year & times$time_year <= end_year
      ],
      collapse = ";", sep = ""
    )
  } else if (!is.null(start_year)) {
    paste(
      times$time_id[times$time_year >= start_year],
      collapse = ";", sep = ""
    )
  } else {
    "all"
  }
}

#' Filter Data for Years Beyond Latest Observed Data
#'
#' This function filters out rows for years beyond the latest observed data
#' and removes rows with NA values for these years.
#'
#' @param data The data to filter.
#'
#' @return The filtered data.
#'
#' @noRd
#' @keywords internal
filter_post_actual_na <- function(data) {
  # WB provides projections ~8 yrs after end of actual data
  data_after_actual <- data |>
    filter(.data$year > times$time_year[nrow(times) - 8])

  if (all(is.na(data_after_actual$value))) {
    data <- data |>
      filter(.data$year <= times$time_year[nrow(times) - 8])
  }

  data
}
