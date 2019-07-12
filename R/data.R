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
"marketing_campaign_tbl"



#' Customer Churn Data Set for a Telecommunications Company
#'
#' A dataset containing data related to telecom customers that have enrolled in various products and services
#'
#' # Telecom Customer Data:
#' - customerID (chr): CUSTOMER ID
#' - gender (chr): Customer's gender ("Female", "Male")
#' - SeniorCitizen (dbl): 1 = Senior Citzen, 0 = Not Senior Citizen
#' - Partner (chr): Whether the customer has a partner or not (Yes, No)
#' - Dependents (chr): Whether the customer has dependents or not (Yes, No)
#' - tenure (dbl): Number of months the customer has stayed with the company
#' - PhoneService (chr): Whether the customer has a phone service or not (Yes, No)
#' - MultipleLines (chr): Whether the customer has multiple lines or not (Yes, No, No phone service)
#' - InternetService (chr): Customer’s internet service provider (DSL, Fiber optic, No)
#' - OnlineSecurity (chr): Whether the customer has online security or not (Yes, No, No internet service)
#' - OnlineBackup (chr): Whether the customer has online backup or not (Yes, No, No internet service)
#' - DeviceProtection (chr): Whether the customer has device protection or not (Yes, No, No internet service)
#' - TechSupport (chr): Whether the customer has tech support or not (Yes, No, No internet service)
#' - StreamingTV (chr): Whether the customer has streaming TV or not (Yes, No, No internet service)
#' - StreamingMovies (chr): Whether the customer has streaming movies or not (Yes, No, No internet service)
#' - Contract (chr): The contract term of the customer (Month-to-month, One year, Two year)
#' - PaperlessBilling (chr): Whether the customer has paperless billing or not (Yes, No)
#' - PaymentMethod (chr): The customer’s payment method (Electronic check, Mailed check, Bank transfer (automatic), Credit card (automatic))
#' - MonthlyCharges (dbl): The amount charged to the customer monthly
#' - TotalCharges (dbl): The total amount charged to the customer
#' - Churn (chr): Outcome. Whether the customer churned or not (Yes or No)
#'
#' @source
#' [IBM Sample Datasets](https://community.ibm.com/community/user/gettingstarted/home)
"customer_churn_tbl"
