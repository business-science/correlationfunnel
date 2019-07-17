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
#' marketing_campaign_tbl %>%
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

    # Check missing
    if (missing(target)) stop('Error in correlate(): argument "target" is missing, with no default', call. = FALSE)

    # Check all data is numeric
    col_types <- data %>%
        purrr::map_df(class) %>%
        tidyr::gather() %>%
        dplyr::pull(value)
    if (any(!(col_types %in% "numeric"))) stop('Error in correlate(): "data" contains non-numeric features.', call. = FALSE)

    # Correlation logic
    target_expr <- rlang::enquo(target)

    y <- data %>% dplyr::pull(!! target_expr)

    # Check data balance
    if (is.binary(y)) check_imbalance(y, thresh = 0.05, .col_name = rlang::quo_name(target_expr), .fun_name = "correlate")

    data %>%
        stats::cor(y = y, ...) %>%
        tibble::as_tibble(rownames = "feature") %>%
        dplyr::rename(correlation = V1) %>%
        tidyr::separate(feature, into = c("feature", "bin"), sep = "__") %>%
        dplyr::filter(!is.na(correlation)) %>%
        dplyr::arrange(abs(correlation) %>% dplyr::desc()) %>%
        dplyr::mutate(feature = forcats::as_factor(feature) %>% forcats::fct_rev())

}

# is.binary function - Checks if vector is binary
is.binary <- function(x) {
    unique_vals <- unique(x)

    all(unique_vals %in% c(0, 1))
}

# Check data imbalance
check_imbalance <- function(x, thresh, .col_name, .fun_name) {

    prop_x <- sum(x) / length(x)

    if (prop_x < thresh) {

        msg1 <- paste0(.fun_name, "(): ")
        msg2 <- paste0("[Data Imbalance Detected] Consider Sampling to balance the classes more than ", scales::percent(thresh))
        msg3 <- paste0("\n  Column with imbalance: ", .col_name)

        msg  <- paste0(msg1, msg2, msg3)

        warning(msg, call. = FALSE)
    }
}
