#'
#'


uljas_api <- function(lang = "en", atype, konv, ...) {
  url <- httr::modify_url(url="http://uljas.tulli.fi/uljas/graph/api.aspx", query = list(lang = lang, atype = atype, konv = konv, ...))

  resp <- httr::GET(url)

  if (httr::http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  parsed <- jsonlite::fromJSON(httr::content(resp, "text"), simplifyVector = TRUE, flatten = TRUE)

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

#'
#'
#' @examples
#' s <- uljas_stats("fi")
#'
uljas_stats <- function(lang = "en"){
  uljas_api(lang =, atype = "stats", konv = "json")
}



#' print method for uljas_api_stats
#'
print.uljas_api_stats <- function(x){
  x$content
}



#' Get dimensions from Uljas api
#'
#' @return a list.
#' @examples
#'   sitc_dims <- uljas_dims(ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC")
#'

uljas_dims <- function(ifile, lang = "en"){
   d <- uljas_api(lang = "en", atype = "dims", konv = "json", ifile = ifile)
   d_list <- d$content$dimension$classification
   names(d_list) <- purrr::map(d_list, function(x) x$label[[1]])
   d_list
}

#' Get classifications from Uljas api
#'
#' @return a list.
#' @examples
#'   sitc_class <- uljas_class(ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC", class = "SITC Products")
#'   sitc_class_all <- uljas_class(ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC", class = NULL)
#'

uljas_class <- function(ifile, class, lang = "en"){
  class <- translate_queries(class)
  cla <- uljas_api(lang = lang, atype = "class", konv = "json", ifile = ifile, class = class)
  cla_list <- cla$content$classification$class
  names(cla_list) <- cla$content$classification$label
  cla_list
  }

#' Get data from Uljas api
#'
#' @examples
#'   sitc_data <- uljas_data(ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC", `Classification of Products SITC1` = 1, TimePeriod = "=ALL", Country = "AT", Flow = 1, Indicators = "V1")

uljas_data <- function(ifile, lang = "en", ...){
  dat <- uljas_api(lang = lang, atype = "data", konv = "json", ifile = ifile, ...)
  dat
}

