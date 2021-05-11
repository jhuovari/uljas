
context("Get table of statistics")

test_that("uljas_stats works", {
  test <- uljas_stats(lang = "en")
  expect_equal(names(test), c("ifile", "title", "utime"))
})

context("Get dimensions")

test_that("uljas_dims works", {
  test <- uljas_dims(ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC")
  expect_equal(names(test[[1]]), c("label", "elim",  "size",  "show"))
})

context("Get classifications")

test_that("uljas_class works", {
  test <- uljas_class(ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC", class = "SITC Products")
  expect_equal(names(test[[1]]), c("code", "text"))
})

context("Get data")

test_that("uljas_data works", {
  sitc_query <- list(`SITC Products` = c("02"), `Time period` = "=LAST", Flow = 1, Country = "AT", Indicators = "V1")
  test <- uljas_data(ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC", classifiers = sitc_query)
  expect_equal(names(test), c(names(sitc_query), "values"))
})

test_that("uljas_data works 2 indicators", {
  sitc_query <- list(`SITC Products` = c("02"), `Time period` = "=LAST", Flow = 1, Country = "AT", Indicators = c("V1", "V3"))
  test <- uljas_data(ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC", classifiers = sitc_query)
  expect_equal(names(test), c(names(sitc_query), "values"))
})
