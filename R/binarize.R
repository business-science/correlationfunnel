#' Turn data with numeric, categorical features into binary data.
#'
#' \code{binarize} returns the binary data coverted from data in normal (numeric and categorical) format.
#'
#'
#' @param data A `tibble` or `data.frame`
#' @param n_bins The number of bins to for converting continuous (numeric features) into discrete features (bins)
#' @param thresh_infreq The threshold for converting categorical (character or factor features) into an "Other" Category.
#' @param name_infreq The name for infrequently appearing categories to be lumped into. Set to "-OTHER" by default.
#' @param one_hot If set to `TRUE`, binarization returns number of new columns = number of levels.
#' If `FALSE`, binarization returns number of new columns = number of levels - 1 (dummy encoding).
#'
#' @return A `tbl`
#'
#' @details
#' ## The Goal
#' The binned format helps correlation analysis to identify non-linear trends between a predictor (binned values) and a
#' response (the target)
#'
#' ## What Binarize Does
#' The `binarize()` function takes data in a "normal" format and converts to a binary format that is useful as a preparation
#' step before using [`correlate()`]:
#'
#' __Numeric Features__:
#' The "Normal Data" format has numeric features that are continuous values in numeric format (`double` or `integer`).
#' The `binarize()` function converts these to bins (categories) and then discretizes the bins using a one-hot encoding process.
#'
#' __Categorical Features__:
#' The "Normal Data" format has categorical features that are `character` or `factor` format.
#' The `binarize()` function converts these to binary features using a one-hot encoding process.
#'
#' @examples
#' library(dplyr)
#' library(correlationfunnel)
#'
#' marketing_campaign_tbl %>%
#'     select(-ID) %>%
#'     binarize()
#'
#'
#' @importFrom recipes "all_nominal" "all_numeric" "all_predictors"
#'
#' @export
binarize <- function(data, n_bins = 4, thresh_infreq = 0.01, name_infreq = "-OTHER", one_hot = TRUE) {
    UseMethod("binarize", data)
}

#' @export
binarize.default <- function(data, n_bins = 4, thresh_infreq = 0.01, name_infreq = "-OTHER", one_hot = TRUE) {
    stop("Error binarize(): Object is not of class `data.frame`.", call. = FALSE)
}

#' @export
binarize.data.frame <- function(data, n_bins = 4, thresh_infreq = 0.01, name_infreq = "-OTHER", one_hot = TRUE) {

    # CHECKS ----

    # Check data is charater, factor, or numeric
    check_data_type(data,
                    classes_allowed = c("numeric", "character", "factor", "ordered"),
                    .fun_name = "binarize")

    # Check missing
    check_missing(data, .fun_name = "binarize")

    # FIXES ----

    # # Find & Isolate Binary Data
    # binary_split <- split_binary(data)
    # data <- binary_split[["not_binary_data"]]
    # data_binary <- binary_split[["binary_data"]]

    # NON-BINARY DATA ----
    if (ncol(data) > 0) {

        # Check & fix numeric factors
        #  - Numeric values with low cardinality (few unique) treated as categorical
        data <- fix_low_cardinality_numeric(data, thresh = n_bins + 3)

        # Check & fix skewed data
        # - Highly skewed data with quantile values of 4 of 5 are same
        #   will be converted to factor
        data <- fix_high_skew_numeric_data(data, n_bins = n_bins, unique_limit = 2)

        # TRANSFORMATION STEPS ----
        recipe_obj <- create_recipe(
            data          = data,
            n_bins        = n_bins,
            thresh_infreq = thresh_infreq,
            name_infreq   = name_infreq,
            one_hot       = one_hot)

        data_transformed_tbl <- data %>%
            recipes::bake(recipe_obj, new_data = .)

        # HANDLE COLUMN NAMES ----
        num_count <- data %>% purrr::map_lgl(is.numeric) %>% sum()
        if (num_count > 0) {
            data_transformed_tbl <- handle_binned_names(
                data   = data_transformed_tbl,
                recipe = recipe_obj)
        }

        data <- data_transformed_tbl
    }

    ## RECOMBINE ----
    #data <- dplyr::bind_cols(data_binary, data)

    return(data)

}


