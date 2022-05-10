#' Calculate distances from keys to keys
#'
#' @param conn a Magnitude connection.
#' @param keys character vector.
#' @param q character vector.
#' @param normalized logical; whether or not vector embeddings should be normalized?
#' @param method string; method to compute distance.
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

#' Order keys by their distances to a key
#'
#' @param conn a Magnitude connection.
#' @param key string.
#' @param q character vector. elements exact same with key will be dropped from result.
#' @param n integer.
#' @param normalized logical; whether or not vector embeddings should be normalized?
#' @param method string; method to compute distance.
#' @return a tibble.
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
  dist <-
    as.matrix(calc_dist(conn, key[1], q, normalized, method))
  tibble::tibble(
    keys = colnames(dist),
    distance = dist[1, ]
  ) %>%
    dplyr::arrange(desc(.data$distance)) %>%
    dplyr::slice_head(n = n)
}
