# ==============================================================================
# Survey Indicators – VERSION SIMPLE avec CALCULS ANNUELS 2024
# Statistics Canada style – Quarterly AND Annual Breakdowns
# NON-PARALLÉLISÉE : Plus rapide et plus simple !
# ==============================================================================

library(survey)
library(dplyr)
library(openxlsx)
library(ggplot2)
library(scales)
library(haven)
library(tidyr)

cat("\n=== VERSION SIMPLE (NON-PARALLÉLISÉE) ===\n\n")

# Charger les données
df_original <- read_dta("data/04_weights/Base_Travail_BT_vf.dta")

# Préparer les données TRIMESTRIELLES
df_quarterly <- df_original %>% filter(!is.na(pmencor_ind) & pmencor_ind > 0)
cat("Données trimestrielles:", nrow(df_quarterly), "observations\n")

# Préparer les données ANNUELLES 2024
df_annual_2024 <- df_original %>% filter(!is.na(pmencor_ind_annuel) & pmencor_ind_annuel > 0)
cat("Données annuelles 2024:", nrow(df_annual_2024), "observations\n\n")
has_annual_data <- nrow(df_annual_2024) > 0

# Créer les designs d'enquête
options(survey.lonely.psu = "adjust")
des_quarterly <- svydesign(ids = ~1, weights = ~pmencor_ind, data = df_quarterly)
if (has_annual_data) {
  des_annual_2024 <- svydesign(ids = ~1, weights = ~pmencor_ind_annuel, data = df_annual_2024)
}

# Configuration
indicators <- c("SU1", "SU2", "SU3", "SU4")

cv_flag <- function(estimate, cv) {
  case_when(is.na(estimate) | estimate == 0 ~ "F", cv < 0.15 ~ "A", cv < 0.30 ~ "B", TRUE ~ "C")
}

quality_footnotes <- data.frame(
  Flag = c("A", "B", "C", "F"),
  Meaning = c("Reliable estimate (CV < 15%)", "Use with caution (15% ≤ CV < 30%)",
              "Unreliable estimate (CV ≥ 30%)", "Estimate suppressed or not reliable")
)

# Fonction d'estimation trimestrielle
estimate_by_quarter <- function(var, design, quarter_var = "trimestre") {
  f <- as.formula(paste0("~", var))
  n_data <- design$variables %>%
    group_by(!!sym(quarter_var)) %>%
    summarise(n_total = n(), n_valid = sum(!is.na(!!sym(var))), 
              n_missing = sum(is.na(!!sym(var))), pct_missing = round(n_missing / n_total * 100, 2), .groups = "drop")
  res <- svyby(f, as.formula(paste0("~", quarter_var)), design, svymean, vartype = c("se", "ci"), na.rm = TRUE)
  res <- as.data.frame(res)
  col_names <- names(res)
  res_renamed <- res
  names(res_renamed)[1] <- quarter_var
  names(res_renamed)[grepl(paste0("^", var, "$"), col_names)] <- "estimate"
  names(res_renamed)[grepl("^se", col_names)] <- "se"
  names(res_renamed)[grepl("^ci_l", col_names)] <- "ci_l"
  names(res_renamed)[grepl("^ci_u", col_names)] <- "ci_u"
  res_renamed %>% left_join(n_data, by = quarter_var) %>%
    mutate(indicator = var, cv = se / estimate, flag = cv_flag(estimate, cv)) %>%
    select(indicator, !!sym(quarter_var), n_total, n_valid, n_missing, pct_missing, estimate, se, ci_l, ci_u, cv, flag)
}

