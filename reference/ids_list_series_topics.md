# List Available Series-Topic combinations from the World Bank International Debt Statistics API

This function returns a tibble with available series-topic combinations
from the World BankInternational Debt Statistics (IDS) API. Each row
provides a mapping from series to topic, with the possibility of
multiple topic per series.

## Usage

``` r
ids_list_series_topics()
```

## Value

A tibble containing the available series and their topics:

- series_id:

  The unique identifier for the series (e.g., "BM.GSR.TOTL.CD").

- topic_id:

  The unique identifier for the topic (e.g., 3).

- topic_name:

  The name of the topic (e.g., "External Debt").

## Examples

``` r
ids_list_series_topics()
#> # A tibble: 524 × 3
#>    series_id         topic_id topic_name      
#>    <chr>                <int> <chr>           
#>  1 BM.GSR.TOTL.CD           3 Economy & Growth
#>  2 BM.GSR.TOTL.CD          20 External Debt   
#>  3 BM.GSR.TOTL.CD          21 Trade           
#>  4 BN.CAB.XOKA.CD           3 Economy & Growth
#>  5 BN.CAB.XOKA.CD          20 External Debt   
#>  6 BX.GRT.EXTA.CD.DT       20 External Debt   
#>  7 BX.GRT.TECH.CD.DT       20 External Debt   
#>  8 BX.GSR.TOTL.CD           3 Economy & Growth
#>  9 BX.GSR.TOTL.CD          20 External Debt   
#> 10 BX.GSR.TOTL.CD          21 Trade           
#> # ℹ 514 more rows
```
