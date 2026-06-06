# ==============================================================================
# Script_name : calc_base_weights.R
# Title       : Compute and Label Base Weights for ENE Survey
# Description : This script defines functions to compute inclusion probabilities
#               and base weights at different stages of the sampling design.
#               It also attaches variable labels for easier understanding.
# Author      : Ezechiel KOFFIE
# Date        : 11-06-2025
# ==============================================================================

# ------------------------------------------------------------------------------
# Load Required Libraries
# ------------------------------------------------------------------------------
library(dplyr)
library(haven)
library(labelled) 

# ------------------------------------------------------------------------------
# Set Base Paths and Parameters
# ------------------------------------------------------------------------------
source("config/1_config.r")
source("scripts/01_utils/check_duplicates.r")


DATA_DIR <- file.path(BASE_DIR, "data")
WEIGHTS_DIR <- file.path(DATA_DIR, "04_weights")
WEIGHTS_COLUMNS_PATH <- file.path(WEIGHTS_DIR, TARGET_QUARTER, "base_weights",
                                  paste0("base_weights_", TARGET_QUARTER, ".dta"))

INCONSISTENT_PATH = file.path(WEIGHTS_DIR, TARGET_QUARTER, "base_weights", 
                              paste0("inconsistent_rows_", TARGET_QUARTER, ".dta"))

PROBABILITY_GT1_PATH <- file.path(WEIGHTS_DIR, TARGET_QUARTER, "base_weights",
                                  paste0("probabilities_gt1_", TARGET_QUARTER, ".dta"))
# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
NB_MENS_ENQ <- 12  # Default number of households interviewed per segment
TARGET_CODES = c(10)

# ------------------------------------------------------------------------------
# Count the segments to drop
# ------------------------------------------------------------------------------
count_seg_drop <- function(file_path, target_codes) {
  data <- read_dta(file_path)
  
  # Ensure incoherence_code is treated as integer
  codes <- as.integer(data$incoherence_code)
  
  # Count total number of matches
  total_count <- sum(codes %in% target_codes, na.rm = TRUE)
  
  return(total_count)
}

get_seg_drop <- function(file_path, target_codes) {
  data <- read_dta(file_path)
  
  # Ensure incoherence_code is treated as integer
  data <- data %>%
    mutate(incoherence_code = as.integer(incoherence_code))
  
  # Filter rows with specified codes
  filtered_data <- data %>%
    filter(incoherence_code %in% target_codes) %>%
    filter(!is.na(region))   # ⬅️ suppression des region NA
  
  # Extract distinct segment identifiers
  segment_info <- filtered_data %>%
    select(region, depart, souspref, ZD, segment) %>%
    distinct()
  
  return(segment_info)
}


seg_drop = count_seg_drop(INCONSISTENT_PATH, TARGET_CODES)
seg_drop_info = get_seg_drop(INCONSISTENT_PATH, TARGET_CODES)

# ------------------------------------------------------------------------------
# Add the nb_zd_strat variable
# ------------------------------------------------------------------------------

compute_nb_zd_strat <- function(data) {
  # Calcul du nombre de ZD par région
  nb_zd_summary <- data %>%
    group_by(region) %>%
    summarise(
      nb_zd_strat    = n(),
      nb_zd_strat_wr = sum(rgmen == 1, na.rm = TRUE),
      .groups = "drop"
    )
  
  # Ajout des colonnes au data original
  data <- data %>%
    left_join(nb_zd_summary, by = "region") %>%
    mutate(
      nb_zd_strat    = ifelse(is.na(nb_zd_strat), 0, nb_zd_strat),
      nb_zd_strat_wr = ifelse(is.na(nb_zd_strat_wr), 0, nb_zd_strat_wr)
    ) %>%
    set_variable_labels(
      nb_zd_strat    = "Nombre de ZD présentes dans l'échantillon par région",
      nb_zd_strat_wr = "Nombre de ZD présentes dans l'échantillon par région (rgmen == 1)"
    )
  
  return(data)
}


# ------------------------------------------------------------------------------
# Compute ZD-level Inclusion Probabilities
# ------------------------------------------------------------------------------
compute_pi_zd <- function(region, nb_mens_seg, nb_men_reg, nb_zd_strat) {
  if (any(is.na(c(region, nb_mens_seg, nb_men_reg, nb_zd_strat))))
    return(NA_real_)
  multiplier <- ifelse(region == 10101, 104, 56)
  multiplier * ((nb_mens_seg * 6)/ nb_men_reg) * (nb_zd_strat / multiplier)
}

# ------------------------------------------------------------------------------
# Compute Household-Level Inclusion Probabilities
# ------------------------------------------------------------------------------
compute_pi_hh <- function(nb_mens_seg) {
  if (is.na(nb_mens_seg) || nb_mens_seg == 0)
    return(NA_real_)
  (NB_MENS_ENQ / nb_mens_seg) * (1 / 6)
}
# ------------------------------------------------------------------------------
# Combine Inclusion Probabilities
# ------------------------------------------------------------------------------
compute_pi_HH <- function(pi_zd, pi_hh) {
  ifelse(is.na(pi_zd) | is.na(pi_hh), NA_real_, pi_zd * pi_hh)
}

