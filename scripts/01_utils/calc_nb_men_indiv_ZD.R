################################################################################
# Script Name: calc_nb_men_indiv_ZD.R
# Purpose:     Aggregate household data by geographic variables, computing:
#              - Total household size (sum of TAILLE_MENAGE)
#              - Number of unique households (ID_Menage)
# Project:     ENE Survey Weights – RP 2021 Sample
# Author:      Ezechiel KOFFIE
# Created:     2025-05-02
# Last Edited: 2025-05-02
#
# Description:
# ------------------------------------------------------------------------------
# This script groups household-level survey data by the following geographic
# dimensions:
#   - REGION, DEPART, SOUSPREFID, P04, P05
#
# It computes two summary statistics for each group:
#   1. Total TAILLE_MENAGE (household size sum)
#   2. Count of unique ID_Menage (households)
#
# The resulting summary table is saved in .csv and .dta formats.
#
# Requirements:
# - The 'dplyr', 'readr', 'stringr' ,and 'haven' packages must be installed.
#
# Inputs:
# - DTA file containing pre-cleaned survey data
#
# Outputs:
# - Aggregated summary saved as .csv and .dta
#
################################################################################

# Load required libraries
library(dplyr)
library(readr)
library(haven)
library(stringr)

# ------------------------------------------------------------------------------
# Define file paths
# ------------------------------------------------------------------------------
# Base directory for the project
BASE_DIR <- "C:/Users/fajmi/Desktop/ENE_SURVEY_WEIGHTS"

# Define paths for input and output files
input_path <- file.path(BASE_DIR, "data", "02_cleaned", "RP_2021", "Bases_Menage_RGPH2021.dta")
output_dir <- file.path(BASE_DIR, "data", "03_processed", "RP_2021")
output_csv <- file.path(output_dir, "Nb_men_indiv_ZD.csv")
output_dta <- file.path(output_dir, "Nb_men_indiv_ZD.dta")

# ------------------------------------------------------------------------------
# Read the cleaned dataset
# ------------------------------------------------------------------------------
cat("Loading cleaned household data...\n")
df <- read_dta(input_path)

# ------------------------------------------------------------------------------
# Group and summarize the data
# ------------------------------------------------------------------------------
cat("Aggregating data by geographic identifiers...\n")
summary_df <- df %>%
  # Format P05 as 4-digit string
  mutate(P05 = str_pad(as.character(P05), width = 4, side = "left", pad = "0")) %>%
  
  # Group and summarise
  group_by(REGION, DEPART, SOUSPREFID, P05) %>%
  summarise(
    Nb_individus = sum(TAILLE_MENAGE, na.rm = TRUE),
    Nb_menages = n_distinct(ID_Menage),
    .groups = "drop"
  ) %>%
  
  # Rename variables
  rename(
    ZD = P05
  ) %>%
  
  # Add variable labels
  mutate(
    Nb_individus = labelled(Nb_individus, label = "Nombre total d'individus dans la ZD"),
    Nb_menages = labelled(Nb_menages, label = "Nombre total de ménages dans la ZD"),
    ZD = labelled(ZD, label = "Zone de Dénombrement (code à 4 chiffres)")
  )
# ------------------------------------------------------------------------------
# Save outputs
# ------------------------------------------------------------------------------
cat("Saving results as .csv...\n")
write_csv(summary_df, output_csv)

cat("Saving results as .dta (Stata)...\n")
write_dta(summary_df, output_dta, version = 14)

# ------------------------------------------------------------------------------
# Done
# ------------------------------------------------------------------------------
cat("Summary table saved to:\n -", output_csv, "\n -", "\n -", output_dta, "\n")
