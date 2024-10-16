
#' @keywords internal
#'
perform_request <- function(
    resource,
    per_page = 1000,
    date = NULL,
    progress = FALSE,
    base_url = "https://api.worldbank.org/v2/sources/6/"
) {

  if (!is.numeric(per_page) || per_page %% 1L != 0 || per_page < 1L || per_page > 32500L) {
    cli::cli_abort("{.arg per_page} must be an integer between 1 and 32,500.")
  }

  is_request_error <- function(resp) {
    status <- resp_status(resp)
    if (status >= 400L) {
      return(TRUE)
    }
    body <- resp_body_json(resp)
    if (length(body) == 1L && length(body[[1L]]$message) == 1L) {
      return(TRUE)
    }
    FALSE
  }

  check_for_body_error <- function(resp) {
    content_type <- resp_content_type(resp)
    if (identical(content_type, "application/json")) {
      body <- resp_body_json(resp)
      message_id <- body[[1]]$message[[1]]$id
      message_value <- body[[1]]$message[[1]]$value
      error_code <- paste("Error code:", message_id)
      docs <- "Read more at <https://datahelpdesk.worldbank.org/knowledgebase/articles/898620-api-error-codes>"
      c(error_code, message_value, docs)
    }
  }

  req <- request(base_url) |>
    req_url_path_append(resource) |>
    req_url_query(format = "json", per_page = per_page, date = date) |>
    req_user_agent("wbids R package (https://github.com/teal-insights/r-wbids)")

  resp <- req_perform(req)

  if (is_request_error(resp)) {
    error_body <- check_for_body_error(resp)
  }

  body <- resp_body_json(resp)

  if (length(body) == 2) {
    pages <- body[[1L]]$pages
  } else {
    pages <- body$pages
  }

  if (pages == 1L) {
    if (length(body) == 2) {
      out <- body[[2L]]
    } else {
      out <- body$source
    }
  } else {
    resps <- req |>
      req_perform_iterative(next_req = iterate_with_offset("page"),
                            max_reqs = pages,
                            progress = progress)
    out <- resps |>
      map(function(x) {resp_body_json(x)[[2]]})
    out <- unlist(out, recursive = FALSE)
  }
  out
}
