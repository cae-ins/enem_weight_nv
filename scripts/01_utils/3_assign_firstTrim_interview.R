################################################################################
# Script Name: assign_firstTrim_interview.R
# Purpose:     For each quarter, update menage data with first interview quarter.
# Author:      Ezechiel KOFFIE
# Date:        2025-05-02
################################################################################

# ------------------------------------------------------------------------------
# Load required libraries
# ------------------------------------------------------------------------------
library(dplyr)
library(fs)
library(haven)
library(janitor)
library(stringr)
library(lubridate)

# ------------------------------------------------------------------------------
# Define base paths
# ------------------------------------------------------------------------------
source("config/1_config.r")
INPUT_ROOT <- file.path(BASE_DIR, "data", "02_Cleaned", "Menage")

OUTPUT_ROOT <- file.path(BASE_DIR, "data", "03_Processed", "Menage")
TRACKING_DIR <- file.path(BASE_DIR, "data", "03_Processed", "Tracking_ID")

# ------------------------------------------------------------------------------
# Load latest interview_key_mapping file
# ------------------------------------------------------------------------------
mapping_files <- dir_ls(TRACKING_DIR, recurse = 1, regexp = "interview_key_mapping_\\d{4}-\\d{2}-\\d{2}\\.dta$")

if (length(mapping_files) == 0) stop("No interview_key_mapping_*.dta found.")
latest_mapping_file <- mapping_files[which.max(file_info(mapping_files)$modification_time)]
mapping_df <- read_dta(latest_mapping_file) %>% clean_names()
message("Loaded mapping file: ", latest_mapping_file)

# ------------------------------------------------------------------------------
# Process each quarter folder
# ------------------------------------------------------------------------------
quarter_dirs <- dir_ls(INPUT_ROOT, type = "directory", regexp = "T\\d_\\d{4}$")

for (dir_path in quarter_dirs) {
  quarter_name <- path_file(dir_path)
  
  # Detect input file inside this folder
  pattern <- paste0("menage_", quarter_name, "\\.dta$")
  input_file <- dir_ls(dir_path, regexp = pattern)
  if (length(input_file) == 0) {
    message("No file matching 'menage_", quarter_name, ".dta' found in ", dir_path)
    next
  }
  
  # Load input data
  df <- read_dta(input_file) %>% clean_names()
  
  # Add first interview quarter
  df <- df %>%
    mutate(
      firsttriminterview = case_when(
        rgmen == 1 ~ quarter_name,
        rgmen == 2 ~ mapping_df$quarter_label[match(v1interviewkey, mapping_df$interview_key)],
        TRUE ~ NA_character_
      )
    )
  
  # Prepare output path
  output_dir <- file.path(OUTPUT_ROOT, quarter_name)
  dir_create(output_dir)
  output_file <- file.path(output_dir, paste0("menage_", quarter_name, ".dta"))
  
  # Save
  write_dta(df, output_file)
  message("Processed and saved: ", output_file)
}

