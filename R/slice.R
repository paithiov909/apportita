#' Slice samples from Magnitude table
#'
#' @param con A Magnitude connection.
#' @param n Integer.
#' @param offset Integer.
#' @param normalized Logical;
#' @return A tibble.
#' @export
slice_n <- function(con, n, offset = 0, normalized = FALSE) {
  n <- n[1]
  offset <- offset[1]
  if (offset > dim(con)[1]) {
    rlang::abort("`offset` must be smaller than rows of Magnitude table.")
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

## TODO: more slice fucntion
## slice_index
## slice_frac
