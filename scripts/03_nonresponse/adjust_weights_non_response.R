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
BASE_DIR <- "C:/Users/e_koffie/Documents/Ponderations_ENE/ENE_SURVEY_WEIGHTS"
TARGET_QUARTER <- "T3_2024"

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
# Function: adjust_non_response_IND
# Purpose : Adjust individual weights using non-response rate at individual level
# ------------------------------------------------------------------------------

adjust_non_response_IND <- function(data) {
  
  if (!all(c("nb_indivs_enq_pot", "nb_indivs_enq_elig", "adjusted_weight_HH") %in% names(data))) {
    stop("Missing required columns: 'nb_indivs_enq_pot', 'nb_indivs_enq_elig', or 'adjusted_weight_HH'.")
  }
  
  data <- data %>%
    mutate(
      adjustment_factor_IND = case_when(
        is.na(nb_indivs_enq_elig) | nb_indivs_enq_elig == 0 ~ NA_real_,
        TRUE ~ nb_indivs_enq_pot / nb_indivs_enq_elig
      ),
      adjusted_weight_IND = adjusted_weight_HH * adjustment_factor_IND,
      adjusted_weight_IND_WR = adjusted_weight_HH_WR * adjustment_factor_IND
    ) %>%
    set_variable_labels(
      adjustment_factor_IND = "Facteur d'ajustement des non-réponses (individus)",
      adjusted_weight_IND   = "Poids ajusté des non-réponses (individus)",
      adjusted_weight_IND_WR = "Poids ajusté des non-réponses (individus) [Trimestre en cours]"
    )
  
  return(data)
}


# ------------------------------------------------------------------------------
# Calculate the base weights 
# ------------------------------------------------------------------------------
weight_data <- read_dta(WEIGHTS_COLUMNS_PATH)
adjusted_data <- adjust_non_response_HH(weight_data, EXPECTED_HH_PER_SEG)
adjusted_data <- adjust_non_response_IND(adjusted_data)

# ------------------------------------------------------------------------------
# Add the adjusted weights to the menage and individus datasets
# ------------------------------------------------------------------------------
menage_path <- file.path(PROCESSED_DIR, "Menage", TARGET_QUARTER)
individu_path <- file.path(PROCESSED_DIR, "Individu", TARGET_QUARTER)

menage_file <- list.files(menage_path, pattern = "^menage.*\\.dta$", full.names = TRUE)[1]
individu_file <- list.files(individu_path, pattern = "^individu.*\\.dta$", full.names = TRUE)[1]

menage_q <- read_dta(menage_file)
individu_q <- read_dta(individu_file)

normalize_column_names  <- function(df) {
  names(df) <- names(df) %>%
    tolower() %>%
    gsub("__", "_", .)
  return(df)
}

menage_q <- normalize_column_names(menage_q)
individu_q <- normalize_column_names(individu_q)

menage_ids <- menage_q %>%
  select(interview_key, hh2, hh3, hh4, hh8, hh7, rgmen) %>%
  distinct()

names(individu_q) <- make.names(names(individu_q), unique = TRUE)
individu_q <- individu_q %>%
  select(-any_of(c("hh2", "hh3", "hh4", "hh8", "hh7", "rgmen")))

individu_q <- individu_q %>%
  left_join(menage_ids, by = "interview_key")


# ------------------------------------------------------------------------------
# Merge weights into menage_q
# ------------------------------------------------------------------------------

menage_q <- menage_q %>%
  left_join(adjusted_data,
            by = c("hh2" = "region",
                   "hh3" = "depart",
                   "hh4" = "souspref",
                   "hh8" = "ZD",
                   "hh7" = "segment"))

# ------------------------------------------------------------------------------
# Merge weights into individu_q
# ------------------------------------------------------------------------------

individu_q <- individu_q %>%
  left_join(adjusted_data,
            by = c("hh2" = "region",
                   "hh3" = "depart",
                   "hh4" = "souspref",
                   "hh8" = "ZD",
                   "hh7" = "segment"))


# Remove dots from column names
names(menage_q) <- gsub("\\.", "_", names(menage_q))
names(individu_q) <- gsub("\\.", "_", names(individu_q))
# ------------------------------------------------------------------------------
# Save Final Dataset
# ------------------------------------------------------------------------------
write_dta(adjusted_data, WEIGHTS_COLUMNS_PATH)
write_dta(menage_q, MENAGE_COLUMNS_PATH)
write_dta(individu_q, INDIVIDU_COLUMN_PATH)
