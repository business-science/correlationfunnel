#' Correlate a response (target) to features in a data set.
#'
#' \code{correlate} returns a correlation between a target column and the features in a data set.
#'
#'
#' @param data A `tibble` or `data.frame`
#' @param target The feature that contains the response (Target) that you want to measure relationship.
#' @param ... Other arguments passed to \link[stats]{cor}
#'
#' @return A `tbl`
#'
#' @details
#' The `correlate()` function provides a convient wrapper around the \link[stats]{cor} function where the `target`
#' is the column containing the Y variable. The function is intended to be used with [`binarize()`], which enables
#' creation of the binary correlation analysis, which is the feed data for the [`plot_correlation_funnel()`] visualization.
#'
#' @seealso
#' [binarize()], [plot_correlation_funnel()]
#'
#' @examples
#' library(dplyr)
#' library(correlationfunnel)
#'
#' bank_marketing_campaign_tbl %>%
#'     select(-ID) %>%
#'     binarize() %>%
#'     correlate(TERM_DEPOSIT__yes)
#'
#'
#' @importFrom rlang !!
#'
#' @export
correlate <- function(data, target, ...) {
    UseMethod("correlate", data)
}

#' @export
correlate.default <- function(data, target, ...) {
    stop("Error correlate(): Object is not of class `data.frame`.", call. = FALSE)
}

#' @export
correlate.data.frame <- function(data, target, ...) {

    # Checks
    if (missing(target)) stop('Error in correlate(): argument "target" is missing, with no default', call. = FALSE)

    target_expr <- rlang::enquo(target)

    y <- data %>% dplyr::pull(!! target_expr)

    data %>%
        stats::cor(y = y, ...) %>%
        tibble::as_tibble(rownames = "feature") %>%
        dplyr::rename(correlation = V1) %>%
        tidyr::separate(feature, into = c("feature", "bin"), sep = "__") %>%
        dplyr::filter(!is.na(correlation)) %>%
        dplyr::arrange(abs(correlation) %>% dplyr::desc()) %>%
        dplyr::mutate(feature = forcats::as_factor(feature) %>% forcats::fct_rev())

}
