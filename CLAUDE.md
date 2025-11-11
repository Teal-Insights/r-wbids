# r-wbids Project Reference

## Project Management with GitHub CLI

- List issues: `gh issue list`
- View issue details: `gh issue view 80` (e.g., for issue \#80 “Rename
  geographies parameter”)
- Create branch for issue: `gh issue develop 80`
- Checkout branch:
  `git checkout 80-rename-geographies-parameter-to-entities`
- Create pull request:
  `gh pr create --title "Rename geographies parameter to entities" --body "Implements #80"`
- List pull requests: `gh pr list`
- View pull request: `gh pr view PR_NUMBER`

## Build/Test/Check Commands

- Build package: `R CMD build .`
- Install package: `R CMD INSTALL .`
- Run all tests: `R -e "devtools::test()"`
- Run single test:
  `R -e "devtools::test_file('tests/testthat/test-FILE_NAME.R', reporter = 'progress')"`
- Run R CMD check: `R -e "devtools::check()"`
- Build Roxygen2 documentation: `R -e "devtools::document()"`
- Build vignettes: `R -e "devtools::build_vignettes()"`
- Build README.md from README.Rmd: `R -e "devtools::build_readme()"`

## Code Style Guidelines

- Use 2 spaces for indentation (no tabs)
- Maximum 80 characters per line
- Use tidyverse style for R code (`dplyr`, `tidyr`, `purrr`)
- Export only functions with explicit `@export` roxygen tag
- Use snake_case for function and variable names
- Prefer implicit returns (last expression is returned)
- Validate function inputs with specific validation functions
- Use `expect_` functions for test assertions
- Document all exported functions with roxygen2 comments (with markdown)
- Include parameter type validation at beginning of functions
- Follow tidyverse error handling patterns with informative messages
