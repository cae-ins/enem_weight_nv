# ==============================================================================
# Libraries
# ==============================================================================
library(dplyr)
library(haven)
library(labelled)

# ==============================================================================
# Paths and Parameters
# ==============================================================================
source("config/1_config.r")

DATA_DIR       <- file.path(BASE_DIR, "data")
PROCESSED_DIR  <- file.path(DATA_DIR, "03_Processed")
WEIGHTS_DIR    <- file.path(DATA_DIR, "04_weights")

# File Paths
WEIGHTS_COLUMNS_PATH <- file.path(WEIGHTS_DIR, TARGET_QUARTER, "base_weights",
                                  paste0("base_weights_", TARGET_QUARTER, ".dta"))
MENAGE_COLUMNS_PATH  <- file.path(WEIGHTS_DIR, TARGET_QUARTER, "base_weights",
                                  paste0("menage_", TARGET_QUARTER, ".dta"))
INDIVIDU_COLUMN_PATH <- file.path(WEIGHTS_DIR, TARGET_QUARTER, "base_weights",
                                  paste0("individu_", TARGET_QUARTER, ".dta"))
INDIVIDU_COLUMN_PATH_SR <- file.path(WEIGHTS_DIR, TARGET_QUARTER, "base_weights",
                                  paste0("SR_individu_", TARGET_QUARTER, ".dta"))                                  

# ==============================================================================
# Load Base Weights Data
# ==============================================================================
weights_data <- read_dta(WEIGHTS_COLUMNS_PATH)

# ==============================================================================
# Function: Adjust for Individual Non-Response
# ==============================================================================
#Nothing to do
# ==============================================================================
# Load Menage and Individu Datasets
# ==============================================================================
menage_path   <- file.path(PROCESSED_DIR, "Menage", TARGET_QUARTER)
individu_path <- file.path(PROCESSED_DIR, "Individu", TARGET_QUARTER)

menage_file   <- list.files(menage_path, pattern = "^menage.*\\.dta$", full.names = TRUE)[1]
individu_file <- list.files(individu_path, pattern = "^individu.*\\.dta$", full.names = TRUE)[1]

menage_q   <- read_dta(menage_file)
individu_q <- read_dta(individu_file)

# Normalize column names
normalize_column_names <- function(df) {
  names(df) <- names(df) %>%
    tolower() %>%
    gsub("__", "_", .)
  df
}

menage_q   <- normalize_column_names(menage_q)
individu_q <- normalize_column_names(individu_q)
names(individu_q) <- make.names(names(individu_q), unique = TRUE)

# ==============================================================================
# Join Identifiers
# ==============================================================================
menage_ids <- menage_q %>%
  select(interview_key, hh2, hh3, hh4, hh8) %>%
  distinct()

individu_q <- individu_q %>%
  select(-any_of(c("hh2", "hh3", "hh4", "hh8"))) %>%
  left_join(menage_ids, by = "interview_key")

# ==============================================================================
# Merge Adjusted Weights
# ==============================================================================
join_keys <- c("hh2" = "region", "hh3" = "depart", "hh4" = "souspref",
               "hh8" = "ZD")

menage_q   <- menage_q   %>% left_join(weights_data, by = join_keys)
individu_q <- individu_q %>% left_join(weights_data, by = join_keys)

# Remove dots from column names
clean_names <- function(df) {
  names(df) <- gsub("\\.", "_", names(df))
  df
}

# ------------------------------------------------------------------
# Fonctions utilitaires et traitement conditionnel selon le trimestre
# ------------------------------------------------------------------
# Fonction utilitaire pour comparer deux trimestres
# quarter_after <- function(q1, q2) {
#   # q1 et q2 au format "Tn_YYYY"
#   to_num <- function(q) {
#     parts <- strsplit(q, "_")[[1]]
#     quarter <- as.integer(sub("T", "", parts[1]))
#     year <- as.integer(parts[2])
#     return(year * 10 + quarter)  # ex: 2024T2 -> 20242
#   }
#   to_num(q1) > to_num(q2)
# }
# 
# # Si TARGET_QUARTER > T2_2024 → on fait la fusion
# if (quarter_after(TARGET_QUARTER, "T2_2024")) {
#   individu_q <- individu_q %>%
#     left_join(
#       menage_q %>%
#         select(interview_key,
#                v1modintr,
#                v1interviewkey,
#                v1interviewkey_next_trim,
#                v1interviewkey1er),
#       by = "interview_key"
#     )
# }
# 
# # Fonction utilitaire pour détecter NA, "", ou "##N/A##"
# is_empty_or_na <- function(x) {
#   is.na(x) | trimws(x) == ""
# }
# 
# if (TARGET_QUARTER == "T2_2024") {
#   # Cas T2_2024 : pas de version v1
#   individu_q <- individu_q %>%
#     mutate(
#       id_gen = paste(interview_key, membres_id, sep = "_")
#     )
# } else {
#   # Autres trimestres : on remplace valeur manquante par la version originale
#   individu_q <- individu_q %>%
#     mutate(
#       id_gen = paste(
#         ifelse(is_empty_or_na(v1interviewkey), interview_key, v1interviewkey),
#         ifelse(is_empty_or_na(membre_id_v1), membres_id, membre_id_v1),
#         sep = "_"
#       )
#     )
# }

menage_q   <- clean_names(menage_q)
individu_q <- clean_names(individu_q)

individu_q$d_weights <- individu_q$corrected_weight_HH 
individu_q_SR <- individu_q %>%
  filter(!is.na(corrected_weight_HH_WR))
individu_q_SR$d_weights  <- individu_q_SR$corrected_weight_HH_WR 
# ==============================================================================
# Save Updated Datasets
# ==============================================================================
write_dta(adjusted_data, WEIGHTS_COLUMNS_PATH)
write_dta(menage_q, MENAGE_COLUMNS_PATH)
write_dta(individu_q, INDIVIDU_COLUMN_PATH)
write_dta(individu_q_SR, INDIVIDU_COLUMN_PATH_SR)
