
<!-- README.md is generated from README.Rmd. Please edit that file -->

# wbids

<!-- badges: start -->
<!-- badges: end -->

`wbids` is an R package that provides a modern, flexible interface for
accessing the World Bank’s International Debt Statistics (IDS). `wbids`
allows users to download, process, and analyze IDS series for multiple
geographies, counterparts and specific time periods. The package is
designed to work seamlessly with World Development Indicators (WDI)
provided through the `wbwdi` package.

The `wbids` package relies on a redefinition of the original World Bank
data: ‘geographies’ contain both countries and regions, while
‘counterparts’ include both counterpart areas and institutions. `wbids`
provides a consistent mapping of identifiers and names across these
different types. See the package vignette for more details on the data
model: TODO: INSERT LINK TO VIGNETTE LATER

This package is a product of Teal Insight and not sponsored by or
affiliated with the World Bank in any way, except for the use of the
World Bank IDS API.

## Installation

You can install the development version of `wbids` like this:

``` r
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
geographies, counterparts, and topics:

``` r
ids_list_series()
ids_list_georaphies()
ids_list_counterparts()
ids_list_series_topics()
```

This data can be used to enrich the IDS data or facilitate data
discovery. For further applications, please consult [Teal Insights’
Guide to Working with the World Bank International Debt
Statistics](https://teal-insights.github.io/teal_insights_guide_to_wbids/).

The interface and namings are fully consistent with World Development
Indicators (WDI) data provided through the ‘wbwdi’ package. You can find
details on
[github.com/tidy-intelligence/r-wbwdi](https://github.com/tidy-intelligence/r-wbwdi).
