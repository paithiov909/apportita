#' @keywords internal
row_norms <- function(x, type = "2") {
  purrr::map_dbl(seq_len(nrow(x)), ~ norm(x[., ], type))
}

#' Calculate Word Rotator's Distance
#'
#' Calculate Word Rotator's Distance between two distributions.
#'
#' Word Rotator's Distance is a measure of textual similarity
#' improved of Word Mover's Distance.
#'
#' @seealso \url{http://dx.doi.org/10.18653/v1/2020.emnlp-main.236}
#'
#' @param x a dense or sparse matrix.
#' @param y a dense or sparse matrix.
#' @param ... other arguments are passed to \code{transport::wasserstein} interenally.
#' @return numeric scalar.
#' @export
wrd <- function(x, y, ...) {
  x_norm <- row_norms(x)
  y_norm <- row_norms(y)
  transport::wasserstein(
    x_norm / sum(x_norm),
    y_norm / sum(y_norm),
    costm = (1 - proxyC::simil(x, y, method = "cosine", use_nan = TRUE)),
    ...
  )
}

#' Calculate Word Rotator's Distance from keys to keys
#'
#' @param conn a Magnitude connection.
#' @param keys character vector.
#' @param q character vector.
#' @param normalized logical; whether or not vector embeddings should be normalized?
#' @param ... other arguments are passed to \code{transport::wasserstein} internally.
#' @return numeric scalar.
#' @export
calc_wrd <- function(conn, keys, q, normalized = TRUE, ...) {
  x <- query(conn, keys, normalized) %>%
    dplyr::select(!"key") %>%
    as.matrix()
  y <- query(conn, q, normalized) %>%
    dplyr::select(!"key") %>%
    as.matrix()
  wrd(x, y, ...)
}
