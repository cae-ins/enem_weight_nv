################################################################################
# Script Name: comp_followup_matrix.R
# Purpose:     Compute follow-up matrix grouped by (region, depart, souspref, zd)
# Author:      Ezechiel KOFFIE (modified by ChatGPT)
# Date:        2025-05-07
################################################################################

# ------------------------------------------------------------------------------
# Load required libraries
# ------------------------------------------------------------------------------
library(dplyr)
library(readxl)
library(writexl)
library(fs)
library(janitor)
library(haven)
library(stringr)
library(tidyr)

# ------------------------------------------------------------------------------
# Step 1: Locate latest subfolder in Tracking_ID
# ------------------------------------------------------------------------------
base_dir <- "C:/Users/e_koffie/Documents/Ponderations_ENE/ENE_SURVEY_WEIGHTS"
tracking_id_dir <- file.path(base_dir, "data", "03_Processed", "Tracking_ID")

latest_subdir <- dir_ls(tracking_id_dir, type = "directory") %>%
  file_info() %>%
  arrange(desc(modification_time)) %>%
  slice(1) %>%
  pull(path)

# ------------------------------------------------------------------------------
# Step 2: Load interview_key_mapping from latest subdir
# ------------------------------------------------------------------------------
mapping_file <- dir_ls(latest_subdir, regexp = "interview_key_mapping_.*\\.dta$")
if (length(mapping_file) == 0) stop("No mapping file found in latest Tracking_ID subfolder.")

df <- read_dta(mapping_file) %>% clean_names()

# ------------------------------------------------------------------------------
# Step 3: Compute follow-up proportions by (region, depart, souspref, zd)
# ------------------------------------------------------------------------------

group_keys <- c("region", "depart", "souspref", "zd", "segment")

# First interviews (v1interviewkey == "")
first_interviews <- df %>%
  filter(v1interviewkey == "") %>%
  count(across(all_of(group_keys)), quarter_label, name = "first_total") %>%
  rename(first_quarter = quarter_label)

# Resurveys (v1interviewkey != "")
resurveys <- df %>%
  filter(v1interviewkey != "") %>%
  count(across(all_of(group_keys)), quarter_label, v1interviewkey, name = "n") %>%
  rename(current_quarter = quarter_label)

# Lookup for the first quarter by interview_key
first_quarters_lookup <- df %>%
  filter(v1interviewkey == "") %>%
  select(all_of(group_keys), interview_key, quarter_label) %>%
  distinct() %>%
  rename(first_quarter = quarter_label)

# Join resurveys with their origin quarters
resurvey_links <- resurveys %>%
  left_join(first_quarters_lookup, by = c(group_keys, "v1interviewkey" = "interview_key")) %>%
  filter(!is.na(first_quarter)) %>%
  count(across(all_of(group_keys)), current_quarter, first_quarter, name = "resurvey_count")

# Combine with first_total to compute proportions
matrix_tabular <- resurvey_links %>%
  left_join(first_interviews, by = c(group_keys, "first_quarter")) %>%
  mutate(proportion = round(resurvey_count / first_total, 4)) %>%
  select(all_of(group_keys), current_quarter, first_quarter, resurvey_count, first_total, proportion)

# Add diagonal (self-resurvey = 1)
self_links <- first_interviews %>%
  mutate(
    current_quarter = first_quarter,
    resurvey_count = NA,
    proportion = 1
  ) %>%
  select(all_of(group_keys), current_quarter, first_quarter, resurvey_count, first_total, proportion)

# Combine everything
final_matrix <- bind_rows(matrix_tabular, self_links) %>%
  arrange(across(all_of(group_keys)), current_quarter, first_quarter)

# ------------------------------------------------------------------------------
# Step 4: Save output
# ------------------------------------------------------------------------------
timestamp <- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")
output_path <- file.path(latest_subdir, paste0("followup_matrix_", timestamp, ".dta"))

write_dta(final_matrix, output_path)
cat("Follow-up matrix by ZD (region, depart, souspref, zd) saved to:\n", output_path, "\n")