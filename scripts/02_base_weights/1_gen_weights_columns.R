# ==============================================================================
# Script Name: gen_weights_columns.R
# Purpose: Gather all the variables necessary for weights calculation
# Author: Ezechiel KOFFIE
# Date: 28-05-2025
# ==============================================================================

# ------------------------------------------------------------------------------
# Load Required Libraries
# ------------------------------------------------------------------------------
library(dplyr)
library(tidyr)
library(readr)
library(haven)
library(readxl)
library(labelled)
library(lubridate)
library(stringr)
library(rlang)  # for .datas

# ------------------------------------------------------------------------------
# Set Base Paths and Parameters
# ------------------------------------------------------------------------------
# Base directory for the project
source("config/1_config.r")

DATA_DIR <- file.path(BASE_DIR, "data")
CLEANED_DENOMBREMENT_DIR <- file.path(DATA_DIR, "02_Cleaned", "Denombrement", TARGET_QUARTER)
PROCESSED_DIR <- file.path(DATA_DIR, "03_Processed")
WEIGHTS_DIR <- file.path(DATA_DIR, "04_weights")
TRACKING_DIR <- file.path(PROCESSED_DIR, "Tracking_ID")

NB_MEN_INDIV_FILE <- file.path(PROCESSED_DIR, "RP_2021", "nb_men_indivs_ZD.dta")
POIDS_REGIONAUX <- file.path(PROCESSED_DIR, "RP_2021", "help_poids_regionaux.dta")
QUARTERS_EXCEL <- file.path(DATA_DIR, "01_raw", "Organisation","quarter_resurvey.xlsx")

# ------------------------------------------------------------------------------
# Load Main Dataset
# ------------------------------------------------------------------------------
nb_men_indiv_ZD <- read_dta(NB_MEN_INDIV_FILE)

nb_men_indiv_ZD <- nb_men_indiv_ZD %>%
  mutate(
    nb_indivs_zd = Nb_individus,
    nb_mens_zd = Nb_menages
  ) %>%
  select(region, depart, souspref, ZD, nb_indivs_zd, nb_mens_zd)

# ------------------------------------------------------------------------------
# Load Menage and Individu Datasets for Current Quarter
# ------------------------------------------------------------------------------
menage_path <- file.path(PROCESSED_DIR, "Menage", TARGET_QUARTER)
individu_path <- file.path(PROCESSED_DIR, "Individu", TARGET_QUARTER)

menage_file <- list.files(menage_path, pattern = "^menage.*\\.dta$", full.names = TRUE)[1]
individu_file <- list.files(individu_path, pattern = "^individu.*\\.dta$", full.names = TRUE)[1]

menage_q <- read_dta(menage_file)
individu_q <- read_dta(individu_file)

# Helper function to rename columns if needed
normalize_column_names  <- function(df) {
  names(df) <- names(df) %>%
    tolower() %>%
    gsub("__", "_", .)
  return(df)
}

menage_q <- normalize_column_names(menage_q)
individu_q <- normalize_column_names(individu_q)

# ------------------------------------------------------------------------------
# Prepare Household-Level Counts (nb_mens_enq)
# ------------------------------------------------------------------------------
mens_enq_counts <- menage_q %>%
  group_by(hh2, hh3, hh4, hh8, hh7) %>%
  summarise(nb_mens_enq = n(), .groups = "drop") %>%
  rename(region = hh2, depart = hh3, souspref = hh4, ZD = hh8, segment = hh7)

# ------------------------------------------------------------------------------
# Prepare Individual-Level Counts
# ------------------------------------------------------------------------------
menage_ids <- menage_q %>%
  select(interview_key, hh2, hh3, hh4, hh8, hh7, rgmen) %>%
  distinct()

names(individu_q) <- make.names(names(individu_q), unique = TRUE)
individu_q <- individu_q %>%
  select(-any_of(c("hh2", "hh3", "hh4", "hh8", "hh7", "rgmen")))

