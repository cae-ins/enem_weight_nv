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

adjust_non_response_HH <- function(data, EXPECTED_HH_PER_SEG = 12, group_vars = c("region", "milieu")) {
  
  if (!all(c("nb_mens_enq", "nb_mens_seg", "base_weight_HH") %in% names(data))) {
    stop("Missing one or more required columns: 'nb_mens_enq', 'nb_mens_seg', 'base_weight_HH'.")
  }
  
  data <- data %>%
    ## -----------------------------------------------
    ## 1️⃣  Créer les **variables de base** (potentiel & effectif)
    ## -----------------------------------------------
    mutate(
      ## 1a.  Potentiel de collecte (segment)
      potentiel_de_collecte = case_when(
        is.na(nb_mens_seg) ~ NA_real_,
        nb_mens_seg < EXPECTED_HH_PER_SEG ~ nb_mens_seg,
        TRUE ~ EXPECTED_HH_PER_SEG
      )
    ) %>%
    ## Grouper par région et milieu pour les calculs de somme
    group_by(across(all_of(group_vars))) %>%
    mutate(
      ## 1b.  Somme du potentiel par région × milieu
      potentiel_region_milieu = sum(potentiel_de_collecte, na.rm = TRUE),
      
      ## 1c.  Effectif interviewé par région × milieu
      nb_mens_enq_region_milieu = sum(nb_mens_enq, na.rm = TRUE)
    ) %>%
    ungroup() %>%
    ## -----------------------------------------------
    ## 2️⃣  Calculer les facteurs (facteur d'ajustement, poids, etc.)
    ## -----------------------------------------------
    mutate(
      ## 2a.  Facteur d'ajustement des ménages
      adjustment_factor_HH = case_when(
        is.na(nb_mens_enq) | nb_mens_enq == 0 ~ NA_real_,
        nb_mens_seg < EXPECTED_HH_PER_SEG ~ nb_mens_seg / nb_mens_enq,
        TRUE ~ EXPECTED_HH_PER_SEG / nb_mens_enq
      ),
      
      ## 2b.  Poids ajustés
      adjusted_weight_HH = base_weight_HH * adjustment_factor_HH,
      adjusted_weight_HH_WR = base_weight_HH_WR * adjustment_factor_HH,
      
      ## 2c.  Facteur de correction (potentiel / effectif)
      correction_factor_region_milieu = case_when(
        nb_mens_enq_region_milieu == 0 ~ NA_real_,   # éviter division par 0
        TRUE ~ potentiel_region_milieu / nb_mens_enq_region_milieu
      ),
      
      ## 2d.  Poids corrigés avec le facteur de correction région×milieu
      corrected_weight_HH = base_weight_HH * correction_factor_region_milieu,
      corrected_weight_HH_WR = base_weight_HH_WR * correction_factor_region_milieu
    ) %>%
    ## -----------------------------------------------
    ## 3️⃣  Ajouter les labels (facultatif)
    ## -----------------------------------------------
    set_variable_labels(
      potentiel_de_collecte = "Potentiel de collecte (segment)",
      potentiel_region_milieu = "Potentiel de collecte par région & milieu",
      nb_mens_enq_region_milieu = "Effectif interviewé par région & milieu",
      adjustment_factor_HH = "Facteur d'ajustement des non-réponses (ménages)",
      adjusted_weight_HH = "Poids de base ajusté des non-réponses (ménages)",
      adjusted_weight_HH_WR = "Poids de base ajusté des non-réponses (ménages) [Trimestre en cours]",
      correction_factor_region_milieu = "Facteur de correction (potentiel / effectif) par région & milieu",
      corrected_weight_HH = "Poids de base corrigé par région & milieu (ménages)",
      corrected_weight_HH_WR = "Poids de base corrigé par région & milieu (ménages) [Trimestre en cours]"
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


# ------------------------------------------------------------------------------
# Visuatlization: 3D Scatter Plot
# Purpose   : Visualize relationship between base weights, adjusted weights, and correction factor
# ------------------------------------------------------------------------------
library(plotly)
library(ggplot2)
library(dplyr)

# On retire les NA afin d’avoir des densités valides
df <- adjusted_data %>%
  select(base_weight_HH,
         adjusted_weight_HH,
         corrected_weight_HH) %>%
  na.omit()

# 1. base_weight_HH
p1 <- ggplot(df, aes(x = base_weight_HH)) +
  geom_density(fill = "steelblue", alpha = 0.6) +
  theme_minimal() +
  labs(title = "Density of base_weight_HH",
       x = "base_weight_HH", y = "Density")

# 2. adjusted_weight_HH
p2 <- ggplot(df, aes(x = adjusted_weight_HH)) +
  geom_density(fill = "darkorange", alpha = 0.6) +
  theme_minimal() +
  labs(title = "Density of adjusted_weight_HH",
       x = "adjusted_weight_HH", y = "Density")

# 3. correction_factor_region_milieu
p3 <- ggplot(df, aes(x = corrected_weight_HH)) +
  geom_density(fill = "darkgreen", alpha = 0.6) +
  theme_minimal() +
  labs(title = "Density of corrected_weight_HH",
       x = "corrected_weight_HH", y = "Density")


library(gridExtra)   # ou cowplot/patchwork
grid.arrange(p1, p2, p3, ncol = 3)



