# Fetch Data from the World Bank International Debt Statistics (IDS) API

Retrieves standardized debt statistics from the World Bank's
International Debt Statistics (IDS) database, which provides
comprehensive data on the external debt of low and middle-income
countries. The function handles country identification, data validation,
and unit standardization, making it easier to conduct cross-country debt
analysis and monitoring.

## Usage

``` r
ids_get(
  entities,
  series,
  counterparts = "WLD",
  start_year = 2000,
  end_year = NULL,
  progress = FALSE,
  geographies = lifecycle::deprecated()
)
```

## Arguments

- entities:

  A character vector of entity identifiers representing debtor countries
  and aggregates. Must use `entity_id` from
  [ids_list_entities](https://teal-insights.github.io/r-wbids/reference/ids_list_entities.md):

  - For individual countries, use ISO3C codes (e.g., "GHA" for Ghana)

  - For aggregates, use World Bank codes (e.g., "LIC" for low income
    countries) The IDS database covers low and middle-income countries
    and related aggregates only. Cannot contain NA values.

- series:

  A character vector of debt statistics series identifiers that must
  match the `series_id` column from
  [ids_list_series](https://teal-insights.github.io/r-wbids/reference/ids_list_series.md).
  Each series represents a specific debt statistic (e.g.,
  "DT.DOD.DECT.CD" for total external debt stocks, "DT.TDS.DECT.CD" for
  debt service payments). Cannot contain NA values.

- counterparts:

  A character vector of creditor identifiers that must match the
  `counterpart_id` column from
  [ids_list_counterparts](https://teal-insights.github.io/r-wbids/reference/ids_list_counterparts.md).
  The default "WLD" returns aggregated global totals across all
  creditors. Common options:

  - "WLD" - World total (aggregated across all creditors)

  - "all" - Retrieve data broken down by all creditors

  - All identifiers are strings, but some are string-formatted numbers
    (e.g., "730" for China, "907" for IMF), while others are alphabetic
    codes (e.g., "BND" for bondholders) Cannot contain NA values.

- start_year:

  A numeric value representing the starting year (default: 2000). This
  default is intended to reduce data volume. For historical analysis,
  explicitly set to 1970 (the earliest year of data available).

- end_year:

  A numeric value representing the ending year (default: NULL). Must be
  \>= 1970 and cannot be earlier than start_year. If NULL, returns data
  through the most recent available year. Some debt service-related
  series include projections of debt service. For the 2024 data release,
  debt service projections are available through 2031.

- progress:

  A logical value indicating whether to display progress messages during
  data retrieval (default: FALSE).

- geographies:

  **\[superseded\]** Superseded in favor of `entities`. If supplied, it
  will be mapped to `entities` with a warning. Do **not** use together
  with `entities`.

## Value

A tibble containing debt statistics with the following columns:

- entity_id:

  The identifier for the debtor entity (e.g., "GHA" for Ghana, "LIC" for
  low income countries)

- series_id:

  The identifier for the debt statistic series (e.g., "DT.DOD.DECT.CD"
  for total external debt stocks)

- counterpart_id:

  The identifier for the creditor (e.g., "WLD" for world total, "730"
  for China)

- year:

  The year of the observation

- value:

  The numeric value of the debt statistic, standardized to the units
  specified in the series definition (typically current US dollars)

## Data Coverage and Validation

The IDS database provides detailed debt statistics for low and
middle-income countries, including:

- Debt stocks and flows

- Debt service and interest payments

- Creditor composition

- Terms and conditions of new commitments

To ensure valid queries:

- Use
  [ids_list_entities](https://teal-insights.github.io/r-wbids/reference/ids_list_entities.md)
  to find valid debtor entity codes

- Use
  [ids_list_series](https://teal-insights.github.io/r-wbids/reference/ids_list_series.md)
  to explore available debt statistics

- Use
  [ids_list_counterparts](https://teal-insights.github.io/r-wbids/reference/ids_list_counterparts.md)
  to see available creditor codes

## See also

- [`ids_list_entities()`](https://teal-insights.github.io/r-wbids/reference/ids_list_entities.md)
  for available debtor entity codes

- [`ids_list_series()`](https://teal-insights.github.io/r-wbids/reference/ids_list_series.md)
  for available debt statistics series codes

- [`ids_list_counterparts()`](https://teal-insights.github.io/r-wbids/reference/ids_list_counterparts.md)
  for available creditor codes

## Examples

``` r
# \donttest{
# Get total external debt stocks for a single country from 2000 onward
ghana_debt <- ids_get(
  entities = "GHA",
  series = "DT.DOD.DECT.CD"  # External debt stocks, total
)

# Compare debt service metrics across income groups
income_groups <- ids_get(
  entities = c("LIC", "LMC", "UMC"),  # Income group aggregates
  series = "DT.TDS.DECT.CD",  # Total debt service
  start_year = 2010
)

# Analyze debt composition by major creditors
creditor_analysis <- ids_get(
  entities = c("KEN", "ETH"),  # Kenya and Ethiopia
  series = c(
    "DT.DOD.DECT.CD",  # Total external debt
    "DT.TDS.DECT.CD"   # Total debt service
  ),
  counterparts = c(
    "WLD",  # World total
    "730",  # China
    "907",  # IMF
    "BND"   # Bondholders
  ),
  start_year = 2015
)
# }
```