indiv_with_ids <- individu_q %>%
  left_join(menage_ids, by = "interview_key")

indiv_enq_counts <- indiv_with_ids %>%
  group_by(hh2, hh3, hh4, hh8, hh7) %>%
  summarise(
    nb_indivs_enq = n(),
    nb_indivs_enq_pot = sum((!is.na(m4confirm) & m4confirm > 15) | (is.na(m4confirm) & ageannee > 15), na.rm = TRUE),
    nb_indivs_enq_elig = sum(!is.na(m4confirm) & m4confirm > 15, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  rename(region = hh2, depart = hh3, souspref = hh4, ZD = hh8, segment = hh7)

# ------------------------------------------------------------------------------
# Load Cleaned Denombrement for Segment-Level Counts (Current + Resurveyed Quarters)
# ------------------------------------------------------------------------------

get_all_quarters <- function(target_q) {
  row <- quarter_mapping %>%
    filter(`Trimestre_En_Cours` == target_q) %>%
    select(starts_with("Trimestre_")) %>%
    unlist(use.names = FALSE) %>%
    na.omit() %>%
    unique()
  
  quarters <- gsub(" ", "_", row)
  return(quarters)
}

quarter_mapping <- read_excel(QUARTERS_EXCEL)

resurvey_quarters <- get_all_quarters(gsub("_", " ", TARGET_QUARTER))
all_quarters <- unique(c(TARGET_QUARTER, resurvey_quarters))

# Set unified quarter start date (for all quarters)
quarter_num <- as.integer(substr(TARGET_QUARTER, 2, 2))
year_num <- as.integer(substr(TARGET_QUARTER, 4, 7))
quarter_start_month <- c("01", "04", "07", "10")[quarter_num]
quarter_start_date <- paste0(year_num, "-", quarter_start_month, "-02") %>% ymd()

seg_survey_all <- list()

for (q in all_quarters) {
  q_dir <- file.path(DATA_DIR, "02_Cleaned", "Denombrement", q)
  
  menage_file <- list.files(q_dir, pattern = "^menage.*\\.dta$", full.names = TRUE)[1]
  enem_file   <- list.files(q_dir, pattern = "^ENEM.*\\.dta$", full.names = TRUE)[1]
  
  if (!file.exists(menage_file) || !file.exists(enem_file)) next
  
  menage <- read_dta(menage_file) %>% normalize_column_names()
  enem   <- read_dta(enem_file) %>% normalize_column_names()
  
  seg_counts <- menage %>%
    group_by(interview_key) %>%
    summarise(
      nb_mens_seg = n(),
      nb_indivs_seg = sum(taille, na.rm = TRUE),
      .groups = "drop"
    )
  
  enem <- enem %>%
    mutate(date1 = quarter_start_date)
  
  survey_info <- enem %>%
    select(interview_key, hh2, hh3, hh4, hh8, hh7, hh6,date1) %>%
    rename(
      region = hh2, depart = hh3, souspref = hh4,
      ZD = hh8, segment = hh7, milieu = hh6, date_ref = date1
    )
  
  seg_survey <- seg_counts %>%
    left_join(survey_info, by = "interview_key") %>%
    select(-interview_key) %>%
    group_by(region, depart, souspref, ZD, segment, milieu) %>%
    summarise(
      nb_mens_seg   = sum(nb_mens_seg, na.rm = TRUE),
      nb_indivs_seg = sum(nb_indivs_seg, na.rm = TRUE),
      date_ref      = first(date_ref),
      .groups = "drop"
    ) %>%
    mutate(
      rgmen = ifelse(q == TARGET_QUARTER, 1, 2),
      first_trim = q
    )
  
  seg_survey_all[[q]] <- seg_survey
}

# Bind all quarters’ data
seg_survey <- bind_rows(seg_survey_all)


# ------------------------------------------------------------------------------
# Merge with Region-Level Data
# ------------------------------------------------------------------------------
nb_men_indiv_ZD <- nb_men_indiv_ZD %>%
  mutate(
    region = as.double(zap_labels(region)),
    depart = as.double(zap_labels(depart)),
    souspref = as.double(zap_labels(souspref))
  )

final_data <- seg_survey %>%
  left_join(nb_men_indiv_ZD, by = c("region", "depart", "souspref", "ZD"))

# ------------------------------------------------------------------------------
# Functions and Add quarter phase
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# Function: quarters_since_q2_2024
# Purpose: Returns a custom quarter phase starting from Q2 2024
# ------------------------------------------------------------------------------
get_quarter_phase <- function(date_ref) {
  date_ref <- as.Date(date_ref)
  
  # Extract year and quarter
  year <- lubridate::year(date_ref)
  month <- lubridate::month(date_ref)
  quarter <- ceiling(month / 3)
  
  # Apply the mapping rules
  phase <- case_when(
    year == 2024 & quarter == 2                     ~ 1,
    (year == 2024 & quarter == 3) |
      (year == 2025 & quarter == 1)                 ~ 2,
    year == 2025 & quarter == 2                     ~ 3,
    (year > 2025) |
      (year == 2025 & quarter %in% c(3, 4))         ~ 4,
    TRUE                                            ~ NA_integer_
  )
  
  return(phase)
}


final_data <- final_data %>%
  mutate(quarter_phase = get_quarter_phase(date_ref))

poids_regionaux <- read_dta(POIDS_REGIONAUX) %>%
  mutate(
    region = as.double(CodReg),
    nb_indivs_reg = as.double(Population)
  )
final_data <- final_data %>%
    left_join(poids_regionaux %>% select(region, nb_indivs_reg), by = "region", suffix = c("", "_from_reg"))
# ------------------------------------------------------------------------------
# Fill Missing Region-Level Counts
# ------------------------------------------------------------------------------
final_data <- final_data %>%
  group_by(region) %>%
  mutate(
    nb_indivs_reg = if_else(is.na(nb_indivs_reg), first(nb_indivs_reg[!is.na(nb_indivs_reg)]), nb_indivs_reg)
  ) %>%
  ungroup()

# ------------------------------------------------------------------------------
# Merge in nb_mens_enq, nb_indivs_enq, nb_indiv_enq_elig
# ------------------------------------------------------------------------------
combined_counts <- mens_enq_counts %>%
  full_join(indiv_enq_counts, by = c("region", "depart", "souspref", "ZD", "segment"))

final_data <- final_data %>%
  left_join(combined_counts, by = c("region", "depart", "souspref", "ZD", "segment"))

final_data <- final_data %>%
  select(
    region, depart, souspref, ZD, segment, milieu,date_ref,
    nb_indivs_enq, nb_indivs_enq_pot, nb_indivs_enq_elig, 
    nb_mens_enq, nb_indivs_seg, nb_mens_seg,
    nb_indivs_zd, nb_mens_zd,
    nb_indivs_reg,
    quarter_phase, rgmen, first_trim
  )

# ------------------------------------------------------------------------------
# Update nb_mens_seg and nb_mens_zd from Denombrement_update if matching rows
# ------------------------------------------------------------------------------

# Define path to Denombrement_update and get latest file
denom_update_dir <- file.path(DATA_DIR,"02_Cleaned", "Denombrement_update")
update_files <- list.files(denom_update_dir, pattern = "\\.dta$", full.names = TRUE)

if (length(update_files) > 0) {
  latest_file <- update_files[which.max(file.info(update_files)$mtime)]
  
  # Load and normalize
  denom_update <- read_dta(latest_file)
  denom_update <- normalize_column_names(denom_update)
  
  # Ensure ZD is character and join keys have correct types
  denom_update <- denom_update %>%
    mutate(
      region   = as.double(region),
      depart   = as.double(depart),
      souspref = as.double(souspref),
      segment  = as.double(segment),
      zd       = as.character(zd)
    ) %>%
    select(region, depart, souspref, zd, segment,
           nb_mens_seg, nb_mens_zd, nb_indivs_seg, nb_indivs_zd)
  
  # Prepare final_data ZD as character for join
  final_data <- final_data %>%
    mutate(ZD = as.character(ZD)) %>%
    left_join(denom_update,
              by = c("region", "depart", "souspref", "ZD" = "zd", "segment"),
              suffix = c("", "_upd"))
  
  # Identify rows with any updated value
  updated_rows <- final_data %>%
    filter(
      !is.na(nb_mens_seg_upd) |
        !is.na(nb_mens_zd_upd) |
        !is.na(nb_indivs_seg_upd) |
        !is.na(nb_indivs_zd_upd)
    ) %>%
    select(region, depart, souspref, ZD, segment)
  
  # Print the updated combinations
  print("Updated rows:")
  print(updated_rows, n=100)
  
  # Replace values where update is available
  final_data <- final_data %>%
    mutate(
      nb_mens_seg    = if_else(!is.na(nb_mens_seg_upd),    nb_mens_seg_upd,    nb_mens_seg),
      nb_mens_zd     = if_else(!is.na(nb_mens_zd_upd),     nb_mens_zd_upd,     nb_mens_zd),
      nb_indivs_seg  = if_else(!is.na(nb_indivs_seg_upd),  nb_indivs_seg_upd,  nb_indivs_seg),
      #nb_indivs_zd   = if_else(!is.na(nb_indivs_zd_upd),   nb_indivs_zd_upd,   nb_indivs_zd)
    ) %>%
    select(-nb_mens_seg_upd, -nb_mens_zd_upd, -nb_indivs_seg_upd, -nb_indivs_zd_upd)
  
  # Drop duplicate rows
  final_data <- final_data %>%
    distinct()
}

final_data <- final_data %>%
  group_by(region, milieu) %>%
  mutate(nb_indivs_milieu = sum(nb_indivs_zd, na.rm = TRUE),
         nb_mens_milieu = sum(nb_mens_zd, na.rm= TRUE)) %>%
  ungroup()


final_data <- final_data %>%
  mutate(
    year = ifelse(!is.na(.data$first_trim) & str_detect(.data$first_trim, "^T[1-4]_\\d{4}$"),
                  as.integer(str_sub(.data$first_trim, 4, 7)),
                  NA_integer_),
    trimester = ifelse(!is.na(.data$first_trim) & str_detect(.data$first_trim, "^T[1-4]_\\d{4}$"),
                       as.integer(str_sub(.data$first_trim, 2, 2)),
                       NA_integer_),
    quarter_rank = ifelse(!is.na(year) & !is.na(trimester),
                          year * 10 + trimester,
                          NA_integer_)
  ) %>%
  group_by(region, depart, souspref, ZD) %>%
  filter(quarter_rank == max(quarter_rank, na.rm = TRUE)) %>%
  ungroup() %>%
  select(-year, -trimester, -quarter_rank) %>%
  group_by(region, milieu) %>%
  mutate(
    nb_indivs_milieu = sum(nb_indivs_zd, na.rm = TRUE),
    nb_mens_milieu = sum(nb_mens_zd, na.rm = TRUE)
  ) %>%
  ungroup()

# ------------------------------------------------------------------------------
# Set Variable Labels
# ------------------------------------------------------------------------------
var_label(final_data$region)         <- "Région"
var_label(final_data$depart)         <- "Département"
var_label(final_data$souspref)       <- "Sous-préfecture"
var_label(final_data$ZD)             <- "Zone de dénombremement"
var_label(final_data$segment)        <- "Segment"
var_label(final_data$milieu)         <- "Milieu de résidence"
var_label(final_data$date_ref)       <- "Date de référence du début"
var_label(final_data$nb_indivs_seg)  <- "Nombre d'individus du segment"
var_label(final_data$nb_mens_seg)    <- "Nombre de ménages du segment"
var_label(final_data$nb_indivs_reg)  <- "Nombre d'individus de la région"
#var_label(final_data$nb_mens_reg)    <- "Nombre de ménages de la région"
var_label(final_data$nb_indivs_zd)   <- "Nombre d'individus de la ZD"
var_label(final_data$nb_mens_zd)     <- "Nombre de ménages de la ZD"
var_label(final_data$quarter_phase)  <- "Nombre de trimestres enquêtés"
var_label(final_data$nb_mens_enq)    <- "Nombre de ménages effectivement enquêtés"
var_label(final_data$nb_indivs_enq)  <- "Nombre d'individus effectivement enquêtés"
var_label(final_data$nb_indivs_enq_pot) <- "Nombre de ménages enquêtés potentiellement éligibles"
var_label(final_data$nb_indivs_enq_elig) <- "Nombre d'individus éligibles"
var_label(final_data$nb_indivs_milieu) <- "Nombre d'individus par (region, milieu de résidence)"
var_label(final_data$nb_mens_milieu) <- "Nombre de ménages par (region, milieu de résidence)"
var_label(final_data$rgmen)          <- "Rang d'interrogation"
var_label(final_data$first_trim)     <- "Premier trimestre d'interrogation"

# ------------------------------------------------------------------------------
# Define integer codes as values with labels as names (required by `labelled()`)
# ------------------------------------------------------------------------------
incoherence_labels <- c(
  "Nb ménages du segment manquant"             = 1L,
  "Nb ménages de la ZD manquant"               = 2L,
  "Nb individus du segment manquant"           = 3L,
  "Nb individus de la ZD manquant"             = 4L,
  "Nb individus enquêtés manquant"             = 5L,
  "Nb ménages enquêtés manquant"               = 6L,
  "Ménages du segment > ménages de la ZD"      = 7L,
  "Individus du segment > individus de la ZD"  = 8L,
  "Ménages du segment > individus du segment"  = 9L,
  "Aucun ménage ou individu enquêté"           = 10L,
  "ZD dupliquée"                               = 11L
)

# ------------------------------------------------------------------------------
# Create the labelled variable
# ------------------------------------------------------------------------------
inconsistent_rows <- final_data %>%
  group_by(region, depart, souspref, ZD, segment) %>%
  mutate(
    tmp_is_duplicate = n() > 1
  ) %>%
  ungroup() %>%
  mutate(
    incoherence_code = case_when(
      is.na(nb_mens_enq) & is.na(nb_indivs_enq) ~ 10L,
      is.na(nb_mens_seg)                        ~ 1L,
      is.na(nb_mens_zd)                         ~ 2L,
      is.na(nb_indivs_seg)                      ~ 3L,
      is.na(nb_indivs_zd)                       ~ 4L,
      is.na(nb_indivs_enq)                      ~ 5L,
      is.na(nb_mens_enq)                        ~ 6L,
      nb_mens_seg > nb_mens_zd                  ~ 7L,
      nb_indivs_seg > nb_indivs_zd              ~ 8L,
      nb_mens_seg > nb_indivs_seg               ~ 9L,
      tmp_is_duplicate                          ~ 11L,
      TRUE ~ NA_integer_
    ),
    incoherence_code = labelled(incoherence_code, labels = incoherence_labels)
  ) %>%
  select(-tmp_is_duplicate) %>%
  filter(!is.na(incoherence_code))


# ------------------------------------------------------------------------------
# Save Final Dataset
# ------------------------------------------------------------------------------
output_file <- file.path(WEIGHTS_DIR, TARGET_QUARTER, "base_weights",paste0("base_weights_", TARGET_QUARTER, ".dta"))
inconsistent_file <- file.path(WEIGHTS_DIR, TARGET_QUARTER, "base_weights", paste0("inconsistent_rows_", TARGET_QUARTER, ".dta"))
dir.create(dirname(output_file), showWarnings = FALSE, recursive = TRUE)
write_dta(final_data, output_file)
write_dta(inconsistent_rows, inconsistent_file)
# ------------------------------------------------------------------------------
# Done
# ------------------------------------------------------------------------------
glimpse(final_data)
