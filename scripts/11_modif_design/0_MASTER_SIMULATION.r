# ======================================================================
# SCRIPT MASTER - SIMULATION DE RÉDUCTION D'ÉCHANTILLON LFS
# ======================================================================
#
# CE SCRIPT ORCHESTRE L'ENSEMBLE DU PIPELINE DE SIMULATION
#
# INSTRUCTIONS:
# 1. Modifier uniquement les paramètres dans la section "PARAMÈTRES À MODIFIER"
# 2. Exécuter ce script
# 3. Les résultats seront sauvegardés dans data/04_weights/simulation/{TARGET_QUARTER}/
#
# ======================================================================

# Nettoyer l'environnement
rm(list = ls())
gc()

# ======================================================================
# ██████╗  █████╗ ██████╗  █████╗ ███╗   ███╗███████╗████████╗██████╗ ███████╗███████╗
# ██╔══██╗██╔══██╗██╔══██╗██╔══██╗████╗ ████║██╔════╝╚══██╔══╝██╔══██╗██╔════╝██╔════╝
# ██████╔╝███████║██████╔╝███████║██╔████╔██║█████╗     ██║   ██████╔╝█████╗  ███████╗
# ██╔═══╝ ██╔══██║██╔══██╗██╔══██║██║╚██╔╝██║██╔══╝     ██║   ██╔══██╗██╔══╝  ╚════██║
# ██║     ██║  ██║██║  ██║██║  ██║██║ ╚═╝ ██║███████╗   ██║   ██║  ██║███████╗███████║
# ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝
# ======================================================================
# PARAMÈTRES À MODIFIER (SECTION UNIQUE)
# ======================================================================

# Trimestre cible (format: "YYYY_TX" ex: "2025_T3")
PARAM_TARGET_QUARTER <- "2025_T3"

# Taux de réduction de l'échantillon (entre 0 et 1)
# 0.75 = garder 75% des ménages = réduction de 25%
# 0.50 = garder 50% des ménages = réduction de 50%
PARAM_RATIO_REDUCTION <- 0.75

# Nombre d'itérations de simulation
PARAM_N_ITER <- 30

# Nombre de ménages enquêtés par segment (base)
PARAM_NB_MENS_ENQ_BASE <- 12

# Seed pour la reproductibilité
PARAM_SEED <- 123

# ======================================================================
# FIN DES PARAMÈTRES - NE PAS MODIFIER EN DESSOUS
# ======================================================================

# ----------------------------------------------------------------------
# CONFIGURATION AUTOMATIQUE
# ----------------------------------------------------------------------

# Charger la configuration de base
source("config/1_config.r")

# Créer les variables dérivées
PARAM_NB_MENS_ENQ_SIM <- PARAM_NB_MENS_ENQ_BASE * PARAM_RATIO_REDUCTION
PARAM_SUFFIXE_SIMU <- paste0(PARAM_TARGET_QUARTER, "_", PARAM_RATIO_REDUCTION * 100, "pct")

# Définir les chemins
DATA_DIR <- file.path(BASE_DIR, "data")
WEIGHTS_DIR <- file.path(DATA_DIR, "04_weights")
SIMULATION_DIR <- file.path(WEIGHTS_DIR, "simulation")
SIMULATION_QUARTER_DIR <- file.path(SIMULATION_DIR, PARAM_TARGET_QUARTER)
SCRIPTS_DIR <- file.path(BASE_DIR, "scripts", "11_modif_design")

