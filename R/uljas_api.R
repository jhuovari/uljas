#' Main api-function for R client for the Finnish Customs (Tulli) database Uljas
#'
#' Use user functions \code{\link{uljas_stats}}, \code{\link{uljas_dims}},
#' \code{\link{uljas_class}} and \code{\link{uljas_data}}.
#' See more from Uljas api page https://tulli.fi/en/statistics/uljas-api
#'
#'
#' @param lang A language code. Available en, fi, se.
#' @param atype A type of query.
#' @param konv A output format
#' @param ... Additional parameters for a query.
#' @param query_list Additional parameters for a query as a list.
#'
#' @export
#' @return A list with uljas api type class.


uljas_api <- function(lang = "en", atype, konv, ..., query_list = NULL) {
  url <- httr::modify_url(url="http://uljas.tulli.fi/uljas/graph/api.aspx",
                          query = c(list(lang = lang, atype = atype, konv = konv, ...),
                                    query_list))

  resp <- httr::GET(url)

  if (httr::http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }


  # Removes illegal BOM. inspired by: https://gist.github.com/hrbrmstr/be3bf6e2b7e8b06648fd
  cont <- readBin(resp$content[4:length(resp$content)], "character")
  # cont <- (httr::content(resp, "text"))

  parsed <- jsonlite::fromJSON(cont, simplifyVector = TRUE, flatten = TRUE)

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



