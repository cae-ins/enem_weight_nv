#' Utilitaires pour la calibration trimestrielle
#'
#' Ce fichier contient les fonctions utilitaires pour la calibration des poids
#' de l'enquête ENE. Ces fonctions permettent d'éviter la duplication de code
#' entre les différents trimestres et schémas de calibration.

# ============================================================================
#' Charger la configuration d'un schéma de calibration
#'
#' @param schema_id Identifiant du schéma (ex: "180X_1D", "312X_1D")
#' @return Liste avec les paramètres du schéma
#' @export
load_schema_config <- function(schema_id) {
  config_file <- file.path(BASE_DIR, "scripts/04_calibration/config/schemas_calibration.csv")

  if (!file.exists(config_file)) {
    stop("Fichier de configuration des schémas introuvable: ", config_file)
  }

  schemas <- read.csv(config_file, stringsAsFactors = FALSE)
  schema <- schemas[schemas$schema_id == schema_id, ]

  if (nrow(schema) == 0) {
    stop("Schéma introuvable: ", schema_id)
  }

  return(as.list(schema))
}

# ============================================================================
#' Construire tous les chemins de fichiers pour une calibration
#'
#' @param year Année (numérique)
#' @param quarter Trimestre (1-4)
#' @param target_quarter Trimestre cible au format "TX_YYYY"
#' @param pathx Identifiant du schéma (ex: "180X_1D")
#' @param setx Identifiant du set de contraintes
#' @return Liste de tous les chemins de fichiers nécessaires
#' @export
build_calibration_paths <- function(year, quarter, target_quarter, pathx, setx) {

  # Répertoires de base
  dir_data_DV <- file.path(BASE_DIR, "data/05_DERIVED_VARIABLES", year, paste0("T", quarter))
  dir_data_PE <- file.path(BASE_DIR, "data/06_POPULATION_ESTIMATES", year, paste0("T", quarter))
  dir_data_QW <- file.path(BASE_DIR, "data/07_QUARTERLY_WEIGHTING", year, paste0("T", quarter), pathx)
  dir_prog_QW <- file.path(BASE_DIR, "scripts/04_calibration/QUARTERLY_WEIGHTING/constraints", pathx)

  # Fonction helper pour les poids
  get_weights_path <- function(target_quarter, use_sr = FALSE) {
    prefix <- if (use_sr) "SR_individu_" else "individu_"
    file.path(BASE_DIR, "data/04_weights", target_quarter, "base_weights",
              paste0(prefix, target_quarter, ".dta"))
  }

  # Fonction helper pour l'export
  get_export_path <- function(target_quarter, quarter, year, use_sr = FALSE) {
    prefix <- if (use_sr) "SR_individu" else "individu"
    file.path(BASE_DIR, "data/04_weights", target_quarter, "calibrated_weights",
              paste0(prefix, "_T", quarter, "_", year, "_CAL.dta"))
  }

  paths <- list(
    # Répertoires
    dir_data_DV = dir_data_DV,
    dir_data_PE = dir_data_PE,
    dir_data_QW = dir_data_QW,
    dir_prog_QW = dir_prog_QW,

    # Fichiers d'entrée - Sample data
    FILE_LFS_ILO_DER_DTA = get_weights_path(target_quarter, use_sr = FALSE),
    FILE_LFS_ILO_DER_RDATA = file.path(dir_data_DV, paste0("LFS_ILO_", year, "_T", quarter, "_DER.RData")),

    # Fichiers d'entrée - Population estimates
    FILE_POP_LFS_BY_REGION_SEX_2AGEGR_CSV = file.path(dir_data_PE, paste0("POP_LFS_BY_REGION_SEX_2AGEGR_", year, "_T", quarter, ".csv")),
    FILE_POP_LFS_BY_REGION_SEX_2AGEGR_XLSX = file.path(dir_data_PE, paste0("POP_LFS_BY_REGION_SEX_2AGEGR_", year, "_T", quarter, ".xlsx")),
    FILE_POP_LFS_BY_REGION_SEX_2AGEGR_DTA = file.path(dir_data_PE, paste0("POP_LFS_BY_REGION_SEX_2AGEGR_", year, "_T", quarter, ".dta")),
    FILE_POP_LFS_BY_REGION_SEX_2AGEGR_RDATA = file.path(dir_data_PE, paste0("POP_LFS_BY_REGION_SEX_2AGEGR_", year, "_T", quarter, ".RData")),

    # Fichiers intermédiaires - Sample data préparées pour Regenesees
    FILE_LFS_SAMPLE_DATA_RDATA = file.path(dir_data_QW, paste0("LFS_SAMPLE_DATA_", year, "_T", quarter, "_", pathx, ".RData")),
    FILE_LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE_RDATA = file.path(dir_data_QW, paste0("LFS_SAMPLE_DATA_", year, "_T", quarter, "_", pathx, "_SUMMARY_OF_Xs_SAMPLE_SIZE.RData")),
    FILE_LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE_XLSX = file.path(dir_data_QW, paste0("LFS_SAMPLE_DATA_", year, "_T", quarter, "_", pathx, "_SUMMARY_OF_Xs_SAMPLE_SIZE.xlsx")),
    FILE_LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT_RDATA = file.path(dir_data_QW, paste0("LFS_SAMPLE_DATA_", year, "_T", quarter, "_", pathx, "_SUMMARY_OF_Xs_EST_DES_WEIGHT.RData")),
    FILE_LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT_XLSX = file.path(dir_data_QW, paste0("LFS_SAMPLE_DATA_", year, "_T", quarter, "_", pathx, "_SUMMARY_OF_Xs_EST_DES_WEIGHT.xlsx")),

    # Fichiers intermédiaires - Known totals
    FILE_LFS_KNOWN_TOTALS_RDATA = file.path(dir_data_QW, paste0("LFS_KNOWN_TOTALS_", year, "_T", quarter, "_", pathx, ".RData")),
    FILE_LFS_KNOWN_TOTALS_XLSX = file.path(dir_data_QW, paste0("LFS_KNOWN_TOTALS_", year, "_T", quarter, "_", pathx, ".xlsx")),

    # Fichiers de sortie - Final weights
    FILE_LFS_CALIBRATION_FINAL_WEIGHTS_RDATA = file.path(dir_data_QW, paste0("LFS_CALIBRATION_", year, "_T", quarter, "_", pathx, "_FINAL_WEIGHTS.RData")),
    FILE_LFS_CALIBRATION_SUMMARY_OF_FINAL_WEIGHTS_CSV = file.path(dir_data_QW, paste0("LFS_CALIBRATION_", year, "_T", quarter, "_", pathx, "_SUMMARY_OF_FINAL_WEIGHTS.csv")),
    FILE_LFS_CALIBRATION_SUMMARY_OF_FINAL_WEIGHTS_RDATA = file.path(dir_data_QW, paste0("LFS_CALIBRATION_", year, "_T", quarter, "_", pathx, "_SUMMARY_OF_FINAL_WEIGHTS.RData")),
    FILE_LFS_CALIBRATION_SUMMARY_OF_FINAL_WEIGHTS_MILIEU_CSV = file.path(dir_data_QW, paste0("LFS_CALIBRATION_", year, "_T", quarter, "_", pathx, "_SUMMARY_OF_FINAL_WEIGHTS_MILIEU.csv")),
    FILE_LFS_CALIBRATION_SUMMARY_OF_FINAL_WEIGHTS_MILIEU_RDATA = file.path(dir_data_QW, paste0("LFS_CALIBRATION_", year, "_T", quarter, "_", pathx, "_SUMMARY_OF_FINAL_WEIGHTS_MILIEU.RData")),

    # Fichiers de sortie - Design weights summaries
    FILE_LFS_CALIBRATION_SUMMARY_OF_DESIGN_WEIGHTS_CSV = file.path(dir_data_QW, paste0("LFS_CALIBRATION_", year, "_T", quarter, "_", pathx, "_SUMMARY_OF_DESIGN_WEIGHTS.csv")),
    FILE_LFS_CALIBRATION_SUMMARY_OF_DESIGN_WEIGHTS_RDATA = file.path(dir_data_QW, paste0("LFS_CALIBRATION_", year, "_T", quarter, "_", pathx, "_SUMMARY_OF_DESIGN_WEIGHTS.RData")),
    LFS_CALIBRATION_SUMMARY_OF_DESIGN_WEIGHTS_MILIEU_CSV = file.path(dir_data_QW, paste0("LFS_CALIBRATION_", year, "_T", quarter, "_", pathx, "_SUMMARY_OF_DESIGN_WEIGHTS_MILIEU.csv")),
    LFS_CALIBRATION_SUMMARY_OF_DESIGN_WEIGHTS_MILIEU_RDATA = file.path(dir_data_QW, paste0("LFS_CALIBRATION_", year, "_T", quarter, "_", pathx, "_SUMMARY_OF_DESIGN_WEIGHTS_MILIEU.RData")),

    # Fichiers de sortie - Correction factors
    FILE_LFS_CALIBRATION_SUMMARY_OF_FINAL_CORR_FACTORS_CSV = file.path(dir_data_QW, paste0("LFS_CALIBRATION_", year, "_T", quarter, "_", pathx, "_SUMMARY_OF_FINAL_CORR_FACTORS.csv")),
    FILE_LFS_CALIBRATION_SUMMARY_OF_FINAL_CORR_FACTORS_RDATA = file.path(dir_data_QW, paste0("LFS_CALIBRATION_", year, "_T", quarter, "_", pathx, "_SUMMARY_OF_FINAL_CORR_FACTORS.RData")),
    FILE_LFS_CALIBRATION_SUMMARY_OF_FINAL_CORR_FACTORS_MILIEU_CSV = file.path(dir_data_QW, paste0("LFS_CALIBRATION_", year, "_T", quarter, "_", pathx, "_SUMMARY_OF_FINAL_CORR_FACTORS_MILIEU.csv")),
    FILE_LFS_CALIBRATION_SUMMARY_OF_FINAL_CORR_FACTORS_MILIEU_RDATA = file.path(dir_data_QW, paste0("LFS_CALIBRATION_", year, "_T", quarter, "_", pathx, "_SUMMARY_OF_FINAL_CORR_FACTORS_MILIEU.RData")),

    # Fichiers de sortie - Image et données calibrées
    FILE_LFS_CALIBRATION_IMAGE_RDATA = file.path(dir_data_QW, paste0("LFS_CALIBRATION_", year, "_T", quarter, "_", pathx, "_IMAGE.RData")),
    FILE_LFS_ILO_CAL_RDATA = file.path(dir_data_QW, paste0("LFS_ILO_", year, "_T", quarter, "_CAL.RData")),
    FILE_LFS_ILO_CAL_DTA = file.path(dir_data_QW, paste0("LFS_ILO_", year, "_T", quarter, "_CAL.dta")),
    FILE_LFS_ILO_CAL_DTA_EXPORT = get_export_path(target_quarter, quarter, year, use_sr = FALSE),

    # Fichiers de sortie - Tables et précision
    FILE_TABLE_1_XLSX = file.path(dir_data_QW, paste0("Table1_", year, "_T", quarter, "_", pathx, ".xlsx")),
    FILE_TEMPLATE_TABLE_1_XLSX = file.path(dir_prog_QW, "Template_table_1.xlsx"),
    LFS_STD_ERR_EMP_LEVELS_CSV = file.path(dir_data_QW, paste0("LFS_STD_ERR_EMP_LEVELS_", year, "_T", quarter, "_", pathx, ".csv")),
    LFS_TABLE_CVS_EMP_LEVEL_TEMPLATE3_XLSX = file.path(dir_data_QW, paste0("Table_CVS_EMPL_Levels_ver3_", year, "_T", quarter, "_", pathx, ".xlsx")),

    # Fichiers de configuration - Scripts et contraintes
    R_SCRIPT_NEW_FUNCTIONS_FOR_X_CONSTRAINS = file.path(BASE_DIR, "scripts/04_calibration/QUARTERLY_WEIGHTING/Other_R_functions_for_Regenesees/Functions_to_Create _X_vector_and_X_Summary_Table.R"),
    R_SCRIPT_X_FORMATS = file.path(BASE_DIR, "scripts/04_calibration/functions/04f_XFormats.R"),
    FILE_CONSTRAINTS_XLSX = file.path(dir_prog_QW, paste0("01_Set_of_constraints_", setx, ".xlsx")),

    # Fichiers additionnels pour statistiques sur Xs
    FILE_LFS_CALIBRATION_SUMMARY_OF_Xs_STATS_XLSX = file.path(dir_data_QW, paste0("LFS_CALIBRATION_", year, "_Q", quarter, "_", pathx, "_SUMMARY_OF_Xs_STATS.xlsx")),
    FILE_LFS_CALIBRATION_SUMMARY_OF_Xs_STATS_RDATA = file.path(dir_data_QW, paste0("LFS_CALIBRATION_", year, "_Q", quarter, "_", pathx, "_SUMMARY_OF_Xs_STATS.RData")),

    # Templates
    LFS_STD_ERR_EMP_LEVEL_TEMPLATE3_XLSX = file.path(BASE_DIR, "scripts/04_calibration/STANDARD_ERRORS/Templates/Template_CVS_EMP_Levels_ver3.xlsx")
  )

  # Créer les répertoires s'ils n'existent pas
  for (dir_path in c(paths$dir_data_QW, paths$dir_prog_QW)) {
    if (!dir.exists(dir_path)) {
      dir.create(dir_path, recursive = TRUE, showWarnings = FALSE)
    }
  }

  return(paths)
}

