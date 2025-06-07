# ==============================================================================
# Script Name: denomb_updates.R
# Purpose: Process newly updated ZD counts from Denombrement_update
#          and create a harmonized dataset with household and individual counts
# Author: [Your Name]
# Date: [Today's Date]
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Load Required Libraries
# ------------------------------------------------------------------------------
library(dplyr)
library(readxl)
library(stringr)
library(purrr)
library(haven)

# ------------------------------------------------------------------------------
# 2. Set Base Paths
# ------------------------------------------------------------------------------
BASE_DIR <- "C:/Users/fajmi/Desktop/ENE_SURVEY_WEIGHTS"
RAW_UPDATE_DIR <- file.path(BASE_DIR, "data", "01_raw", "Denombrement_update")
CLEANED_BASE_DIR <- file.path(BASE_DIR, "data", "02_Cleaned", "Denombrement")
ref_path <- file.path(BASE_DIR, "data", "03_processed", "RP_2021", "nb_men_indivs_ZD.dta")

# ------------------------------------------------------------------------------
# 3. Identify All Excel Files and Associated Quarters
# ------------------------------------------------------------------------------
update_files <- list.files(RAW_UPDATE_DIR, recursive = TRUE, pattern = "\\.xlsx$", full.names = TRUE)

extract_quarter <- function(path) {
  folder <- str_match(path, "Denombrement_update/(T\\d_\\d{4})")[,2]
  return(folder)
}

# ------------------------------------------------------------------------------
# 4. Read, Select Relevant Columns, Tag Quarter, and Bind All Excel Files
# ------------------------------------------------------------------------------
# ==============================================================================
# Project: ENE Survey Weights Processing
# Purpose: Process newly updated ZD counts from Denombrement_update
#          and create a harmonized dataset with household and individual counts
# Author: [Your Name]
# Date: [Today's Date]
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Load Required Libraries
# ------------------------------------------------------------------------------
library(dplyr)
library(readxl)
library(stringr)
library(purrr)
library(haven)

# ------------------------------------------------------------------------------
# 2. Set Base Paths
# ------------------------------------------------------------------------------
BASE_DIR <- "C:/Users/fajmi/Desktop/ENE_SURVEY_WEIGHTS"
RAW_UPDATE_DIR <- file.path(BASE_DIR, "data", "01_raw", "Denombrement_update")
CLEANED_BASE_DIR <- file.path(BASE_DIR, "data", "02_Cleaned", "Denombrement")
ref_path <- file.path(BASE_DIR, "data", "03_processed", "RP_2021", "nb_men_indivs_ZD.dta")

# ------------------------------------------------------------------------------
# 3. Identify All Excel Files and Associated Quarters
# ------------------------------------------------------------------------------
update_files <- list.files(RAW_UPDATE_DIR, recursive = TRUE, pattern = "\\.xlsx$", full.names = TRUE)

extract_quarter <- function(path) {
  folder <- str_match(path, "Denombrement_update/(T\\d_\\d{4})")[,2]
  return(folder)
}

# ------------------------------------------------------------------------------
# 4. Read, Select Relevant Columns, Tag Quarter, and Bind All Excel Files
# ------------------------------------------------------------------------------
skipped_files <- c()

read_and_tag_file <- function(file_path) {
  quarter <- extract_quarter(file_path)
  df <- read_excel(file_path)
  
  # Skip files missing IDSeg and log them
  if (!"IDSeg" %in% names(df)) {
    skipped_files <<- c(skipped_files, file_path)
    return(NULL)
  }
  
  # Standardize types before selection to avoid bind_rows issues
  df <- df %>%
    mutate(
      HH2          = as.character(HH2),
      HH3          = as.character(HH3),
      HH4          = as.character(HH4),
      HH8          = as.character(HH8),
      IDSeg        = as.numeric(zap_labels(IDSeg)),
      code_ilot    = as.numeric(zap_labels(code_ilot)),
      ilot__id     = as.numeric(zap_labels(ilot__id)),
      batiment__id = as.numeric(zap_labels(batiment__id)),
      menage__id   = as.numeric(zap_labels(menage__id)),
      adresse_menage = as.character(adresse_menage)
    )
  
  df %>%
    select(
      interview_key = interview__key,
      region        = HH2,
      depart        = HH3,
      souspref      = HH4,
      ZD            = HH8,
      segment       = IDSeg,
      code_ilot     = code_ilot,
      ilot_id       = ilot__id,
      batiment_id   = batiment__id,
      menage_id     = menage__id,
      adresse_menage
    ) %>%
    mutate(quarter = quarter)
}


zd_info <- map_dfr(update_files, read_and_tag_file)

# Reference codes
code_ref <- read_dta(ref_path) %>%
  select(region, region_label, depart, depart_label, souspref, souspref_label) %>%
  distinct() %>%
  mutate(across(ends_with("_label"), as.character))

# Join and replace labels with numeric codes
zd_info <- zd_info %>%
  left_join(code_ref %>% distinct(region, region_label), by = c("region" = "region_label")) %>%
  left_join(code_ref %>% distinct(depart, depart_label), by = c("depart" = "depart_label")) %>%
  left_join(code_ref %>% distinct(souspref, souspref_label), by = c("souspref" = "souspref_label")) %>%
  transmute(
    interview_key,
    region    = as.double(zap_labels(region.y)),
    depart    = as.double(zap_labels(depart.y)),
    souspref  = as.double(zap_labels(souspref.y)),
    ZD,
    segment,
    code_ilot,
    ilot_id,
    batiment_id,
    menage_id,
    adresse_menage,
    quarter
  )

