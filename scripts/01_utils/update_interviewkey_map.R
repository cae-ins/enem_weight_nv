################################################################################
# Script Name: update_interviewkey_map.R
# Purpose:     Update interview_key to first quarter mapping by detecting new
#              quarter folders and appending new records to existing tracking file.
#              Adds timestamped output folder and updates processed quarters list.
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
library(readxl)
library(writexl)

# ------------------------------------------------------------------------------
# Define base paths
# ------------------------------------------------------------------------------
source("config/1_config.r")
INPUT_DIR <- file.path(BASE_DIR, "data", "02_Cleaned", "Menage")
OUTPUT_DIR_ROOT <- file.path(BASE_DIR, "data", "03_Processed", "Tracking_ID")


# ------------------------------------------------------------------------------
# Step 1: Locate latest quarters_processed log
# ------------------------------------------------------------------------------
log_files <- dir_ls(OUTPUT_DIR_ROOT, recurse = 1, regexp = "quarters_processed_\\d{4}-\\d{2}-\\d{2}\\.xlsx$")

if (length(log_files) > 0) {
  latest_log_file <- log_files[which.max(file_info(log_files)$modification_time)]
  processed_quarters <- read_excel(latest_log_file)$quarter_label
  message("Loaded processed quarters from: ", latest_log_file)
} else {
  processed_quarters <- character(0)
  message("ℹ️ No processed quarters log found. Starting fresh.")
}

# ------------------------------------------------------------------------------
# Create today's dated output folder
# ------------------------------------------------------------------------------
update_date <- format(Sys.Date(), "%Y-%m-%d")
OUTPUT_DIR <- file.path(OUTPUT_DIR_ROOT, update_date)
dir_create(OUTPUT_DIR)

# ------------------------------------------------------------------------------
# Step 2: Detect and order all quarter folders
# ------------------------------------------------------------------------------
all_dirs <- dir_ls(INPUT_DIR, type = "directory", regexp = "T\\d+_\\d{4}")
ordered_dirs <- tibble(
  dir = all_dirs,
  quarter_label = path_file(all_dirs)
) %>%
  mutate(
    quarter_num = as.integer(str_extract(quarter_label, "(?<=T)\\d")),
    year = as.integer(str_extract(quarter_label, "\\d{4}$")),
    order_index = (year - min(year)) * 4 + quarter_num
  ) %>%
  arrange(order_index)

# ------------------------------------------------------------------------------
# Step 3: Filter new quarters
# ------------------------------------------------------------------------------
new_quarters <- ordered_dirs %>% 
  filter(!quarter_label %in% processed_quarters)

if (nrow(new_quarters) == 0) {
  message("No new quarters to update. Mapping is up-to-date.")
  quit(save = "no")
}

# ------------------------------------------------------------------------------
# Step 4: Load existing interview_key_mapping file (latest)
# ------------------------------------------------------------------------------
mapping_files <- dir_ls(OUTPUT_DIR_ROOT, recurse = 1, regexp = "interview_key_mapping_\\d{4}-\\d{2}-\\d{2}\\.dta$")

if (length(mapping_files) > 0) {
  latest_mapping_file <- mapping_files[which.max(file_info(mapping_files)$modification_time)]
  existing_mapping <- read_dta(latest_mapping_file) %>% clean_names()
  message("Loaded existing mapping from: ", latest_mapping_file)
} else {
  existing_mapping <- tibble()
  message("ℹ️ No existing mapping found. Creating new.")
}

# ------------------------------------------------------------------------------
# Step 5: Read and process new quarters
# ------------------------------------------------------------------------------
new_data_list <- list()

for (i in seq_len(nrow(new_quarters))) {
  quarter_label <- new_quarters$quarter_label[i]
  quarter_index <- new_quarters$order_index[i]
  current_dir <- new_quarters$dir[i]
  
  file_path <- dir_ls(current_dir, regexp = "menage.*\\.dta$", recurse = FALSE)
  if (length(file_path) == 0) next
  
  df <- read_dta(file_path) %>%
    clean_names() %>%
    mutate(
      date1 = suppressWarnings(as_datetime(date1)),
      quarter_label = quarter_label,
      quarter_index = quarter_index,
      region = hh2,
      depart = hh3,
      souspref = hh4,
      zd = hh8,
      segment = hh7
    )
  
  required_vars <- c("interview_key", "v1interviewkey", "date1", "quarter_label","region", "depart", "souspref", "zd", "segment")
  available_vars <- intersect(required_vars, names(df))
  
  df <- df[, available_vars, drop = FALSE]
  
  new_data_list[[quarter_label]] <- df
}

new_mapping <- bind_rows(new_data_list)

# ------------------------------------------------------------------------------
# Step 6: Combine and deduplicate
# ------------------------------------------------------------------------------
updated_mapping <- bind_rows(existing_mapping, new_mapping) %>%
  distinct(interview_key, .keep_all = TRUE)

# ------------------------------------------------------------------------------
# Step 7: Save new mapping file
# ------------------------------------------------------------------------------
mapping_filename <- paste0("interview_key_mapping_", update_date, ".dta")
mapping_path <- file.path(OUTPUT_DIR, mapping_filename)
write_dta(updated_mapping, mapping_path)
message("Updated mapping saved to: ", mapping_path)

# ------------------------------------------------------------------------------
# Step 8: Save updated quarters_processed log
# ------------------------------------------------------------------------------
updated_quarters <- union(processed_quarters, new_quarters$quarter_label) %>%
  sort()

quarters_log_filename <- paste0("quarters_processed_", update_date, ".xlsx")
quarters_log_path <- file.path(OUTPUT_DIR, quarters_log_filename)

write_xlsx(tibble(quarter_label = updated_quarters), quarters_log_path)
message("Quarters processed log updated at: ", quarters_log_path)

