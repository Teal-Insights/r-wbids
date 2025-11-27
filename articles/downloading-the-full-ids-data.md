# Downloading the Full IDS Data

``` r
library(wbids)
```

The `wbids` package provides two ways to download the complete
International Debt Statistics (IDS) dataset.

With
[`ids_bulk()`](https://teal-insights.github.io/r-wbids/reference/ids_bulk.md),
you need to download and combine multiple Excel files:

``` r
# Step 1: Get list of available files
files <- ids_bulk_files()

# Step 2: Download each file
data_list <- lapply(files$file_url, ids_bulk)

# Step 3: Combine all data
full_data <- rbind(data_list)
```

With
[`ids_get_ed()`](https://teal-insights.github.io/r-wbids/reference/ids_get_ed.md),
you get everything in one step:

``` r
full_data <- ids_get_ed("debt_statistics")
```

The
[`ids_get_ed()`](https://teal-insights.github.io/r-wbids/reference/ids_get_ed.md)
function is faster because:

- Downloads one optimized file instead of multiple Excel files
- Uses Parquet format which is faster to read than Excel
- Data is already processed and ready to use

For most use cases,
[`ids_get_ed()`](https://teal-insights.github.io/r-wbids/reference/ids_get_ed.md)
is the recommended approach due to its simplicity and performance
benefits.
