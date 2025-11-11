# Retrieve Available Bulk Download Files for International Debt Statistics

This function returns a tibble with metadata for files available for
bulk download via the World Bank International Debt Statistics (IDS). It
includes information such as file names, URLs, and the last update dates
for each file in Excel (xlsx) format.

## Usage

``` r
ids_bulk_files()
```

## Value

A tibble containing the available files and their metadata:

- file_name:

  The name of the file available for download.

- file_url:

  The URL to download the file in Excel format.

- last_updated_date:

  The date when the file was last updated.

## Examples

``` r
# \donttest{
ids_bulk_files()
#> Warning: cannot open URL 'https://datacatalogapi.worldbank.org/ddhxext/DatasetDownload?dataset_unique_id=0038015&version_id=': HTTP status was '429 Unknown Error'
#> Error in open.connection(con, "rb"): cannot open the connection to 'https://datacatalogapi.worldbank.org/ddhxext/DatasetDownload?dataset_unique_id=0038015&version_id='
# }
```