# ============================================================================
#' Initialiser l'environnement pour une calibration
#'
#' @param target_quarter Trimestre cible au format "TX_YYYY" (ex: "T1_2025")
#' @param schema_id Identifiant du schéma (ex: "180X_1D")
#' @return Liste avec toutes les configurations et chemins
#' @export
initialize_calibration_env <- function(target_quarter, schema_id) {

  # Parser le target quarter
  parsed <- parse_target_quarter(target_quarter)
  quarter <- parsed$quarter
  year <- parsed$year

  # Charger la configuration du schéma
  schema_config <- load_schema_config(schema_id)

  # Construire tous les chemins
  paths <- build_calibration_paths(
    year = year,
    quarter = quarter,
    target_quarter = target_quarter,
    pathx = schema_config$pathx,
    setx = schema_config$setx
  )

  # Retourner l'environnement complet
  env <- list(
    target_quarter = target_quarter,
    year = year,
    quarter = quarter,
    xnum = schema_config$xnum,
    setx = schema_config$setx,
    pathx = schema_config$pathx,
    schema_id = schema_id,
    description = schema_config$description,
    paths = paths
  )

  cat("\n==========================================================\n")
  cat("Environnement de calibration initialisé\n")
  cat("==========================================================\n")
  cat("Trimestre cible:", target_quarter, "\n")
  cat("Année:", year, "\n")
  cat("Trimestre:", quarter, "\n")
  cat("Schéma:", schema_id, "\n")
  cat("Description:", schema_config$description, "\n")
  cat("Nombre de contraintes:", schema_config$xnum, "\n")
  cat("==========================================================\n\n")

  return(env)
}

# ============================================================================
#' Parser un trimestre cible
#'
#' @param target_quarter Trimestre au format "TX_YYYY"
#' @return Liste avec quarter, year, et original
#' @export
parse_target_quarter <- function(target_quarter) {

  if (is.null(target_quarter) || !is.character(target_quarter)) {
    stop("target_quarter must be a character string")
  }

  if (!grepl("^T[1-4]_[0-9]{4}$", target_quarter)) {
    stop("target_quarter format should be 'TX_YYYY' where X is 1-4 and YYYY is a 4-digit year")
  }

  parts <- strsplit(target_quarter, "_")[[1]]
  quarter_part <- parts[1]
  year_part <- parts[2]

  quarter <- as.numeric(gsub("T", "", quarter_part))
  year <- as.numeric(year_part)

  result <- list(
    quarter = quarter,
    year = year,
    original = target_quarter
  )

  return(result)
}
