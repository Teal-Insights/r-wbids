test_that("geographies input validation works", {
  expect_error(
    ids_get(geographies = NA, series = "DT.DOD.DPPG.CD", counterparts = "all")
  )
  expect_error(
    ids_get(geographies = 123, series = "DT.DOD.DPPG.CD", counterparts = "all")
  )
})

test_that("series input validation works", {
  expect_error(
    ids_get(geographies = "ZMB", series = NA, counterparts = "all")
  )
  expect_error(
    ids_get(geographies = "ZMB", series = 123, counterparts = "all")
  )
})

test_that("counterparts input validation works", {
  expect_error(
    ids_get(geographies = "ZMB", series = "DT.DOD.DPPG.CD", counterparts = NA)
  )
  expect_error(
    ids_get(geographies = "ZMB", series = "DT.DOD.DPPG.CD", counterparts = 123)
  )
})

test_that("start_date and end_date input validation works", {
  expect_error(
    ids_get(geographies = "ZMB", series = "DT.DOD.DPPG.CD",
            counterparts = "all", start_date = 1960)
  )
  expect_error(
    ids_get(geographies = "ZMB", series = "DT.DOD.DPPG.CD",
            counterparts = "all", end_date = 1960)
  )
  expect_error(
    ids_get(geographies = "ZMB", series = "DT.DOD.DPPG.CD",
            counterparts = "all", start_date = 2020, end_date = 2015)
  )
})

test_that("progress input validation works", {
  expect_error(
    ids_get(geographies = "ZMB", series = "DT.DOD.DPPG.CD",
            counterparts = "all", progress = "yes")
  )
})

test_that("time range construction works", {
  result <- ids_get(geographies = "ZMB", series = "DT.DOD.DPPG.CD",
                    counterparts = "all", start_date = 2015, end_date = 2020)
  expect_true(all(unique(result$year) == seq(2015, 2020, 1)))
})

test_that("API request behavior without errors", {
  result <- ids_get(geographies = "ZMB", series = "DT.DOD.DPPG.CD",
                    counterparts = "all")
  expect_type(result, "list")
  expect_true(nrow(result) > 0)
})
