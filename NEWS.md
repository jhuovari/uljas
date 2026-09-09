# uljas 0.2.0

## New features

* `uljas_data()` divides a query that is over the api limit of 50 000 cells
  into several requests and combines the answers (#5). The result is the same
  as that of a single request. `max_cells = Inf` sends the query as it is.

* `uljas_query_size()` returns the number of cells a query asks for, also when
  it is asked for with the keywords `"=ALL"`, `"=FIRST"` and `"=LAST"`.

* A query longer than the 2048 bytes that the server accepts in an url is sent
  as a post request. A query of more than about 230 codes was earlier answered
  with a status 404.

* The api answers a failed query with an html page, from which its own message
  is now passed on, e.g. "Query result compinations are over limit (50000)" or
  "Query ifile not found or is not valid" (#1).

## Bug fixes

* `uljas_data()` works again. The Uljas api returns the total of a
  classification with an empty string as its code, which
  `rjstat::fromJSONstat()` has rejected since rjstat 0.4.0. The JSON-stat
  answer is now parsed by the package itself and the rjstat dependency is
  dropped.

* `uljas_dims()` now uses its `lang` argument, instead of always answering in
  English.

* `uljas_data()` now passes its `naming` argument to the api.

* A failed request is reported with its status code and url. The api answers
  with an html error page, which was earlier reported as
  "API did not return json".

* Text is read as UTF-8 instead of the native encoding, so that scandinavian
  characters are correct also outside an UTF-8 locale. The byte order mark of
  the answer is removed without `readBin()` (#2).

* Queries are made over https. The api redirects http to https.

## Other changes

* `uljas_class()` has `class = NULL` as a default, i.e. all main
  classifications.

* The unused tidyr, rlang and rjstat dependencies are dropped.

* The tests do not require a network connection any more, apart from the api
  tests, which are skipped on CRAN and without a connection.
