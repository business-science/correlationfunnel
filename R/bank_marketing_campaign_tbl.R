#' Marketing Data for a Bank
#'
#' A dataset containing data related to bank clients, last contact of the current marketing campaign, and attributes related to a
#' previous marketing campaign.
#'
#' # Bank Client Data:
#' - ID (chr): CUSTOMER ID
#' - AGE (dbl): Customer's age
#' - JOB (chr): Type of job (categorical: "admin.","unknown","unemployed","management","housemaid","entrepreneur","student", "blue-collar","self-employed","retired","technician","services")
#' - MARITAL (chr): marital status (categorical: "married","divorced","single"; note: "divorced" means divorced or widowed)
#' - EDUCATION (chr): categorical: "unknown","secondary","primary","tertiary"
#' - DEFAULT (chr): Has credit in default? (binary: "yes","no")
#' - BALANCE (dbl): Average yearly balance, in euros (numeric)
#' - HOUSING (chr): Has housing loan? (binary: "yes","no")
#' - LOAN (chr): Has personal loan? (binary: "yes","no")
#'
#' # Features related to the last contact during the current marketing campaign:
#' - CONTACT (chr): Contact communication type (categorical: "unknown","telephone","cellular")
#' - DAY (dbl): Last contact day of the month (numeric)
#' - MONTH (chr): Last contact month of year (categorical: "jan", "feb", "mar", ..., "nov", "dec")
#' - DURATION (dbl): Last contact duration, in seconds (numeric)
#'
#' # Additional Attributes:
#' - CAMPAIGN (dbl): Number of contacts performed during this campaign and for this client (numeric, includes last contact)
#' - PDAYS (dbl): Number of days that passed by after the client was last contacted from a previous campaign (numeric, -1 means client was not previously contacted)
#' - PREVIOUS (dbl): Number of contacts performed before this campaign and for this client (numeric)
#' - POUTCOME (chr): Outcome of the previous marketing campaign (categorical: "unknown","other","failure","success")
#'
#' # Target Variable (Response):
#' - TERM_DEPOSIT (chr): Has the client subscribed a term deposit? (binary: "yes","no")
#'
#' @source
#' [Moro et al., 2014](https://archive.ics.uci.edu/ml/datasets/Bank+Marketing) S. Moro, P. Cortez and P. Rita. A Data-Driven Approach to Predict the Success of Bank Telemarketing. Decision Support Systems, Elsevier, 62:22-31, June 2014
"bank_marketing_campaign_tbl"
