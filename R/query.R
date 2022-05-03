#' Query
#'
#' Handles a query of keys which could be a list (a character vector)
#' of keys.
#'
#' @param con A Magnitude connection.
#' @param q Character vector;
#' @param normalized Logical;
#' @return A tibble.
#' @export
query <- function(con, q, normalized = TRUE) {
  tbl <-
    dplyr::tbl(con, "magnitude") %>%
    dplyr::filter(.data$key %in% q) %>%
    dplyr::collect()
  ## TODO: _out_of_vocab_vector
  db_result_to_vec(con, tbl, normalized)
}

#' Calculate distances from keys to keys in q
#'
#' @param con a Magnitude connection.
#' @param key character vector.
#' @param q character vector.
#' @param normalized logical.
#' @param mehtod string; method to compute distance.
#' @param ... other arguments are passed to \code{proxyC::dist}.
#' @return a sparse Matrix of 'Matrix' package.
#' @export
calc_dist <- function(con, key, q, normalized = TRUE,
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
  x <- query(con, key, normalized) %>%
    tibble::column_to_rownames("key") %>%
    as.matrix()
  y <- query(con, q, normalized) %>%
    tibble::column_to_rownames("key") %>%
    as.matrix()
  proxyC::dist(x, y, method = method, ...)
}

#' Order q by their distances to key
#'
#' @param con a Magnitude connection.
#' @param key string.
#' @param q character vector.
#' @param normalized logical; whether or not vector embeddings should be normalized?
#' @param method string; method to compute distance.
#' @param n integer.
#' @return an ordered named numeric vector of which elements represent distances to `key`.
#' @export
doesnt_match <- function(con, key, q, normalized = TRUE,
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
                         n = 1L) {
  if (length(key) != 1L) {
    rlang::warn("length of `key` is not 1L. the first element will be used.")
  }
  q <- unique(q[which(!q %in% key, arr.ind = TRUE)])
  n <- ifelse(n > length(q), length(q), n)
  simil <-
    as.matrix(calc_dist(con, key[1], q, normalized, method))
  ix <- sort(simil, decreasing = TRUE, index.return = TRUE)$ix
  purrr::set_names(simil[1, ix], names(simil[1, ix]))[1:n]
}

#' Calculate similarities from keys to keys in q
#'
#' @param con a Magnitude connection.
#' @param key character vector.
#' @param q character vector.
#' @param normalized logical.
#' @param mehtod string; method to compute similarity.
#' @param ... other arguments are passed to \code{proxyC::simil}.
#' @return a sparse Matrix of 'Matrix' package.
#' @export
calc_simil <- function(con, key, q, normalized = TRUE,
                        method = c(
                          "cosine",
                          "correlation",
                          "jaccard",
                          "ejaccard",
                          "dice",
                          "edice",
                          "hamann",
                          "simple matching",
                          "faith"
                        ),
                        ...) {
  method <- rlang::arg_match(method)
  x <- query(con, key, normalized) %>%
    tibble::column_to_rownames("key") %>%
    as.matrix()
  y <- query(con, q, normalized) %>%
    tibble::column_to_rownames("key") %>%
    as.matrix()
  proxyC::simil(x, y, method = method, ...)
}

#' Order q by their similarity to key
#'
#' @param con a Magnitude connection.
#' @param key string.
#' @param q character vector.
#' @param normalized logical.
#' @param mehtod string; method to compute similarity.
#' @param n integer.
#' @return an ordered named numeric vector of which elements represent similarities to `key`.
#' @export
most_similar_to_given <- function(con, key, q, normalized = TRUE,
                                  method = c(
                                    "cosine",
                                    "correlation",
                                    "jaccard",
                                    "ejaccard",
                                    "dice",
                                    "edice",
                                    "hamann",
                                    "simple matching",
                                    "faith"
                                  ),
                                  n = 1L) {
  if (length(key) != 1L) {
    rlang::warn("length of `key` is not 1L. the first element will be used.")
  }
  q <- unique(q[which(!q %in% key, arr.ind = TRUE)])
  n <- ifelse(n > length(q), length(q), n)
  simil <-
    as.matrix(calc_simil(con, key[1], q, normalized, method))
  ix <- sort(simil, decreasing = TRUE, index.return = TRUE)$ix
  purrr::set_names(simil[1, ix], names(simil[1, ix]))[1:n]
}
