mock_debt_statistics_data <- function(entity_id, series_id,
                                      counterpart_id, year, value) {
  list(
    list(
      variable = list(
        list(concept = "Country", id = entity_id, value = entity_id),
        list(concept = "Series", id = series_id, value = series_id),
        list(
          concept = "Counterpart-Area", id = counterpart_id,
          value = counterpart_id
        ),
        list(concept = "Time", id = paste0("YR", year),
             value = as.character(year))
      ),
      value = value
    )
  )
}
