#' Plot a Correlation Funnel
#'
#' \code{plot_correlation_funnel} returns a correlation funnel visualization in either static (`ggplot2`) or
#' interactive (`plotly`) formats.
#'
#'
#' @param data A `tibble` or `data.frame`
#' @param interactive Returns either a static (`ggplot2`) visualization or an interactive (`plotly`) visualization
#' @param limits Sets the X-Axis limits for the correlation space
#' @param alpha Sets the transparency of the points on the plot.
#'
#' @return A static `ggplot2` plot or an interactive `plotly` plot
#'
#'
#' @seealso
#' [binarize()], [correlate()]
#'
#' @examples
#' library(dplyr)
#' library(correlationfunnel)
#'
#' marketing_campaign_tbl %>%
#'     select(-ID) %>%
#'     binarize() %>%
#'     correlate(TERM_DEPOSIT__yes) %>%
#'     plot_correlation_funnel()
#'
#'
#' @export
plot_correlation_funnel <- function(data,  interactive = FALSE, limits = c(-1, 1), alpha = 1) {
    UseMethod("plot_correlation_funnel", data)
}

#' @export
plot_correlation_funnel.default <- function(data,  interactive = FALSE, limits = c(-1, 1), alpha = 1) {
    stop("plot_correlation_funnel(): Object is not of class `data.frame`.", call. = FALSE)
}

#' @export
plot_correlation_funnel.data.frame <- function(data,  interactive = FALSE, limits = c(-1, 1), alpha = 1) {

    # Checks
    check_column_names(
        data,
        acceptable_column_names = c("feature", "bin", "correlation"),
        .fun_name = "plot_correlation_funnel")

    if (interactive) {

        data <- data %>%
            dplyr::mutate(label_text = stringr::str_glue("{feature}
                                         Bin: {bin}
                                         Correlation: {round(correlation, 3)}"))

        g <- data %>%
            ggplot2::ggplot(ggplot2::aes(x = correlation, y = feature, text = label_text)) +

            # Geometries
            ggplot2::geom_vline(xintercept = 0, linetype = 2, color = "red") +
            ggplot2::geom_point(color = "#2c3e50", alpha = alpha) +
            # ggrepel::geom_text_repel(ggplot2::aes(label = bin), size = 3, color = "#2c3e50") +

            # Formatting
            ggplot2::scale_x_continuous(limits = limits) +
            theme_tq() +
            ggplot2::labs(title = "Correlation Funnel")

        p <- plotly::ggplotly(g, tooltip = "text")

        return(p)

    } else {
        g <- data %>%
            ggplot2::ggplot(ggplot2::aes(x = correlation, y = feature, text = bin)) +

            # Geometries
            ggplot2::geom_vline(xintercept = 0, linetype = 2, color = "red") +
            ggplot2::geom_point(color = "#2c3e50", alpha = alpha) +
            ggrepel::geom_text_repel(ggplot2::aes(label = bin), size = 3, color = "#2c3e50") +

            # Formatting
            ggplot2::scale_x_continuous(limits = limits) +
            theme_tq() +
            ggplot2::labs(title = "Correlation Funnel")

        return(g)
    }

}

# Check column names of data
check_column_names <- function(data, acceptable_column_names, .fun_name) {

    if (any(!(names(data) %in% acceptable_column_names))) {

        msg1 <- paste0(.fun_name, "(): ")
        msg2 <- paste0("[Unnacceptable Data] Acceptable data is generated from the output of correlate().")

        msg  <- paste0(msg1, msg2)

        stop(msg, call. = FALSE)
    }
}