# Créer les dossiers si nécessaire
dir.create(SIMULATION_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(SIMULATION_QUARTER_DIR, showWarnings = FALSE, recursive = TRUE)

# Sauvegarder les paramètres dans un fichier pour référence
params_list <- list(
  TARGET_QUARTER = PARAM_TARGET_QUARTER,
  RATIO_REDUCTION = PARAM_RATIO_REDUCTION,
  N_ITER = PARAM_N_ITER,
  NB_MENS_ENQ_BASE = PARAM_NB_MENS_ENQ_BASE,
  NB_MENS_ENQ_SIM = PARAM_NB_MENS_ENQ_SIM,
  SEED = PARAM_SEED,
  SUFFIXE_SIMU = PARAM_SUFFIXE_SIMU,
  DATE_EXECUTION = Sys.time()
)

saveRDS(params_list, file.path(SIMULATION_QUARTER_DIR, paste0("params_", PARAM_SUFFIXE_SIMU, ".rds")))

# ----------------------------------------------------------------------
# AFFICHAGE DES PARAMÈTRES
# ----------------------------------------------------------------------

cat("\n")
cat("╔══════════════════════════════════════════════════════════════════╗\n")
cat("║         SIMULATION DE RÉDUCTION D'ÉCHANTILLON LFS               ║\n")
cat("╠══════════════════════════════════════════════════════════════════╣\n")
cat("║ Paramètres:                                                      ║\n")
cat(sprintf("║   - Trimestre cible     : %-37s║\n", PARAM_TARGET_QUARTER))
cat(sprintf("║   - Taux de réduction   : %-37s║\n", paste0(PARAM_RATIO_REDUCTION * 100, "%")))
cat(sprintf("║   - Ménages/segment     : %-37s║\n", paste0(PARAM_NB_MENS_ENQ_SIM, " (au lieu de ", PARAM_NB_MENS_ENQ_BASE, ")")))
cat(sprintf("║   - Nombre d'itérations : %-37s║\n", PARAM_N_ITER))
cat(sprintf("║   - Seed                : %-37s║\n", PARAM_SEED))
cat("╠══════════════════════════════════════════════════════════════════╣\n")
cat(sprintf("║ Dossier de sortie: %-45s║\n", ""))
cat(sprintf("║   %s\n", SIMULATION_QUARTER_DIR))
cat("╚══════════════════════════════════════════════════════════════════╝\n")
cat("\n")

# ----------------------------------------------------------------------
# FONCTIONS UTILITAIRES
# ----------------------------------------------------------------------

run_step <- function(step_number, step_name, script_path) {
  cat("\n")
  cat("┌──────────────────────────────────────────────────────────────────┐\n")
  cat(sprintf("│ ÉTAPE %d: %-56s│\n", step_number, step_name))
  cat("└──────────────────────────────────────────────────────────────────┘\n")

  temps_debut <- Sys.time()

  tryCatch({
    source(script_path)
    temps_fin <- Sys.time()
    duree <- difftime(temps_fin, temps_debut, units = "mins")
    cat(sprintf("\n✓ Étape %d terminée en %.2f minutes\n", step_number, as.numeric(duree)))
    return(TRUE)
  }, error = function(e) {
    cat(sprintf("\n✗ ERREUR à l'étape %d: %s\n", step_number, e$message))
    return(FALSE)
  })
}

# ----------------------------------------------------------------------
# EXÉCUTION DU PIPELINE
# ----------------------------------------------------------------------

temps_total_debut <- Sys.time()

cat("\n")
cat("═══════════════════════════════════════════════════════════════════\n")
cat("                    DÉBUT DU PIPELINE                              \n")
cat("═══════════════════════════════════════════════════════════════════\n")

# Étape 1: Sélection aléatoire des PSU
step1_ok <- run_step(1, "Sélection aléatoire des PSU",
                     file.path(SCRIPTS_DIR, "1_selection_aleatoire_psu_auto.r"))

if (!step1_ok) {
  stop("Pipeline arrêté à l'étape 1")
}

# Étape 2: Calcul des poids de base
step2_ok <- run_step(2, "Calcul des poids de base",
                     file.path(SCRIPTS_DIR, "2_poids_de_base_auto.r"))

if (!step2_ok) {
  stop("Pipeline arrêté à l'étape 2")
}

# Étape 3: Calibration
step3_ok <- run_step(3, "Calibration",
                     file.path(SCRIPTS_DIR, "3_calibration_auto.r"))

if (!step3_ok) {
  stop("Pipeline arrêté à l'étape 3")
}

# Étape 4: Fusion avec données individuelles
step4_ok <- run_step(4, "Fusion avec données individuelles",
                     file.path(SCRIPTS_DIR, "4_attach_lfs_ind_data_auto.r"))

if (!step4_ok) {
  stop("Pipeline arrêté à l'étape 4")
}

# Étape 5: Estimation de la précision
step5_ok <- run_step(5, "Estimation de la précision",
                     file.path(SCRIPTS_DIR, "5_estimate_precision_auto.r"))

if (!step5_ok) {
  stop("Pipeline arrêté à l'étape 5")
}

# ----------------------------------------------------------------------
# RÉSUMÉ FINAL
# ----------------------------------------------------------------------

temps_total_fin <- Sys.time()
duree_totale <- difftime(temps_total_fin, temps_total_debut, units = "mins")

cat("\n")
cat("═══════════════════════════════════════════════════════════════════\n")
cat("                    PIPELINE TERMINÉ                               \n")
cat("═══════════════════════════════════════════════════════════════════\n")
cat(sprintf("Durée totale: %.2f minutes\n", as.numeric(duree_totale)))
cat(sprintf("Résultats dans: %s\n", SIMULATION_QUARTER_DIR))
cat("\n")
cat("Fichiers générés (avec suffixe:", PARAM_SUFFIXE_SIMU, "):\n")
cat("  - resume_30_iterations_", PARAM_SUFFIXE_SIMU, ".parquet/.dta\n", sep = "")
cat("  - resume_transformations_", PARAM_SUFFIXE_SIMU, ".dta\n", sep = "")
cat("  - resume_calibrations_", PARAM_SUFFIXE_SIMU, ".dta/.xlsx\n", sep = "")
cat("  - resume_fusions_", PARAM_SUFFIXE_SIMU, ".dta/.xlsx\n", sep = "")
cat("  - indicateurs_SU_survey_complet_", PARAM_SUFFIXE_SIMU, ".xlsx\n", sep = "")
cat("  - recapitulatif_SU_survey_", PARAM_SUFFIXE_SIMU, ".dta\n", sep = "")
cat("  - graphique_SU_SE_", PARAM_SUFFIXE_SIMU, ".png\n", sep = "")
cat("  - graphique_SU_CV_", PARAM_SUFFIXE_SIMU, ".png\n", sep = "")
cat("\n")
cat("Par itération (dans iteration_X/):\n")
cat("  - LFS_ILO_CAL_IND_FUSED_", PARAM_SUFFIXE_SIMU, "_iter_X.dta\n", sep = "")
cat("  - base_psu_enrichie_", PARAM_SUFFIXE_SIMU, "_iter_X.dta\n", sep = "")
cat("  - individus_enrichis_", PARAM_SUFFIXE_SIMU, "_iter_X.dta\n", sep = "")
cat("\n")
