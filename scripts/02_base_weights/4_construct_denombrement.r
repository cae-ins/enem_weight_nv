DATA_DIR <- file.path(BASE_DIR, "data")
CLEANED_DENOMBREMENT_DIR <- file.path(DATA_DIR, "02_Cleaned", "Denombrement", TARGET_QUARTER)
PROCESSED_DIR <- file.path(DATA_DIR, "03_Processed")
WEIGHTS_DIR <- file.path(DATA_DIR, "04_weights")
TRACKING_DIR <- file.path(PROCESSED_DIR, "Tracking_ID")

NB_MEN_INDIV_FILE <- file.path(PROCESSED_DIR, "RP_2021", "nb_men_indivs_ZD.dta")
POIDS_REGIONAUX <- file.path(PROCESSED_DIR, "RP_2021", "help_poids_regionaux.dta")
QUARTERS_EXCEL <- file.path(DATA_DIR, "01_raw", "Organisation","quarter_resurvey.xlsx")

library(dplyr)
charger_corrections <- function(q, domaine = "denombrement") {
  fichier <- file.path(BASE_DIR, "scripts", "07_correction_quarter", domaine, paste0("correction_", q, ".r"))
  env <- new.env()
  if (file.exists(fichier)) {
    source(fichier, local = env)
  } else {
    warning(paste("Pas de fichier de correction pour", q))
  }
  return(env)
}



# ------------------------------------------------------------------


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
library(purrr)
library(dplyr)
library(haven)  # pour read_dta

# Fonction modulaire qui traite un trimestre donné
traiter_denombr_quarter <- function(q) {
  env <- charger_corrections(q, domaine = "denombrement")

  q_dir <- file.path(DATA_DIR, "02_Cleaned", "Denombrement", q)
  menage_file <- list.files(q_dir, pattern = "^menage.*\\.dta$", full.names = TRUE)
  enem_file <- list.files(q_dir, pattern = "^ENEM.*\\.dta$", full.names = TRUE)
  if (length(menage_file) == 0 || length(enem_file) == 0) return(NULL)
  if (!file.exists(menage_file[1]) || !file.exists(enem_file[1])) return(NULL)

  menage <- read_dta(menage_file[1]) %>% normalize_column_names()
  enem <- read_dta(enem_file[1]) %>% normalize_column_names()

  enem <- apply_if_exists(env, "suppression_par_interview_key", enem)
  enem <- apply_if_exists(env, "correction_reaffectation_denombrement", enem)

  seg_counts <- menage %>%
    group_by(interview_key) %>%
    summarise(
      nb_mens_seg = n(),
      nb_indivs_seg = sum(taille, na.rm = TRUE),
      .groups = "drop"
    )

  seg_counts <- apply_if_exists(env, "correction_taille_segment_par_interview_key", seg_counts)

  enem <- enem %>% mutate(date1 = quarter_start_date)

  survey_info <- enem %>%
    select(interview_key, hh2, hh3, hh4, hh8, hh7, hh6, date1) %>%
    rename(
      region = hh2,
      depart = hh3,
      souspref = hh4,
      ZD = hh8,
      segment = hh7,
      milieu = hh6,
      date_ref = date1
    )

  seg_survey <- seg_counts %>%
    left_join(survey_info, by = "interview_key") %>%
    select(-interview_key) %>%
    group_by(region, depart, souspref, ZD, segment, milieu) %>%
    summarise(
      nb_mens_seg = sum(nb_mens_seg, na.rm = TRUE),
      nb_indivs_seg = sum(nb_indivs_seg, na.rm = TRUE),
      date_ref = first(date_ref),
      .groups = "drop"
    ) %>%
    mutate(
      rgmen = ifelse(q == TARGET_QUARTER, 1, 2),
      first_trim = q
    )

  seg_survey <- apply_if_exists(env, "correction_taille_segment_par_geo", seg_survey)
  seg_survey <- apply_if_exists(env, "suppression_par_combinaisons_geo", seg_survey)
  seg_survey <- apply_if_exists(env, "ajouter_missing", seg_survey)

  return(seg_survey)
}


seg_survey_all <- set_names(all_quarters) %>%
  map(traiter_denombr_quarter)

# Bind all quarters’ data
seg_survey <- bind_rows(seg_survey_all)
glimpse(seg_survey)
