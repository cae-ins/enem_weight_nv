# Project root: ENE_BASE_DIR if set, otherwise the working directory, which must
# be the repository root (every script sources "config/1_config.r" relatively).
# No path of a given computer is written in the code: the data are downloaded
# from MinIO into <root>/data (scripts/medallion/03_download_weights_inputs.ps1).
BASE_DIR <- normalizePath(Sys.getenv("ENE_BASE_DIR", unset = getwd()), winslash = "/", mustWork = TRUE)
if (!file.exists(file.path(BASE_DIR, "config", "1_config.r"))) {
  stop("BASE_DIR n'est pas la racine du dépôt ENE_SURVEY_WEIGHTS : ", BASE_DIR,
       " (lancer depuis la racine ou définir ENE_BASE_DIR)", call. = FALSE)
}
# Quarter to process: ENE_QUARTER (same variable as the MinIO scripts) or the value below.
TARGET_QUARTER <- Sys.getenv("ENE_QUARTER", unset = "T1_2026")

# Correction de la non-réponse des ménages : à partir de ce trimestre, la production
# utilise la non-réponse modélisée (03_nonresponse/2_attrition_propensity.R, après
# 02_base_weights/3_indivs_weights.R). Le poids de l'ancienne méthode (cellules
# régionales) est conservé dans d_weights_cellules et calé à côté (FINAL_WEIGHT_cellules).
NR_MODEL_FIRST_QUARTER <- "T1_2026"

# Directory templates (use `sprintf()` or `glue` for dynamic quarters)
PATHS <- list(
  # Raw data
  raw_denombrement = file.path(BASE_DIR, "data/01_raw/Denombrement/{quarter}"),
  raw_rp2021 = file.path(BASE_DIR, "data/01_raw/RP_2021"),

  # Cleaned data
  cleaned_denombrement = file.path(BASE_DIR, "data/02_cleaned/Denombrement/{quarter}"),
  cleaned_menage = file.path(BASE_DIR, "data/02_cleaned/Menage/{quarter}"),

  # Processed data
  processed_tracking = file.path(BASE_DIR, "data/03_processed/Tracking_ID"),
  processed_menage = file.path(BASE_DIR, "data/03_processed/Menage/{quarter}"),
  processed_rp2021 = file.path(BASE_DIR, "data/03_processed/RP_2021"),

  # Weights
  weights_base = file.path(BASE_DIR, "data/04_weights/{quarter}/base_weights")
)

# File templates (use `sprintf()` for placeholders like %s)
FILES <- list(
  menage          = "menage_%s.dta", # %s = quarter
  individu        = "individu_%s.dta",
  interview_map   = "interview_key_mapping_%s.dta", # %s = date
  base_weights    = "base_weights_%s.dta" # %s = quarter
)

# Helper function to generate paths
get_path <- function(type, ..., quarter = NULL) {
  path <- PATHS[[type]]
  if (!is.null(quarter)) path <- gsub("\\{quarter\\}", quarter, path)
  file.path(path, ...)
}

apply_if_exists <- function(env, fn_name, data) {
  if (exists(fn_name, envir = env, mode = "function")) {
    data <- get(fn_name, envir = env)(data)
  }
  return(data)
}

parse_target_quarter <- function(target_quarter) {
  
  # Check if input is valid
  if (is.null(target_quarter) || !is.character(target_quarter)) {
    stop("target_quarter must be a character string")
  }
  
  # Check format (should be like "T1_2025", "T2_2024", etc.)
  if (!grepl("^T[1-4]_[0-9]{4}$", target_quarter)) {
    stop("target_quarter format should be 'TX_YYYY' where X is 1-4 and YYYY is a 4-digit year")
  }
  
  # Extract quarter number and year
  parts <- strsplit(target_quarter, "_")[[1]]
  quarter_part <- parts[1]  # "T1", "T2", etc.
  year_part <- parts[2]     # "2025", "2024", etc.
  
  # Extract just the number from quarter part
  quarter <- as.numeric(gsub("T", "", quarter_part))
  year <- as.numeric(year_part)
  
  # Return as a named list
  result <- list(
    quarter = quarter,
    year = year,
    original = target_quarter
  )
  
  # Print results
  cat("Parsed target quarter:\n")
  cat("Quarter:", quarter, "\n")
  cat("Year:", year, "\n")
  
  return(result)
}
#source("scripts/02_base_weights/3_indivs_weights.R")
# Parse the target quarter
parsed <- parse_target_quarter(TARGET_QUARTER)

# Extract individual components
quarter <- parsed$quarter  
year <- parsed$year  

get_weights_path <- function(target_quarter, use_sr = FALSE) {
  # Choisir le préfixe selon SR ou pas
  prefix <- if (use_sr) "SR_individu_" else "individu_"
  
  file.path(BASE_DIR,
    "data", "04_weights", target_quarter, "base_weights",
    paste0(prefix, target_quarter, ".dta")
  )
}

get_export_path <- function(target_quarter, quarter, year, use_sr = FALSE) {
  prefix <- if (use_sr) "SR_individu" else "individu"
  
  file.path(BASE_DIR, 
    "data", "04_weights", target_quarter, "calibrated_weights",
    paste0(prefix, "_T", quarter, "_", year, "_CAL.dta")
  )
}
