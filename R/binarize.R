#' Turn data with numeric, categorical features into binary data.
#'
#' \code{binarize} returns the binary data coverted from data in normal (numeric and categorical) format.
#'
#'
#' @param data A `tibble` or `data.frame`
#' @param n_bins The number of bins to for converting continuous (numeric features) into discrete features (bins)
#' @param thresh_infreq The threshold for converting categorical (character or factor features) into an "Other" Category.
#' @param name_infreq The name for infrequently appearing categories to be lumped into. Set to "OTHER" by default.
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
#' bank_marketing_campaign_tbl %>%
#'     select(-ID) %>%
#'     binarize()
#'
#'
#' @importFrom recipes "all_nominal" "all_numeric" "all_predictors"
#'
#' @export
binarize <- function(data, n_bins = 4, thresh_infreq = 0.01, name_infreq = "OTHER") {
    UseMethod("binarize", data)
}

#' @export
binarize.default <- function(data, n_bins = 4, thresh_infreq = 0.01, name_infreq = "OTHER") {
    stop("Error binarize(): Object is not of class `data.frame`.", call. = FALSE)
}

#' @export
binarize.data.frame <- function(data, n_bins = 4, thresh_infreq = 0.01, name_infreq = "OTHER") {

    suppressWarnings({

        # Compute Binary Data
        recipe_obj <- recipes::recipe(~ ., data = data) %>%
            # Remove zero variance variables
            recipes::step_zv(all_predictors()) %>%

            # Reduce cardinality of infrequent categorical levels
            recipes::step_other(
                all_nominal(),
                threshold = thresh_infreq,
                other     = name_infreq) %>%

            # Convert continuous features to binned features
            recipes::step_discretize(
                all_numeric(),
                options = list(
                    cuts = n_bins,
                    min_unique = 1)
            ) %>%

            # Convert categorical and binned features to binary features
            recipes::step_dummy(
                all_nominal(),
                one_hot = TRUE,
                naming  = purrr::partial(recipes::dummy_names, sep = "__")) %>%

            # Drop any features that have no variance
            recipes::step_zv(all_predictors()) %>%
            recipes::prep()

        data_transformed_tbl <- data %>%
            recipes::bake(recipe_obj, new_data = .)

        # Handle Names
        bin_labels_tbl <- recipes::tidy(recipe_obj) %>%
            dplyr::filter(type == "discretize") %>%
            dplyr::pull(number) %>%

            # Get binary name labels
            recipes::tidy(recipe_obj, .) %>%
            dplyr::group_by(terms) %>%
            dplyr::mutate(value_lead = dplyr::lead(value, n = 1)) %>%
            dplyr::slice(-dplyr::n()) %>%

            dplyr::mutate(bin_label = stringr::str_glue("{value}_{value_lead}")) %>%
            dplyr::select(-id, -dplyr::contains("value")) %>%
            dplyr::mutate(bin = 1:(dplyr::n()) ) %>%
            dplyr::mutate(label_current = stringr::str_glue("{terms}__bin{bin}")) %>%
            dplyr::mutate(label_new = stringr::str_glue("{terms}__{bin_label}"))

        new_names_tbl <- tibble::tibble(label_current = names(data_transformed_tbl)) %>%
            dplyr::left_join(bin_labels_tbl, by = "label_current") %>%
            dplyr::mutate(label_new = dplyr::case_when(
                is.na(label_new) ~ label_current,
                TRUE ~ label_new)) %>%
            dplyr::select(label_current, label_new)

        names(data_transformed_tbl) <- new_names_tbl$label_new
    })

    return(data_transformed_tbl)

}