# SUPPORTING FUNCTIONS -----

# Checks for missing values
check_data_type <- function(data, classes_allowed = c("numeric", "character", "factor", "ordered"), .fun_name = NULL) {

    class_summary_tbl <- data %>%
        purrr::map_df(~ class(.)[[1]]) %>%
        tidyr::gather(key = "feature", value = "class") %>%
        dplyr::mutate(unacceptable_class = !(class %in% classes_allowed))

    if (sum(class_summary_tbl$unacceptable_class) > 0) {
        columns_with_unnacceptable_classes <- class_summary_tbl %>%
            dplyr::filter(unacceptable_class > 0) %>%
            dplyr::pull(feature)

        msg1 <- paste0(.fun_name, "(): ")
        if (.fun_name == "binarize") {
            bad_types <- "non-numeric or non-categorical"
        } else if (.fun_name == "correlate") {
            bad_types <- "non-numeric"
        } else {
            bad_types <- "bad"
        }
        msg2 <- stringr::str_glue("[Unnacceptable Columns Detected] The following columns contain {bad_types} data types: ")
        msg3 <- paste0(columns_with_unnacceptable_classes, collapse = ", ")

        msg  <- paste0(msg1, msg2, msg3)

        stop(msg, call. = FALSE)
    }

}

# Checks for missing values
check_missing <- function(data, .fun_name = NULL) {

    missing_summary_tbl <- data %>%
        purrr::map_df(~ sum(is.na(.))) %>%
        tidyr::gather(key = "feature", value = "count_na") %>%
        dplyr::arrange(dplyr::desc(count_na))

    if (sum(missing_summary_tbl$count_na) > 0) {
        columns_with_na_values <- missing_summary_tbl %>%
            dplyr::filter(count_na > 0) %>%
            dplyr::pull(feature)

        msg1 <- paste0(.fun_name, "(): ")
        msg2 <- "[Missing Values Detected] The following columns contain NAs: "
        msg3 <- paste0(columns_with_na_values, collapse = ", ")

        msg  <- paste0(msg1, msg2, msg3)

        stop(msg, call. = FALSE)
    }

}

# Checks and isolates any binary data
# split_binary <- function(data){
#
#     # Format logical data as numeric
#     data <- data %>%
#         dplyr::mutate_if(is.logical, as.numeric)
#
#     binary_data <- data %>%
#         dplyr::select_if(is.binary)
#
#     not_binary_data <- data %>%
#         dplyr::select_if(~ !is.binary(.))
#
#     return(list("binary_data" = binary_data, "not_binary_data" = not_binary_data))
#
# }

# Checks & Fixes Numeric Data that Should be factor (categorical)
fix_low_cardinality_numeric <- function(data, thresh = 6, .fun_name = NULL) {

    num_class <- data %>% purrr::map_lgl(is.numeric)

    if (any(num_class)) {

        numeric_check_tbl <- data %>%
            dplyr::select_if(is.numeric) %>%
            dplyr::summarise_all(~ length(unique(.))) %>%
            tidyr::gather() %>%
            dplyr::arrange(dplyr::desc(value)) %>%
            dplyr::mutate(check = dplyr::case_when(
                value == 1 ~ "Zero Variance",
                value < thresh ~ "Possible Factor",
                TRUE ~ "Pass"
            ))

        cols_num_to_factor <- numeric_check_tbl %>%
            dplyr::filter(check == "Possible Factor") %>%
            dplyr::pull(key)

        if (length(cols_num_to_factor) > 0) {
            data <- data %>%
                dplyr::mutate_at(.vars = dplyr::vars(cols_num_to_factor), .funs = as.factor)
        }

    }

    return(data)
}

