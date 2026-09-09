test_that("special characters are translated for a query", {
  expect_equal(translate_queries("V\u00e4est\u00f6 V\u00c4EST\u00d6"),
               "V*228;est*246;*;V*196;EST*214;")
  expect_equal(translate_queries("SITC Products"), "SITC*;Products")
  expect_equal(translate_queries(c("Ahvenanmaa", "\u00c5land")),
               c("Ahvenanmaa", "*197;land"))
})
