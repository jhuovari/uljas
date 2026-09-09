# uljas 0.2.0

## Bug fixes

* `uljas_data()` works again. The Uljas api returns the total of a
  classification with an empty string as its code, which
  `rjstat::fromJSONstat()` has rejected since rjstat 0.4.0. The JSON-stat
  answer is now parsed by the package itself and the rjstat dependency is
  dropped (#3).

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
