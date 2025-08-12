################################################################################
# Script Name: gen_interviewkey_map.R
# Purpose:     Create a mapping from each interview_key to the first quarter
#              it was surveyed using v1interviewkey linkage.
# Author:      Ezechiel KOFFIE
# Date:        2025-05-02
################################################################################

# ------------------------------------------------------------------------------
# Load required libraries
# ------------------------------------------------------------------------------
library(dplyr)
library(fs)
library(stringr)
library(janitor)
library(haven)
library(lubridate)
library(readr)

# ------------------------------------------------------------------------------
# Define base directory and output path
# ------------------------------------------------------------------------------
source("config/1_config.r")
input_dir <- file.path(BASE_DIR, "data" ,"02_Cleaned", "Menage")
OUTPUT_MAPPING_FILE <- file.path(BASE_DIR, "data" ,"03_Processed", "Tracking_ID","interview_key_mapping.dta")

# ------------------------------------------------------------------------------
# Step 1: Order folders by quarter (e.g., T2_2024 < T1_2025)
# ------------------------------------------------------------------------------
all_dirs <- dir_ls(input_dir, type = "directory", regexp = "T\\d+_\\d{4}")
ordered_dirs <- tibble(
  dir = all_dirs,
  quarter_name = path_file(all_dirs)
) %>%
  mutate(
    quarter_num = as.integer(str_extract(quarter_name, "(?<=T)\\d")),
    year = as.integer(str_extract(quarter_name, "\\d{4}$")),
    order_index = (year - min(year)) * 4 + quarter_num
  ) %>%
  arrange(order_index)

# ------------------------------------------------------------------------------
# Step 2: Read and consolidate menage files
# ------------------------------------------------------------------------------
tracking_data <- list()

for (i in seq_len(nrow(ordered_dirs))) {
  quarter_label <- ordered_dirs$quarter_name[i]
  quarter_index <- ordered_dirs$order_index[i]
  current_dir <- ordered_dirs$dir[i]
  
  file_path <- dir_ls(current_dir, regexp = "menage.*\\.dta$", recurse = FALSE)
  if (length(file_path) == 0) next
  
  df <- read_dta(file_path) %>%
    clean_names() %>%
    mutate(
      date1 = as_datetime(date1),
      quarter_label = quarter_label,
      quarter_index = quarter_index,
      region = hh2,
      depart = hh3,
      souspref = hh4,
      zd = hh8,
      segment = hh7
    ) %>%
    select(interview_key, v1interviewkey, date1, quarter_label, region, depart, souspref, zd, segment)
  
  tracking_data[[quarter_label]] <- df
}

tracking_df <- bind_rows(tracking_data)

write_dta(tracking_df, OUTPUT_MAPPING_FILE)
message("Mapping file saved to: ", OUTPUT_MAPPING_FILE)

# ------------------------------------------------------------------------------

