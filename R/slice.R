#' Slice samples from a Magnitude table
#'
#' @param con a Magnitude connection.
#' @param n integer.
#' @param offset integer.
#' @param normalized logical;
#' @return a tibble.
#' @export
slice_n <- function(con, n, offset = 0, normalized = TRUE) {
  n <- n[1]
  offset <- offset[1]
  if (offset > dim(con)[1]) {
    rlang::abort("`offset` must be smaller than the Magnitude size.")
  }
  res <-
    RSQLite::dbSendQuery(con,
      "SELECT * FROM magnitude LIMIT ? OFFSET ?",
      params = list(as.integer(n), as.integer(offset))
    )
  tbl <- RSQLite::dbFetch(res) %>%
    tibble::as_tibble()
  RSQLite::dbClearResult(res)
  db_result_to_vec(con, tbl, normalized)
}

#' Slice samples by index from a Magnitude table
#'
#' @param con a Magnitude connection.
#' @param index integer vector.
#' @param normalized logical;
#' @return a tibble.
#' @export
slice_index <- function(con, index, normalized = TRUE) {
  if (max(index) > dim(con)[1]) {
    rlang::warn("`index` bigger than the Magnitude table size is ignored.")
  }
  index <- as.integer(index[!index > dim(con)[1]])
  res <-
    RSQLite::dbSendQuery(con,
      "SELECT * FROM magnitude WHERE ROWID IN (?)",
      params = list(index)
    )
  tbl <- RSQLite::dbFetch(res) %>%
    tibble::as_tibble()
  RSQLite::dbClearResult(res)
  db_result_to_vec(con, tbl, normalized)
}

#' Slice samples by frac from a Magnitude table
#'
#' @param con a Magnitude connection.
#' @param frac numeric.
#' @param normalized logical;
#' @return a tibble.
#' @export
slice_frac <- function(con, frac = .001, normalized = TRUE) {
  if (frac > 1) {
    rlang::abort("`frac` must be smaller than 1.")
  }
  size <- dim(con)[1]
  index <- sample(seq_len(size),
    size = trunc(size * as.numeric(frac)),
    replace = FALSE
  )
  slice_index(con, index, normalized)
}
