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

#' Calculates the distance from keys to the keys in q
#'
#' @param con A Magnitude connection.
#' @param key Character vector.
#' @param q Character vector.
#' @param normalized Logical.
#' @param mehtod String; method to compute distance.
#' @param ... Other arguments are passed to \code{proxyC::dist}.
#' @return A sparse Matrix of 'Matrix' package.
#' @export
query_dist <- function(con, key, q, normalized = TRUE,
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
  key <- query(con, key, normalized)
  q <- query(con, q, normalized)
  proxyC::dist(
    as.matrix(dplyr::select(key, starts_with("dim"))),
    as.matrix(dplyr::select(q, starts_with("dim"))),
    method = method,
    ...
  )
}

#' Find the farest key out of q
#'
#' Given a set of keys, figures out which key doesn't match the rest.
#'
#' @param con A Magnitude connection.
#' @param key String.
#' @param q Character vector.
#' @param normalized Logical.
#' @param method String; method to compute distance.
#' @param n Integer.
#' @return A named numeric vector of which elements represent distances to `key`.
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
  ## FIXME: removing q that exact same in key
  ## since proxyC returns shuffled results when y contains a same matrix with x.
  q <- q[which(!q %in% key, arr.ind = TRUE)]
  n <- ifelse(n > length(q), length(q), n)

  dist <-
    as.matrix(query_dist(con, key[1], q, normalized, method)) %>%
    t() %>%
    as.data.frame()
  dist$q <- q

  dist %>%
    dplyr::slice_max(.data$V1, n = n, with_ties = TRUE) %>%
    (function(x) {
      purrr::set_names(x$V1, x$q)
    })()
}

#' Calculate the similarity from keys to the keys in q
#'
#' @param con A Magnitude connection.
#' @param key Character vector.
#' @param q Character vector.
#' @param normalized Logical.
#' @param mehtod String; method to compute similarity.
#' @param ... Other arguments are passed to \code{proxyC::simil}.
#' @return A sparse Matrix of 'Matrix' package.
#' @export
query_simil <- function(con, key, q, normalized = TRUE,
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
  key <- query(con, key, normalized)
  q <- query(con, q, normalized)
  proxyC::simil(
    as.matrix(dplyr::select(key, starts_with("dim"))),
    as.matrix(dplyr::select(q, starts_with("dim"))),
    method = method,
    ...
  )
}

#' Find the most similar key out of q
#'
#' Query for the most similar key out of a list of keys
#' to a given key like so.
#'
#' @param con A Magnitude connection.
#' @param key String.
#' @param q Character vector.
#' @param normalized Logical.
#' @param mehtod String; method to compute similarity.
#' @param n Integer.
#' @return A named numeric vector of which elements represent similarities to `key`.
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
  ## FIXME: removing q that exact same in key
  ## since proxyC returns shuffled results when y contains a same matrix with x.
  q <- q[which(!q %in% key, arr.ind = TRUE)]
  n <- ifelse(n > length(q), length(q), n)

  simil <-
    as.matrix(query_simil(con, key[1], q, normalized, method)) %>%
    t() %>%
    as.data.frame()
  simil$q <- q

  simil %>%
    dplyr::slice_max(.data$V1, n = n, with_ties = TRUE) %>%
    (function(x) {
      purrr::set_names(x$V1, x$q)
    })()
}
