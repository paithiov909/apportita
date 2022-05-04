#' apportita: Utilities for Handling 'magnitude' Word Embeddings
#' @docType package
#' @keywords internal
"_PACKAGE"

#' @import dplyr
#' @importFrom rlang enquo enquos .data := as_name as_label
#' @importFrom utils globalVariables
utils::globalVariables("where")

#' @keywords internal
db_result_to_vec <- function(conn, tbl, normalized) {
  if (!normalized) {
    magnitude <- dplyr::pull(tbl, .data$magnitude)
    tbl %>%
      dplyr::select(!.data$magnitude) %>%
      dplyr::mutate(across(
        where(is.numeric),
        ~ . * (as.double(magnitude) / as.double(10**precision(conn)))
      ))
  } else {
    tbl %>%
      dplyr::select(!.data$magnitude) %>%
      dplyr::mutate(across(
        where(is.numeric),
        ~ . / as.double(10**precision(conn))
      ))
  }
}

#' @keywords internal
# db_query_similarity <- function(con, positive, negative,
#                                 min_similarity,
#                                 topn = 10L,
#                                 exclude_keys = NULL,
#                                 return_similarities = FALSE,
#                                 method = "distance",
#                                 effort = 1.0) {
#   NULL
# }