# ------------------------------------------------------------------------------
# 6. Aggregate Household Counts
# ------------------------------------------------------------------------------
agg_data <- zd_info %>%
  group_by(region, depart, souspref, ZD, segment, quarter) %>%
  summarise(nb_mens_seg = n(), .groups = "drop") %>%
  left_join(
    zd_info %>%
      group_by(region, depart, souspref, ZD, quarter) %>%
      summarise(nb_mens_zd = n(), .groups = "drop"),
    by = c("region", "depart", "souspref", "ZD", "quarter")
  )

# ------------------------------------------------------------------------------
# 7. Get Individual Counts (merge menage + ENEM by interview_key)
# ------------------------------------------------------------------------------

get_menage_data <- function(q) {
  # Path to the cleaned quarter-specific folder
  cleaned_path <- file.path(CLEANED_BASE_DIR, q)
  
  # Load each required dataset (menage, batiment, ilot, ENEM)
  menage_file   <- list.files(cleaned_path, pattern = "^menage.*\\.dta$", full.names = TRUE)[1]
  batiment_file <- list.files(cleaned_path, pattern = "^batiment.*\\.dta$", full.names = TRUE)[1]
  ilot_file     <- list.files(cleaned_path, pattern = "^ilot.*\\.dta$", full.names = TRUE)[1]
  enem_file     <- list.files(cleaned_path, pattern = "^ENEM.*\\.dta$", full.names = TRUE)[1]
  
  if (any(is.na(c(menage_file, batiment_file, ilot_file, enem_file)))) {
    message(paste("Skipping quarter", q, ": One or more files are missing"))
    return(NULL)
  }
  
  # Load datasets
  menage   <- read_dta(menage_file)
  batiment <- read_dta(batiment_file)
  ilot     <- read_dta(ilot_file)
  enem     <- read_dta(enem_file)
  
  # Merge menage + batiment on: interview_key, ilotid, batimentid
  menage_bat <- menage %>%
    left_join(batiment,
              by = c("interview_key", "ilot_id", "batiment_id")) %>%
    filter(!is.na(adresse))  # Remove unmatched if needed (or use _merge filter equivalent)
  
  # Merge with ilot on: interview_key and ilot_id
  if ("ilot_id" %in% names(menage_bat)) {
    menage_bat <- menage_bat %>%
      left_join(ilot, by = c("interview_key", "ilot_id"))  # bring in code_ilot
  } else {
    warning(paste("ilot_id column missing in menage + batiment merge for quarter:", q))
    return(NULL)
  }
  
  # Merge with ENEM to get region/depart/souspref/ZD
  enem_select <- enem %>%
    select(interview_key = interview_key,
           region  = hh2,
           depart  = hh3,
           souspref= hh4,
           ZD      = hh8)
  
  menage_full <- menage_bat %>%
    left_join(enem_select, by = "interview_key") %>%
    select(interview_key, region, depart, souspref, ZD,
           code_ilot, ilot_id, batiment_id, menage_id, adresse_menage, taille) %>%
    mutate(quarter = q,
           code_ilot = as.numeric(zap_label(code_ilot)))
  
  return(menage_full)
}

# Get unique quarters from zd_info
quarters <- unique(zd_info$quarter)
# Load and combine all relevant menage + ENEM files
menage_data <- map_dfr(quarters, get_menage_data)

# ------------------------------------------------------------------------------
# 8. Merge to Get Individual Counts by Segment and ZD
# ------------------------------------------------------------------------------

zd_info_indivs <- zd_info %>%
  left_join(menage_data, by = c("region", "depart", "souspref", "ZD", "code_ilot", 
                                "ilot_id", "batiment_id", "menage_id", "adresse_menage", "quarter"))

# Compute counts
zd_info_final <- zd_info_indivs %>%
  group_by(region, depart, souspref, ZD, segment, quarter) %>%
  summarise(nb_indivs_seg = sum(taille, na.rm = TRUE), .groups = "drop") %>%
  left_join(
    zd_info_indivs %>%
      group_by(region, depart, souspref, ZD, quarter) %>%
      summarise(nb_indivs_zd = sum(taille, na.rm = TRUE), .groups = "drop"),
    by = c("region", "depart", "souspref", "ZD", "quarter")
  ) %>%
  left_join(
    zd_info %>%
      group_by(region, depart, souspref, ZD, segment, quarter) %>%
      summarise(nb_mens_seg = n(), .groups = "drop") %>%
      left_join(
        zd_info %>%
          group_by(region, depart, souspref, ZD, quarter) %>%
          summarise(nb_mens_zd = n(), .groups = "drop"),
        by = c("region", "depart", "souspref", "ZD", "quarter")
      ),
    by = c("region", "depart", "souspref", "ZD", "segment", "quarter")
  )

# ------------------------------------------------------------------------------
# 8. Final Merge: Add interview_key
# ------------------------------------------------------------------------------
interview_keys <- zd_info_final %>%
  select(region, depart, souspref, ZD, segment, quarter, interview_key) %>%
  distinct()

final_dataset <- agg_data %>%
  left_join(zd_info_indivs, by = c("region", "depart", "souspref", "ZD", "segment", "quarter")) %>%
  left_join(interview_keys, by = c("region", "depart", "souspref", "ZD", "segment", "quarter")) %>%
  select(interview_key, region, depart, souspref, ZD, segment,
         nb_mens_seg, nb_mens_zd, nb_indivs_seg, nb_indivs_zd, quarter)

# ------------------------------------------------------------------------------
# 9. Save Final Dataset
# ------------------------------------------------------------------------------
output_path <- file.path(BASE_DIR, "data", "03_Processed", "final_new_denombrement.dta")
write_dta(final_dataset, output_path)

# ------------------------------------------------------------------------------
# Done
# ------------------------------------------------------------------------------
glimpse(final_dataset)
