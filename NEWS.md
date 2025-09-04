# wbids 1.1.0

* Rename `geographies` to `entities` across all functions (soft deprecation, no breaking change).

# wbids 1.0.0

* `ids_get()` Roxygen2 documentation enhancements.
* `ids_get()` now makes a single consolidated API call for all series and countries rather than one call per series-country combination, greatly improving performance.
* `ids_get()` now fails with an informative error message if the user requests too much data.
* `ids_get()` now takes `start_year` and `end_year` rather than `start_date` and `end_date` arguments (breaking change).

## Bug fixes

* `ids_list_counterparts()` now contains `counterpart_iso2code` for all countries and regions.
* `read_bulk_file()` now returns the correct column for `counterpart_id`.
* `ids_get()` no longer returns NAs for some geographies.
* `ids_get()` no longer returns the wrong counterpart_type for some rows.
* `ids_get()` now removes trailing whitespace and correctly encodes special characters.
* Removed a third-party dependency that was causing tests to fail on CRAN.

# wbids 0.1.0

* Initial CRAN submission.
* Includes download of individual series via `ids_get()`. Use `ids_list_*()` functions to list supported geographies, series, and counterparts, respectively. 
* Includes bulk download of multiple series via `ids_bulk()`. Use `ids_bulk_files()` and `ids_bulk_series()` to get information for supported files and series, respectively.
