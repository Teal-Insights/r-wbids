# Download and Process Bulk Data File for International Debt Statistics

This function downloads a data file from the World Bank International
Debt Statistics (IDS), reads and processes the data into a tidy format.

## Usage

``` r
ids_bulk(
  file_url,
  file_path = tempfile(fileext = ".xlsx"),
  quiet = FALSE,
  timeout = getOption("timeout", 60),
  warn_size = TRUE
)
```

## Arguments

- file_url:

  A character string specifying the URL of the Excel file to download.
  This parameter is required (see
  [ids_bulk_files](https://teal-insights.github.io/r-wbids/reference/ids_bulk_files.md)).

- file_path:

  An optional character string specifying the file path where the
  downloaded file will be saved. Defaults to a temporary file with
  `.xlsx` extension. The file will automatically be deleted after
  processing.

- quiet:

  A logical parameter indicating whether messages should be printed to
  the console.

- timeout:

  An integer specifying the timeout in seconds for downloading the file.
  Defaults to the current R timeout setting.

- warn_size:

  A logical parameter indicating whether to warn about large downloads.
  Defaults to TRUE.

## Value

A tibble containing processed debt statistics data with the following
columns:

- entity_id:

  The unique identifier for the entity (e.g., "ZMB").

- series_id:

  The unique identifier for the series (e.g., "DT.DOD.DPPG.CD").

- counterpart_id:

  The unique identifier for the counterpart series.

- year:

  The year corresponding to the data (as an integer).

- value:

  The numeric value representing the statistic for the given entity,
  series, counterpart, and year.

## Examples

``` r
if (FALSE) { # \dontrun{
available_files <- ids_bulk_files()
data <- ids_bulk(
  available_files$file_url[1]
)
} # }
```
