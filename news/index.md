# Changelog

## wbids (development version)

## wbids 1.1.1

CRAN release: 2025-11-11

- Examples that made third-party API calls are now skipped on CRAN.
- Mocks are used to prevent API calls in tests.

## wbids 1.1.0

CRAN release: 2025-09-04

- Rename `geographies` to `entities` across all functions (soft
  deprecation, no breaking change).

## wbids 1.0.0

CRAN release: 2025-02-08

- [`ids_get()`](https://teal-insights.github.io/r-wbids/reference/ids_get.md)
  Roxygen2 documentation enhancements.
- [`ids_get()`](https://teal-insights.github.io/r-wbids/reference/ids_get.md)
  now makes a single consolidated API call for all series and countries
  rather than one call per series-country combination, greatly improving
  performance.
- [`ids_get()`](https://teal-insights.github.io/r-wbids/reference/ids_get.md)
  now fails with an informative error message if the user requests too
  much data.
- [`ids_get()`](https://teal-insights.github.io/r-wbids/reference/ids_get.md)
  now takes `start_year` and `end_year` rather than `start_date` and
  `end_date` arguments (breaking change).

### Bug fixes

- [`ids_list_counterparts()`](https://teal-insights.github.io/r-wbids/reference/ids_list_counterparts.md)
  now contains `counterpart_iso2code` for all countries and regions.
- `read_bulk_file()` now returns the correct column for
  `counterpart_id`.
- [`ids_get()`](https://teal-insights.github.io/r-wbids/reference/ids_get.md)
  no longer returns NAs for some geographies.
- [`ids_get()`](https://teal-insights.github.io/r-wbids/reference/ids_get.md)
  no longer returns the wrong counterpart_type for some rows.
- [`ids_get()`](https://teal-insights.github.io/r-wbids/reference/ids_get.md)
  now removes trailing whitespace and correctly encodes special
  characters.
- Removed a third-party dependency that was causing tests to fail on
  CRAN.

## wbids 0.1.0

CRAN release: 2024-11-15

- Initial CRAN submission.
- Includes download of individual series via
  [`ids_get()`](https://teal-insights.github.io/r-wbids/reference/ids_get.md).
  Use `ids_list_*()` functions to list supported geographies, series,
  and counterparts, respectively.
- Includes bulk download of multiple series via
  [`ids_bulk()`](https://teal-insights.github.io/r-wbids/reference/ids_bulk.md).
  Use
  [`ids_bulk_files()`](https://teal-insights.github.io/r-wbids/reference/ids_bulk_files.md)
  and
  [`ids_bulk_series()`](https://teal-insights.github.io/r-wbids/reference/ids_bulk_series.md)
  to get information for supported files and series, respectively.
