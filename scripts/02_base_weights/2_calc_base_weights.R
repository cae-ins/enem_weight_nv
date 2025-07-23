# ==============================================================================
# Script_name : calc_base_weights.R
# Title       : Compute and Label Base Weights for ENE Survey
# Description : This script defines functions to compute inclusion probabilities
#               and base weights at different stages of the sampling design.
#               It also attaches variable labels for easier understanding.
# Author      : Ezechiel KOFFIE
# Date        : 11-06-2025
# ==============================================================================

# ------------------------------------------------------------------------------
# Load Required Libraries
# ------------------------------------------------------------------------------
library(dplyr)
library(haven)
library(labelled) 

# ------------------------------------------------------------------------------
# Set Base Paths and Parameters
# ------------------------------------------------------------------------------
source("config/1_config.r")
source("scripts/01_utils/check_duplicates.r")


DATA_DIR <- file.path(BASE_DIR, "data")
WEIGHTS_DIR <- file.path(DATA_DIR, "04_weights")
WEIGHTS_COLUMNS_PATH <- file.path(WEIGHTS_DIR, TARGET_QUARTER, "base_weights",
                                  paste0("base_weights_", TARGET_QUARTER, ".dta"))

INCONSISTENT_PATH = file.path(WEIGHTS_DIR, TARGET_QUARTER, "base_weights", 
                              paste0("inconsistent_rows_", TARGET_QUARTER, ".dta"))
# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
NB_MENS_ENQ <- 12  # Default number of households interviewed per segment
TARGET_CODES = c(10)

# ------------------------------------------------------------------------------
# Count the segments to drop
# ------------------------------------------------------------------------------
count_seg_drop <- function(file_path, target_codes) {
  data <- read_dta(file_path)
  
  # Ensure incoherence_code is treated as integer
  codes <- as.integer(data$incoherence_code)
  
  # Count total number of matches
  total_count <- sum(codes %in% target_codes, na.rm = TRUE)
  
  return(total_count)
}

get_seg_drop <- function(file_path, target_codes) {
  data <- read_dta(file_path)
  
  # Ensure incoherence_code is treated as integer
  data <- data %>%
    mutate(incoherence_code = as.integer(incoherence_code))
  
  # Filter rows with specified codes
  filtered_data <- data %>%
    filter(incoherence_code %in% target_codes)
  
  # Extract distinct segment identifiers
  segment_info <- filtered_data %>%
    select(region, depart, souspref, ZD, segment) %>%
    distinct()
  
  return(segment_info)
}

seg_drop = count_seg_drop(INCONSISTENT_PATH, TARGET_CODES)
seg_drop_info = get_seg_drop(INCONSISTENT_PATH, TARGET_CODES)

# ------------------------------------------------------------------------------
# Add the nb_zd_strat variable
# ------------------------------------------------------------------------------

compute_nb_zd_strat <- function(data, seg_infos) {
  seg_to_drop_counts <- seg_infos %>%
    group_by(region) %>%
    summarise(segment_drop = n(), .groups = "drop")
  
  data <- data %>%
    left_join(seg_to_drop_counts, by = "region") %>%
    mutate(
      segment_drop = ifelse(is.na(segment_drop), 0, segment_drop),
      
      nb_zd_strat = case_when(
        region == 10101 ~ (13 * quarter_phase) - segment_drop,
        TRUE            ~ (7 * quarter_phase)  - segment_drop
      ),
      
      nb_zd_strat_wr = case_when(
        rgmen == 1 & region == 10101 ~ 13 - segment_drop,
        rgmen == 1                  ~ 7 - segment_drop,
        TRUE                        ~ NA_real_
      )
    ) %>%
    set_variable_labels(
      segment_drop     = "Nombre de segments non interrogés dans la région",
      nb_zd_strat      = "Nombre de segments interrogés dans la région",
      nb_zd_strat_wr   = "Nombre de segments interrogés dans la région (Trimestre en cours uniquement)"
    )
  
  return(data)
}

# ------------------------------------------------------------------------------
# Compute ZD-level Inclusion Probabilities
# ------------------------------------------------------------------------------
compute_pi_zd <- function(region, nb_indivs_zd, nb_indivs_reg, nb_zd_strat) {
  if (any(is.na(c(region, nb_indivs_zd, nb_indivs_reg, nb_zd_strat))) || nb_indivs_reg == 0)
    return(NA_real_)
  multiplier <- ifelse(region == 10101, 104, 56)
  multiplier * (nb_indivs_zd / nb_indivs_reg) * (nb_zd_strat / multiplier)
}

