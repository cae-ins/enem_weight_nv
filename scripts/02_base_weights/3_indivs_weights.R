# ==============================================================================
# Libraries
# ==============================================================================
library(dplyr)
library(haven)
library(labelled)

# ==============================================================================
# Paths and Parameters
# ==============================================================================
source("config/1_config.r")

DATA_DIR       <- file.path(BASE_DIR, "data")
PROCESSED_DIR  <- file.path(DATA_DIR, "03_Processed")
WEIGHTS_DIR    <- file.path(DATA_DIR, "04_weights")

# File Paths
WEIGHTS_COLUMNS_PATH <- file.path(WEIGHTS_DIR, TARGET_QUARTER, "base_weights",
                                  paste0("base_weights_", TARGET_QUARTER, ".dta"))
MENAGE_COLUMNS_PATH  <- file.path(WEIGHTS_DIR, TARGET_QUARTER, "base_weights",
                                  paste0("menage_", TARGET_QUARTER, ".dta"))
INDIVIDU_COLUMN_PATH <- file.path(WEIGHTS_DIR, TARGET_QUARTER, "base_weights",
                                  paste0("individu_", TARGET_QUARTER, ".dta"))

# ==============================================================================
# Load Base Weights Data
# ==============================================================================
weights_data <- read_dta(WEIGHTS_COLUMNS_PATH)

# ==============================================================================
# Function: Adjust for Individual Non-Response
# ==============================================================================
adjust_non_response_IND <- function(data) {
  
  required_cols <- c("nb_indivs_enq_pot", "nb_indivs_enq_elig", 
                     "adjusted_weight_HH", "adjusted_weight_HH_WR",
                     "margin_factor_HH", "margin_factor_HH_WR")
  
    if (!all(required_cols %in% names(data))) {
    missing_cols <- required_cols[!required_cols %in% names(data)]
    stop(paste("Missing required columns for adjustment:", paste(missing_cols, collapse = ", ")))
  }
  
  data %>%
    mutate(
      adjustment_factor_IND = case_when(
        is.na(nb_indivs_enq_elig) | nb_indivs_enq_elig == 0 ~ NA_real_,
        TRUE ~ nb_indivs_enq_pot / nb_indivs_enq_elig
      ),
      adjusted_weight_IND    = adjusted_weight_HH * margin_factor_HH    * adjustment_factor_IND,
      adjusted_weight_IND_WR = adjusted_weight_HH_WR * margin_factor_HH_WR * adjustment_factor_IND
    ) %>%
    set_variable_labels(
      adjustment_factor_IND  = "Facteur d'ajustement des non-réponses (individus)",
      adjusted_weight_IND    = "Poids ajusté des non-réponses (individus)",
      adjusted_weight_IND_WR = "Poids ajusté des non-réponses (individus) [Trimestre en cours]"
    )
}

adjusted_data <- adjust_non_response_IND(weights_data)

# ==============================================================================
# Load Menage and Individu Datasets
# ==============================================================================
menage_path   <- file.path(PROCESSED_DIR, "Menage", TARGET_QUARTER)
individu_path <- file.path(PROCESSED_DIR, "Individu", TARGET_QUARTER)

menage_file   <- list.files(menage_path, pattern = "^menage.*\\.dta$", full.names = TRUE)[1]
individu_file <- list.files(individu_path, pattern = "^individu.*\\.dta$", full.names = TRUE)[1]

menage_q   <- read_dta(menage_file)
individu_q <- read_dta(individu_file)

# Normalize column names
normalize_column_names <- function(df) {
  names(df) <- names(df) %>%
    tolower() %>%
    gsub("__", "_", .)
  df
}

menage_q   <- normalize_column_names(menage_q)
individu_q <- normalize_column_names(individu_q)
names(individu_q) <- make.names(names(individu_q), unique = TRUE)

# ==============================================================================
# Join Identifiers
# ==============================================================================
menage_ids <- menage_q %>%
  select(interview_key, hh2, hh3, hh4, hh8, hh7, rgmen) %>%
  distinct()

individu_q <- individu_q %>%
  select(-any_of(c("hh2", "hh3", "hh4", "hh8", "hh7", "rgmen"))) %>%
  left_join(menage_ids, by = "interview_key")

# ==============================================================================
# Merge Adjusted Weights
# ==============================================================================
join_keys <- c("hh2" = "region", "hh3" = "depart", "hh4" = "souspref",
               "hh8" = "ZD", "hh7" = "segment")

menage_q   <- menage_q   %>% left_join(adjusted_data, by = join_keys)
individu_q <- individu_q %>% left_join(adjusted_data, by = join_keys)

# Remove dots from column names
clean_names <- function(df) {
  names(df) <- gsub("\\.", "_", names(df))
  df
}
menage_q   <- clean_names(menage_q)
individu_q <- clean_names(individu_q)

# ==============================================================================
# Save Updated Datasets
# ==============================================================================
write_dta(adjusted_data, WEIGHTS_COLUMNS_PATH)
write_dta(menage_q, MENAGE_COLUMNS_PATH)
write_dta(individu_q, INDIVIDU_COLUMN_PATH)
