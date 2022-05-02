#' @keywords internal
db_result_to_vec <- function(con, tbl, normalized) {
  magnitude <- dplyr::pull(tbl, .data$magnitude)
  if (!normalized) {
    tbl %>%
      dplyr::select(!.data$magnitude) %>%
      dplyr::mutate(across(
        where(is.numeric),
        ~ . * (as.double(magnitude) / as.double(10**precision(con)))
      ))
  } else {
    tbl %>%
      dplyr::select(!.data$magnitude) %>%
      dplyr::mutate(across(
        where(is.numeric),
        ~ . / as.double(10**precision(con))
      ))
  }
}
