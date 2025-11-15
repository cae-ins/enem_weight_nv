# ==============================================================================
# Libraries
# ==============================================================================
library(dplyr)
library(haven)
library(labelled)
library(readxl)
library(tibble)

# ==============================================================================
# Mode : "quarter" ou "year"
# ==============================================================================
MODE <- "year"            # <-- mettre "quarter" ou "year"

source("config/1_config.r")

DATA_DIR    <- file.path(BASE_DIR, "data")
WEIGHTS_DIR <- file.path(DATA_DIR, "04_weights")

# ==============================================================================
# Fonction de parsing trimestriel
# ==============================================================================
parse_target_quarter <- function(target_quarter) {
  if (!grepl("^T[1-4]_[0-9]{4}$", target_quarter)) {
    stop("Format attendu : TX_YYYY")
  }
  parts <- strsplit(target_quarter, "_")[[1]]
  list(
    quarter = as.numeric(gsub("T","",parts[1])),
    year    = as.numeric(parts[2]),
    original = target_quarter
  )
}
parsed  <- parse_target_quarter(TARGET_QUARTER)
quarter <- parsed$quarter
year    <- parsed$year

quarter
year

# ==============================================================================
# Détermination du chemin INDIVIDU selon le MODE
# ==============================================================================
if (MODE == "quarter") {
  
  parsed  <- parse_target_quarter(TARGET_QUARTER)
  quarter <- parsed$quarter
  year    <- parsed$year
  TARGET_YEAR <- as.character(year)

  message("🔹 Mode trimestriel activé : ", TARGET_QUARTER)
  
  get_export_path <- function(target_quarter, quarter, year) {
    file.path(
      BASE_DIR, "data", "04_weights", target_quarter, "calibrated_weights",
      paste0("individu_T", quarter, "_", year, "_CAL.dta")
    )
  }
  
  INDIVIDU_PATH <- get_export_path(TARGET_QUARTER, quarter, year)

  OUT_DIR <- file.path(WEIGHTS_DIR, TARGET_QUARTER, "household_weights")
  MENAGE_OUT_PATH_15PLUS <- file.path(OUT_DIR,
                                      paste0("menage_weights_15plus_", TARGET_QUARTER, ".dta"))
  MENAGE_OUT_PATH_ALL    <- file.path(OUT_DIR,
                                      paste0("menage_weights_all_", TARGET_QUARTER, ".dta"))

  
} else if (MODE == "year") {
  TARGET_YEAR <- as.character(year)
  message("🔹 Mode annuel activé : ", TARGET_YEAR)

  INDIVIDU_PATH <- file.path(
    WEIGHTS_DIR, TARGET_YEAR,
    paste0("individu_calibrated_", TARGET_YEAR, ".dta")
  )

  OUT_DIR <- file.path(WEIGHTS_DIR, TARGET_YEAR, "household_weights")
  MENAGE_OUT_PATH_15PLUS <- file.path(OUT_DIR,
                                      paste0("menage_weights_15plus_", TARGET_YEAR, ".dta"))
  MENAGE_OUT_PATH_ALL    <- file.path(OUT_DIR,
                                      paste0("menage_weights_all_", TARGET_YEAR, ".dta"))
}

dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)


# ==============================================================================
# Load Data
# ==============================================================================
message("📥 Lecture du fichier : ", INDIVIDU_PATH)
indiv_data <- read_dta(INDIVIDU_PATH)

required_vars <- c("interview_key", "FINAL_WEIGHT", "ageannee")
missing_vars  <- setdiff(required_vars, names(indiv_data))
if (length(missing_vars) > 0) stop("Variables manquantes : ", paste(missing_vars, collapse=", "))


# ==============================================================================
# Household weights function
# ==============================================================================
compute_household_weights <- function(data, age_filter = TRUE) {
  df <- if (age_filter) data %>% filter(ageannee >= 15) else data
  
  df %>%
    group_by(interview_key) %>%
    summarise(
      n_members = n(),
      hh_weight = mean(FINAL_WEIGHT, na.rm=TRUE),
      .groups = "drop"
    )
}

# ==============================================================================
# Compute Weights
# ==============================================================================
message("📌 Calcul poids ménages 15+")
menage_weights_15plus <- compute_household_weights(indiv_data, TRUE)

message("📌 Calcul poids ménages tous âges")
menage_weights_all <- compute_household_weights(indiv_data, FALSE)

# ==============================================================================
# Save
# ==============================================================================
write_dta(menage_weights_15plus, MENAGE_OUT_PATH_15PLUS)
write_dta(menage_weights_all,    MENAGE_OUT_PATH_ALL)

message("\n✅ Fichiers enregistrés :")
message(" - ", MENAGE_OUT_PATH_15PLUS)
message(" - ", MENAGE_OUT_PATH_ALL)
