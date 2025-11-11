# Superseded: List Available Geographies

**\[superseded\]**

`ids_list_geographies()` has been superseded in favor of
[`ids_list_entities()`](https://teal-insights.github.io/r-wbids/reference/ids_list_entities.md).
It still works, but will be retired in a future release. Please use
[`ids_list_entities()`](https://teal-insights.github.io/r-wbids/reference/ids_list_entities.md)
instead.

## Usage

``` r
ids_list_geographies()
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

## See also

[`ids_list_entities()`](https://teal-insights.github.io/r-wbids/reference/ids_list_entities.md)
