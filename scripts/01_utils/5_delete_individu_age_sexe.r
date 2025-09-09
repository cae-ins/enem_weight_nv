################################################################################
# Script Name: delete_individu_age_sexe.R
# Purpose:     For each quarter, delete individual with no sex, no ages and no 
#              household or household with no individuals.
# Author:      Franck MIGONE
# Date:        2025-09-01
################################################################################

# Chargement des packages
library(dplyr)
library(haven) 
library(glue) # si le fichier est un .dta (Stata)

source("config/1_config.r")
# Définir le chemin d'accès
INPUT_ROOT <- file.path(BASE_DIR, "data", "03_Processed")
# Chemin vers la base individu (ajuster selon l'extension réelle)
menage_path <- file.path(INPUT_ROOT, "Menage", TARGET_QUARTER)
individu_path <- file.path(INPUT_ROOT, "Individu", TARGET_QUARTER)

menage_file <- list.files(menage_path, pattern = "^menage.*\\.dta$", full.names = TRUE)[1]
individu_file <- list.files(individu_path, pattern = "^individu.*\\.dta$", full.names = TRUE)[1]

# Lire la base
menage   <- read_dta(menage_file)
individu <- read_dta(individu_file) 
dim(individu)
# Nettoyage : suppression des lignes où ageanne ou m5 sont NA
individu_cleaned <- individu %>%
  filter(!is.na(AgeAnnee)) %>%
  filter(!is.na(M5)) %>%
  filter(AgeAnnee != -9998)


cat(glue("Initial rows: Menage = {nrow(menage)}, Individu = {nrow(individu_cleaned)}\n"))
join_key <- "interview__key" 
matched_keys <- intersect(menage[[join_key]], individu[[join_key]])
cat(glue("Number of matched rows: {length(matched_keys)}\n"))

# ------------------------------------------------------------------------------ 
# Keep only matched rows in each dataset
# ------------------------------------------------------------------------------ 
menage_matched   <- menage %>% filter(!!sym(join_key) %in% matched_keys)
individu_matched <- individu_cleaned %>% filter(!!sym(join_key) %in% matched_keys)
# ------------------------------------------------------------------------------ 
# Logging removed rows
# ------------------------------------------------------------------------------ 
cat(glue("Rows removed from Menage: {nrow(menage) - nrow(menage_matched)}\n"))
cat(glue("Rows removed from Individu: {nrow(individu_cleaned) - nrow(individu_matched)}\n"))
# ------------------------------------------------------------------------------ 
# Save filtered datasets (overwrite originals)
# ------------------------------------------------------------------------------ 
write_dta(menage_matched, menage_file)
write_dta(individu_matched, individu_file)
