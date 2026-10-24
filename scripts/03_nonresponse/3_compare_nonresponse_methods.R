# ==============================================================================
# Script_name : 3_compare_nonresponse_methods.R
# Title       : Compare the two non-response methods after calibration
# Description : From T1 2026, the production file calibrated_weights/
#               individu_<quarter>_CAL.dta holds FINAL_WEIGHT (modelled
#               non-response, production) and FINAL_WEIGHT_cellules (historical
#               cell adjustment, same calibration). This script compares the
#               weight share by interview rank and the weight dispersion.
#               Nothing is recalibrated here. The indicators under both weights
#               are computed in ENE_INDICATORS_TABULATIONS from the weighted base
#               published on MinIO (gold/enem/<quarter>/base_ponderee/).
#               Writes base_weights/nr_comparaison_*_<quarter>.csv, published
#               with the weights by "python scripts/medallion/medallion.py upload-outputs".
# Usage       : Rscript scripts/03_nonresponse/3_compare_nonresponse_methods.R [--quarter=T1_2026]
# ==============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(haven)
})

source("config/1_config.r")

args <- commandArgs(trailingOnly = TRUE)
quarter <- TARGET_QUARTER
for (arg in args) {
  if (grepl("^--quarter=", arg)) quarter <- sub("^--quarter=", "", arg)
  else stop("Option inconnue : ", arg, call. = FALSE)
}

W_DIR <- "data/04_weights"
BW_DIR <- file.path(W_DIR, quarter, "base_weights")
out_path <- function(name) file.path(BW_DIR, paste0("nr_comparaison_", name, "_", quarter, ".csv"))

cal_path <- file.path(W_DIR, quarter, "calibrated_weights", paste0("individu_", quarter, "_CAL.dta"))
weights <- haven::read_dta(cal_path, col_select = any_of(c(
  "interview_key", "membres_id", "rang", "FINAL_WEIGHT", "FINAL_WEIGHT_cellules"
))) %>%
  mutate(across(everything(), haven::zap_labels))
if (!"FINAL_WEIGHT_cellules" %in% names(weights)) {
  stop("FINAL_WEIGHT_cellules absent de ", cal_path,
       " : relancer 2_attrition_propensity.R puis le master de calage.", call. = FALSE)
}

methods <- c(modele = "FINAL_WEIGHT", cellules = "FINAL_WEIGHT_cellules")

by_rank <- weights %>% group_by(rang) %>%
  summarise(n = n(), across(all_of(unname(methods)), sum), .groups = "drop") %>%
  mutate(across(all_of(unname(methods)), ~ 100 * .x / sum(.x), .names = "part_{.col}"))
write.csv(by_rank, out_path("poids_par_rang"), row.names = FALSE, fileEncoding = "UTF-8")

weight_stats <- sapply(methods, function(v) {
  w <- weights[[v]]
  c(min = min(w), p50 = median(w), p99 = unname(quantile(w, 0.99)), max = max(w),
    cv = sd(w) / mean(w), kish_deff = 1 + (sd(w) / mean(w))^2)
})
write.csv(as.data.frame(weight_stats), out_path("dispersion"), fileEncoding = "UTF-8")

cat("\n== Poids calibrés par rang (%) ==\n"); print(as.data.frame(by_rank), digits = 3)
cat("\n== Dispersion des poids calibrés ==\n"); print(weight_stats, digits = 3)