# ------------------------------------------------------------------------------
# Compute Household-Level Inclusion Probabilities
# ------------------------------------------------------------------------------
compute_pi_hh <- function(nb_mens_seg) {
  if (is.na(nb_mens_seg) || nb_mens_seg == 0)
    return(NA_real_)
  if (NB_MENS_ENQ > nb_mens_seg)
    return(1)
  (NB_MENS_ENQ / nb_mens_seg) * (1 / 6)
}
# ------------------------------------------------------------------------------
# Combine Inclusion Probabilities
# ------------------------------------------------------------------------------
compute_pi_HH <- function(pi_zd, pi_hh) {
  ifelse(is.na(pi_zd) | is.na(pi_hh), NA_real_, pi_zd * pi_hh)
}

# ------------------------------------------------------------------------------
# Append Base Weights to Dataset
# ------------------------------------------------------------------------------
append_base_weights <- function(data, resurvey = TRUE) {
  # Mandatory variables for all calculations
  required_cols <- c("region", "nb_indivs_zd", "nb_indivs_reg", 
                     "nb_zd_strat", "nb_mens_seg")
  if (resurvey) {
    required_cols <- c(required_cols, "proportion")
  }
  
  missing <- setdiff(required_cols, names(data))
  if (length(missing) > 0) {
    stop(paste("Missing required columns:", paste(missing, collapse = ", ")))
  }
  
  data <- data %>%
    mutate(
      pi_zd     = mapply(compute_pi_zd, region, nb_indivs_zd, nb_indivs_reg, nb_zd_strat),
      pi_zd_wr  = mapply(compute_pi_zd, region, nb_indivs_zd, nb_indivs_reg, nb_zd_strat_wr),
      pi_hh     = mapply(compute_pi_hh, nb_mens_seg),
      pi_HH     = compute_pi_HH(pi_zd, pi_hh),
      pi_HH_wr  = compute_pi_HH(pi_zd_wr, pi_hh),
      base_weight_HH    = ifelse(!is.na(pi_HH) & pi_HH != 0, 1 / pi_HH, NA_real_),
      base_weight_HH_WR = ifelse(!is.na(pi_HH_wr) & pi_HH_wr != 0, 1 / pi_HH_wr, NA_real_)
    )
  
  data <- data %>%
    set_variable_labels(
      pi_zd       = "Probabilité d'inclusion au niveau de la ZD",
      pi_zd_wr    = "Probabilité d'inclusion au niveau de la ZD (Trimestre en cours uniquement)",
      pi_hh       = "Probabilité d'inclusion du ménage dans le segment",
      pi_HH       = "Probabilité d'inclusion combinée ZD × HH",
      pi_HH_wr    = "Probabilité d'inclusion combinée ZD × HH (Trimestre en cours uniquement)",
      base_weight_HH = "Poids de base des ménages du segment",
      base_weight_HH_WR = "Poids de base des ménages du segment (Trimestre en cours uniquement)"
    )
  
  return(data)
}

# ------------------------------------------------------------------------------
# Calculate the base weights 
# ------------------------------------------------------------------------------
weight_data <- read_dta(WEIGHTS_COLUMNS_PATH)
weight_data <- compute_nb_zd_strat(weight_data, seg_drop_info)

## Drop the inconsistent rows
weight_data <- weight_data %>%
  anti_join(seg_drop_info, by = c("region", "depart", "souspref", "ZD", "segment"))

# Compute weights with or without resurvey logic
weight_data <- append_base_weights(weight_data, resurvey = FALSE)
write_dta(weight_data, WEIGHTS_COLUMNS_PATH)
# ------------------------------------------------------------------------------
# Save Final Dataset
# ------------------------------------------------------------------------------

# Ajoute les infos de doublons

# Check final data quality
cat("\n🔍 Running final quality checks...\n")
final_qc <- check_duplicates(
  weight_data, 
  c("region", "depart", "souspref", "ZD", "segment")
)

# Create quality report
if (final_qc$summary$duplicate_rows == 0) {
  cat("✅ Quality check PASSED - No duplicates found\n")
} else {
  cat("⚠️  Quality check FAILED - Found", final_qc$summary$duplicate_rows, "duplicate rows\n")
  cat("Consider reviewing the data before proceeding\n")
}
glimpse(weight_data)
source("scripts/07_correction_quarter/0_apply_quarter_correction.r")
weight_data <- apply_quarter_correction(weight_data, TARGET_QUARTER)

write_dta(weight_data, WEIGHTS_COLUMNS_PATH)
cat("Base weights calculated and saved to:", WEIGHTS_COLUMNS_PATH, "\n")














