#' @import dbplyr
#' @import RSQLite
#' @importFrom methods new
#' @importFrom rlang enquo enquos .data .env := as_name as_label
#' @importFrom stats runif
#' @keywords internal
"_PACKAGE"

#' @keywords internal
db_result_to_vec <- function(conn, tbl, normalized) {
  prec <- precision(conn)
  if (!normalized) {
    magnitude <- dplyr::pull(tbl, .data$magnitude)
    tbl |>
      dplyr::select(!"magnitude") |>
      dplyr::mutate(dplyr::across(
        dplyr::where(is.numeric),
        ~ . * (as.double(magnitude) / as.double(10**prec))
      ))
  } else {
    tbl |>
      dplyr::select(!"magnitude") |>
      dplyr::mutate(dplyr::across(
        dplyr::where(is.numeric),
        ~ . / as.double(10**prec)
      ))
  }
}
