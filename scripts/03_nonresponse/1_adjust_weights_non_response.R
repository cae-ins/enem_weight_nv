# ==============================================================================
# Script_name : adjust_weights_non_response.R
# Title       : Adjust Base Weights for Non-Response at Segment Level
# Description : This script adjusts the base weights calculated in the previous
#               step using the effective number of surveyed households per segment.
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

DATA_DIR <- file.path(BASE_DIR, "data")
PROCESSED_DIR <- file.path(DATA_DIR, "03_Processed")
WEIGHTS_DIR <- file.path(DATA_DIR, "04_weights")
WEIGHTS_COLUMNS_PATH <- file.path(WEIGHTS_DIR, TARGET_QUARTER, "base_weights",
                                  paste0("base_weights_", TARGET_QUARTER, ".dta"))
MENAGE_COLUMNS_PATH <- file.path(WEIGHTS_DIR, TARGET_QUARTER, "base_weights",
                                 paste0("menage_", TARGET_QUARTER, ".dta"))

INDIVIDU_COLUMN_PATH<- file.path(WEIGHTS_DIR, TARGET_QUARTER, "base_weights",
                                 paste0("individu_", TARGET_QUARTER, ".dta"))

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
EXPECTED_HH_PER_SEG <- 12  # Planned number of households per segment

# ------------------------------------------------------------------------------
# Function: adjust_weights_non_response
# Purpose : Adjust base weights using non-response rate at segment level
# ------------------------------------------------------------------------------
adjust_non_response_HH <- function(data, EXPECTED_HH_PER_SEG = 12) {
  
  if (!all(c("nb_mens_enq", "nb_mens_seg", "base_weight_HH") %in% names(data))) {
    stop("Missing one or more required columns: 'nb_mens_enq', 'nb_mens_seg', 'base_weight_HH'.")
  }
  
  data <- data %>%
    mutate(
      adjustment_factor_HH = case_when(
        is.na(nb_mens_enq) | nb_mens_enq == 0 ~ NA_real_,
        nb_mens_seg < EXPECTED_HH_PER_SEG     ~ nb_mens_seg / nb_mens_enq,
        TRUE                                  ~ EXPECTED_HH_PER_SEG / nb_mens_enq
      ),
      adjusted_weight_HH = base_weight_HH * adjustment_factor_HH,
      adjusted_weight_HH_WR = base_weight_HH_WR * adjustment_factor_HH
    ) %>%
    set_variable_labels(
      adjustment_factor_HH = "Facteur d'ajustement des non-réponses (ménages)",
      adjusted_weight_HH   = "Poids de base ajusté des non-réponses (ménages)",
      adjusted_weight_HH_WR = "Poids de base ajusté des non-réponses (ménages) [Trimestre en cours]"
    )
  
  return(data)
}

# ------------------------------------------------------------------------------
# Calculate the base weights 
# ------------------------------------------------------------------------------
weight_data <- read_dta(WEIGHTS_COLUMNS_PATH)
adjusted_data <- adjust_non_response_HH(weight_data, EXPECTED_HH_PER_SEG)

# ------------------------------------------------------------------------------
# Save Final Dataset
# ------------------------------------------------------------------------------
write_dta(adjusted_data, WEIGHTS_COLUMNS_PATH)


