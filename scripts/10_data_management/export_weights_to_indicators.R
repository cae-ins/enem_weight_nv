# ==============================================================================
# export_weights_to_indicators.R
# Transfère les poids calibrés vers ENE_INDICATORS_TABULATIONS
# À lancer APRÈS la calibration (run_calibration.R)
#
# Symétrique de :
#   T4_2025_v/program/copy_to_cleaned.do  (Stata → ENE_SURVEY_WEIGHTS)
# Ce script assure :
#   ENE_SURVEY_WEIGHTS → ENE_INDICATORS_TABULATIONS
# ==============================================================================

source("config/1_config.r")

# ==============================================================================
# PARAMÈTRE UNIQUE À MODIFIER
# ==============================================================================
# TARGET_QUARTER est déjà défini dans config/1_config.r (ex: "T4_2025")
# Décommenter pour surcharger ponctuellement :
# TARGET_QUARTER <- "T1_2025"

# ==============================================================================
# CHEMINS
# ==============================================================================

INDICATORS_DIR <- "C:/Users/f.migone/Desktop/ENE_INDICATORS_TABULATIONS"
DEST_BASE_DIR  <- file.path(INDICATORS_DIR, "Bulletin_Trimestriel", "Base", "Base_brute")

src_cal <- get_export_path(TARGET_QUARTER, quarter, year, use_sr = FALSE)

# Fichiers de destination (nommage cohérent avec l'existant dans Base_brute)
dest_poids    <- file.path(DEST_BASE_DIR, paste0("poids_",    TARGET_QUARTER, ".dta"))
dest_individu <- file.path(DEST_BASE_DIR, paste0("individu_", TARGET_QUARTER, "_CAL.dta"))

# ==============================================================================
# VALIDATIONS
# ==============================================================================

cat("\n")
cat("══════════════════════════════════════════════════════════\n")
cat("  EXPORT POIDS CALIBRÉS → ENE_INDICATORS_TABULATIONS\n")
cat("══════════════════════════════════════════════════════════\n\n")

cat("Trimestre cible :", TARGET_QUARTER, "\n\n")

# Vérifier source
if (!file.exists(src_cal)) {
  stop(
    "Fichier source introuvable :\n  ", src_cal,
    "\nLancez d'abord : source('scripts/04_calibration/run_calibration.R')"
  )
}
cat("✓ Source :", src_cal, "\n")
cat("  Taille :", round(file.size(src_cal) / 1024 / 1024, 1), "MB\n\n")

# Vérifier dossier destination
if (!dir.exists(DEST_BASE_DIR)) {
  stop(
    "Dossier de destination introuvable :\n  ", DEST_BASE_DIR,
    "\nVérifiez que ENE_INDICATORS_TABULATIONS est bien à l'emplacement attendu."
  )
}

# ==============================================================================
# EXTRACTION DES POIDS SEULS (poids_TX_YYYY.dta)
# Contient uniquement les identifiants + variables de poids,
# pour être mergé indépendamment dans ENE_INDICATORS_TABULATIONS
# ==============================================================================

cat("─────────────────────────────────────────────────────────\n")
cat("Étape 1 : Extraction des variables de poids\n")

library(haven)
library(dplyr)

data_cal <- read_dta(src_cal)

# Variables de poids et identifiants clés
weight_vars <- c("interview_key", "cle_individu", "membre_id",
                 "pmencor_ind", "pmencor_ind_annuel",
                 "ZD", "region", "milieu", "trimestre")

# Garder uniquement les colonnes qui existent dans le fichier
weight_vars_present <- intersect(weight_vars, names(data_cal))
missing_vars <- setdiff(weight_vars, names(data_cal))

if (length(missing_vars) > 0) {
  cat("  ⚠ Variables absentes (ignorées) :", paste(missing_vars, collapse = ", "), "\n")
}

poids_df <- data_cal %>% select(all_of(weight_vars_present))

write_dta(poids_df, dest_poids)
cat("✓ Poids exportés :", dest_poids, "\n")
cat("  Observations  :", nrow(poids_df), "\n")
cat("  Variables      :", ncol(poids_df), "\n\n")

# ==============================================================================
# COPIE DE LA BASE CALIBRÉE COMPLÈTE (individu_TX_YYYY_CAL.dta)
# ==============================================================================

cat("─────────────────────────────────────────────────────────\n")
cat("Étape 2 : Copie de la base calibrée complète\n")

file.copy(src_cal, dest_individu, overwrite = TRUE)

if (!file.exists(dest_individu)) {
  stop("Échec de la copie vers : ", dest_individu)
}

cat("✓ Base complète copiée :", dest_individu, "\n")
cat("  Taille :", round(file.size(dest_individu) / 1024 / 1024, 1), "MB\n\n")

# ==============================================================================
# RÉSUMÉ
# ==============================================================================

cat("══════════════════════════════════════════════════════════\n")
cat("  EXPORT TERMINÉ\n")
cat("══════════════════════════════════════════════════════════\n\n")

cat("Fichiers créés dans :\n")
cat("  ", DEST_BASE_DIR, "\n\n")
cat("  → poids_",    TARGET_QUARTER, ".dta   (identifiants + pmencor_ind)\n", sep = "")
cat("  → individu_", TARGET_QUARTER, "_CAL.dta  (base calibrée complète)\n\n", sep = "")

cat("Prochaine étape dans ENE_INDICATORS_TABULATIONS :\n")
cat("  workflow_complet(\"T", quarter, "\", ", year, ")\n\n", sep = "")
