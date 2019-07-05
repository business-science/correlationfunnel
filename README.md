
<!-- README.md is generated from README.Rmd. Please edit that file -->

# correlationfunnel

[![Travis build
status](https://travis-ci.org/business-science/correlationfunnel.svg?branch=master)](https://travis-ci.org/business-science/correlationfunnel)
[![Coverage
status](https://codecov.io/gh/business-science/correlationfunnel/branch/master/graph/badge.svg)](https://codecov.io/github/business-science/correlationfunnel?branch=master)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/correlationfunnel)](https://cran.r-project.org/package=correlationfunnel)
![](http://cranlogs.r-pkg.org/badges/correlationfunnel?color=brightgreen)
![](http://cranlogs.r-pkg.org/badges/grand-total/correlationfunnel?color=brightgreen)

> Speed Up Exploratory Data Analysis (EDA)

The goal of `correlationfunnel` is to speed up Exploratory Data Analysis
(EDA). Here’s how to use it.

## Installation

You can install the released version of `correlationfunnel` from
[GitHub](https://github.com/business-science/) with:

``` r
devtools::install_github("business-science/correlationfunnel")
```

## Correlation Funnel in 2-Minutes

**Problem**: Exploratory data analysis (EDA) often involves looking at
feature-target relationships independently. The problem is that this
process of comparing feature after feature is very time consuming even
for small data sets. ***Rather than search for relationships, what if we
could let the relationships come to
us?***

<img src="man/figures/README-corr_funnel.png" width="35%" align="right" style="border-style: solid; border-width: 2px; border-color: #2c3e50; margin-left: 10px; "/>

**Solution:** Enter `correlationfunnel`. The package drastically speeds
up EDA by providing a **succinct workflow** and **interactive
visualization tools** for understanding which features have
relationships to target (response). This is excellent for pre-modeling /
pre-Machine Learning since you can determine quickly if you have
predictive features (those with relationship to the target feature).

## Example - Bank Marketing Campaign

First, load the libraries.

``` r
library(correlationfunnel)
library(dplyr)
```

Next, collect data to analyze. We’ll use Marketing Campaign Data for a
Bank that was popularized by the [UCI Machine Learning
Repository](https://archive.ics.uci.edu/ml/datasets/Bank+Marketing). We
can load the data with
`data("bank_marketing_campaign_tbl")`.

``` r
# Use ?bank_marketing_campagin_tbl to get a description of the marketing campaign features
data("bank_marketing_campaign_tbl")

bank_marketing_campaign_tbl %>% glimpse()
#> Observations: 45,211
#> Variables: 18
#> $ ID           <chr> "2836", "2837", "2838", "2839", "2840", "2841", "28…
#> $ AGE          <dbl> 58, 44, 33, 47, 33, 35, 28, 42, 58, 43, 41, 29, 53,…
#> $ JOB          <chr> "management", "technician", "entrepreneur", "blue-c…
#> $ MARITAL      <chr> "married", "single", "married", "married", "single"…
#> $ EDUCATION    <chr> "tertiary", "secondary", "secondary", "unknown", "u…
#> $ DEFAULT      <chr> "no", "no", "no", "no", "no", "no", "no", "yes", "n…
#> $ BALANCE      <dbl> 2143, 29, 2, 1506, 1, 231, 447, 2, 121, 593, 270, 3…
#> $ HOUSING      <chr> "yes", "yes", "yes", "yes", "no", "yes", "yes", "ye…
#> $ LOAN         <chr> "no", "no", "yes", "no", "no", "no", "yes", "no", "…
#> $ CONTACT      <chr> "unknown", "unknown", "unknown", "unknown", "unknow…
#> $ DAY          <dbl> 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, …
#> $ MONTH        <chr> "may", "may", "may", "may", "may", "may", "may", "m…
#> $ DURATION     <dbl> 261, 151, 76, 92, 198, 139, 217, 380, 50, 55, 222, …
#> $ CAMPAIGN     <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ PDAYS        <dbl> -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,…
#> $ PREVIOUS     <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
#> $ POUTCOME     <chr> "unknown", "unknown", "unknown", "unknown", "unknow…
#> $ TERM_DEPOSIT <chr> "no", "no", "no", "no", "no", "no", "no", "no", "no…
```

### Response & Predictor Relationships

Most modeling problems involve a response (Enrolled in `TERM_DEPOSIT`,
yes/no) and predictors (AGE, JOB, MARITAL, etc). Our job is to determine
which predictors are related to the response. We can do this through
**Binary Correlation Analysis**.

### Binary Correlation Analysis

Binary Correlation Analysis is the process of converting continuous
(numeric) and categorical (character/factor) data to binary features. We
can then perform a correlation analysis to see if there is predictive
value between the features and the response (target).

#### Step 1: Convert to Binary Format

The first step is converting the continuous and categorical data into
binary (0/1) format. We de-select any non-predictive features. The
`binarize()` function then converts the features into binary features.

``` r
bank_marketing_campaign_binarized_tbl <- bank_marketing_campaign_tbl %>%
    select(-ID) %>%
    binarize(n_bins = 4, thresh_infreq = 0.01)

bank_marketing_campaign_binarized_tbl
#> # A tibble: 45,211 x 65
#>    `AGE__-Inf_33` AGE__33_39 AGE__39_48 AGE__48_Inf JOB__admin.
#>             <dbl>      <dbl>      <dbl>       <dbl>       <dbl>
#>  1              0          0          0           1           0
#>  2              0          0          1           0           0
#>  3              1          0          0           0           0
#>  4              0          0          1           0           0
#>  5              1          0          0           0           0
#>  6              0          1          0           0           0
#>  7              1          0          0           0           0
#>  8              0          0          1           0           0
#>  9              0          0          0           1           0
#> 10              0          0          1           0           0
#> # … with 45,201 more rows, and 60 more variables: JOB__blue.collar <dbl>,
#> #   JOB__entrepreneur <dbl>, JOB__housemaid <dbl>, JOB__management <dbl>,
#> #   JOB__retired <dbl>, JOB__self.employed <dbl>, JOB__services <dbl>,
#> #   JOB__student <dbl>, JOB__technician <dbl>, JOB__unemployed <dbl>,
#> #   JOB__OTHER <dbl>, MARITAL__divorced <dbl>, MARITAL__married <dbl>,
#> #   MARITAL__single <dbl>, EDUCATION__primary <dbl>,
#> #   EDUCATION__secondary <dbl>, EDUCATION__tertiary <dbl>,
#> #   EDUCATION__unknown <dbl>, DEFAULT__no <dbl>, DEFAULT__yes <dbl>,
#> #   `BALANCE__-Inf_72` <dbl>, BALANCE__72_448 <dbl>,
#> #   BALANCE__448_1428 <dbl>, BALANCE__1428_Inf <dbl>, HOUSING__no <dbl>,
#> #   HOUSING__yes <dbl>, LOAN__no <dbl>, LOAN__yes <dbl>,
#> #   CONTACT__cellular <dbl>, CONTACT__telephone <dbl>,
#> #   CONTACT__unknown <dbl>, `DAY__-Inf_8` <dbl>, DAY__8_16 <dbl>,
#> #   DAY__16_21 <dbl>, DAY__21_Inf <dbl>, MONTH__apr <dbl>,
#> #   MONTH__aug <dbl>, MONTH__feb <dbl>, MONTH__jan <dbl>,
#> #   MONTH__jul <dbl>, MONTH__jun <dbl>, MONTH__mar <dbl>,
#> #   MONTH__may <dbl>, MONTH__nov <dbl>, MONTH__oct <dbl>,
#> #   MONTH__sep <dbl>, MONTH__OTHER <dbl>, `DURATION__-Inf_103` <dbl>,
#> #   DURATION__103_180 <dbl>, DURATION__180_319 <dbl>,
#> #   DURATION__319_Inf <dbl>, `CAMPAIGN__-Inf_2` <dbl>,
#> #   CAMPAIGN__2_3 <dbl>, CAMPAIGN__3_Inf <dbl>, POUTCOME__failure <dbl>,
#> #   POUTCOME__other <dbl>, POUTCOME__success <dbl>,
#> #   POUTCOME__unknown <dbl>, TERM_DEPOSIT__no <dbl>,
#> #   TERM_DEPOSIT__yes <dbl>
```

#### Step 2: Perform Correlation Analysis

The second step is to perform a correlation analysis between the
response (target = TERM\_DEPOSIT\_yes) and the rest of the features.
This returns a specially formatted tibble with the feature, the bin, and
the bin’s correlation to the target. The format is exactly what we need
for the next step - Producing the **Correlation
Funnel**

``` r
bank_marketing_campaign_correlated_tbl <- bank_marketing_campaign_binarized_tbl %>%
    correlate(target = TERM_DEPOSIT__yes)

bank_marketing_campaign_correlated_tbl
#> # A tibble: 65 x 3
#>    feature      bin      correlation
#>    <fct>        <chr>          <dbl>
#>  1 TERM_DEPOSIT no            -1.000
#>  2 TERM_DEPOSIT yes            1.000
#>  3 DURATION     319_Inf        0.318
#>  4 POUTCOME     success        0.307
#>  5 DURATION     -Inf_103      -0.191
#>  6 POUTCOME     unknown       -0.167
#>  7 CONTACT      unknown       -0.151
#>  8 HOUSING      no             0.139
#>  9 HOUSING      yes           -0.139
#> 10 CONTACT      cellular       0.136
#> # … with 55 more rows
```

#### Step 3: Visualize the Correlation Funnel

A **Correlation Funnel** is an tornado plot that lists the highest
correlation features (based on absolute magnitude) at the top of the and
the lowest correlation features at the bottom. The resulting
visualization looks like a Funnel.

To produce the **Correlation Funnel**, use `plot_correlation_funnel()`.
Try setting `interactive = TRUE` to get an interactive plot that can be
zoomed in on.

``` r
bank_marketing_campaign_correlated_tbl %>%
    plot_correlation_funnel(interactive = FALSE)
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

### Examining the Results

The most important features are towards the top. So we can investigate
these.

``` r
bank_marketing_campaign_correlated_tbl %>%
    filter(feature %in% c("DURATION", "POUTCOME", "CONTACT", "HOUSING")) %>%
    plot_correlation_funnel(interactive = FALSE, limits = c(-0.4, 0.4))
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

We can see that the following prospect groups have a much greater
correlation with enrollment in the TERM DEPOSIT product:

  - When the DURATION, the amount of time a prospect is engaged in
    marketing campaign material, is 319 seconds or longer.

  - When POUTCOME, whether or not a prospect has previously enrolled in
    a product, is “success”.

  - When CONTACT, the medium used to contact the person, is “cellular”

  - When HOUSING, whether or not the contact has a HOME LOAN is “no”

## Usage in the Real-World

[***Business Science***](https://www.business-science.io/) teaches
students how to apply data science for business. The entire curriculum
is crafted around business consulting with data science. **Learn from
our data science application experience with real-world business
projects.**

## Learn from Real-World Business Projects

Students learn by solving real world projects using our repeatable
project-management framework along with cutting-edge tools like the
Correlation Analysis, Automated Machine Learning, and Feature
Explanation as part of our ROI-Driven Data Science Curriculum.

  - [**Learn Data Science Foundations
    (DS4B 101-R)**](https://university.business-science.io/p/ds4b-101-r-business-analysis-r):
    Learn the entire `tidyverse` (`dplyr`, `ggplot2`, `rmarkdown`, &
    more) and `parsnip` - Solve 2 Projects - Customer Segmentation and
    Price Optimization projects

  - [**Learn Advanced Machine Learning & Business Consulting
    (DS4B 201-R)**](https://university.business-science.io/p/hr201-using-machine-learning-h2o-lime-to-predict-employee-turnover/):
    Churn Project solved with Correlation Analysis, `H2O` AutoML, `LIME`
    Feature Explanation, and ROI-driven Analysis / Recommendation
    Systems

  - [**Learn Predictive Web Application Development
    (DS4B 102-R)**](https://university.business-science.io/p/ds4b-102-r-shiny-web-application-business-level-1/):
    Build 2 Predictive `Shiny` Web Apps - Sales Dashboard with Demand
    Forecasting & Price Prediction App
