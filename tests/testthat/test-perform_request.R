devtools::load_all()

test_that("perform_request returns data for a series resource", {
  resource <- "series"
  result <- perform_request(resource)
  expect_true(result[[1]]$name == "International Debt Statistics")
  expect_true(result[[1]]$id == "6")
})
