# List Available Series from the World Bank International Debt Statistics API

This function returns a tibble with available series from the World Bank
International Debt Statistics (IDS) API. Each series provides data on
various debt-related indicators.

## Usage

``` r
ids_list_series()
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
ids_list_series()
#> # A tibble: 574 × 6
#>    series_id   series_name source_id source_name source_note source_organization
#>    <chr>       <chr>           <int> <chr>       <chr>       <chr>              
#>  1 BM.GSR.TOT… Imports of…         2 "World Dev… "Imports o… "Balance of Paymen…
#>  2 BN.CAB.XOK… Current ac…         2 "World Dev… "Balance o… "Balance of Paymen…
#>  3 BX.GRT.EXT… Grants, ex…        81 " Internat… "Grants ar… "World Bank, Inter…
#>  4 BX.GRT.TEC… Technical …        81 " Internat… "Technical… "World Bank, Inter…
#>  5 BX.GSR.TOT… Exports of…         2 "World Dev… "Exports o… "Balance of Paymen…
#>  6 BX.KLT.DIN… Foreign di…        81 " Internat… "Foreign d… "International Mon…
#>  7 BX.KLT.DRE… Primary in…        81 " Internat… "Primary i… "International Mon…
#>  8 BX.PEF.TOT… Portfolio …        81 " Internat… "Portfolio… "International Mon…
#>  9 BX.TRF.PWK… Personal t…         2 "World Dev… "Personal … "IMF balance of pa…
#> 10 DT.AMT.BLA… CB, bilate…        81 " Internat… "Central b… "World Bank, Inter…
#> # ℹ 564 more rows
```
