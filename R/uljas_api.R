#' Main api-function for R client for the Finnish Customs (Tulli) database Uljas
#'
#' Use user functions \code{\link{uljas_stats}}, \code{\link{uljas_dims}},
#' \code{\link{uljas_class}} and \code{\link{uljas_data}}.
#' See more from Uljas api page https://tulli.fi/en/statistics/uljas-api
#'
#'
#' @param lang a language code. Available en, fi, se.
#' @param atype a type of query.
#' @param konv a output format
#' @param ... additional parameters for a query.
#' @param query_list additional parameters for a query as a list.
#' @export


uljas_api <- function(lang = "en", atype, konv, ..., query_list = NULL) {
  url <- httr::modify_url(url="http://uljas.tulli.fi/uljas/graph/api.aspx",
                          query = c(list(lang = lang, atype = atype, konv = konv, ...),
                                    query_list))

  resp <- httr::GET(url)

  if (httr::http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  cont <- httr::content(resp, "text")
  parsed <- suppressWarnings(jsonlite::fromJSON(cont, simplifyVector = TRUE, flatten = TRUE))

  if (httr::http_error(resp)) {
    stop(
      sprintf(
        "Uljas API request failed [%s]\n%s\n<%s>",
        httr::status_code(resp),
        parsed$message,
        parsed$documentation_url
      ),
      call. = FALSE
    )
  }

  structure(
    list(
      content = parsed,
      url = url,
      response = resp
    ),
    class = paste0("uljas_api_", atype)
  )
}