# ------------------------------------------------------------------------------
# Append Base Weights to Dataset
# ------------------------------------------------------------------------------
append_base_weights <- function(data, resurvey = TRUE) {
  # Mandatory variables for all calculations
  required_cols <- c("region",  "nb_men_reg", 
                     "nb_zd_strat", "nb_mens_seg")
  if (resurvey) {
    required_cols <- c(required_cols, "proportion")
  }
  
  missing <- setdiff(required_cols, names(data))
  if (length(missing) > 0) {
    stop(paste("Missing required columns:", paste(missing, collapse = ", ")))
  }
  
  data <- data %>%
    mutate(
      pi_zd     = mapply(compute_pi_zd,region, nb_mens_seg, nb_men_reg, nb_zd_strat),
      pi_zd_wr  = mapply(compute_pi_zd, region, nb_mens_seg, nb_men_reg, nb_zd_strat_wr),
      pi_hh     = mapply(compute_pi_hh, nb_mens_seg),
      pi_HH     = compute_pi_HH(pi_zd, pi_hh),
      pi_HH_wr  = compute_pi_HH(pi_zd_wr, pi_hh),
      base_weight_HH    = ifelse(!is.na(pi_HH) & pi_HH != 0, 1 / pi_HH, NA_real_),
      base_weight_HH_WR = ifelse(!is.na(pi_HH_wr) & pi_HH_wr != 0, 1 / pi_HH_wr, NA_real_)
    )
  
  data <- data %>%
    set_variable_labels(
      pi_zd       = "Probabilité d'inclusion au niveau de la ZD",
      pi_zd_wr    = "Probabilité d'inclusion au niveau de la ZD (Trimestre en cours uniquement)",
      pi_hh       = "Probabilité d'inclusion du ménage dans le segment",
      pi_HH       = "Probabilité d'inclusion combinée ZD × HH",
      pi_HH_wr    = "Probabilité d'inclusion combinée ZD × HH (Trimestre en cours uniquement)",
      base_weight_HH = "Poids de base des ménages du segment",
      base_weight_HH_WR = "Poids de base des ménages du segment (Trimestre en cours uniquement)"
    )
  
  return(data)
}

# ------------------------------------------------------------------------------
# Check Inclusion Probability Bounds
# ------------------------------------------------------------------------------
check_probability_bounds <- function(data, output_path = NULL, tolerance = 1e-12) {
  probability_cols <- c("pi_zd", "pi_zd_wr", "pi_hh", "pi_HH", "pi_HH_wr")
  available_cols <- intersect(probability_cols, names(data))

  if (length(available_cols) == 0) {
    warning("No probability columns found for probability bounds check.")
    return(data)
  }

  row_keys <- c(
    "region", "depart", "souspref", "ZD", "segment", "milieu", "date_ref",
    "nb_mens_seg", "nb_men_reg", "nb_zd_strat", "nb_zd_strat_wr",
    "pi_zd", "pi_zd_wr", "pi_hh", "pi_HH", "pi_HH_wr",
    "base_weight_HH", "base_weight_HH_WR"
  )

  rows_with_id <- data %>%
    mutate(row_id = dplyr::row_number())

  probability_issues <- dplyr::bind_rows(lapply(available_cols, function(col) {
    rows_with_id %>%
      filter(!is.na(.data[[col]]) & .data[[col]] > 1 + tolerance) %>%
      mutate(
        probability_var = col,
        probability_value = .data[[col]]
      ) %>%
      select(row_id, probability_var, probability_value, any_of(row_keys))
  }))

  if (nrow(probability_issues) == 0) {
    cat("Probability bounds check PASSED - no inclusion probability greater than 1\n")
    return(data)
  }

  if (!is.null(output_path)) {
    dir.create(dirname(output_path), showWarnings = FALSE, recursive = TRUE)
    write_dta(probability_issues, output_path)
  }

  cat("\nProbability bounds check FAILED - inclusion probabilities greater than 1:\n")
  print(probability_issues, n = min(50, nrow(probability_issues)))

  stop(
    "Blocage: ", nrow(probability_issues),
    " probabilite(s) d'inclusion depassent 1. ",
    "Verifier le fichier de controle: ", output_path,
    call. = FALSE
  )
}

# ------------------------------------------------------------------------------
# Calculate the base weights 
# ------------------------------------------------------------------------------
weight_data <- read_dta(WEIGHTS_COLUMNS_PATH)
## Drop the inconsistent rows
keys <- c("region", "depart", "souspref", "ZD", "segment")

weight_data <- weight_data %>%
  # 1. supprimer les lignes avec region manquante
  filter(!is.na(region)) %>%
  
  # 2. supprimer les segments/ZD listés dans seg_drop_info
  anti_join(
    seg_drop_info %>% distinct(across(all_of(keys))),
    by = keys
  )

weight_data <- weight_data %>%
  anti_join(seg_drop_info, by = c("region", "depart", "souspref", "ZD", "segment"))

# Check final data quality
cat("\n🔍 Running final quality checks...\n")
final_qc <- check_duplicates(
  weight_data, 
  c("region", "depart", "souspref", "ZD", "segment")
)

# Create quality report
if (final_qc$summary$duplicate_rows == 0) {
  cat("✅ Quality check PASSED - No duplicates found\n")
} else {
  cat("⚠️  Quality check FAILED - Found", final_qc$summary$duplicate_rows, "duplicate rows\n")
  cat("Consider reviewing the data before proceeding\n")
}
glimpse(weight_data)
source("scripts/07_correction_quarter/0_apply_quarter_correction.r")
weight_data <- apply_quarter_correction(weight_data, TARGET_QUARTER)

weight_data <- compute_nb_zd_strat(weight_data)

# Compute weights with or without resurvey logic
weight_data <- append_base_weights(weight_data, resurvey = FALSE)

weight_data <- check_probability_bounds(weight_data, output_path = PROBABILITY_GT1_PATH)

# ------------------------------------------------------------------------------
# Save Final Dataset
# ------------------------------------------------------------------------------
write_dta(weight_data, WEIGHTS_COLUMNS_PATH)
cat("Base weights calculated and saved to:", WEIGHTS_COLUMNS_PATH, "\n")















