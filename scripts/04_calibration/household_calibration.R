# ==============================================================================
# Libraries
# ==============================================================================

library(dplyr)
library(haven)
library(labelled)
library(readxl)

# ==============================================================================
# Paths and Parameters
# ==============================================================================
# ------------------------------------------------------------------------------

source("config/1_config.r")
DATA_DIR     <- file.path(BASE_DIR, "data")
PROCESSED_DIR <- file.path(DATA_DIR, "03_Processed")
WEIGHTS_DIR   <- file.path(DATA_DIR, "04_weights")

WEIGHTS_COLUMNS_PATH <- file.path(
  WEIGHTS_DIR, TARGET_QUARTER, "base_weights",
  paste0("base_weights_", TARGET_QUARTER, ".dta")
)
MENAGE_COLUMNS_PATH <- file.path(
  WEIGHTS_DIR, TARGET_QUARTER, "base_weights",
  paste0("menage_", TARGET_QUARTER, ".dta")
)
INDIVIDU_COLUMN_PATH <- file.path(
  WEIGHTS_DIR, TARGET_QUARTER, "base_weights",
  paste0("individu_", TARGET_QUARTER, ".dta")
)

# ==============================================================================
# Load Data
# ==============================================================================
weights_data <- read_dta(WEIGHTS_COLUMNS_PATH)
# Path to Stata file containing Urban_Pop_menage and Rural_Pop_Menage
# Extraire les 2 derniers chiffres de l'année
annee_courte <- substr(TARGET_QUARTER, 6, 7)  # "25" de "T1_2025"

POP_MENAGE_PATH <- file.path(
  WEIGHTS_DIR, 
  paste0("struct_menage_rp", annee_courte, ".xlsx")
)
# Read the Stata file
pop_menage_data <- read_excel(POP_MENAGE_PATH)

# ==============================================================================
# Function: Aggregate Base Weights
# ==============================================================================
weights_data <- weights_data %>%
  select(-any_of(c("Urbain_Pop_Menage", "Rural_Pop_Menage"))) %>% 
  left_join(
    pop_menage_data %>% select(region, Urbain_Pop_Menage, Rural_Pop_Menage),
    by = "region"
  )


aggregate_base_weights <- function(data) {
  # By region
  weights_by_region <- data %>%
    group_by(region) %>%
    summarise(
      base_weight_HH_reg    = sum(base_weight_HH * nb_mens_enq, na.rm = TRUE),
      base_weight_HH_WR_reg = sum(base_weight_HH_WR * nb_mens_enq, na.rm = TRUE),
      .groups = "drop"
    )
  
  # By region and milieu
  weights_by_milieu <- data %>%
    group_by(region, milieu) %>%
    summarise(
      base_weight_HH_milieu    = sum(base_weight_HH * nb_mens_enq, na.rm = TRUE),
      base_weight_HH_WR_milieu = sum(base_weight_HH_WR * nb_mens_enq, na.rm = TRUE),
      .groups = "drop"
    )
  
  # Merge aggregates back


# Merge with weights_data by region and milieu

  
  # Merge aggregates back
  data <- data %>%
    left_join(weights_by_region, by = "region") %>%
    left_join(weights_by_milieu, by = c("region", "milieu")) 
  

  
  return(data)
}

weights_data <- weights_data %>%
  aggregate_base_weights() 
# ==============================================================================
# Function: Compute Margin Factors
# ==============================================================================

compute_margin_factors <- function(data) {
  data <- data %>%
    mutate(margin_factor_HH = case_when(
      milieu == 1 ~ Urbain_Pop_Menage * base_weight_HH_reg / base_weight_HH_milieu,
      milieu == 2 ~ Rural_Pop_Menage  * base_weight_HH_reg / base_weight_HH_milieu,
      TRUE ~ NA_real_
    ),
    margin_factor_HH_WR = case_when(
      milieu == 1 ~ Urbain_Pop_Menage * base_weight_HH_WR_reg / base_weight_HH_WR_milieu,
      milieu == 2 ~ Rural_Pop_Menage  * base_weight_HH_WR_reg / base_weight_HH_WR_milieu,
      TRUE ~ NA_real_
    )
    ) %>%
    set_variable_labels(
      margin_factor_HH    = "Facteur de calage des poids HH",
      margin_factor_HH_WR = "Facteur de calage des poids HH (Trimestre en cours)"
    )
}
weights_data <- weights_data %>%
  compute_margin_factors()
# ==============================================================================
# Processing
# ==============================================================================
library(tibble)
weights_data <- as_tibble(weights_data)

glimpse(weights_data)
# ==============================================================================
# Save Final Dataset
# ==============================================================================
write_dta(weights_data, WEIGHTS_COLUMNS_PATH)
