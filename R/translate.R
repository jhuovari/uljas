#' Replace special characters in queries
#'
#' @examples
#'  translate_queries("Väestö VÄESTÖ")

translate_queries <- function(x){
  # c("ä" = "*228;", "ö" = "*246;", "å" = "*229;", "Ä" = "*196;", "Ö" = "*214;", "Å" = "*197;", " " = "*;")
  trans_table <- c("\\u00e4" = "*228;",
                   "\\u00f6" = "*246;",
                   "\\u00e5" = "*229;",
                   "\\u00c4" = "*196;",
                   "\\u00d6" = "*214;",
                   "\\u00c5" = "*197;",
                   " " = "*;")
  stringr::str_replace_all(x, trans_table)
}


