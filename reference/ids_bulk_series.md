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
#> # A tibble: 495 × 6
#>    series_id   series_name source_id source_name source_note source_organization
#>    <chr>       <chr>           <int> <chr>       <chr>       <chr>              
#>  1 NY.GNP.MKT… GNI (curre…         2 "World Dev… Gross nati… "Country official …
#>  2 DT.INT.BLA… PS, bilate…        81 " Internat… Public sec… "World Bank, Inter…
#>  3 DT.TDS.PRO… PPG, other…        81 " Internat… Public and… "World Bank, Inter…
#>  4 DT.TDS.PRO… GG, other …        81 " Internat… General go… "World Bank, Inter…
#>  5 DT.TDS.PRO… OPS, other…        81 " Internat… Other publ… "World Bank, Inter…
#>  6 DT.TDS.PRO… PS, other …        81 " Internat… Public sec… "World Bank, Inter…
#>  7 DT.TDS.PRV… GG, privat…        81 " Internat… General go… "World Bank, Inter…
#>  8 DT.TDS.PRV… OPS, priva…        81 " Internat… Other publ… "World Bank, Inter…
#>  9 DT.TDS.PRV… PRVG, priv…        81 " Internat… Private se… "World Bank, Inter…
#> 10 DT.TDS.PRV… PS, privat…        81 " Internat… Public sec… "World Bank, Inter…
#> # ℹ 485 more rows
# }
```
