# clean_income_variables.R
# ------------------------------------------------------------
# This script implements the methodology described in the
# "APPROCHE METHODOLOGIQUE APUREMENT DE LA VARIABLE REVENU" document.
# It performs:
#   1. Descriptive statistics (mean, min, max, percentiles, missing)
#   2. Standardisation of units (convert all amounts to a monthly basis)
#   3. Outlier detection using several statistical methods
# The script expects the configuration file `income_vars_config.R`
# (in the same folder) to define the mapping between income components
# (a‑l) and the corresponding amount and frequency variables for the
# main job (EP) and secondary job (ES).

# ---- Load libraries ------------------------------------------------
library(dplyr)
library(tidyr)
library(purrr)

# ---- Source configuration --------------------------------------------
source("income_vars_config.R")

# ---- Helper functions ------------------------------------------------
# Convert amount to monthly using the frequency multiplier
convert_to_monthly <- function(amount, freq) {
    mult <- freq_to_monthly(freq)
    amount * mult
}

# Compute descriptive statistics for a numeric vector
describe_vec <- function(x) {
    n_miss <- sum(is.na(x))
    n_total <- length(x)
    prop_miss <- n_miss / n_total
    stats <- list(
        mean = mean(x, na.rm = TRUE),
        min = min(x, na.rm = TRUE),
        max = max(x, na.rm = TRUE),
        p10 = quantile(x, 0.10, na.rm = TRUE),
        p25 = quantile(x, 0.25, na.rm = TRUE),
        p50 = quantile(x, 0.50, na.rm = TRUE),
        p75 = quantile(x, 0.75, na.rm = TRUE),
        p90 = quantile(x, 0.90, na.rm = TRUE),
        n_missing = n_miss,
        prop_missing = prop_miss
    )
    stats
}

# Outlier detection methods (return logical vector of outliers)
outlier_sd <- function(x) {
    m <- mean(x, na.rm = TRUE)
    s <- sd(x, na.rm = TRUE)
    lower <- m - 2 * s
    upper <- m + 2 * s
    x < lower | x > upper
}

outlier_zscore <- function(x) {
    m <- mean(x, na.rm = TRUE)
    s <- sd(x, na.rm = TRUE)
    z <- (x - m) / s
    abs(z) > 3
}

outlier_tukey <- function(x) {
    q1 <- quantile(x, 0.25, na.rm = TRUE)
    q3 <- quantile(x, 0.75, na.rm = TRUE)
    iqr <- q3 - q1
    lower <- q1 - 3 * iqr
    upper <- q3 + 3 * iqr
    x < lower | x > upper
}

outlier_modified_tukey <- function(x) {
    q1 <- quantile(x, 0.25, na.rm = TRUE)
    q2 <- quantile(x, 0.50, na.rm = TRUE)
    q3 <- quantile(x, 0.75, na.rm = TRUE)
    lower <- q1 - 6 * (q2 - q1)
    upper <- q3 + 6 * (q3 - q2)
    x < lower | x > upper
}

outlier_median <- function(x) {
    med <- median(x, na.rm = TRUE)
    q1 <- quantile(x, 0.25, na.rm = TRUE)
    q3 <- quantile(x, 0.75, na.rm = TRUE)
    iqr <- q3 - q1
    lower <- med - 2.3 * iqr
    upper <- med + 2.3 * iqr
    x < lower | x > upper
}

# ------------------------------------------------------------
# Main processing function
process_income <- function(df, job_prefix = c("EP", "ES")) {
    results <- list()

    for (prefix in job_prefix) {
        amount_vars <- if (prefix == "EP") EP_AMOUNT_VARS else ES_AMOUNT_VARS
        freq_vars <- if (prefix == "EP") EP_FREQUENCY_VARS else ES_FREQUENCY_VARS

        # Build a tidy data frame with component, amount, frequency
        income_tbl <- map2_dfr(names(amount_vars), amount_vars, function(comp, amt_var) {
            freq_var <- freq_vars[[comp]]
            tibble(
                component = comp,
                amount = df[[amt_var]],
                freq = df[[freq_var]]
            )
        })

        # Standardise to monthly
        income_tbl <- income_tbl %>%
            mutate(amount_monthly = convert_to_monthly(amount, freq))

        # Descriptive statistics per component
        descr <- income_tbl %>%
            group_by(component) %>%
            summarise(stats = list(describe_vec(amount_monthly)), .groups = "drop") %>%
            unnest_wider(stats)

        # Outlier flags per method
        outlier_flags <- income_tbl %>%
            group_by(component) %>%
            mutate(
                out_sd   = outlier_sd(amount_monthly),
                out_z    = outlier_zscore(amount_monthly),
                out_tuk  = outlier_tukey(amount_monthly),
                out_modt = outlier_modified_tukey(amount_monthly),
                out_med  = outlier_median(amount_monthly)
            ) %>%
            ungroup()

        results[[prefix]] <- list(
            descriptive = descr,
            outliers    = outlier_flags
        )
    }
    results
}

# ------------------------------------------------------------
# Example usage (replace `your_data` with the actual dataframe):
# load(FILE_LFS_ILO_DER_RDATA)   # loads LFS_ILO_DER
# income_results <- process_income(LFS_ILO_DER)
# Save results for later analysis
# save(income_results, file = "income_cleaning_results.RData")

# End of script
