
<!-- README.md is generated from README.Rmd. Please edit that file -->

# wbids

<!-- badges: start -->

<!-- badges: end -->

<!-- ## Installation -->

<!-- You can install the development version of wbids like so: -->

<!-- ``` r -->

<!-- # FILL THIS IN! HOW CAN PEOPLE INSTALL YOUR DEV PACKAGE? -->

<!-- ``` -->

<!-- ## Example -->

<!-- This is a basic example which shows you how to solve a common problem: -->

<!-- ```{r example} -->

<!-- library(wbids) -->

<!-- ## basic example code -->

<!-- ``` -->

## Development

### Create functions and tests

- `use_r(name=)` creates a pair of source and test files with the
  selected filename
- If the source file already exists and is open in your IDE, you can
  instead do `usethis::use_test()` to create an appropriately named test
  file

### Add dependencies

- `usethis::use_package(package)` adds the named package to DESCRIPTION
  dependencies
- `usethis::use_dev_package(package, type="Suggests")` adds a
  development dependency (won’t be installed for end-users)
- `usethis::use_import_from(package, fun=)` adds a single function
  import to the roxygen2 docs

### Install and update dependencies

- `renv::init()` sets up the project’s file system for dependency
  management with renv
- `renv::install()` installs all dependencies listed in DESCRIPTION,
  *including Suggests/development dependencies*
- `renv::snapshot()` regenerates the lockfile to match currently
  installed dependencies, *excluding Suggests/development dependencies*
- `renv::update()` updates all package dependencies to latest versions
- `renv::restore()` installs all dependencies declared in the lockfile

### Add Data

- `usethis::use_data(some_dataframe, name="filename")` saves a data
  object to “data/filename.rda” for use as a package export
- `usethis::use_data_raw("dataset_name")` creates an empty R script in
  the “data-raw” directory—this is where you put any automation scripts
  that are used for generating/updating the exported dataset but that
  you *don’t* want to export to the end-user

### Lint

- `lintr::lint_package()`

### Run tests

- `testthat::test_file()`
- `testthat::test_package()`

### Add Documentation

- `use_vignette()`
- `use_article()`
- `use_package_doc()`

### Build

- `devtools::build_readme()`
- `devtools::build()`
- `devtools::check()`
- `devtools::install()`
