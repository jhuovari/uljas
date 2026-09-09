# The Uljas api returns the total of a classification with an empty string as
# its code, which is why the JSON-stat response is parsed by the package
# itself instead of rjstat. See jsonstat_to_df().

test_json <- paste0(
  '{"dataset":{',
  '"label":"test",',
  '"dimension":{',
  '"id":["Product","Time period"],',
  '"size":[2,3],',
  '"Product":{"label":"Product","category":{',
  '"index":{"":0,"2":1},',
  '"label":{"":"Total","2":"Crude materials"}}},',
  '"Time period":{"label":"Time period","category":{',
  '"index":{"202601":0,"202602":1,"202603":2}}}},',
  '"value":[1,2,3,4,null,6]}}'
)

parse_test_json <- function(json = test_json, ...) {
  jsonstat_to_df(jsonlite::fromJSON(json, simplifyVector = TRUE), ...)
}

test_that("a total with an empty code is parsed", {
  dat <- parse_test_json()

  expect_s3_class(dat, "tbl_df")
  expect_equal(names(dat), c("Product", "Time period", "value"))
  expect_equal(levels(dat$Product), c("Total", "Crude materials"))
})

test_that("values are in a row-major order", {
  dat <- parse_test_json()

  expect_equal(nrow(dat), 6)
  expect_equal(dat$value, c(1, 2, 3, 4, NA, 6))
  expect_equal(as.character(dat$Product),
               rep(c("Total", "Crude materials"), each = 3))
  expect_equal(as.character(dat$`Time period`),
               rep(c("202601", "202602", "202603"), times = 2))
})

test_that("naming = 'id' returns codes", {
  dat <- parse_test_json(naming = "id")

  expect_equal(levels(dat$Product), c("", "2"))
})

test_that("use_factors = FALSE returns characters", {
  dat <- parse_test_json(use_factors = FALSE)

  expect_type(dat$Product, "character")
})

test_that("a category without a label falls back to the code", {
  dat <- parse_test_json()

  expect_equal(as.character(dat$`Time period`)[1], "202601")
})

test_that("a sparse value object is parsed", {
  json <- sub('"value":\\[1,2,3,4,null,6\\]',
              '"value":{"0":1,"5":6}', test_json)
  dat <- jsonstat_to_df(jsonlite::fromJSON(json, simplifyVector = TRUE))

  expect_equal(dat$value, c(1, NA, NA, NA, NA, 6))
})

test_that("an inconsistent dataset is reported", {
  json <- sub('"size":\\[2,3\\]', '"size":[2,4]', test_json)

  expect_error(jsonstat_to_df(jsonlite::fromJSON(json, simplifyVector = TRUE)),
               "different number of categories")

  json <- sub('"value":\\[1,2,3,4,null,6\\]', '"value":[1,2,3]', test_json)

  expect_error(jsonstat_to_df(jsonlite::fromJSON(json, simplifyVector = TRUE)),
               "returned 3 values for 6 cells")
})

test_that("a response that is not a dataset is reported", {
  expect_error(jsonstat_to_df(list(a = 1)), "did not return a JSON-stat dataset")
})
