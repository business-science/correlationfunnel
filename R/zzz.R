.onAttach <- function(libname,pkgname) {

    bsu_rule_color <- "#2c3e50"
    bsu_main_color <- "#1f78b4"

    # Check Theme: If Dark, Update Colors
    if (rstudioapi::isAvailable()) {
        theme <- rstudioapi::getThemeInfo()
        if (theme$dark) {
            bsu_rule_color <- "#7FD2FF"
            bsu_main_color <- "#18bc9c"
        }
    }

    bsu_main <- crayon::make_style(bsu_main_color)

    msg1 <- paste0(
        cli::rule(left = "Using correlationfunnel?", col = bsu_rule_color, line = 2),
        bsu_main('\nYou might also be interested in applied data science training for business.\n'),
        bsu_main('</> Learn more at - www.business-science.io </>')
    )

    msg2 <- paste0(
        cli::rule(left = "correlationfunnel Tip #1", col = bsu_rule_color, line = 2),
        bsu_main('\nMake sure your data is not overly imbalanced prior to using `correlate()`.\nIf less than 5% imbalance, consider sampling. :)')
    )

    msg3 <- paste0(
        cli::rule(left = "correlationfunnel Tip #2", col = bsu_rule_color, line = 2),
        bsu_main("\nClean your NA's prior to using `binarize()`.\nMissing values and cleaning data are critical to getting great correlations. :)")
    )

    msg4 <- paste0(
        cli::rule(left = "correlationfunnel Tip #3", col = bsu_rule_color, line = 2),
        bsu_main("\nUsing `binarize()` with data containing many columns or many rows can increase dimensionality substantially.\nTry subsetting your data column-wise or row-wise to avoid creating too many columns.\nYou can always make a big problem smaller by sampling. :)")
    )

    msg <- c(msg1, msg1, msg2, msg3, msg4)[sample(1:5, size = 1)]
    packageStartupMessage(msg)

}
