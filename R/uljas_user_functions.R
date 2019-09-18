#'
#' @export
#' @examples
#' stats <- uljas_stats("fi")
#'
uljas_stats <- function(lang = "en"){
  stats <- uljas_api(lang =, atype = "stats", konv = "json")
  stats$content
}




#' Get dimensions from Uljas api
#' @export
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
#' @export
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
#' @export
#' @examples
#'   sitc_query <- list(`Classification of Products SITC1` = c("0" , "1"), TimePeriod = "=ALL", Flow = 1, Country = "AT", Indicators = "V1")
#'   sitc_data <- uljas_data(ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC", classifiers = sitc_query)

uljas_data <- function(ifile, lang = "en", classifiers, ...){
  classifiers <- purrr::map(classifiers, paste, collapse = '"')
  dat <- uljas_api(lang = lang, atype = "data", konv = "json", ifile = ifile, ..., query_list = classifiers)
  dat <- suppressMessages(tidyr::unnest_wider(dat$content, keys))
  dat <- dplyr::mutate(dat, vals = unlist(vals))
  names(dat) <- c(names(classifiers)[1:(length(names(classifiers))-1)], "values")
  dat
}

