# List Available Entities from the World Bank International Debt Statistics API

This function returns a tibble with available entities from the World
Bank International Debt Statistics (IDS) API. Each row provides details
on entities, including their unique identifiers, names, and types.

## Usage

``` r
ids_list_entities()
```

## Value

A tibble containing the available entities and their attributes:

- entity_id:

  ISO 3166-1 alpha-3 code of the entity (e.g., "ZMB").

- entity_name:

  The standardized name of the entity (e.g., "Zambia").

- entity_iso2code:

  ISO 3166-1 alpha-2 code of the entity (e.g., "ZM").

- entity_type:

  The type of entity (e.g., "Country", "Region").

- capital_city:

  The capital city of the entity (e.g., "Lusaka").

- region_id:

  The unique identifier for the region (e.g., "SSF").

- region_iso2code:

  ISO 3166-1 alpha-2 code of the region (e.g., "ZG").

- region_name:

  The name of the region (e.g., "Sub-Saharan Africa").

- admin_region_id:

  The unique identifier for the administrative region (e.g., "SSA").

- admin_region_iso2code:

  The ISO 3166-1 alpha-2 code for the administrative region (e.g.,
  "ZF").

- admin_region_name:

  The name of the administrative region (e.g., "Sub-Saharan Africa
  (excluding high income)").

- lending_type_id:

  The unique identifier for the lending type (e.g., "IDX").

- lending_type_iso2code:

  ISO code for the lending type (e.g., "XI").

- lending_type_name:

  The name of the lending type (e.g., "IDA").

## Examples

``` r
ids_list_entities()
#> # A tibble: 134 × 17
#>    entity_id entity_iso2code entity_type capital_city entity_name  region_id
#>    <chr>     <chr>           <chr>       <chr>        <chr>        <chr>    
#>  1 AFG       AF              Country     Kabul        Afghanistan  MEA      
#>  2 AGO       AO              Country     Luanda       Angola       SSF      
#>  3 ALB       AL              Country     Tirane       Albania      ECS      
#>  4 ARG       AR              Country     Buenos Aires Argentina    LCN      
#>  5 ARM       AM              Country     Yerevan      Armenia      ECS      
#>  6 AZE       AZ              Country     Baku         Azerbaijan   ECS      
#>  7 BDI       BI              Country     Bujumbura    Burundi      SSF      
#>  8 BEN       BJ              Country     Porto-Novo   Benin        SSF      
#>  9 BFA       BF              Country     Ouagadougou  Burkina Faso SSF      
#> 10 BGD       BD              Country     Dhaka        Bangladesh   SAS      
#> # ℹ 124 more rows
#> # ℹ 11 more variables: region_iso2code <chr>, region_name <chr>,
#> #   admin_region_id <chr>, admin_region_iso2code <chr>,
#> #   admin_region_name <chr>, income_level_id <chr>,
#> #   income_level_iso2code <chr>, income_level_name <chr>,
#> #   lending_type_id <chr>, lending_type_iso2code <chr>, lending_type_name <chr>
```
