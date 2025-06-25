# Project root (use `here::here()` if working in RStudio)
BASE_DIR <- "C:/Users/f.migone/Desktop/ENE_SURVEY_WEIGHTS"  
TARGET_QUARTER <- "T1_2025"
# Directory templates (use `sprintf()` or `glue` for dynamic quarters)
PATHS <- list(
  # Raw data
  raw_denombrement = file.path(BASE_DIR, "data/01_raw/Denombrement/{quarter}"),
  raw_rp2021       = file.path(BASE_DIR, "data/01_raw/RP_2021"),
  
  # Cleaned data
  cleaned_denombrement = file.path(BASE_DIR, "data/02_Cleaned/Denombrement/{quarter}"),
  cleaned_menage       = file.path(BASE_DIR, "data/02_Cleaned/Menage/{quarter}"),
  
  # Processed data
  processed_tracking = file.path(BASE_DIR, "data/03_Processed/Tracking_ID"),
  processed_menage   = file.path(BASE_DIR, "data/03_Processed/Menage/{quarter}"),
  processed_rp2021   = file.path(BASE_DIR, "data/03_Processed/RP_2021"),
  
  # Weights
  weights_base = file.path(BASE_DIR, "data/04_weights/{quarter}/base_weights")
)

# File templates (use `sprintf()` for placeholders like %s)
FILES <- list(
  menage          = "menage_%s.dta",          # %s = quarter
  individu        = "individu_%s.dta",
  interview_map   = "interview_key_mapping_%s.dta",  # %s = date
  base_weights    = "base_weights_%s.dta"     # %s = quarter
)

# Helper function to generate paths
get_path <- function(type, ..., quarter = NULL) {
  path <- PATHS[[type]]
  if (!is.null(quarter)) path <- gsub("\\{quarter\\}", quarter, path)
  file.path(path, ...)
}