# ==============================================================================
# Libraries
# ==============================================================================
library(dplyr)
library(haven)
library(labelled)
library(readxl)
library(tibble)

# ==============================================================================
# Paths and Parameters
# ==============================================================================
parse_target_quarter <- function(target_quarter) {
  
  # Check if input is valid
  if (is.null(target_quarter) || !is.character(target_quarter)) {
    stop("target_quarter must be a character string")
  }
  
  # Check format (should be like "T1_2025", "T2_2024", etc.)
  if (!grepl("^T[1-4]_[0-9]{4}$", target_quarter)) {
    stop("target_quarter format should be 'TX_YYYY' where X is 1-4 and YYYY is a 4-digit year")
  }
  
  # Extract quarter number and year
  parts <- strsplit(target_quarter, "_")[[1]]
  quarter_part <- parts[1]  # "T1", "T2", etc.
  year_part <- parts[2]     # "2025", "2024", etc.
  
  # Extract just the number from quarter part
  quarter <- as.numeric(gsub("T", "", quarter_part))
  year <- as.numeric(year_part)
  
  # Return as a named list
  result <- list(
    quarter = quarter,
    year = year,
    original = target_quarter
  )
  
  # Print results
  cat("Parsed target quarter:\n")
  cat("Quarter:", quarter, "\n")
  cat("Year:", year, "\n")
  
  return(result)
}
source("config/1_config.r")
#source("scripts/02_base_weights/3_indivs_weights.R")
# Parse the target quarter
parsed <- parse_target_quarter(TARGET_QUARTER)

# Extract individual components
quarter <- parsed$quarter  
year <- parsed$year        


DATA_DIR      <- file.path(BASE_DIR, "data")
WEIGHTS_DIR   <- file.path(DATA_DIR, "04_weights")

# Version plus flexible avec option SR
get_export_path <- function(target_quarter, quarter, year, use_sr = FALSE) {
  prefix <- if (use_sr) "SR_individu" else "individu"
  
  file.path(BASE_DIR, 
    "data", "04_weights", target_quarter, "calibrated_weights",
    paste0(prefix, "_T", quarter, "_", year, "_CAL.dta")
  )
}

INDIVIDU_PATH <- get_export_path(TARGET_QUARTER, quarter, year, use_sr = FALSE)

MENAGE_OUT_PATH_15PLUS <- file.path(
  WEIGHTS_DIR, TARGET_QUARTER, "household_weights",
  paste0("menage_weights_15plus_", TARGET_QUARTER, ".dta")
)

MENAGE_OUT_PATH_ALL <- file.path(
  WEIGHTS_DIR, TARGET_QUARTER, "household_weights",
  paste0("menage_weights_all_", TARGET_QUARTER, ".dta")
)

dir.create(dirname(MENAGE_OUT_PATH_15PLUS), recursive = TRUE, showWarnings = FALSE)

# ==============================================================================
# Load Calibrated Individual Data
# ==============================================================================
indiv_data <- read_dta(INDIVIDU_PATH)
glimpse(indiv_data)

# Vérifie les variables clés
required_vars <- c("interview_key", "FINAL_WEIGHT", "ageannee")
missing_vars <- setdiff(required_vars, names(indiv_data))
if (length(missing_vars) > 0) {
  stop(paste("Variables manquantes dans LFS_ILO_CAL :", paste(missing_vars, collapse = ", ")))
}

# ==============================================================================
# Function: Compute Household Weights
# ==============================================================================
# age_filter = TRUE -> restreint aux individus de 15 ans et plus
# age_filter = FALSE -> utilise tous les membres du ménage
# ==============================================================================
compute_household_weights <- function(data, age_filter = TRUE) {
  
  df <- data
  if (age_filter) {
    df <- df %>% filter(ageannee >= 15)
    version_label <- "15plus"
  } else {
    version_label <- "all_ages"
  }
  
  menage_weights <- df %>%
    group_by(interview_key) %>%
    summarise(
      n_members = n(),
      hh_weight = mean(FINAL_WEIGHT, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    set_variable_labels(
      n_members = if (age_filter) 
        "Nombre de membres du ménage âgés de 15 ans et plus" 
      else 
        "Nombre total de membres du ménage",
      hh_weight = if (age_filter)
        "Poids du ménage (moyenne des poids individuels calibrés, 15+)"
      else
        "Poids du ménage (moyenne des poids individuels calibrés, tous âges)"
    )
  
  # --- Vérification cohérence
    cat("\nVérification des poids ménages (version :", version_label, ")\n")
  return(menage_weights)
}

# ==============================================================================
# Compute Both Versions
# ==============================================================================
cat("\n=== Calcul des poids ménages (15 ans et plus) ===\n")
menage_weights_15plus <- compute_household_weights(indiv_data, age_filter = TRUE)

cat("\n=== Calcul des poids ménages (tous âges) ===\n")
menage_weights_all <- compute_household_weights(indiv_data, age_filter = FALSE)

# ==============================================================================
# Save Outputs
# ==============================================================================
write_dta(menage_weights_15plus, MENAGE_OUT_PATH_15PLUS)
write_dta(menage_weights_all, MENAGE_OUT_PATH_ALL)

cat("\n✅ Fichiers enregistrés :\n",
    "- ", MENAGE_OUT_PATH_15PLUS, "\n",
    "- ", MENAGE_OUT_PATH_ALL, "\n")

# ==============================================================================
# Optionnel : tableau récapitulatif
# ==============================================================================
summary_table <- bind_rows(
  menage_weights_15plus %>% mutate(version = "15plus"),
  menage_weights_all %>% mutate(version = "all_ages")
) %>%
  group_by(version) %>%
  summarise(
    n_households = n(),
    mean_weight = mean(hh_weight, na.rm = TRUE),
    min_weight = min(hh_weight, na.rm = TRUE),
    max_weight = max(hh_weight, na.rm = TRUE),
    .groups = "drop"
  )

print(summary_table)
