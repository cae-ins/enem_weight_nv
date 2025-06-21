################################################################################
# Script Name: concat_denomb.R
# Purpose:     Concatenate `.dta` files with the same name across subdirectories
#              by rows (vertical stacking), and save them to a designated output directory.
# Project:     National Employment Survey – Data Integration
# Author:      Ezechiel KOFFIE
# Created:     2025-05-02
# Last Edited: 2025-05-02
#
# Description:
# ------------------------------------------------------------------------------
# This script concatenates denombrement `.dta` datasets vertically:
# - Recursively searches subdirectories under a parent directory for `.dta` files
# - Identifies files with the same name
# - Vertically binds rows across files with the same name (i.e., stacking)
# - Retains all columns across datasets, filling missing columns with NA
# - Cleans and saves the result into an output directory
#
# Requirements:
# - R packages: haven, dplyr, purrr, fs, stringr, janitor
#
################################################################################

# ------------------------------------------------------------------------------
# Load required libraries
# ------------------------------------------------------------------------------
library(haven)
library(dplyr)
library(purrr)
library(fs)
library(stringr)
library(janitor)

# ------------------------------------------------------------------------------
# Define paths
# ------------------------------------------------------------------------------
BASE_DIR <- "C:/Users/e_koffie/Documents/Ponderations_ENE/ENE_SURVEY_WEIGHTS"

PARENT_DIR <- file.path(BASE_DIR, "data/01_raw", "Denombrement", "T2_2024")
OUTPUT_DIR <- file.path(BASE_DIR, "data/02_cleaned", "Denombrement", "T2_2024")

# Ensure output directory exists
dir_create(OUTPUT_DIR)

# ------------------------------------------------------------------------------
# Index all `.dta` files under subdirectories
# ------------------------------------------------------------------------------
cat("Indexing .dta files...\n")

dta_index <- dir_info(PARENT_DIR, recurse = TRUE, glob = "*.dta") %>%
  mutate(file_name = path_file(path)) %>%
  group_by(file_name) %>%
  summarise(paths = list(path), .groups = "drop")

# ------------------------------------------------------------------------------
# Process each group of files by filename
# ------------------------------------------------------------------------------
cat("Processing files grouped by name (vertical concat)...\n")

for (i in seq_len(nrow(dta_index))) {
  file_group <- dta_index[i, ]
  file_name <- file_group$file_name
  file_paths <- file_group$paths[[1]]
  
  cat("Merging:", file_name, "from", length(file_paths), "files\n")
  
  # Read and clean datasets
  datasets <- lapply(file_paths, function(path) {
    df <- read_dta(path)
    df <- janitor::clean_names(df)
    return(df)
  })
  
  # Harmonize all datasets to have the union of all variable names
  all_vars <- unique(unlist(lapply(datasets, names)))
  
  datasets_aligned <- lapply(datasets, function(df) {
    missing_vars <- setdiff(all_vars, names(df))
    if (length(missing_vars) > 0) {
      df[missing_vars] <- NA
    }
    df <- df[all_vars]
    return(df)
  })
  
  # Concatenate datasets by rows
  merged_df <- bind_rows(datasets_aligned)
  
  # Save to output directory
  output_path <- file.path(OUTPUT_DIR, file_name)
  write_dta(merged_df, path = output_path)
  
  cat("Saved:", output_path, "\n\n")
}

cat("Done. All files successfully processed.\n")