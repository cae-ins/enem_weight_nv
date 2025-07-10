################################################################################
# Script Name: assign_firstTrim_interview.R
# Purpose:     For each quarter, update menage data with first interview quarter.
# Author:      Ezechiel KOFFIE
# Date:        2025-05-02
################################################################################

# ------------------------------------------------------------------------------
# Load required libraries
# ------------------------------------------------------------------------------


# Chargement des packages
library(dplyr)
library(haven)  # si le fichier est un .dta (Stata)

source("config/1_config.r")
# Définir le chemin d'accès
INPUT_ROOT <- file.path(BASE_DIR, "data", "03_Processed")
# Chemin vers la base individu (ajuster selon l'extension réelle)
menage_path <- file.path(INPUT_ROOT, "Menage", TARGET_QUARTER)
individu_path <- file.path(INPUT_ROOT, "Individu", TARGET_QUARTER)

menage_file <- list.files(menage_path, pattern = "^menage.*\\.dta$", full.names = TRUE)[1]
individu_file <- list.files(individu_path, pattern = "^individu.*\\.dta$", full.names = TRUE)[1]

# Lire la base
individu <- read_dta(individu_file) 

# Nettoyage : suppression des lignes où ageanne ou m5 sont NA
individu_cleaned <- individu %>%
  filter(!is.na(AgeAnnee)) %>%
  filter(!is.na(M5))

# Sauvegarde (en écrasant l’ancienne base)
write_dta(individu_cleaned, individu_file) 
