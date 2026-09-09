# These tests query the live Uljas api.

sitc <- "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC"

skip_uljas <- function() {
  skip_on_cran()
  skip_if_offline("uljas.tulli.fi")
}

test_that("uljas_stats works", {
  skip_uljas()

  stats <- uljas_stats(lang = "en")

  expect_equal(names(stats), c("ifile", "title", "utime"))
  expect_true(sitc %in% stats$ifile)
})

test_that("uljas_dims works", {
  skip_uljas()

  dims <- uljas_dims(ifile = sitc)

  expect_equal(names(dims[[1]]), c("label", "elim", "size", "show"))
  expect_true("Time period" %in% names(dims))
})

test_that("uljas_dims uses lang", {
  skip_uljas()

  dims <- uljas_dims(ifile = sitc, lang = "fi")

  expect_true("Aika" %in% names(dims))
})

test_that("uljas_class works", {
  skip_uljas()

  cla <- uljas_class(ifile = sitc, class = "SITC Products")

  expect_named(cla, "SITC Products")
  expect_equal(names(cla[[1]]), c("code", "text"))
})

test_that("uljas_class returns all main classifications with class = NULL", {
  skip_uljas()

  cla <- uljas_class(ifile = sitc, class = NULL)

  expect_gt(length(cla), 1)
  expect_equal(names(cla[[1]]), c("code", "text"))
})

test_that("uljas_data works", {
  skip_uljas()

  query <- list(`SITC Products` = "2", `Time period` = "=FIRST",
                Flow = 1, Country = "AT", Indicators = "V1")
  dat <- uljas_data(ifile = sitc, classifiers = query)

  expect_equal(names(dat), c(names(query), "values"))
  expect_equal(nrow(dat), 1)
})

test_that("uljas_data works with several indicators and periods", {
  skip_uljas()

  query <- list(`SITC Products` = "2", `Time period` = c("202601", "202602"),
                Flow = 1, Country = "AT", Indicators = c("V1", "V3"))
  dat <- uljas_data(ifile = sitc, classifiers = query)

  expect_equal(names(dat), c(names(query), "values"))
  expect_equal(nrow(dat), 4)
  # the last classifier varies fastest
  expect_equal(as.character(dat$`Time period`),
               rep(c("202601", "202602"), each = 2))
})

test_that("uljas_data works when the answer includes a total", {
  # a regression test for the total, the code of which is an empty string
  skip_uljas()

  query <- list(`SITC Products` = "=ALL", `Time period` = "=FIRST",
                Flow = 1, Country = "AT", Indicators = "V1")
  dat <- uljas_data(ifile = sitc, classifiers = query)

  expect_gt(nrow(dat), 1)
  expect_equal(as.character(dat$`SITC Products`)[1], "Total")
})

test_that("uljas_data uses naming", {
  skip_uljas()

  query <- list(`SITC Products` = "2", `Time period` = "=FIRST",
                Flow = 1, Country = "AT", Indicators = "V1")
  dat <- uljas_data(ifile = sitc, classifiers = query, naming = "id")

  expect_equal(as.character(dat$`SITC Products`), "2")
  expect_equal(as.character(dat$Indicators), "V1")
})

test_that("a failing query is reported with a status code", {
  skip_uljas()

  expect_error(uljas_dims(ifile = "/DATABASE/no/such/file"),
               "Uljas API request failed")
})

test_that("a wrong output format is reported", {
  expect_error(uljas_api(atype = "stats", konv = "csv"),
               "Wrong output format")
})
