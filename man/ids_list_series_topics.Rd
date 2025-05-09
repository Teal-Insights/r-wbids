% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ids_list_series_topics.R
\name{ids_list_series_topics}
\alias{ids_list_series_topics}
\title{List Available Series-Topic combinations from the World Bank International
Debt Statistics API}
\usage{
ids_list_series_topics()
}
\value{
A tibble containing the available series and their topics:
\describe{
\item{series_id}{The unique identifier for the series (e.g.,
"BM.GSR.TOTL.CD").}
\item{topic_id}{The unique identifier for the topic (e.g., 3).}
\item{topic_name}{The name of the topic (e.g., "External Debt").}
}
}
\description{
This function returns a tibble with available series-topic combinations from
the World BankInternational Debt Statistics (IDS) API. Each row provides a
mapping from series to topic, with the possibility of multiple topic per
series.
}
\examples{
ids_list_series_topics()

}
