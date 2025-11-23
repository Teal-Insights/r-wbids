# Get full IDS tables from EconDataverse datasets

A convenience wrapper around
[`econdatasets::ed_get()`](https://tidy-intelligence.github.io/r-econdatasets/reference/ed_get.html)
that retrieves tables from the World Bank International Debt Statistics
(IDS) dataset hosted on EconDataverse Hugging Face repositories.

## Usage

``` r
ids_get_ed(table = "debt_statistics", columns = NULL, quiet = FALSE)
```

## Arguments

- table:

  Character string naming the table from the IDS dataset. Default:
  `"debt_statistics"`.

- columns:

  Character vector naming the columns. Defaults to `NULL`.

- quiet:

  A logical parameter indicating whether messages should be printed to
  the console.

## Value

A `data.frame` containing the requested IDS table, or `NULL` if the
download fails.

## See also

[`econdatasets::ed_get()`](https://tidy-intelligence.github.io/r-econdatasets/reference/ed_get.html)
for the underlying function that downloads data from EconDataverse
repositories.

## Examples

``` r
# \donttest{
# Get the default debt statistics table
debt_statitics <- ids_get_ed()
#> → Reading dataset from
#>   https://huggingface.co/datasets/econdataverse/wbids/resolve/main/debt_statistics.parquet
#> ✔ Successfully loaded debt_statistics from wbids

# Get a different table from IDS
series_data <- ids_get_ed("series")
#> → Reading dataset from
#>   https://huggingface.co/datasets/econdataverse/wbids/resolve/main/series.parquet
#> ✔ Successfully loaded series from wbids
# }
```
