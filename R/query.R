#' Check if keys exist in a Magnitude table?
#'
#' @param conn a Magnitude connection.
#' @param keys a character vector.
#' @return a tibble.
#' @export
has_exact <- function(conn, keys) {
  vec <-
    dplyr::tbl(conn, "magnitude") %>%
    dplyr::select("key") %>%
    dplyr::filter(.data$key %in% keys) %>%
    dplyr::collect()
  tibble::tibble(
    keys = keys,
    exists = ifelse(seq_along(keys) %in% which(keys %in% dplyr::pull(vec, "key"), arr.ind = TRUE),
      TRUE,
      FALSE
    )
  )
}

#' Get vector embeddings of keys
#'
#' Get vector embeddings of keys.
#' If out of vocabulary, their embeddings would be generated at random.
#'
#' @param conn a Magnitude connection.
#' @param q a character vector.
#' @param normalized logical; whether or not vector embeddings should be normalized?
#' @param ngram_beg integer. If supplied, the function gets out-of-vocabulary vectors
#' by using character ngrams of which length are `ngram_end - ngram_beg`.
#' @param ngram_end integer.
#' @param topn integer used for making out-of-vocabulary vectors.
#' @return a tibble.
#' @export
query <- function(conn, q, normalized = TRUE,
                  ngram_beg = NULL,
                  ngram_end = NULL,
                  topn = 5L) {
  if (missing(ngram_beg)) {
    ngram_beg <- subword_start(conn)
  }
  if (missing(ngram_end)) {
    ngram_end <- subword_end(conn)
  }
  vec <-
    dplyr::tbl(conn, "magnitude") %>%
    dplyr::filter(.data$key %in% q) %>%
    dplyr::collect()

  q <- q[which(!q %in% dplyr::pull(vec, "key"), arr.ind = TRUE)]

  if (normalized && rlang::is_empty(q)) {
    db_result_to_vec(conn, vec, normalized)
  } else if (normalized && ifelse(rlang::is_empty(subword(conn)), 0, subword(conn)) > 0) {
    bow <- "\uf000"
    eow <- bow
    search_query <- paste(
      "SELECT magnitude.* FROM magnitude_subword, magnitude",
      "WHERE char_ngrams MATCH ( ? ) AND magnitude.ROWID = magnitude_subword.ROWID",
      "ORDER BY ( (LENGTH(offsets(magnitude_subword)) - LENGTH(REPLACE(offsets(magnitude_subword), ' ', ''))) + 1 ) DESC,",
      "LENGTH(magnitude.key) ASC",
      "LIMIT ?"
    )
    oov_vec <- purrr::map_dfr(q, function(key) {
      n <- ngram_end - ngram_beg
      ## FIXME: fix the way to make character ngrams
      ngrams <-
        paste0(bow, key, eow) %>%
        strsplit(split = "") %>%
        purrr::map(~ embed(., n)[, n:1]) %>%
        purrr::map_dfr(~ as.data.frame(t(.))) %>%
        dplyr::summarise(across(where(is.character), ~ paste0(., collapse = "")))
      res <-
        RSQLite::dbSendQuery(conn, search_query,
          params = list(
            paste0(ngrams[1, ], collapse = " OR "),
            as.integer(topn)
          )
        )
      similar_keys_vec <- RSQLite::dbFetch(res)
      RSQLite::dbClearResult(res)

      ## FIXME: better random vector
      if (nrow(similar_keys_vec) == 0) {
        tibble::as_tibble(
          matrix(scale(runif(1 * dim(conn)[2], -1, 1)),
            nrow = 1,
            ncol = dim(conn)[2],
            dimnames = list(1, seq_len(dim(conn)[2]) - 1)
          ),
          .name_repair = ~ paste("dim", .x, sep = "_")
        )
      } else {
        tibble::as_tibble(
          matrix(scale(runif(nrow(similar_keys_vec) * dim(conn)[2], -1, 1)),
            nrow = nrow(similar_keys_vec),
            ncol = dim(conn)[2]
          ) * .3 + dplyr::select(similar_keys_vec, !c("key", "magnitude")) * .7
        ) %>%
          dplyr::summarise(across(where(is.double), ~ mean(.)))
      }
    })
    oov_vec$key <- q
    db_result_to_vec(conn, dplyr::bind_rows(vec, oov_vec), normalized)
  } else {
    rlang::warn(
      paste(
        "some of keys may be lacking since the Magnitude file does not have subword table",
        "and `normalized` is FALSE."
      )
    )
    db_result_to_vec(conn, vec, normalized)
  }
}
