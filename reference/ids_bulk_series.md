# Retrieve Bulk Series Metadata for International Debt Statistics

This function retrieves a tibble with metadata for series available via
bulk download of the World Bank International Debt Statistics (IDS).

## Usage

``` r
ids_bulk_series()
```

## Value

A tibble containing the available series and their metadata:

- series_id:

  The unique identifier for the series (e.g., "BN.CAB.XOKA.CD").

- series_name:

  The name of the series (e.g., "Current account balance (current
  US\$)").

- source_id:

  The ID of the data source providing the indicator.

- source_name:

  The name or description of the source of the indicator data.

- source_note:

  Additional notes or descriptions about the data source.

- source_organization:

  The organization responsible for the data source.

## Examples

``` r
# \donttest{
ids_bulk_series()
#> Warning: cannot open URL 'https://datacatalogapi.worldbank.org/ddhxext/DatasetDownload?dataset_unique_id=0038015&version_id=': HTTP status was '429 Unknown Error'
#> Error in open.connection(con, "rb"): cannot open the connection to 'https://datacatalogapi.worldbank.org/ddhxext/DatasetDownload?dataset_unique_id=0038015&version_id='
# }
```