# Fonction d'estimation trimestrielle par strate
estimate_by_quarter_and_strata <- function(var, design, quarter_var = "trimestre", strata_var) {
  f <- as.formula(paste0("~", var))
  n_data <- design$variables %>%
    group_by(!!sym(quarter_var), !!sym(strata_var)) %>%
    summarise(n_total = n(), n_valid = sum(!is.na(!!sym(var))), 
              n_missing = sum(is.na(!!sym(var))), pct_missing = round(n_missing / n_total * 100, 2), .groups = "drop")
  res <- svyby(f, as.formula(paste0("~", quarter_var, "+", strata_var)), design, svymean, vartype = c("se", "ci"), na.rm = TRUE)
  res <- as.data.frame(res)
  col_names <- names(res)
  res_renamed <- res
  names(res_renamed)[1] <- quarter_var
  names(res_renamed)[2] <- strata_var
  names(res_renamed)[grepl(paste0("^", var, "$"), col_names)] <- "estimate"
  names(res_renamed)[grepl("^se", col_names)] <- "se"
  names(res_renamed)[grepl("^ci_l", col_names)] <- "ci_l"
  names(res_renamed)[grepl("^ci_u", col_names)] <- "ci_u"
  res_renamed %>% left_join(n_data, by = c(quarter_var, strata_var)) %>%
    mutate(indicator = var, cv = se / estimate, flag = cv_flag(estimate, cv)) %>%
    select(indicator, !!sym(quarter_var), !!sym(strata_var), n_total, n_valid, n_missing, pct_missing, estimate, se, ci_l, ci_u, cv, flag)
}

# Fonction d'estimation annuelle globale
estimate_annual_overall <- function(var, design) {
  f <- as.formula(paste0("~", var))
  n_data <- data.frame(n_total = nrow(design$variables), n_valid = sum(!is.na(design$variables[[var]])),
                       n_missing = sum(is.na(design$variables[[var]])),
                       pct_missing = round(sum(is.na(design$variables[[var]])) / nrow(design$variables) * 100, 2))
  res <- svymean(f, design = design, na.rm = TRUE)
  estimate <- as.numeric(coef(res))
  se <- as.numeric(SE(res))
  ci <- confint(res)
  data.frame(indicator = var, period = "2024_Annual", n_total = n_data$n_total, n_valid = n_data$n_valid,
             n_missing = n_data$n_missing, pct_missing = n_data$pct_missing,
             estimate = estimate, se = se, ci_l = ci[1], ci_u = ci[2], cv = se / estimate,
             flag = cv_flag(estimate, se / estimate))
}

# Fonction d'estimation annuelle par strate
estimate_annual_by_strata <- function(var, design, strata_var) {
  f <- as.formula(paste0("~", var))
  n_data <- design$variables %>%
    group_by(!!sym(strata_var)) %>%
    summarise(n_total = n(), n_valid = sum(!is.na(!!sym(var))), 
              n_missing = sum(is.na(!!sym(var))), pct_missing = round(n_missing / n_total * 100, 2), .groups = "drop")
  res <- svyby(f, as.formula(paste0("~", strata_var)), design, svymean, vartype = c("se", "ci"), na.rm = TRUE)
  res <- as.data.frame(res)
  col_names <- names(res)
  res_renamed <- res
  names(res_renamed)[1] <- strata_var
  names(res_renamed)[grepl(paste0("^", var, "$"), col_names)] <- "estimate"
  names(res_renamed)[grepl("^se", col_names)] <- "se"
  names(res_renamed)[grepl("^ci_l", col_names)] <- "ci_l"
  names(res_renamed)[grepl("^ci_u", col_names)] <- "ci_u"
  res_renamed %>% left_join(n_data, by = strata_var) %>%
    mutate(indicator = var, period = "2024_Annual", cv = se / estimate, flag = cv_flag(estimate, cv)) %>%
    select(indicator, period, !!sym(strata_var), n_total, n_valid, n_missing, pct_missing, estimate, se, ci_l, ci_u, cv, flag)
}

# ESTIMATIONS TRIMESTRIELLES
cat("=== ESTIMATIONS TRIMESTRIELLES ===\n")
cat("  National...\n")
results_quarterly_all <- bind_rows(lapply(indicators, estimate_by_quarter, design = des_quarterly)) %>%
  mutate(across(c(estimate, se, ci_l, ci_u, cv), ~round(., 4))) %>% arrange(indicator, trimestre)