# Checks and fixes numeric data with high skew
fix_high_skew_numeric_data <- function(data, n_bins, unique_limit) {

    num_class <- data %>% purrr::map_lgl(is.numeric)

    if (any(num_class)) {

        # Inspect feature distributions
        column_quantiles_tbl <- data %>%
            dplyr::select_if(is.numeric) %>%
            purrr::map_df(stats::quantile)

        # Count unique quantiles
        column_unique_count_tbl <- column_quantiles_tbl %>%
            purrr::map_df(~ length(unique(.))) %>%
            tidyr::gather(key = "feature", value = "count_unique_quantile")

        # If less than three, convert to factor
        cols_num_to_factor <- column_unique_count_tbl %>%
            dplyr::filter(count_unique_quantile <= unique_limit) %>%
            dplyr::pull(feature)

        if (length(cols_num_to_factor) > 0) {

            data <- data %>%
                dplyr::mutate_at(.vars = dplyr::vars(cols_num_to_factor), .funs = ~ as.factor(.))
        }

    }

    return(data)

}

create_recipe <- function(data, n_bins, thresh_infreq, name_infreq, one_hot) {

    # Compute Binary Data
    num_count <- data %>% purrr::map_lgl(is.numeric) %>% sum()
    cat_count <- (data %>% purrr::map_lgl(is.character) %>% sum()) +
        (data %>% purrr::map_lgl(is.factor) %>% sum())

    # Remove zero variance variables
    recipe_obj <- recipes::recipe(~ ., data = data) %>%
        recipes::step_zv(all_predictors())

    # Reduce cardinality of infrequent categorical levels
    if (cat_count > 0) {
        if (thresh_infreq == 0) thresh_infreq <- 1e-9 # Resolves error on thresh_infreq = 0
        recipe_obj <- recipe_obj %>%
            recipes::step_other(
                all_nominal(),
                threshold = thresh_infreq,
                other     = name_infreq)
    }

    # Convert continuous features to binned features
    if (num_count > 0) {
        recipe_obj <- recipe_obj %>%
            recipes::step_discretize(
                all_numeric(),
                options = list(
                    cuts = n_bins,
                    min_unique = 1)
            )
    }

    # Convert categorical and binned features to binary features
    name_system <- function(var, lvl, ordinal = FALSE, sep = "__") {
        if (!ordinal) {
            lvl <- lvl %>%
                stringr::str_trim() %>%
                stringr::str_replace_all(" ", "_")
            nms <- paste(var, lvl, sep = sep)
        } else {
            nms <- paste0(var, recipes::names0(length(lvl), sep))
            }
        nms
    }
    recipe_obj <- recipe_obj %>%
        recipes::step_dummy(
            all_nominal(),
            one_hot = one_hot,
            # naming  = purrr::partial(recipes::dummy_names, sep = "__")
            naming = name_system
            ) %>%

        # Drop any features that have no variance
        recipes::step_zv(all_predictors())

    suppressWarnings(recipe_obj <- recipes::prep(recipe_obj))

    return(recipe_obj)

}

# Handle Numeric Bin Names
handle_binned_names <- function(data, recipe) {

    suppressWarnings({

        bin_labels_tbl <- recipes::tidy(recipe) %>%
            dplyr::filter(type == "discretize") %>%
            dplyr::pull(number) %>%

            # Get binary name labels
            recipes::tidy(recipe, .) %>%
            dplyr::group_by(terms) %>%
            dplyr::mutate(value_lead = dplyr::lead(value, n = 1)) %>%
            dplyr::slice(-dplyr::n()) %>%

            dplyr::mutate(bin_label = stringr::str_glue("{value}_{value_lead}")) %>%
            dplyr::select(-id, -dplyr::contains("value")) %>%
            dplyr::mutate(bin = 1:(dplyr::n()) ) %>%
            dplyr::mutate(label_current = stringr::str_glue("{terms}__bin{bin}")) %>%
            dplyr::mutate(label_new = stringr::str_glue("{terms}__{bin_label}"))

        new_names_tbl <- tibble::tibble(label_current = names(data)) %>%
            dplyr::left_join(bin_labels_tbl, by = "label_current") %>%
            dplyr::mutate(label_new = dplyr::case_when(
                is.na(label_new) ~ label_current,
                TRUE ~ label_new)) %>%
            dplyr::select(label_current, label_new)

        names(data) <- new_names_tbl$label_new

    })

    return(data)
}


