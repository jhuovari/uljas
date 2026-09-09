#' Main api-function for R client for the Finnish Customs (Tulli) database Uljas
#'
#' Use user functions \code{\link{uljas_stats}}, \code{\link{uljas_dims}},
#' \code{\link{uljas_class}} and \code{\link{uljas_data}}.
#' See more from the Uljas api page
#' \url{https://tilastot.tulli.fi/en/uljas-statistical-database/uljas-api}.
#'
#'
#' @param lang A language code. Available en, fi, se.
#' @param atype A type of query. One of stats, dims, class or data.
#' @param konv A output format. One of json or json-stat.
#' @param ... Additional parameters for a query.
#' @param query_list Additional parameters for a query as a list.
#' @param naming whether to use (longer) labels or (shorter) ids.
#'
#' @export
#' @return A list with uljas api type class.


uljas_api <- function(lang = "en", atype, konv, ..., query_list = NULL, naming = "label") {

  if (!konv %in% c("json", "json-stat")) {
    stop("Wrong output format ", konv, ". Allowed are json and json-stat.",
         call. = FALSE)
  }

  url <- httr::modify_url(url = uljas_url,
                          query = c(list(lang = lang, atype = atype, konv = konv, ...),
                                    query_list))

  resp <- httr::GET(url, httr::user_agent(uljas_agent))

  # An error is reported before the content type, as the api answers with an
  # html error page.
  if (httr::http_error(resp)) {
    stop(
      sprintf(
        "Uljas API request failed [%s]\n<%s>",
        httr::status_code(resp),
        url
      ),
      call. = FALSE
    )
  }

  if (httr::http_type(resp) != "application/json") {
    stop(
      sprintf(
        "Uljas API returned %s instead of json.\n<%s>",
        httr::http_type(resp),
        url
      ),
      call. = FALSE
    )
  }

  cont <- uljas_content(resp)

  if (konv == "json") {
    parsed <- jsonlite::fromJSON(cont, simplifyVector = TRUE, flatten = TRUE)
  } else {
    parsed <- jsonstat_to_df(jsonlite::fromJSON(cont, simplifyVector = TRUE),
                             naming = naming)
  }

  # Return
  structure(
    list(
      content = parsed,
      url = url,
      response = resp
    ),
    class = paste0("uljas_api_", atype)
  )
}


uljas_url <- "https://uljas.tulli.fi/uljas/graph/api.aspx"

uljas_agent <- "uljas R package (https://github.com/jhuovari/uljas)"


#' Text content of an Uljas api response
#'
#' The api prefixes the json with an illegal byte order mark.
#'
#' @param resp a response from \code{httr::GET}.
#'
#' @return a UTF-8 string.
#' @noRd
uljas_content <- function(resp) {
  cont <- httr::content(resp, as = "text", encoding = "UTF-8")
  sub("^\uFEFF", "", cont)
}