cat("  Régionales...\n")
results_quarterly_region <- bind_rows(lapply(indicators, estimate_by_quarter_and_strata, design = des_quarterly, strata_var = "region")) %>%
  mutate(across(c(estimate, se, ci_l, ci_u, cv), ~round(., 4))) %>% arrange(indicator, trimestre, region)

cat("  Par district...\n")
results_quarterly_district <- bind_rows(lapply(indicators, estimate_by_quarter_and_strata, design = des_quarterly, strata_var = "District")) %>%
  mutate(across(c(estimate, se, ci_l, ci_u, cv), ~round(., 4))) %>% arrange(indicator, trimestre, District)
cat("  ✓ Terminé\n\n")

# ESTIMATIONS ANNUELLES 2024
if (has_annual_data) {
  cat("=== ESTIMATIONS ANNUELLES 2024 ===\n")
  cat("  National...\n")
  results_annual_all <- bind_rows(lapply(indicators, estimate_annual_overall, design = des_annual_2024)) %>%
    mutate(across(c(estimate, se, ci_l, ci_u, cv), ~round(., 4)))
  
  cat("  Régionales...\n")
  results_annual_region <- bind_rows(lapply(indicators, estimate_annual_by_strata, design = des_annual_2024, strata_var = "region")) %>%
    mutate(across(c(estimate, se, ci_l, ci_u, cv), ~round(., 4))) %>% arrange(indicator, region)
  
  cat("  Par district...\n")
  results_annual_district <- bind_rows(lapply(indicators, estimate_annual_by_strata, design = des_annual_2024, strata_var = "District")) %>%
    mutate(across(c(estimate, se, ci_l, ci_u, cv), ~round(., 4))) %>% arrange(indicator, District)
  cat("  ✓ Terminé\n\n")
}

# FICHIERS EXCEL
cat("=== CRÉATION DES FICHIERS EXCEL ===\n")
output_dir <- "data/08_STANDARD_ERRORS"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

headerStyle <- createStyle(fontSize = 12, fontColour = "white", fgFill = "#4F81BD",
                           halign = "center", valign = "center", textDecoration = "bold", border = "TopBottomLeftRight")
dataStyle <- createStyle(halign = "center", valign = "center", border = "TopBottomLeftRight", wrapText = TRUE)

# TRIMESTRIEL
wb_q <- createWorkbook()
addWorksheet(wb_q, "Overall_Details")
writeDataTable(wb_q, "Overall_Details", results_quarterly_all, withFilter = TRUE)

quarters <- unique(results_quarterly_region$trimestre)
for (q in quarters) {
  addWorksheet(wb_q, paste0("Region_Q", q))
  writeDataTable(wb_q, paste0("Region_Q", q), results_quarterly_region %>% filter(trimestre == q), withFilter = TRUE)
  addWorksheet(wb_q, paste0("District_Q", q))
  writeDataTable(wb_q, paste0("District_Q", q), results_quarterly_district %>% filter(trimestre == q), withFilter = TRUE)
}
saveWorkbook(wb_q, file.path(output_dir, "survey_indicators_QUARTERLY.xlsx"), overwrite = TRUE)
cat("  ✓ QUARTERLY.xlsx\n")

# ANNUEL 2024
if (has_annual_data) {
  wb_a <- createWorkbook()
  addWorksheet(wb_a, "Overall_Details")
  writeDataTable(wb_a, "Overall_Details", results_annual_all, withFilter = TRUE)
  addWorksheet(wb_a, "Regional")
  writeDataTable(wb_a, "Regional", results_annual_region, withFilter = TRUE)
  addWorksheet(wb_a, "District")
  writeDataTable(wb_a, "District", results_annual_district, withFilter = TRUE)
  saveWorkbook(wb_a, file.path(output_dir, "survey_indicators_ANNUAL_2024.xlsx"), overwrite = TRUE)
  cat("  ✓ ANNUAL_2024.xlsx\n")
}

cat("\n✅ TERMINÉ ! Fichiers dans:", output_dir, "\n\n")
message("Analyse complète avec estimations trimestrielles ET annuelles 2024 !")
