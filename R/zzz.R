.onAttach <- function(libname,pkgname) {
    msg1 <- stringr::str_glue("Using correlationfunnel? - You might also be interested in applied business training & education:
                              > Apply Correlation Analysis, H2O Automatic Machine Learning, & LIME to a Churn Problem in our
                                Data Science For Business (DS4B 201-R) Course - www.business-science.io")

    msg2 <- stringr::str_glue("correlationfunnel tip: Make sure your data is not overly imbalanced prior to
                              using `correlate()`. If less than 5% imbalance, consider sampling. :)")

    msg3 <- stringr::str_glue("correlationfunnel tip: Clean your NA's prior to using `binarize()`. Missing values
                              and cleaning data are critical to getting great correlations. :)")

    msg <- c(msg1, msg2, msg3)[sample(1:3, size = 1)]
    packageStartupMessage(msg)
    # --as-cran check is complaining of this, as a NOTE
    #attach(NULL, name='.quantmodEnv')
}
