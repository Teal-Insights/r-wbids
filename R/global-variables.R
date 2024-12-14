# We only use system data objects as global variables.
# See https://cran.r-project.org/web/packages/dplyr/vignettes/in-packages.html
# For data masking, import .data from rlang and then use .data$var instead of
# var.
# For tidy selection, use "var" instead of var.
utils::globalVariables(c(
  "geographies", "series", "counterparts", "series_topics", "times"
))
