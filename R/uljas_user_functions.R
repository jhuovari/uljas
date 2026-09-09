#' Get statistics from the Uljas database.
#'
#' Returns a data.frame of statistics in the Uljas database.
#'
#' @param lang a language code. Available en, fi, se.
#'
#' @export
#' @return a data.frame with the columns ifile, title and utime.
#' @examples
#' \donttest{
#'   stats <- uljas_stats("fi")
#' }
uljas_stats <- function(lang = "en"){
  stats <- uljas_api(lang = lang, atype = "stats", konv = "json")
  stats$content
}




#' Get dimensions from Uljas api
#'
#' \code{uljas_dims} return dimensions that are available for a certain statistics.
#' Use ifile from \code{\link{uljas_stats}}.
#'
#' @param ifile a name of the statistics file with relative data directory path.
#'        Get from \code{\link{uljas_stats}}
#' @inheritParams uljas_stats
#'
#' @export
#' @return a named list of data.frames, one for each dimension.
#' @examples
#' \donttest{
#'   sitc_dims <- uljas_dims(ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC")
#' }

uljas_dims <- function(ifile, lang = "en"){
  d <- uljas_api(lang = lang, atype = "dims", konv = "json", ifile = ifile)
  d_list <- d$content$dimension$classification
  names(d_list) <- vapply(d_list, function(x) as.character(x$label)[[1]], character(1))
  d_list
}

#' Get classifications from Uljas api
#'
#' \code{uljas_class} returns the values in a classification. With
#' \code{class = NULL} the values of all main classifications are returned.
#'
#' @param class a name of a classification from \code{\link{uljas_dims}}, or
#'        NULL for all main classifications.
#' @inheritParams uljas_dims
#' @export
#' @return a named list of data.frames with the columns code and text.
#' @examples
#' \donttest{
#'   sitc_class <- uljas_class(class = "SITC Products",
#'                             ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC")
#'   sitc_class_all <- uljas_class(class = NULL,
#'                             ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC")
#' }

uljas_class <- function(class = NULL, ifile, lang = "en"){
  # a query without a class returns all main classifications
  class_query <- if (!is.null(class)) list(class = translate_queries(class))
  cla <- uljas_api(lang = lang, atype = "class", konv = "json", ifile = ifile,
                   query_list = class_query)
  cla_list <- cla$content$classification$class
  names(cla_list) <- cla$content$classification$label
  cla_list
}

#' Get data from Uljas api
#'
#' \code{uljas_data} returns the data for class value combinations from a statistics
#' (specified with ifile parameter).
#'
#' A classifier value may also be one of the api keywords \code{"=ALL"},
#' \code{"=FIRST"} and \code{"=LAST"}. Note that the keywords follow the order
#' of the classification, which for time periods is the newest first, and that
#' the code of a total is an empty string.
#'
#' @param classifiers a list of classes with values of levels to get.
#' @inheritParams uljas_dims
#' @param naming whether to use (longer) labels or (shorter) ids.
#' @param ... additional parameters for a query. Passed to \code{\link{uljas_api}}.
#'
#' @export
#' @return a tibble with a column for each classifier and a values column.
#' @examples
#' \donttest{
#'   sitc_query <- list(`Classification of Products SITC1` = c("0" , "1"),
#'                      `Time period` = "=ALL", Flow = 1, Country = "AT", Indicators = "V1")
#'   sitc_data <- uljas_data(ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC",
#'                           classifiers = sitc_query)
#' }

uljas_data <- function(classifiers, ifile, lang = "en", naming = "label", ...){
  classifiers <- purrr::map(classifiers, paste, collapse = '"')
  dat <- uljas_api(lang = lang, atype = "data", konv = "json-stat",
                   ifile = ifile, ...,
                   naming = naming,
                   query_list = classifiers)
  dplyr::rename(dat$content, values = "value")
}
