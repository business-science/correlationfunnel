.onAttach <- function(libname,pkgname) {
    msg <- stringr::str_glue("Using correlationfunnel? - You might also be interested in applied business training & education:
                              > Apply Correlation Analysis, H2O Automatic Machine Learning, & LIME to a Churn Problem in
                                Business Science's Data Science For Business (DS4B 201-R) Course - www.business-science.io")
    packageStartupMessage(msg)
    # --as-cran check is complaining of this, as a NOTE
    #attach(NULL, name='.quantmodEnv')
}
