# The api limits an individual request to 50 000 cells, i.e. to 50 000
# combinations of the classifier values. uljas_data() divides a larger query
# into several requests, for which the size of the query has to be known
# beforehand also when it is asked for with the api keywords.


#' Number of cells a query asks for
#'
#' \code{uljas_query_size} returns the number of cells, i.e. the number of
#' classifier value combinations, that a query asks for. An individual request
#' is limited to 50 000 cells and \code{\link{uljas_data}} divides a larger
#' query into several requests.
#'
#' The sizes of the classifications are asked for with
#' \code{\link{uljas_dims}}, if the query uses the keyword \code{"=ALL"}.
#'
#' @inheritParams uljas_data
#'
#' @export
#' @return a number, NA if the size of a classification is not known.
#' @examples
#' \donttest{
#'   uljas_query_size(
#'     ifile = "/DATABASE/01 ULKOMAANKAUPPATILASTOT/02 SITC/ULJAS_SITC",
#'     classifiers = list(`Classification of Products SITC5` = "=ALL",
#'                        `Time period` = "=ALL", Flow = 1, Country = "AT",
#'                        Indicators = "V1"))
#' }
uljas_query_size <- function(classifiers, ifile, lang = "en") {
  prod(uljas_classifier_sizes(classifiers, ifile = ifile, lang = lang))
}


#' Parse an api keyword of a classifier value
#'
#' The keywords are "=ALL", "=FIRST" and "=LAST", the two latter with an
#' optional number of values.
#'
#' @param value a single classifier value.
#'
#' @return a list with the keyword and its number of values, or NULL if the
#'   value is not a keyword.
#' @noRd
uljas_keyword <- function(value) {
  found <- stringr::str_match(
    as.character(value),
    stringr::regex("^=(ALL|FIRST|LAST)(?:\\s+|\\*;)?([0-9]+)?$",
                   ignore_case = TRUE)
  )

  if (is.na(found[, 1])) return(NULL)

  list(keyword = toupper(found[, 2]), n = as.integer(found[, 3]))
}


#' Number of values a single classifier value asks for
#'
#' @param value a single classifier value.
#' @param class_size the number of values in the classification, or NA.
#'
#' @return a number, NA if not known.
#' @noRd
uljas_value_size <- function(value, class_size = NA_real_) {
  keyword <- uljas_keyword(value)

  if (is.null(keyword)) return(1)
  if (keyword$keyword == "ALL") return(as.numeric(class_size))
  if (is.na(keyword$n)) return(1)

  min(as.numeric(keyword$n), as.numeric(class_size), na.rm = TRUE)
}


#' Codes a classifier value asks for
#'
#' @param value classifier values.
#' @param codes all the codes of the classification, in the order of the api.
#'
#' @return a character vector of codes.
#' @noRd
uljas_value_codes <- function(value, codes) {
  asked <- lapply(value, function(x) {
    keyword <- uljas_keyword(x)
    if (is.null(keyword)) return(as.character(x))

    n <- if (is.na(keyword$n)) 1L else keyword$n
    switch(keyword$keyword,
           ALL = codes,
           FIRST = utils::head(codes, n),
           LAST = utils::tail(codes, n))
  })

  unique(unlist(asked, use.names = FALSE))
}


#' Sizes of the classifications of a statistics file
#'
#' @inheritParams uljas_dims
#'
#' @return a numeric vector named with the classifications in lower case.
#' @noRd
uljas_class_sizes <- function(ifile, lang = "en") {
  classifications <- do.call(rbind, uljas_dims(ifile = ifile, lang = lang))

  sizes <- as.numeric(classifications$size)
  names(sizes) <- tolower(as.character(classifications$label))
  sizes
}


#' Codes of a classification
#'
#' @inheritParams uljas_class
#'
#' @return a character vector of codes.
#' @noRd
uljas_class_codes <- function(class, ifile, lang = "en") {
  as.character(uljas_class(class = class, ifile = ifile, lang = lang)[[1]]$code)
}


