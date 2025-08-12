# Project root (use `here::here()` if working in RStudio)
BASE_DIR <- "C:/Users/f.migone/Desktop/ENE_SURVEY_WEIGHTS"  
setwd(BASE_DIR)
TARGET_QUARTER <- "T2_2025"

# Install required packages if not already installed
required_packages <- c("dplyr", "haven", "labelled", "readxl", "stringr", "purrr","paws","aws.signature","jsonlite")
new_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]
if (length(new_packages)) {
  install.packages(new_packages)
}
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
library(paws)
library(aws.signature)
library(jsonlite)
#
# -- Fonction de connexion à MinIO depuis un fichier JSON --
#connect_minio <- function(credentials_path, endpoint_url, verify = FALSE) {
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
#}

# -- Exemple d'utilisation --
#credentials_file <- "credentials.json"
#endpoint <- "http://192.168.1.230:30137"

#s3 <- connect_minio(credentials_file, endpoint)

# -- Test : liste les buckets --
#print(s3$list_buckets())

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

apply_if_exists <- function(env, fn_name, data) {
  if (exists(fn_name, envir = env, mode = "function")) {
    data <- get(fn_name, envir = env)(data)
  }
  return(data)
}
