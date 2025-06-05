################################################################################
# Script Name: extract_rp2021_vars.R
# Purpose:     Extract selected variables from a large .sav file and export to 
#              .dta and .csv formats
# Project:     ENE Survey Weights – RP 2021 Sample
# Author:      Ezechiel KOFFIE
# Created:     2025-05-02
# Last Edited: 2025-05-02
#
# Description:
# ------------------------------------------------------------------------------
# This script reads a subset of variables from a large SPSS (.sav) file and 
# exports the selection as both a Stata (.dta) file and a CSV (.csv) file.
#
# Requirements:
# - The 'haven' package for reading/writing .sav/.dta
# - The 'readr' package for efficient CSV writing (optional but recommended)
#
# Inputs:
# - SPSS data file (.sav) located at `sav_path`
#
# Outputs:
# - Stata .dta file and CSV .csv file saved to `output_dir`
#
################################################################################

# Load required packages
library(haven)
library(readr)  # for efficient write_csv()

# ------------------------------------------------------------------------------
# Define file paths
# ------------------------------------------------------------------------------
# Base directory for the project
BASE_DIR <- "C:/Users/e_koffie/Documents/Ponderations_ENE/ENE_SURVEY_WEIGHTS"

# Define input path (SPSS .sav file)
sav_path <- "D:/RP_2021/Bases_Menage_RGPH2024_EMPLOI.sav"

# Define output files paths
output_dir <- file.path(BASE_DIR, "data", "02_cleaned", "RP_2021")
output_dta <- file.path(output_dir, "Bases_Menage_RGPH2021_GPS.dta")
output_csv <- file.path(output_dir, "Bases_Menage_RGPH2021_GPS.csv")

# ------------------------------------------------------------------------------
# Define the variables to extract
# ------------------------------------------------------------------------------
#vars_to_extract <- c(
#  "ID_Menage", "INDIV_ID", "REGION", "DEPART", "SOUSPREFID", "P_ZC",
#  "P04", "P05", "P06", "P07", "P08", "P09", "P09A", "P09B",
#  "P10", "P10A", "P10B", "TAILLE_MENAGE"
#)

vars_to_extract <- c(
  "ID_Menage", "INDIV_ID", "REGION", "DEPART", "SOUSPREFID", "P_ZC",
  "P04", "P05", "P08", "P06", "P07", "P09", "P09A", "P09B", "P10",
  "TAILLE_MENAGE", "P10A", "P10B", "CHOIX_GPS",
  "LATITUDE", "LONGITUDE", "ALTITUDE", "GPS_PRECISION"
)

# ------------------------------------------------------------------------------
# Load only the selected variables
# ------------------------------------------------------------------------------
cat("Reading selected variables from .sav file...\n")
selected_data <- read_sav(sav_path, col_select = all_of(vars_to_extract))

# ------------------------------------------------------------------------------
# Export as Stata .dta file
# ------------------------------------------------------------------------------
cat("Saving data as .dta (Stata) file...\n")
write_dta(selected_data, path = output_dta, version = 14)

# ------------------------------------------------------------------------------
# Export as CSV file
# ------------------------------------------------------------------------------
cat("Saving data as .csv file...\n")
write_csv(selected_data, file = output_csv, na = "")

# ------------------------------------------------------------------------------
# Done
# ------------------------------------------------------------------------------
cat("Export complete. Files saved to:\n -", output_dta, "\n -", output_csv, "\n")
