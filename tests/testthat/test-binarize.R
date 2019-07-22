# TEST BINARIZE ----

# 1.0 SETUP ----
non_data_frame <- 1:100

set.seed(123)
bad_tbl <- tibble(
    date = seq.Date(from = ymd("2018-01-01"), ymd("2018-12-31"), by = "day"),
    n = rnorm(n = 365),
    c = rep("yes", length.out = 365),
    b = sample(c(0,1), size = 365, replace = TRUE) %>% as.logical()
)

data("customer_churn_tbl")

data("marketing_campaign_tbl")

# 2.0 TESTS ----

# 2.1 Check Data Type ----
test_that("Check non-data frame throws error", {
    expect_error(non_data_frame %>% binarize())
})

test_that("Check data types", {

    expect_error({
        bad_tbl %>%
            binarize()
    })

})

# 2.2 Check missing data ----
test_that("Check missing data", {

    expect_error({
        customer_churn_tbl %>%
            binarize()
    })

})

# 2.3 Check Numeric Binarization ----
test_that("Check binarize - numeric", {

    AGE_bin4_tbl <- marketing_campaign_tbl %>% select(AGE) %>% binarize(n_bins = 4)
    expect_equal(ncol(AGE_bin4_tbl), 4)

    AGE_bin5_tbl <- marketing_campaign_tbl %>% select(AGE) %>% binarize(n_bins = 5)
    expect_equal(ncol(AGE_bin5_tbl), 5)

})

test_that("Check binarize - numeric - high skew", {

    PDAYS_bin5_tbl <- marketing_campaign_tbl %>% select(PDAYS) %>% binarize(n_bins = 5)
    expect_equal(ncol(PDAYS_bin5_tbl), 2)

    PREVIOUS_thresh_infreq_0_tbl <- marketing_campaign_tbl %>% select(PREVIOUS) %>% binarize(thresh_infreq = 0)
    expect_equal(ncol(PREVIOUS_thresh_infreq_0_tbl), 41)

})

# 2.4 Check Categorical Binarization ----
test_that("Check binarize - categorical", {

    JOB_thresh_infreq_0_tbl <- marketing_campaign_tbl %>% select(JOB) %>% binarize(thresh_infreq = 0, name_infreq = "MISC")
    expect_equal(ncol(JOB_thresh_infreq_0_tbl), 12)
    expect_false(names(JOB_thresh_infreq_0_tbl) %>% str_detect("MISC") %>% any()) # Should not contain a miscellaneous column

    JOB_thresh_infreq_0.1_tbl <- marketing_campaign_tbl %>% select(JOB) %>% binarize(thresh_infreq = 0.1, name_infreq = "MISC")
    expect_equal(ncol(JOB_thresh_infreq_0.1_tbl), 5)
    expect_true(names(JOB_thresh_infreq_0.1_tbl) %>% str_detect("MISC") %>% any()) # Should contain a miscellaneous column

})


