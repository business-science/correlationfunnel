# TEST CORRELATE ----

# 1.0 SETUP ----
non_data_frame <- 1:100

set.seed(123)
bad_tbl <- tibble(
    date = seq.Date(from = ymd("2018-01-01"), ymd("2018-12-31"), by = "day"),
    n = rnorm(n = 365),
    c = rep("yes", length.out = 365),
    b = sample(c(0,1), size = 365, replace = TRUE) %>% as.logical()
)

set.seed(123)
bad_balance_tbl <- tibble(
    target = c(rep(0, 99), 1),
    x = sample(c(0, 1), size = 100, replace = TRUE)
) %>%
    binarize()

data("marketing_campaign_tbl")

marketing_binarized_tbl <- marketing_campaign_tbl %>%
    select(-ID) %>%
    binarize(n_bins = 4, thresh_infreq = 0.01, name_infreq = "MISC")

# 2.0 TESTS ----

# 2.1 Check Data & Class Types ----
test_that("Check non-data frame throws error", {
    expect_error(non_data_frame %>% correlate())
})

test_that("Test missing target", {
    expect_error({
        bad_tbl %>%
            correlate()
    })
})

test_that("Check for non-numeric columns", {
    expect_error({
        bad_tbl %>%
            correlate(n)
    })
})

test_that("Check for bad balance", {
    expect_warning({
        bad_balance_tbl %>%
            correlate(target__1)
    })
})

# 2.2 Check Correlation ----
test_that("Check correlation", {

    marketing_correlated_tbl <- marketing_binarized_tbl %>%
        correlate(TERM_DEPOSIT__yes)

    expect_equal(nrow(marketing_correlated_tbl), 74)
    expect_equal(ncol(marketing_correlated_tbl), 3)

})


