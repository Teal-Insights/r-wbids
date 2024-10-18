extract_values <- function(data, path, type = "character") {
  path_expr <- rlang::parse_expr(path)

  # Define the return type based on the type parameter
  FUN.VALUE <- switch(
    type,
    "character" = NA_character_,
    "integer" = NA_integer_,
    "numeric" = NA_real_,
    stop("Invalid type. Must be one of 'character', 'integer', or 'numeric'.")
  )

  vapply(data, function(x) {
    result <- rlang::eval_tidy(path_expr, x)
    if (is.null(result) || length(result) == 0) {
      return(FUN.VALUE)
    }
    return(result)
  }, FUN.VALUE = FUN.VALUE, USE.NAMES = FALSE)
}
