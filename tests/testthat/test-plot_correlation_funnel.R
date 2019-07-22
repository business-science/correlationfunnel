# TEST PLOT_CORRELATION_FUNNEL ----

# 1.0 SETUP ----
non_data_frame <- 1:100

set.seed(123)
bad_tbl <- tibble(
    date = seq.Date(from = ymd("2018-01-01"), ymd("2018-12-31"), by = "day"),
    n = rnorm(n = 365),
    c = rep("yes", length.out = 365),
    b = sample(c(0,1), size = 365, replace = TRUE) %>% as.logical()
)

data("marketing_campaign_tbl")

marketing_correlated_tbl <- marketing_campaign_tbl %>%
    select(-ID) %>%
    binarize(n_bins = 4, thresh_infreq = 0.01, name_infreq = "MISC") %>%
    correlate(TERM_DEPOSIT__yes)

g <- plot_correlation_funnel(marketing_correlated_tbl)

p <- plot_correlation_funnel(marketing_correlated_tbl, interactive = TRUE)

# 2.0 TESTS ----

# 2.1 Check Data & Class Types ----
test_that("Check non-data frame throws error", {
    expect_error(non_data_frame %>%  plot_correlation_funnel())
})

test_that("Check bad column names", {
    expect_error(bad_tbl %>% plot_correlation_funnel())
})

# 2.2 Check output of plot_correlation_funnel()
test_that("Check ggplot", {
    expect_true(any(class(g) %in% "ggplot"))
})

test_that("Check plotly", {
    expect_true(any(class(p) %in% "plotly"))
})
