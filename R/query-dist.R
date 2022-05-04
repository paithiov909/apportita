#' Calculate distances from keys to keys
#'
#' @param conn a Magnitude connection.
#' @param keys character vector.
#' @param q character vector.
#' @param normalized logical; whether or not vector embeddings should be normalized?
#' @param mehtod string; method to compute distance.
#' @param ... other arguments are passed to \code{proxyC::dist}.
#' @return a sparse Matrix of 'Matrix' package.
#' @export
calc_dist <- function(conn, keys, q, normalized = TRUE,
                      method = c(
                        "euclidean",
                        "chisquared",
                        "kullback",
                        "manhattan",
                        "maximum",
                        "canberra",
                        "minkowski",
                        "hamming"
                      ),
                      ...) {
  method <- rlang::arg_match(method)
  x <- query(conn, keys, normalized) %>%
    tibble::column_to_rownames("key") %>%
    as.matrix()
  y <- query(conn, q, normalized) %>%
    tibble::column_to_rownames("key") %>%
    as.matrix()
  proxyC::dist(x, y, method = method, ...)
}

#' Order keys by their distances to key
#'
#' @param conn a Magnitude connection.
#' @param key string.
#' @param q character vector.
#' @param n integer.
#' @param normalized logical; whether or not vector embeddings should be normalized?
#' @param method string; method to compute distance.
#' @return an ordered named numeric vector of which elements represent distances to `key`.
#' @export
doesnt_match <- function(conn, key, q, n = 1L,
                         normalized = TRUE,
                         method = c(
                           "euclidean",
                           "chisquared",
                           "kullback",
                           "manhattan",
                           "maximum",
                           "canberra",
                           "minkowski",
                           "hamming"
                         )) {
  if (length(key) != 1L) {
    rlang::warn("length of `key` is not 1L. the first element will be used.")
  }
  q <- unique(q[which(!q %in% key, arr.ind = TRUE)])
  n <- ifelse(n > length(q), length(q), n)
  simil <-
    as.matrix(calc_dist(conn, key[1], q, normalized, method))
  ix <- sort(simil, decreasing = TRUE, index.return = TRUE)$ix
  purrr::set_names(simil[1, ix], names(simil[1, ix]))[1:n]
}
