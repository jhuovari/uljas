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

test_that("uljas_query_size counts the cells of a query", {
  skip_uljas()

  query <- list(`SITC Products` = "=ALL", `Time period` = "=LAST 6",
                Flow = 1, Country = "AT", Indicators = c("V1", "V3"))
  products <- nrow(uljas_class(ifile = sitc, class = "SITC Products")[[1]])

  expect_equal(uljas_query_size(query, ifile = sitc), products * 6 * 2)
})

test_that("uljas_data gives the same answer split or not", {
  skip_uljas()

  query <- list(`SITC Products` = "=ALL", `Time period` = "=LAST 6",
                Flow = 1, Country = "AT", Indicators = "V1")
  one <- uljas_data(ifile = sitc, classifiers = query)
  many <- suppressMessages(
    uljas_data(ifile = sitc, classifiers = query, max_cells = 60)
  )

  expect_gt(nrow(one), 60)
  expect_equal(as.data.frame(many), as.data.frame(one))
})

test_that("uljas_data splits a query over the cell limit", {
  # 3191 products x 18 periods = 57 438 cells, i.e. over the api limit
  skip_uljas()

  query <- list(`Classification of Products SITC5` = "=ALL",
                `Time period` = "=ALL", Flow = 1, Country = "AT",
                Indicators = "V1")
  cells <- uljas_query_size(query, ifile = sitc)
  skip_if(cells <= 50000, "the statistics file no longer has a query this large")

  dat <- suppressMessages(uljas_data(ifile = sitc, classifiers = query))

  expect_equal(nrow(dat), cells)
  expect_error(uljas_data(ifile = sitc, classifiers = query, max_cells = Inf),
               "over limit")
})

test_that("a query too long for an url is sent as a post request", {
  skip_uljas()

  # the server answers a query string over 2048 bytes with a status 404
  codes <- uljas_class(ifile = sitc,
                       class = "Classification of Products SITC5")[[1]]$code
  skip_if(length(codes) < 400, "not enough codes for a long query")

  query <- list(`Classification of Products SITC5` = codes[1:400],
                `Time period` = "=FIRST", Flow = 1, Country = "AT",
                Indicators = "V1")
  dat <- uljas_data(ifile = sitc, classifiers = query)

  expect_equal(nrow(dat), 400)
})

test_that("a failing query is reported with a status code", {
  skip_uljas()

  expect_error(uljas_dims(ifile = "/DATABASE/no/such/file"),
               "Uljas API request failed")
  # the message of the api itself is passed on
  expect_error(uljas_dims(ifile = "/DATABASE/no/such/file"),
               "ifile not found")
})

test_that("a wrong output format is reported", {
  expect_error(uljas_api(atype = "stats", konv = "csv"),
               "Wrong output format")
})
