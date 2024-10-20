#' List Available Series-Topic combinations from the World Bank International
#' Debt Statistics API
#'
#' This function returns a tibble with available series-topic combinations from
#' the World BankInternational Debt Statistics (IDS) API. Each row provides a
#' mapping from series to topic, with the possibility of multiple topic per
#' series.
#'
#' @return A tibble containing the available series and their topics:
#' \describe{
#'   \item{series_id}{The unique identifier for the series (e.g.,
#'                    "BM.GSR.TOTL.CD").}
#'   \item{topic_id}{The unique identifier for the topic (e.g., 3).}
#'   \item{topic_name}{The name of the topic (e.g., "External Debt").}
#' }
#'
#' @export
#'
#' @examples
#' ids_list_series_topics()
#'
ids_list_series_topics <- function() {
  series_topics
}
