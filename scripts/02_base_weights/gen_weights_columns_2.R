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

# ------------------------------------------------------------------------------
# Set Base Paths and Parameters
# ------------------------------------------------------------------------------
BASE_DIR <- "C:/Users/e_koffie/Documents/Ponderations_ENE/ENE_SURVEY_WEIGHTS"
TARGET_QUARTER <- "T3_2024"  # Change to target quarter

DATA_DIR <- file.path(BASE_DIR, "data")
CLEANED_DENOMBREMENT_DIR <- file.path(DATA_DIR, "02_Cleaned", "Denombrement", TARGET_QUARTER)
PROCESSED_DIR <- file.path(DATA_DIR, "03_Processed")
WEIGHTS_DIR <- file.path(DATA_DIR, "04_weights")
TRACKING_DIR <- file.path(PROCESSED_DIR, "Tracking_ID")

NB_MEN_INDIV_FILE <- file.path(PROCESSED_DIR, "RP_2021", "nb_men_indivs_ZD.dta")
INC_PROB_FUNC_PATH <- file.path(BASE_DIR, "scripts", "02_base_weights", "inc_probs_functions.R")

# ------------------------------------------------------------------------------
# Load Main Dataset
# ------------------------------------------------------------------------------
nb_men_indiv_ZD <- read_dta(NB_MEN_INDIV_FILE)

