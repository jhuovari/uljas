# The splitting logic is tested without the api by mocking the one function
# that asks for the codes of a classification.

mock_codes <- function(sizes) {
  testthat::local_mocked_bindings(
    uljas_class_codes = function(class, ifile, lang = "en") {
      as.character(seq_len(sizes[[class]]))
    },
    .env = parent.frame()
  )
}

cells <- function(part, sizes) {
  prod(vapply(names(part), function(name) {
    value <- part[[name]]
    if (identical(value, "=ALL")) sizes[[name]] else length(value)
  }, numeric(1)))
}

test_that("api keywords are parsed", {
  expect_null(uljas_keyword("2"))
  expect_null(uljas_keyword(""))
  expect_equal(uljas_keyword("=ALL")$keyword, "ALL")
  expect_true(is.na(uljas_keyword("=ALL")$n))
  expect_equal(uljas_keyword("=LAST 12")$n, 12L)
  expect_equal(uljas_keyword("=LAST*;12")$n, 12L)
  expect_equal(uljas_keyword("=first")$keyword, "FIRST")
})

test_that("the size of a classifier value is counted", {
  expect_equal(uljas_value_size("2"), 1)
  expect_equal(uljas_value_size("=ALL", 54), 54)
  expect_equal(uljas_value_size("=LAST", 54), 1)
  expect_equal(uljas_value_size("=LAST 12", 54), 12)
  # more values than the classification has
  expect_equal(uljas_value_size("=LAST 99", 54), 54)
  # an unknown classification
  expect_true(is.na(uljas_value_size("=ALL", NA)))
})

test_that("keywords are resolved to codes", {
  codes <- c("", "a", "b", "c")

  expect_equal(uljas_value_codes("=ALL", codes), codes)
  expect_equal(uljas_value_codes("=FIRST", codes), "")
  expect_equal(uljas_value_codes("=FIRST 2", codes), c("", "a"))
  expect_equal(uljas_value_codes("=LAST 2", codes), c("b", "c"))
  expect_equal(uljas_value_codes(c("a", "c"), codes), c("a", "c"))
  expect_equal(uljas_value_codes(c("=LAST 1", "a"), codes), c("c", "a"))
})

test_that("a total is not asked for with an empty code", {
  # the api reads an empty parameter as no selection at all
  expect_equal(uljas_group_value("", c("", "a", "b")), "=FIRST 1")
  expect_equal(uljas_group_value("", c("a", "b", "")), "=LAST 1")
  expect_equal(uljas_group_value(c("", "a"), c("", "a", "b")), c("", "a"))
  expect_equal(uljas_group_value("a", c("", "a", "b")), "a")
})

test_that("a query under the limit is a single request", {
  query <- list(a = as.character(1:5), b = as.character(1:5))

  expect_length(uljas_split_query(query, c(a = 5, b = 5), "f", "en", 25), 1)
})

test_that("the smallest classifier that fits whole requests is split", {
  sizes <- c(big = 3191, small = 18)
  mock_codes(sizes)

  query <- list(big = "=ALL", small = "=ALL")
  parts <- uljas_split_query(query, sizes, "f", "en", 50000)

  expect_length(parts, 2)
  # the large classification is left as it is, so the requests stay short
  expect_equal(vapply(parts, function(p) p$big, character(1)), c("=ALL", "=ALL"))
  expect_equal(lengths(lapply(parts, function(p) p$small)), c(15, 3))
  expect_true(all(vapply(parts, cells, numeric(1), sizes = sizes) <= 50000))
})

test_that("several classifiers are split when one is not enough", {
  sizes <- c(a = 6, b = 4, c = 2)
  mock_codes(sizes)

  query <- list(a = "=ALL", b = "=ALL", c = "=ALL")
  parts <- uljas_split_query(query, sizes, "f", "en", 3)

  part_cells <- vapply(parts, cells, numeric(1), sizes = sizes)
  expect_true(all(part_cells <= 3))
  expect_equal(sum(part_cells), prod(sizes))
})

test_that("every cell is asked for exactly once", {
  sizes <- c(a = 7, b = 5)
  mock_codes(sizes)

  query <- list(a = "=ALL", b = "=ALL")
  parts <- uljas_split_query(query, sizes, "f", "en", 6)

  asked <- do.call(rbind, lapply(parts, function(part) {
    expand.grid(a = uljas_value_codes(part$a, as.character(1:7)),
                b = uljas_value_codes(part$b, as.character(1:5)),
                stringsAsFactors = FALSE)
  }))

  expect_equal(nrow(asked), prod(sizes))
  expect_equal(nrow(unique(asked)), prod(sizes))
})

test_that("splitting is not attempted without a size", {
  query <- list(a = "=ALL")

  expect_length(uljas_query_parts(query, "f", "en", Inf), 1)
  expect_length(uljas_query_parts(list(), "f", "en", 10), 1)
  expect_length(uljas_query_parts(unname(list("=ALL")), "f", "en", 10), 1)
})

test_that("an impossible cell limit is reported", {
  expect_error(uljas_query_parts(list(a = "1"), "f", "en", 0),
               "at least one cell")
  expect_error(uljas_query_parts(list(a = "1"), "f", "en", NA),
               "at least one cell")
})

test_that("a query of single values is not split further", {
  # a guard against splitting for ever with a very small limit
  expect_length(uljas_split_query(list(a = "1", b = "2"), c(a = 1, b = 1),
                                  "f", "en", 1),
                1)
})
