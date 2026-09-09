# A minimal reader for the JSON-stat 1.x responses of the Uljas API.
#
# rjstat::fromJSONstat() can not be used, because the Uljas API returns the
# "Total" category of a classification with an empty string as its code, and
# rjstat (>= 0.4.0) rejects category codes with less than one character.


#' Categories of a single JSON-stat dimension
#'
#' @param dimension a single dimension of a parsed JSON-stat dataset.
#' @param naming whether to use (longer) labels or (shorter) ids.
#'
#' @return a character vector of categories in the order of the data.
#' @noRd
jsonstat_categories <- function(dimension, naming = "label") {
  category <- dimension$category
  index <- category$index
  label <- category$label

  if (!is.null(index)) {
    if (is.null(names(index))) {
      # index as an array of codes
      codes <- as.character(unlist(index, use.names = FALSE))
    } else {
      # index as an object of code = position pairs
      codes <- names(index)[order(unlist(index, use.names = FALSE))]
    }
  } else if (!is.null(names(label))) {
    codes <- names(label)
  } else {
    stop("A JSON-stat dimension without an index or a labelled category.",
         call. = FALSE)
  }

  if (naming != "label" || is.null(label)) return(codes)

  labels <- vapply(
    label,
    function(x) if (length(x)) as.character(x)[[1]] else NA_character_,
    character(1)
  )

  # match() is used instead of label[codes], as "" never matches a name
  pos <- match(codes, names(label))
  ifelse(is.na(pos) | is.na(labels[pos]), codes, labels[pos])
}


#' Values of a parsed JSON-stat dataset
#'
#' @param value the value element of a parsed JSON-stat dataset.
#' @param n the number of cells in the dataset.
#'
#' @return a vector of length n.
#' @noRd
jsonstat_values <- function(value, n) {
  if (is.list(value) && !is.null(names(value))) {
    # a sparse value object of zero based position = value pairs
    values <- rep(NA_real_, n)
    pos <- as.integer(names(value)) + 1L
    values[pos] <- vapply(
      value,
      function(x) if (length(x)) as.numeric(x)[[1]] else NA_real_,
      numeric(1)
    )
    return(values)
  }

  if (is.list(value)) {
    value <- vapply(
      value,
      function(x) if (length(x)) as.numeric(x)[[1]] else NA_real_,
      numeric(1)
    )
  }

  unname(value)
}


#' Convert a JSON-stat dataset to a data.frame
#'
#' @param x a JSON-stat response parsed with \code{jsonlite::fromJSON}.
#' @param naming whether to use (longer) labels or (shorter) ids.
#' @param use_factors whether dimensions are returned as factors.
#'
#' @return a tibble with a column for every dimension and a value column.
#' @noRd
jsonstat_to_df <- function(x, naming = "label", use_factors = TRUE) {
  dataset <- if (is.null(x$dataset)) x else x$dataset
  dimension <- dataset$dimension

  if (is.null(dimension) || is.null(dimension$id) || is.null(dimension$size)) {
    stop("The Uljas API did not return a JSON-stat dataset.", call. = FALSE)
  }

  ids <- as.character(unlist(dimension$id, use.names = FALSE))
  sizes <- as.integer(unlist(dimension$size, use.names = FALSE))

  if (length(ids) != length(sizes)) {
    stop("The number of JSON-stat dimensions and sizes do not match.",
         call. = FALSE)
  }

  categories <- lapply(ids, function(id) jsonstat_categories(dimension[[id]], naming))
  wrong <- lengths(categories) != sizes

  if (any(wrong)) {
    stop("The JSON-stat dimension(s) ", paste0("'", ids[wrong], "'", collapse = ", "),
         " have a different number of categories than the reported size.",
         call. = FALSE)
  }

  cells <- prod(sizes)
  values <- jsonstat_values(dataset$value, cells)

  if (length(values) != cells) {
    stop("The Uljas API returned ", length(values), " values for ", cells,
         " cells.", call. = FALSE)
  }

  # values are in a row-major order, i.e. the last dimension varies fastest
  columns <- lapply(seq_along(ids), function(i) {
    column <- rep(categories[[i]],
                  each = prod(sizes[-seq_len(i)]),
                  times = prod(sizes[seq_len(i - 1)]))
    if (use_factors) factor(column, levels = unique(categories[[i]])) else column
  })

  labels <- vapply(ids, function(id) {
    label <- dimension[[id]]$label
    if (naming == "label" && length(label)) as.character(label)[[1]] else id
  }, character(1))

  names(columns) <- unname(labels)

  dplyr::as_tibble(c(columns, list(value = values)))
}
