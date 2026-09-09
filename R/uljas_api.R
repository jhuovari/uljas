#' Main api-function for R client for the Finnish Customs (Tulli) database Uljas
#'
#' Use user functions \code{\link{uljas_stats}}, \code{\link{uljas_dims}},
#' \code{\link{uljas_class}} and \code{\link{uljas_data}}.
#' See more from the Uljas api page
#' \url{https://tilastot.tulli.fi/en/uljas-statistical-database/uljas-api}.
#'
#' A query is sent as a get request, or as a post request if it is longer than
#' the 2048 bytes that the server accepts in an url.
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

  query <- c(list(lang = lang, atype = atype, konv = konv, ...), query_list)
  url <- httr::modify_url(url = uljas_url, query = query)

  # The server answers a too long url with a status 404, but accepts the same
  # query as a post request without a length limit.
  resp <- if (nchar(url, type = "bytes") > uljas_max_url) {
    httr::POST(uljas_url, body = query, encode = "form",
               httr::user_agent(uljas_agent))
  } else {
    httr::GET(url, httr::user_agent(uljas_agent))
  }

  # An error is reported before the content type, as the api answers with an
  # html error page.
  if (httr::http_error(resp)) {
    api_message <- uljas_api_message(resp)
    stop(
      sprintf(
        "Uljas API request failed [%s]%s\n<%s>",
        httr::status_code(resp),
        if (is.na(api_message)) "" else paste0("\n", api_message),
        uljas_short_url(url)
      ),
      call. = FALSE
    )
  }

  if (httr::http_type(resp) != "application/json") {
    stop(
      sprintf(
        "Uljas API returned %s instead of json.\n<%s>",
        httr::http_type(resp),
        uljas_short_url(url)
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

# the server rejects a query string longer than 2048 bytes
uljas_max_url <- 1500


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


#' Error message of an Uljas api response
#'
#' The api answers a failed query with an html page, on which the message is
#' url encoded.
#'
#' @param resp a response from \code{httr::GET}.
#'
#' @return a string, NA if the page has no message.
#' @noRd
uljas_api_message <- function(resp) {
  cont <- tryCatch(uljas_content(resp), error = function(e) NA_character_)
  if (is.na(cont[[1]])) return(NA_character_)

  message <- stringr::str_match(cont, "Query failed: <i>\\((.*)\\)</i>")[, 2]
  if (is.na(message)) return(NA_character_)

  # the page decodes the message itself, see writeErrorPage() on it
  message <- tryCatch(utils::URLdecode(message), error = function(e) message)
  gsub("+", " ", message, fixed = TRUE)
}


#' Shorten an url for a message
#'
#' @param url an url.
#' @param max the largest number of characters to keep.
#'
#' @return a string.
#' @noRd
uljas_short_url <- function(url, max = 300) {
  if (nchar(url) <= max) return(url)
  paste0(substr(url, 1, max), "...")
}
