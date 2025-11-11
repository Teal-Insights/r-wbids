# List Available Counterparts from the World Bank International Debt Statistics API

This function returns a tibble with available counterparts from the
World Bank International Debt Statistics (IDS) API. Each row provides
details on counterparts, including their unique identifiers, names, and
types.

## Usage

``` r
ids_list_counterparts()
```

## Value

A tibble containing the available counterparts and their attributes:

- counterpart_id:

  The unique identifier for the counterpart (e.g., "730").

- counterpart_name:

  The standardized name of the counterpart (e.g., "China").

- counterpart_iso2code:

  ISO 3166-1 alpha-2 code of the counterpart (e.g., "CN").

- counterpart_iso3code:

  ISO 3166-1 alpha-3 code of the counterpart (e.g., "CHN").

- counterpart_type:

  The type of counterpart (e.g., "Country", "Institution", "Region").

## Examples

``` r
ids_list_counterparts()
#> # A tibble: 303 × 5
#>    counterpart_id counterpart_name counterpart_iso2code counterpart_iso3code
#>    <chr>          <chr>            <chr>                <chr>               
#>  1 001            Austria          AT                   AUT                 
#>  2 002            Belgium          BE                   BEL                 
#>  3 003            Denmark          DK                   DNK                 
#>  4 004            France           FR                   FRA                 
#>  5 005            Germany          DE                   DEU                 
#>  6 006            Italy            IT                   ITA                 
#>  7 007            Netherlands      NL                   NLD                 
#>  8 008            Norway           NO                   NOR                 
#>  9 009            Portugal         PT                   PRT                 
#> 10 010            Sweden           SE                   SWE                 
#> # ℹ 293 more rows
#> # ℹ 1 more variable: counterpart_type <chr>
```
