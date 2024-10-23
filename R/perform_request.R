#' @keywords internal
#'
perform_request <- function(
  resource,
  per_page = 1000,
  progress = FALSE,
  base_url = "https://api.worldbank.org/v2/sources/6/"
) {
  validate_per_page(per_page)

  req <- create_request(base_url, resource, per_page)
  resp <- httr2::req_perform(req)

  if (is_request_error(resp)) {
    handle_request_error(resp)
  }

  body <- httr2::resp_body_json(resp)
  pages <- extract_pages(body)

  if (pages == 1L) {
    out <- extract_single_page_data(body)
  } else {
    out <- fetch_multiple_pages(req, pages, progress)
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

is_request_error <- function(resp) {
  status <- httr2::resp_status(resp)
  if (status >= 400L) {
    return(TRUE)
  }
  body <- httr2::resp_body_json(resp)
  if (length(body) == 1L && length(body[[1L]]$message) == 1L) {
    return(TRUE)
  }
  FALSE
}

handle_request_error <- function(resp) {
  error_body <- check_for_body_error(resp)
  cli::cli_alert_danger(paste(error_body, collapse = "\n"))
}

check_for_body_error <- function(resp) {
  content_type <- httr2::resp_content_type(resp)
  if (identical(content_type, "application/json")) {
    body <- httr2::resp_body_json(resp)
    message_id <- body[[1]]$message[[1]]$id
    message_value <- body[[1]]$message[[1]]$value
    error_code <- paste("Error code:", message_id)
    docs <- paste0(
      "Read more at <https://datahelpdesk.worldbank.org/",
      "knowledgebase/articles/898620-api-error-codes>"
    )
    c(error_code, message_value, docs)
  }
}

extract_pages <- function(body) {
  if (length(body) == 2) {
    body[[1L]]$pages
  } else {
    body$pages
  }
}

extract_single_page_data <- function(body) {
  if (length(body) == 2) {
    body[[2L]]
  } else {
    body$source
  }
}

fetch_multiple_pages <- function(req, pages, progress) {
  resps <- req |>
    httr2::req_perform_iterative(
      next_req = httr2::iterate_with_offset("page"),
      max_reqs = pages,
      progress = progress
    )
  out <- resps |>
    purrr::map(function(x) {
      httr2::resp_body_json(x)$source
    })
  unlist(out, recursive = FALSE)
}
