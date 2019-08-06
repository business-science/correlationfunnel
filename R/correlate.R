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
#' The default method is the Pearson correlation, which is the Correlation Coefficient from L. Duan et al., 2014.
#' This represents the linear relationship between two dichotomous features (binary variables).
#' Learn more about the binary correlation approach in the Vignette covering the Methodology, Key Considerations and FAQs.
#'
#'
#'
#' @references
#' Lian Duan, W. Nick Street, Yanchi Liu, Songhua Xu, and Brook Wu. 2014. Selecting the right correlation
#' measure for binary data. ACM Trans. Knowl. Discov. Data 9, 2, Article 13 (September 2014), 28 pages.
#' DOI: http://dx.doi.org/10.1145/2637484
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

    # Check missing
    if (missing(target)) stop('Error in correlate(): argument "target" is missing, with no default', call. = FALSE)

    # Check all data is numeric
    check_data_type(data,
                    classes_allowed = "numeric",
                    .fun_name = "correlate")

    # Extract target
    target_expr <- rlang::enquo(target)
    target_name <- rlang::quo_name(target_expr)
    y <- data %>% dplyr::pull(!! target_expr)

    # Check data balance
    if (is.binary(y)) check_imbalance(x = y, thresh = 0.05, .col_name = target_name, .fun_name = "correlate")

    # Correlation logic
    data_transformed_tbl <- data %>%
        stats::cor(y = y, ...) %>%
        tibble::as_tibble(rownames = "feature") %>%
        dplyr::rename(correlation = V1) %>%
        tidyr::separate(feature, into = c("feature", "bin"), sep = "__") %>%
        dplyr::filter(!is.na(correlation)) %>%
        dplyr::arrange(abs(correlation) %>% dplyr::desc()) %>%
        dplyr::mutate(feature = forcats::as_factor(feature) %>% forcats::fct_rev())

    return(data_transformed_tbl)

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
        msg2 <- paste0("[Data Imbalance Detected] Consider sampling to balance the classes more than ", scales::percent(thresh))
        msg3 <- paste0("\n  Column with imbalance: ", .col_name)

        msg  <- paste0(msg1, msg2, msg3)

        warning(msg, call. = FALSE)
    }

}