nb_men_indiv_ZD <- nb_men_indiv_ZD %>%
  mutate(
    nb_indivs_zd = Nb_individus,
    nb_mens_zd = Nb_menages
  ) %>%
  group_by(region) %>%
  mutate(
    nb_indivs_reg = sum(Nb_individus, na.rm = TRUE),
    nb_mens_reg = sum(Nb_menages, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  select(region, depart, souspref, ZD,
         nb_indivs_reg, nb_mens_reg,
         nb_indivs_zd, nb_mens_zd)

# ------------------------------------------------------------------------------
# Load Menage and Individu Datasets for Current Quarter
# ------------------------------------------------------------------------------
menage_path <- file.path(PROCESSED_DIR, "Menage", TARGET_QUARTER)
individu_path <- file.path(PROCESSED_DIR, "Individu", TARGET_QUARTER)

menage_file <- list.files(menage_path, pattern = "^menage.*\\.dta$", full.names = TRUE)[1]
individu_file <- list.files(individu_path, pattern = "^individu.*\\.dta$", full.names = TRUE)[1]

menage_q <- read_dta(menage_file)
individu_q <- read_dta(individu_file)

# ------------------------------------------------------------------------------
# Clean column names (normalize interview_key)
# ------------------------------------------------------------------------------
names(menage_q) <- gsub("interview__key", "interview_key", names(menage_q))
names(individu_q) <- gsub("interview__key", "interview_key", names(individu_q))

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
  select(interview_key, hh2, hh3, hh4, hh8, hh7) %>%
  distinct()

indiv_with_ids <- individu_q %>%
  left_join(menage_ids, by = "interview_key")

indiv_enq_counts <- indiv_with_ids %>%
  group_by(hh2, hh3, hh4, hh8, hh7) %>%
  summarise(
    nb_indivs_enq = n(),
    nb_indivs_enq_elig = sum(!is.na(M4Confirm)),
    .groups = "drop"
  ) %>%
  rename(region = hh2, depart = hh3, souspref = hh4, ZD = hh8, segment = hh7)

# ------------------------------------------------------------------------------
# Load Cleaned Denombrement for Segment-Level Counts
# ------------------------------------------------------------------------------
denom_menage_file <- list.files(CLEANED_DENOMBREMENT_DIR, pattern = "^menage.*\\.dta$", full.names = TRUE)[1]
denom_enem_file   <- list.files(CLEANED_DENOMBREMENT_DIR, pattern = "^ENEM.*\\.dta$", full.names = TRUE)[1]

menage <- read_dta(denom_menage_file)
enem   <- read_dta(denom_enem_file)

seg_counts <- menage %>%
  group_by(interview_key) %>%
  summarise(
    nb_mens_seg = n(),
    nb_indivs_seg = sum(taille, na.rm = TRUE),
    .groups = "drop"
  )

# ------------------------------------------------------------------------------
# Handle Reference Date
# ------------------------------------------------------------------------------
quarter_num <- as.integer(substr(TARGET_QUARTER, 2, 2))
year_num <- as.integer(substr(TARGET_QUARTER, 4, 7))
quarter_start_month <- c("01", "04", "07", "10")[quarter_num]
quarter_start_date <- paste0(year_num, "-", quarter_start_month, "-02") %>% ymd()

if (!"date1" %in% names(enem)) {
  enem <- enem %>% mutate(date1 = quarter_start_date)
}

survey_info <- enem %>%
  select(interview_key, hh2, hh3, hh4, hh8, hh7, date1) %>%
  rename(
    region = hh2, depart = hh3, souspref = hh4,
    ZD = hh8, segment = hh7, date_ref = date1
  )

seg_survey <- seg_counts %>%
  left_join(survey_info, by = "interview_key")

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
# Source Inclusion Probability Functions and Add nb_zd_strat
# ------------------------------------------------------------------------------
source(INC_PROB_FUNC_PATH)

final_data <- final_data %>%
  mutate(nb_zd_strat = quarters_since_q2_2024(date_ref))

# ------------------------------------------------------------------------------
# Fill Missing Region-Level Counts
# ------------------------------------------------------------------------------
final_data <- final_data %>%
  group_by(region) %>%
  mutate(
    nb_indivs_reg = if_else(is.na(nb_indivs_reg), first(nb_indivs_reg[!is.na(nb_indivs_reg)]), nb_indivs_reg),
    nb_mens_reg = if_else(is.na(nb_mens_reg), first(nb_mens_reg[!is.na(nb_mens_reg)]), nb_mens_reg)
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
    region, depart, souspref, ZD, segment, date_ref,
    nb_indivs_enq, nb_indivs_enq_elig, nb_mens_enq,
    nb_indivs_seg, nb_mens_seg,
    nb_indivs_zd, nb_mens_zd,
    nb_indivs_reg, nb_mens_reg,
    nb_zd_strat
  )
# ------------------------------------------------------------------------------
# Set Variable Labels
# ------------------------------------------------------------------------------
var_label(final_data$region)         <- "Région"
var_label(final_data$depart)         <- "Département"
var_label(final_data$souspref)       <- "Sous-préfecture"
var_label(final_data$ZD)             <- "Zone de dénombremement"
var_label(final_data$segment)        <- "Segment"
var_label(final_data$date_ref)       <- "Date de référence du début"
var_label(final_data$nb_indivs_seg)  <- "Nombre d'individus du segment"
var_label(final_data$nb_mens_seg)    <- "Nombre de ménages du segment"
var_label(final_data$nb_indivs_reg)  <- "Nombre d'individus de la région"
var_label(final_data$nb_mens_reg)    <- "Nombre de ménages de la région"
var_label(final_data$nb_indivs_zd)   <- "Nombre d'individus de la ZD"
var_label(final_data$nb_mens_zd)     <- "Nombre de ménages de la ZD"
var_label(final_data$nb_zd_strat)    <- "Nombre de ZD enquêtés dans la région ce trimestre"
#var_label(final_data$interview_key)  <- "Interview key"
var_label(final_data$nb_mens_enq)    <- "Nombre de ménages effectivement enquêtés"
var_label(final_data$nb_indivs_enq)  <- "Nombre d'individus effectivement enquêtés"
var_label(final_data$nb_indivs_enq_elig) <- "Nombre d'individus éligibles (M4Confirm non NA)"

# ------------------------------------------------------------------------------
# Save Final Dataset
# ------------------------------------------------------------------------------
output_file <- file.path(WEIGHTS_DIR, "Menage", TARGET_QUARTER, paste0("weights_columns_", TARGET_QUARTER, ".dta"))
dir.create(dirname(output_file), showWarnings = FALSE, recursive = TRUE)
write_dta(final_data, output_file)

# ------------------------------------------------------------------------------
# Done
# ------------------------------------------------------------------------------
glimpse(final_data)