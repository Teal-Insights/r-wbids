
<!-- README.md is generated from README.Rmd. Please edit that file -->

# wbids

<!-- badges: start -->

[![R-CMD-check](https://github.com/Teal-Insights/r-wbids/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Teal-Insights/r-wbids/actions/workflows/R-CMD-check.yaml)
[![Lint](https://github.com/Teal-Insights/r-wbids/actions/workflows/lint.yaml/badge.svg)](https://github.com/Teal-Insights/r-wbids/actions/workflows/lint.yaml)
[![Codecov test
coverage](https://codecov.io/gh/Teal-Insights/r-wbids/graph/badge.svg)](https://app.codecov.io/gh/Teal-Insights/r-wbids)
<!-- badges: end -->

`wbids` is an R package to access and analyze the World Bank’s
[International Debt Statistics
(IDS)](https://datacatalog.worldbank.org/search/dataset/0038015/). IDS
provides creditor-debtor relationships between countries, regions, and
institutions. ‘wbids’ enables users to download, process and work with
IDS series across multiple geographies, counterparts, and time periods.

The `wbids` package relies on a redefinition of the original World Bank
data: ‘geographies’ contain both countries and regions, while
‘counterparts’ include both counterpart areas and institutions. `wbids`
provides a consistent mapping of identifiers and names across these
different types. The corresponding [package
vignette](https://teal-insights.github.io/r-wbids/articles/data-model.html)
provides more details on the data model.

This package is a product of Teal Insights and not sponsored by or
affiliated with the World Bank in any way, except for the use of the
World Bank IDS API.

## Installation

You can install `wbids` from CRAN via:

``` r
install.packages("wbids")
```

You can also install the development version of `wbids` like this:

``` r
# install.packages("pak")
pak::pak("teal-insights/r-wbids")
```

## Usage

The main function `ids_get()` provides an interface to download multiple
IDS series for multiple geographies and counterparts and specific date
ranges.

``` r
library(wbids)

ids_get(
  geographies = c("ZMB", "ZAF"),
  series = c("DT.DOD.DPPG.CD", "BM.GSR.TOTL.CD"),
  counterparts = c("216", "231"),
  start_date = 2015,
  end_date = 2020
)
```

The package comes with prepared metadata about available series,
geographies, counterparts, and topics. Please consult the [package
vignette](https://teal-insights.github.io/r-wbids/articles/data-model.html)
for details.

``` r
ids_list_series()
ids_list_geographies()
ids_list_counterparts()
ids_list_series_topics()
```

This data can be used to enrich the IDS series or facilitate data
discovery. For further applications, please consult [Teal Insights’
Guide to Working with the World Bank International Debt
Statistics](https://teal-insights.github.io/teal-insights-guide-to-wbids/).

The interface and column names are fully consistent with World
Development Indicators (WDI) data provided through the `wbwdi` package.
You can find details on
[github.com/tidy-intelligence/r-wbwdi](https://github.com/tidy-intelligence/r-wbwdi).
