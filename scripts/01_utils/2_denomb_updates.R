# ==============================================================================
# Script Name: denomb_updates.R
# Purpose: Process newly updated ZD counts from Denombrement_update
#          and create a harmonized dataset with household and individual counts
# Author: Ezechiel KOFFIE
# Date: 13-07-2025
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
source("config/1_config.r")

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
# 4. Read and Combine Excel Files
# ------------------------------------------------------------------------------
skipped_files <- c()

read_and_tag_file <- function(file_path) {
  quarter <- extract_quarter(file_path)
  df <- read_excel(file_path)
  
  if (!"IDSeg" %in% names(df)) {
    skipped_files <<- c(skipped_files, file_path)
    return(NULL)
  }
  
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
    ) %>%
    select(
      interview_key = interview__key,
      region        = HH2,
      depart        = HH3,
      souspref      = HH4,
      ZD            = HH8,
      segment       = IDSeg,
      code_ilot,
      ilot_id       = ilot__id,
      batiment_id   = batiment__id,
      menage_id     = menage__id,
      adresse_menage
    ) %>%
    mutate(quarter = quarter)
  
  return(df)
}

zd_info <- map_dfr(update_files, read_and_tag_file)

# ------------------------------------------------------------------------------
# 5. Reference Label Mapping
# ------------------------------------------------------------------------------
code_ref <- read_dta(ref_path) %>%
  select(region, region_label, depart, depart_label, souspref, souspref_label) %>%
  distinct() %>%
  mutate(across(ends_with("_label"), as.character))

zd_info <- zd_info %>%
  left_join(code_ref %>% distinct(region, region_label), by = c("region" = "region_label")) %>%
  left_join(code_ref %>% distinct(depart, depart_label), by = c("depart" = "depart_label")) %>%
  left_join(code_ref %>% distinct(souspref, souspref_label), by = c("souspref" = "souspref_label")) %>%
  transmute(
    interview_key,
    region    = as.double(zap_labels(region.y)),
    depart    = as.double(zap_labels(depart.y)),
    souspref  = as.double(zap_labels(souspref.y)),
    ZD        = as.character(ZD),
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
# 7. Extract Menage and Individual Info
# ------------------------------------------------------------------------------
normalize_column_names <- function(df) {
  names(df) <- tolower(gsub("__", "_", names(df)))
  return(df)
}

get_menage_data <- function(q) {
  cleaned_path <- file.path(CLEANED_BASE_DIR, q)
  
  menage_file   <- list.files(cleaned_path, pattern = "^menage.*\\.dta$", full.names = TRUE)[1]
  batiment_file <- list.files(cleaned_path, pattern = "^batiment.*\\.dta$", full.names = TRUE)[1]
  ilot_file     <- list.files(cleaned_path, pattern = "^ilot.*\\.dta$", full.names = TRUE)[1]
  enem_file     <- list.files(cleaned_path, pattern = "^ENEM.*\\.dta$", full.names = TRUE)[1]
  
  if (any(is.na(c(menage_file, batiment_file, ilot_file, enem_file)))) {
    message(paste("Skipping quarter", q, ": One or more files are missing"))
    return(NULL)
  }
  
  menage   <- read_dta(menage_file)   %>% normalize_column_names()
  batiment <- read_dta(batiment_file) %>% normalize_column_names()
  ilot     <- read_dta(ilot_file)     %>% normalize_column_names()
  enem     <- read_dta(enem_file)     %>% normalize_column_names()
  
  menage_bat <- menage %>%
    left_join(batiment, by = c("interview_key", "ilot_id", "batiment_id")) %>%
    filter(!is.na(adresse))
  
  menage_bat <- menage_bat %>%
    left_join(ilot, by = c("interview_key", "ilot_id"))
  
  enem_select <- enem %>%
    select(interview_key, region = hh2, depart = hh3, souspref = hh4, ZD = hh8) %>%
    mutate(ZD = as.character(ZD))
  
  menage_full <- menage_bat %>%
    left_join(enem_select, by = "interview_key") %>%
    select(interview_key, region, depart, souspref, ZD,
           code_ilot, ilot_id, batiment_id, menage_id, adresse_menage, taille) %>%
    mutate(quarter = q, code_ilot = as.numeric(zap_labels(code_ilot)))
  
  return(menage_full)
}

quarters <- unique(zd_info$quarter)
menage_data <- map_dfr(quarters, get_menage_data)

# ------------------------------------------------------------------------------
# 8. Merge Menage Info to ZD and Aggregate Individuals
# ------------------------------------------------------------------------------
zd_info_indivs <- zd_info %>%
  left_join(menage_data, by = c("region", "depart", "souspref", "ZD", "code_ilot", 
                                "ilot_id", "batiment_id", "menage_id", "adresse_menage", "quarter"))

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
    agg_data,
    by = c("region", "depart", "souspref", "ZD", "segment", "quarter")
  )

# ------------------------------------------------------------------------------
# 9. Final Dataset Formatting
# ------------------------------------------------------------------------------
final_dataset <- zd_info_final %>%
  select(
    region, depart, souspref, ZD, segment,
    nb_indivs_seg, nb_mens_seg, nb_indivs_zd, nb_mens_zd, quarter
  ) %>%
  mutate(
    ZD = str_pad(as.character(ZD), width = 4, side = "left", pad = "0")
  )

# ------------------------------------------------------------------------------
# 10. Save Final Dataset with Timestamp
# ------------------------------------------------------------------------------
timestamp <- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")
output_filename <- paste0("denombrement_update_", timestamp, ".dta")
output_path <- file.path(BASE_DIR, "data", "02_Cleaned", "Denombrement_update", output_filename)

subset_dataset <- final_dataset %>%
  filter(segment == 1)

# --------------------------------------------------------------------------------------------------------------
# 11. Traitement spécifique pour les données de T2_2024 dont les fichiers excels de ZDs ne sont plus disponibles
# --------------------------------------------------------------------------------------------------------------

final_dataset <- update_T2_2024(final_dataset)
subset_dataset <- update_T2_2024(subset_dataset)

# --------------------------------------------------------------------------------------------------------------
# 12. Traitement spécifique pour les données de T4_2024 (idem)
# --------------------------------------------------------------------------------------------------------------

final_dataset <- update_T4_2024(final_dataset)
subset_dataset <- update_T4_2024(subset_dataset)

# ------------------------------------------------------------------------------
# 13. Final save
# ------------------------------------------------------------------------------

glimpse(final_dataset)
glimpse(subset_dataset)

message("Final dataset created with ", nrow(final_dataset), " records.")
write_dta(final_dataset, output_path)
message("Dataset segment 1 created with ", nrow(subset_dataset), " records.")
write_dta(subset_dataset, output_path)