#' Number of values every classifier of a query asks for
#'
#' @inheritParams uljas_data
#'
#' @return a numeric vector, NA where the size is not known.
#' @noRd
uljas_classifier_sizes <- function(classifiers, ifile, lang = "en") {
  values <- lapply(classifiers, as.character)

  if (length(values) == 0) return(numeric())
  if (is.null(names(values))) return(rep(NA_real_, length(values)))

  # the size of a classification is needed only for the keyword "=ALL"
  needs_size <- vapply(values, function(value) {
    any(vapply(value, function(x) {
      keyword <- uljas_keyword(x)
      !is.null(keyword) && keyword$keyword == "ALL"
    }, logical(1)))
  }, logical(1))

  class_sizes <- if (any(needs_size)) {
    uljas_class_sizes(ifile = ifile, lang = lang)
  } else {
    numeric()
  }

  sizes <- vapply(seq_along(values), function(i) {
    name <- tolower(names(values)[i])
    class_size <- if (name %in% names(class_sizes)) {
      class_sizes[[name]]
    } else {
      NA_real_
    }
    sum(vapply(values[[i]], uljas_value_size, numeric(1),
               class_size = class_size))
  }, numeric(1))

  names(sizes) <- names(values)
  sizes
}


#' Value of a group of codes for a query
#'
#' The empty code of a total can not be asked for on its own, as the api reads
#' an empty parameter as no selection at all. Such a group is asked for with a
#' keyword instead.
#'
#' @param group the codes of one request.
#' @param codes all the codes of the classification.
#'
#' @return a character vector for the query.
#' @noRd
uljas_group_value <- function(group, codes) {
  group <- unname(as.character(group))
  if (!identical(group, "")) return(group)

  total <- match("", codes)
  if (identical(total, 1L)) return("=FIRST 1")
  if (identical(total, length(codes))) return("=LAST 1")

  group
}


#' Divide a query into requests under the cell limit
#'
#' @inheritParams uljas_data
#' @param max_cells the largest number of cells in one request.
#'
#' @return a list of classifier lists.
#' @noRd
uljas_query_parts <- function(classifiers, ifile, lang = "en", max_cells = 50000) {
  if (!is.numeric(max_cells) || length(max_cells) != 1 || is.na(max_cells) ||
      max_cells < 1) {
    stop("max_cells has to be at least one cell.", call. = FALSE)
  }

  if (!is.finite(max_cells) || length(classifiers) == 0 ||
      is.null(names(classifiers))) {
    return(list(classifiers))
  }

  sizes <- uljas_classifier_sizes(classifiers, ifile = ifile, lang = lang)

  # a query of an unknown size is left to the api
  if (anyNA(sizes) || prod(sizes) <= max_cells) return(list(classifiers))

  uljas_split_query(lapply(classifiers, as.character), sizes,
                    ifile = ifile, lang = lang, max_cells = max_cells)
}


#' Split a query along one classifier at a time
#'
#' @inheritParams uljas_query_parts
#' @param sizes the number of values every classifier asks for.
#'
#' @return a list of classifier lists.
#' @noRd
uljas_split_query <- function(classifiers, sizes, ifile, lang, max_cells) {
  # nothing left to split, even if the query is still over the limit
  if (prod(sizes) <= max_cells || all(sizes <= 1)) return(list(classifiers))

  # how many values of a classifier fit in one request with the others
  fit <- floor(max_cells / (prod(sizes) / sizes))

  # The smallest classifier that can be divided into whole requests keeps the
  # number of requests at its minimum and the requests themselves short. If
  # there is none, the largest one is asked for one value at a time and the
  # rest of the query is divided as well.
  splittable <- which(fit >= 1 & sizes > 1)
  i <- if (length(splittable)) {
    splittable[which.min(sizes[splittable])]
  } else {
    which.max(sizes)
  }

  class_codes <- uljas_class_codes(names(classifiers)[i], ifile = ifile,
                                   lang = lang)
  codes <- uljas_value_codes(classifiers[[i]], class_codes)
  per_request <- max(1, min(fit[[i]], length(codes)))
  groups <- split(codes, ceiling(seq_along(codes) / per_request))

  parts <- lapply(groups, function(group) {
    part <- classifiers
    part[[i]] <- uljas_group_value(group, class_codes)

    part_sizes <- sizes
    part_sizes[i] <- length(group)

    uljas_split_query(part, part_sizes, ifile = ifile, lang = lang,
                      max_cells = max_cells)
  })

  do.call(c, unname(parts))
}
