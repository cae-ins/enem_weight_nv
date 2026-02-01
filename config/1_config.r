# Project root (use `here::here()` if working in RStudio)
BASE_DIR <- "C:/Users/f.migone/Desktop/ENE_SURVEY_WEIGHTS"
setwd(BASE_DIR)
TARGET_QUARTER <- "T3_2025"

# Install required packages if not already installed
required_packages <- c("survey","dplyr", "haven", "labelled", "readxl", "stringr", "purrr", "paws", "aws.signature", "jsonlite")
new_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]
if (length(new_packages)) {
  install.packages(new_packages)
}
# Directory templates (use `sprintf()` or `glue` for dynamic quarters)
PATHS <- list(
  # Raw data
  raw_denombrement = file.path(BASE_DIR, "data/01_raw/Denombrement/{quarter}"),
  raw_rp2021 = file.path(BASE_DIR, "data/01_raw/RP_2021"),

  # Cleaned data
  cleaned_denombrement = file.path(BASE_DIR, "data/02_Cleaned/Denombrement/{quarter}"),
  cleaned_menage = file.path(BASE_DIR, "data/02_Cleaned/Menage/{quarter}"),

  # Processed data
  processed_tracking = file.path(BASE_DIR, "data/03_Processed/Tracking_ID"),
  processed_menage = file.path(BASE_DIR, "data/03_Processed/Menage/{quarter}"),
  processed_rp2021 = file.path(BASE_DIR, "data/03_Processed/RP_2021"),

  # Weights
  weights_base = file.path(BASE_DIR, "data/04_weights/{quarter}/base_weights")
)
library(paws)
library(aws.signature)
library(jsonlite)
#
# -- Fonction de connexion à MinIO depuis un fichier JSON --
# connect_minio <- function(credentials_path, endpoint_url, verify = FALSE) {
# Lire le fichier JSON
#  creds <- fromJSON(credentials_path)

# Connexion S3 via paws avec credentials + endpoint + verify
#  s3 <- paws::s3(
#    config = list(
#      credentials = list(
#        creds = list(
#          access_key_id = creds$access_key,
#          secret_access_key = creds$secret_key
#        )
#      ),
#      endpoint = endpoint_url,
#      region = "",
#      s3_force_path_style = TRUE,
#      ssl_verification = verify
#    )
#  )

#  return(s3)
# }

# -- Exemple d'utilisation --
# credentials_file <- "credentials.json"
# endpoint <- "http://192.168.1.230:30137"

# s3 <- connect_minio(credentials_file, endpoint)

# -- Test : liste les buckets --
# print(s3$list_buckets())

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