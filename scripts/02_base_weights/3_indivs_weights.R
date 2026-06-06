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

DATA_DIR <- file.path(BASE_DIR, "data")
PROCESSED_DIR <- file.path(DATA_DIR, "03_processed")
WEIGHTS_DIR <- file.path(DATA_DIR, "04_weights")

# File Paths
WEIGHTS_COLUMNS_PATH <- file.path(
  WEIGHTS_DIR, TARGET_QUARTER, "base_weights",
  paste0("base_weights_", TARGET_QUARTER, ".dta")
)
MENAGE_COLUMNS_PATH <- file.path(
  WEIGHTS_DIR, TARGET_QUARTER, "base_weights",
  paste0("menage_", TARGET_QUARTER, ".dta")
)
INDIVIDU_COLUMN_PATH <- file.path(
  WEIGHTS_DIR, TARGET_QUARTER, "base_weights",
  paste0("individu_", TARGET_QUARTER, ".dta")
)
INDIVIDU_COLUMN_PATH_SR <- file.path(
  WEIGHTS_DIR, TARGET_QUARTER, "base_weights",
  paste0("SR_individu_", TARGET_QUARTER, ".dta")
)

# ==============================================================================
# Load Base Weights Data
# ==============================================================================
weights_data <- read_dta(WEIGHTS_COLUMNS_PATH)

# ==============================================================================
# Function: Adjust for Individual Non-Response
# ==============================================================================
# Nothing to do
# ==============================================================================
# Load Menage and Individu Datasets
# ==============================================================================
menage_path <- file.path(PROCESSED_DIR, "Menage", TARGET_QUARTER)
individu_path <- file.path(PROCESSED_DIR, "Individu", TARGET_QUARTER)

menage_file <- list.files(menage_path, pattern = "^menage.*\\.dta$", full.names = TRUE)[1]
individu_file <- list.files(individu_path, pattern = "^individu.*\\.dta$", full.names = TRUE)[1]

menage_q <- read_dta(menage_file)
individu_q <- read_dta(individu_file)

# Normalize column names
normalize_column_names <- function(df) {
  names(df) <- names(df) %>%
    tolower() %>%
    gsub("__", "_", .)
  df
}

menage_q <- normalize_column_names(menage_q)
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
join_keys <- c(
  "hh2" = "region", "hh3" = "depart", "hh4" = "souspref",
  "hh8" = "ZD"
)

dim(menage_q)
dim(individu_q)
menage_q <- menage_q %>% left_join(weights_data, by = join_keys)
individu_q <- individu_q %>% left_join(weights_data, by = join_keys)
dim(menage_q)
dim(individu_q)
individu_q %>%
  count(interview_key, membres_id) %>%
  filter(n > 1)
individu_q <- individu_q %>%
  distinct(interview_key, membres_id, .keep_all = TRUE)
dim(menage_q)
dim(individu_q)
# Remove dots from column names
clean_names <- function(df) {
  names(df) <- gsub("\\.", "_", names(df))
  df
}

menage_q <- clean_names(menage_q)
individu_q <- clean_names(individu_q)

individu_q <- individu_q %>%
  filter(!is.na(corrected_weight_HH))

individu_q$d_weights <- individu_q$corrected_weight_HH
individu_q_SR <- individu_q %>%
  filter(!is.na(corrected_weight_HH_WR))
individu_q_SR$d_weights <- individu_q_SR$corrected_weight_HH_WR
# ==============================================================================
# Save Updated Datasets
# ==============================================================================
write_dta(weights_data, WEIGHTS_COLUMNS_PATH)
write_dta(menage_q, MENAGE_COLUMNS_PATH)
write_dta(individu_q, INDIVIDU_COLUMN_PATH)
write_dta(individu_q_SR, INDIVIDU_COLUMN_PATH_SR)
