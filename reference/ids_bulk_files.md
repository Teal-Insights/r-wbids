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
#> # A tibble: 6 × 3
#>   file_name                                           file_url last_updated_date
#>   <chr>                                               <chr>    <date>           
#> 1 Bulk Download File - Debtor Countries: A to D, Cou… https:/… 2024-12-04       
#> 2 Bulk Download File - Debtor Countries: L to M, Cou… https:/… 2024-12-04       
#> 3 Bulk Download File - Debtor Countries: V to Z, Cou… https:/… 2024-12-04       
#> 4 Bulk Download File - Debtor Countries: E to K, Cou… https:/… 2024-12-04       
#> 5 Bulk Download File - Debtor Countries: N to Q, Cou… https:/… 2024-12-04       
#> 6 Bulk Download File - Debtor Countries: R to U, Cou… https:/… 2024-12-04       
# }
```
