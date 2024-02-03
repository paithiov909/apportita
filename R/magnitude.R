#' Create a Magnitude connection
#'
#' @param path string; a path to a magnitude file.
#' @param ... other arguments are passed to \code{RSQLite::dbConnect}.
#' @returns a Magnitude connection object inheriting
#' SQLiteConnection class from 'RSQLite' package.
#' @export
magnitude <- function(path, ...) {
  new_magnitude(file.path(path), ...)
}

#' @keywords internal
precision <- function(conn) {
  conn@format %>%
    dplyr::filter(.data$key == "precision") %>%
    dplyr::pull("value")
}

#' @keywords internal
subword <- function(conn) {
  conn@format %>%
    dplyr::filter(.data$key == "subword") %>%
    dplyr::pull("value")
}

#' @keywords internal
subword_start <- function(conn) {
  conn@format %>%
    dplyr::filter(.data$key == "subword_start") %>%
    dplyr::pull("value")
}

#' @keywords internal
subword_end <- function(conn) {
  conn@format %>%
    dplyr::filter(.data$key == "subword_end") %>%
    dplyr::pull("value")
}

#' @keywords internal
highest_entropy_dims <- function(conn) {
  conn@format %>%
    dplyr::filter(.data$key == "entropy") %>%
    dplyr::pull("value")
}

#' @keywords internal
max_duplicate_keys <- function(conn) {
  duplicated_key <- conn@format %>%
    dplyr::filter(.data$key == "max_duplicate_key") %>%
    dplyr::pull("value")
  if (duplicated_key == 0) {
    res <-
      RSQLite::dbSendQuery(
        conn,
        "SELECT MAX(key_count) FROM (SELECT COUNT(key) AS key_count FROM magnitude GROUP BY key);"
      )
    tbl <- RSQLite::dbFetch(res) %>%
      tibble::as_tibble()
    RSQLite::dbClearResult(res)
    ifelse(rlang::is_empty(tbl[1, 1]), 1, tbl[1, 1])
  } else {
    duplicated_key
  }
}

#' Magnitude class
#'
#' Connection object to a magnitude file.
#'
#' @name magnitude-class
#' @param dbname a path to the magnitude file.
#' @param ... other arguments are passed to \code{RSQLite::dbConnect}.
#' @returns a Magnitude class object.
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
#' @param x a Magnitude connection.
#' @returns a numeric vector.
#' @export
setMethod("dim",
  signature = c(x = "Magnitude"),
  function(x) {
    rows <- x@format %>%
      dplyr::filter(.data$key == "size") %>%
      dplyr::pull("value")
    cols <- x@format %>%
      dplyr::filter(.data$key == "dim") %>%
      dplyr::pull("value")
    c(rows, cols)
  }
)

#' Close a Magnitude connection
#' @param con a Magnitude connection.
#' @returns the value from \code{RSQLite::dbDisconnect} is returned invisibly.
#' @export
setMethod("close",
  signature = c(con = "Magnitude"),
  function(con) {
    RSQLite::dbDisconnect(con)
  }
)
