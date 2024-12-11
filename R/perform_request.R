#' @keywords internal
#' @noRd
#'
perform_request <- function(
  resource,
  per_page = 15000L,
  progress = FALSE,
  base_url = "https://api.worldbank.org/v2/sources/6/",
  max_tries = 10L
) {
  validate_per_page(per_page)
  validate_max_tries(max_tries)

  req <- create_request(base_url, resource, per_page) |>
    httr2::req_retry(max_tries = max_tries)

  validate_request_url(req$url)

  resp <- httr2::req_perform(req)

  if (is_request_error(resp)) {
    handle_request_error(resp)
  }

  body <- httr2::resp_body_json(resp)
  pages <- body$pages

  if (pages == 1L) {
    out <- body$source$data
  } else {
    resps <- req |>
      httr2::req_perform_iterative(
        next_req = httr2::iterate_with_offset("page"),
        max_reqs = pages,
        progress = progress
      )
    out <- resps |>
      purrr::map(\(x) httr2::resp_body_json(x)$source$data) |>
      unlist(recursive = FALSE, use.names = FALSE)
  }
  out
}

validate_per_page <- function(per_page) {
  if (
    !is.numeric(per_page) || per_page %% 1L != 0 ||
      per_page < 1L || per_page > 32500L
  ) {
    cli::cli_abort("{.arg per_page} must be an integer between 1 and 32,500.")
  }
}

create_request <- function(base_url, resource, per_page) {
  httr2::request(base_url) |>
    httr2::req_url_path_append(resource) |>
    httr2::req_url_query(format = "json", per_page = per_page) |>
    httr2::req_user_agent(
      "wbids R package (https://github.com/teal-insights/r-wbids)"
    )
}

validate_request_url <- function(url) {
  if (nchar(url) > 4000L) {
    cli::cli_abort(c(
      paste(
        "{.arg url} must be have less than 4000 characters."
      ),
      "i" = paste(
        "For larger requests, consider using {.fn ids_bulk} to download the",
        "complete dataset. See {.fn ids_bulk_files} for available files."
      )
    ))
  }
}

is_request_error <- function(resp) {
  status <- httr2::resp_status(resp)
  content_type <- httr2::resp_content_type(resp)
  if (status >= 400L || content_type == "text/xml") {
    TRUE
  } else {
    FALSE
  }
}

handle_request_error <- function(resp) {
  error_string <- httr2::resp_body_string(resp)
  error_code <- sub('.*<wb:message id="([0-9]+)".*', "\\1",
                    error_string)
  error_message <- sub('.*<wb:message id="[0-9]+" key="([^"]*)".*', "\\1",
                       error_string)
  error_description <- sub(".*<wb:message.*?>(.*?)</wb:message>.*", "\\1",
                           error_string)
  cli::cli_abort(
    paste("API Error Code", error_code, ":", error_message, error_description,
          collapse = "\n")
  )
}

validate_max_tries <- function(max_tries) {
  if (!is.numeric(max_tries) || max_tries %% 1L != 0 || max_tries < 1L) {
    cli::cli_abort("{.arg max_tries} must be a positive integer.")
  }
}
