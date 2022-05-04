#' Create a Magnitude connection
#'
#' @param path string; path to a magnitude file.
#' @param ... other arguments are passed to \code{RSQLite::dbConnect}.
#' @return a Magnitude connection object inheriting
#' SQLiteConnection class from 'RSQLite' package.
#' @export
magnitude <- function(path, ...) {
  new_magnitude(file.path(path), ...)
}

#' Close a Magnitude connection
#'
#' @param conn a Magnitude connection.
#' @return the value from \code{RSQLite::dbDisconnect} is returned invisibly.
#' @export
close <- function(conn) {
  RSQLite::dbDisconnect(conn)
}

#' @keywords internal
precision <- function(conn) {
  subset(conn@format, key == "precision")$value
}

#' @keywords internal
subword <- function(conn) {
  subset(conn@format, key == "subword")$value
}

#' @keywords internal
subword_start <- function(conn) {
  subset(conn@format, key == "subword_start")$value
}

#' @keywords internal
subword_end <- function(conn) {
  subset(conn@format, key == "subword_end")$value
}

#' @keywords internal
highest_entropy_dims <- function(conn) {
  subset(conn@format, key == "entropy")$value
}

## TODO: remove?
#' @keywords internal
max_duplicate_keys <- function(conn) {
  duplicated_key_query <- subset(conn@format, key == "max_duplicate_keys")$value
  if (duplicated_key_query == 0) {
    res <-
      RSQLite::dbSendQuery(
        conn,
        "SELECT MAX(key_count) FROM (SELECT COUNT(key) AS key_count FROM magnitude GROUP BY key);"
      )
    tbl <- RSQLite::dbFetch(res) %>%
      tibble::as_tibble()
    RSQLite::dbClearResult(res)
    ifelse(rlang::empty(tbl[1, 1]), 1, tbl[1, 1])
  } else {
    duplicated_key_query
  }
}

#' Magnitude class
#'
#' Connection object to a magnitude file.
#'
#' @name magnitude-class
#' @param dbname the path to the magnitude file.
#' @param ... other arguments are passed to \code{RSQLite::dbConnect}.
#' @return a Magnitude class object.
#' @keywords internal
new_magnitude <- function(dbname, ...) {
  conn <- RSQLite::dbConnect(RSQLite::SQLite(), dbname, ...)
  format <-
    dplyr::tbl(conn, "magnitude_format") %>%
    dplyr::collect()
  new("Magnitude", conn, format = format)
}

#' @keywords internal
setClass("Magnitude",
  slots = c(format = "data.frame"),
  prototype = list(format = data.frame(key = character(), value = integer())),
  contains = "SQLiteConnection"
)

#' Dimensions of a Magnitude table
#' @export
setMethod("dim",
  signature = c(x = "Magnitude"),
  function(x) {
    c(subset(x@format, key == "size")$value, subset(x@format, key == "dim")$value)
  }
)
