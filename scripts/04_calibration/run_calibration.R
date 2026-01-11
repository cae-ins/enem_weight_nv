########################################################################################################################
########################################################################################################################
########################################################################################################################
########                                                                                                        ########
########                 SCRIPT ORCHESTRATEUR DE CALIBRATION TRIMESTRIELLE - VERSION DYNAMIQUE                 ########
########                                                                                                        ########
########                           Enquête Nationale sur l'Emploi (ENE-M) - Côte d'Ivoire                      ########
########                                                                                                        ########
########  Ce script remplace les 237 fichiers dupliqués par une approche paramétrée et dynamique                ########
########  qui évite la répétition de code et facilite la maintenance                                            ########
########                                                                                                        ########
########  UTILISATION:                                                                                          ########
########    1. Définir TARGET_QUARTER et SCHEMA_ID ci-dessous                                                   ########
########    2. Source ce script : source("scripts/04_calibration/run_calibration.R")                           ########
########    3. La calibration s'exécute automatiquement                                                         ########
########                                                                                                        ########
########  AVANTAGES:                                                                                            ########
########    - 1 seul fichier au lieu de 237                                                                     ########
########    - Tous les schémas centralisés dans config/schemas_calibration.csv                                 ########
########    - Modifications propagées instantanément à tous les trimestres/schémas                              ########
########    - Facilité de maintenance et de débogage                                                            ########
########                                                                                                        ########
########################################################################################################################
########################################################################################################################
########################################################################################################################


# ============================================================================
# CONFIGURATION PRINCIPALE
# ============================================================================
# À MODIFIER selon vos besoins

# Trimestre cible (format: "TX_YYYY" où X = 1-4, YYYY = année)
# Exemples: "T1_2025", "T2_2024", "T3_2025"
TARGET_QUARTER <- "T1_2025"    # MODIFIEZ ICI

# Schéma de calibration à utiliser
# Options disponibles: "180X_1D", "312X_1D", "444X_1D", "182X_1D",
#                      "156X_1D_ALLWR_np", "222X_1D_ALLWR_np", etc.
# Voir config/schemas_calibration.csv pour la liste complète
SCHEMA_ID <- "180X_1D"         # MODIFIEZ ICI

# Option pour utiliser SR (Sans Réponse) - généralement FALSE
USE_SR <- FALSE

# Mode interactif pour tester les bornes de calibration
# Si TRUE, le script s'arrête avant la calibration pour vous permettre
# de tester différentes bornes interactivement
INTERACTIVE_BOUNDS_MODE <- FALSE    # MODIFIEZ ICI pour activer le mode interactif


# ============================================================================
# CHARGEMENT DES LIBRAIRIES
# ============================================================================

cat("\n")
cat("########################################################\n")
cat("# Chargement des librairies nécessaires...            #\n")
cat("########################################################\n\n")

library("rstudioapi")     # Navigation dans RStudio
library("ReGenesees")     # Calibration et calcul de poids
library("dplyr")          # Manipulation de données
library("summarytools")   # Résumés statistiques
library("excel.link")     # Interaction avec Excel
library("readxl")         # Lecture de fichiers Excel
library("writexl")        # Écriture de fichiers Excel
library("expss")          # Tables pondérées
library("haven")          # Lecture/écriture SPSS et Stata

cat("✓ Toutes les librairies chargées avec succès\n\n")


# ============================================================================
# CHARGEMENT DE LA CONFIGURATION GLOBALE
# ============================================================================

cat("########################################################\n")
cat("# Chargement de la configuration globale...           #\n")
cat("########################################################\n\n")

# Charger le fichier de configuration principal
source("config/1_config.r")

# Charger les fonctions utilitaires de calibration
source(file.path(BASE_DIR, "scripts/04_calibration/functions/calibration_utils.R"))

# Charger les fonctions interactives pour le test des bornes
source(file.path(BASE_DIR, "scripts/04_calibration/functions/calibration_interactive.R"))

# Charger les fonctions de contrôle qualité
source(file.path(BASE_DIR, "scripts/04_calibration/functions/calibration_quality_checks.R"))

cat("✓ Configuration globale chargée\n")
cat("✓ Fonctions utilitaires chargées\n")
cat("✓ Fonctions interactives chargées\n")
cat("✓ Fonctions de contrôle qualité chargées\n\n")


# ============================================================================
# INITIALISATION DE L'ENVIRONNEMENT DE CALIBRATION
# ============================================================================

cat("########################################################\n")
cat("# Initialisation de l'environnement...                #\n")
cat("########################################################\n\n")

# Initialiser l'environnement avec tous les paramètres et chemins
cal_env <- initialize_calibration_env(
  target_quarter = TARGET_QUARTER,
  schema_id = SCHEMA_ID
)

# Extraire les variables principales dans l'environnement global
year <- cal_env$year
quarter <- cal_env$quarter
xnum <- cal_env$xnum
setx <- cal_env$setx
pathx <- cal_env$pathx

# Copier tous les chemins dans l'environnement global pour compatibilité
list2env(cal_env$paths, envir = .GlobalEnv)

# Construire PROG_DIR pour les scripts
PROG_DIR <- file.path(BASE_DIR, "scripts/04_calibration/QUARTERLY_WEIGHTING/constraints", pathx)

cat("✓ Environnement initialisé avec succès\n\n")


# ============================================================================
# ÉTAPE 1: CHARGEMENT DES DONNÉES ET TOTAUX CONNUS
# ============================================================================

cat("\n")
cat("========================================================\n")
cat("  ÉTAPE 1: Chargement des données                      \n")
cat("========================================================\n\n")

# Chercher le script dans l'ancien emplacement (pour compatibilité)
script_01 <- list.files(
  file.path(BASE_DIR, "scripts/04_calibration/QUARTERLY_WEIGHTING"),
  pattern = paste0("01_Upload_Sample_Data_and_Known_Totals_in_R_", pathx, "\\.R"),
  recursive = TRUE,
  full.names = TRUE
)[1]

if (!is.na(script_01) && file.exists(script_01)) {
  cat("  → Exécution du script de chargement des données...\n")
  source(script_01)
  cat("✓ Données chargées avec succès\n\n")
} else {
  cat("⚠ Script 01 introuvable, passage à l'étape suivante\n\n")
}


# ============================================================================
# ÉTAPE 1B: OUVERTURE DU FICHIER DE CONTRAINTES EXCEL
# ============================================================================

cat("========================================================\n")
cat("  ÉTAPE 1B: Ouverture du fichier de contraintes        \n")
cat("========================================================\n\n")

if (file.exists(FILE_CONSTRAINTS_XLSX)) {
  cat("  → Ouverture du fichier:", basename(FILE_CONSTRAINTS_XLSX), "\n")

  tryCatch({
    xls <- xl.get.excel()
    xl.workbook.close(xl.workbook.name = NULL)
    xl.workbook.open(FILE_CONSTRAINTS_XLSX)
    cat("✓ Fichier de contraintes ouvert\n\n")
  }, error = function(e) {
    cat("⚠ Erreur lors de l'ouverture du fichier Excel:", e$message, "\n")
    cat("  (Cela peut être normal si Excel n'est pas disponible)\n\n")
  })
} else {
  cat("⚠ Fichier de contraintes introuvable:", FILE_CONSTRAINTS_XLSX, "\n")
  cat("  Veuillez vérifier que le fichier existe\n\n")
}


# ============================================================================
# ÉTAPE 2: PRÉPARATION DES DONNÉES ÉCHANTILLON POUR REGENESEES
# ============================================================================

cat("========================================================\n")
cat("  ÉTAPE 2: Préparation des données échantillon         \n")
cat("========================================================\n\n")

script_02 <- list.files(
  file.path(BASE_DIR, "scripts/04_calibration/QUARTERLY_WEIGHTING"),
  pattern = paste0("02_Prepare_input_sample_data_for_regenesees_", pathx, "\\.R"),
  recursive = TRUE,
  full.names = TRUE
)[1]

if (!is.na(script_02) && file.exists(script_02)) {
  cat("  → Préparation des données échantillon pour Regenesees...\n")
  source(script_02)
  cat("✓ Données échantillon préparées\n\n")
} else {
  cat("⚠ Script 02 introuvable\n\n")
}


# ============================================================================
# ÉTAPE 3: PRÉPARATION DES TOTAUX DE POPULATION POUR REGENESEES
# ============================================================================

cat("========================================================\n")
cat("  ÉTAPE 3: Préparation des totaux de population        \n")
cat("========================================================\n\n")

script_03 <- list.files(
  file.path(BASE_DIR, "scripts/04_calibration/QUARTERLY_WEIGHTING"),
  pattern = paste0("03_Prepare_input_pop_figures_for_regenesees_", pathx, "\\.R"),
  recursive = TRUE,
  full.names = TRUE
)[1]

if (!is.na(script_03) && file.exists(script_03)) {
  cat("  → Préparation des totaux de population...\n")
  source(script_03)
  cat("✓ Totaux de population préparés\n\n")
} else {
  cat("⚠ Script 03 introuvable\n\n")
}


# ============================================================================
# ÉTAPE 3B: MODE INTERACTIF DE TEST DES BORNES (OPTIONNEL)
# ============================================================================

if (INTERACTIVE_BOUNDS_MODE) {
  cat("\n")
  cat("╔═══════════════════════════════════════════════════════════════════════════╗\n")
  cat("║                   MODE INTERACTIF ACTIVÉ                                  ║\n")
  cat("╚═══════════════════════════════════════════════════════════════════════════╝\n\n")

  cat("Le script va maintenant s'arrêter pour vous permettre de tester les bornes\n")
  cat("de calibration avant de lancer la calibration complète.\n\n")

  cat("Les objets suivants sont disponibles dans votre environnement :\n")
  cat("  • design_lfs      : Objet design créé avec e.svydesign\n")
  cat("  • popdataframe    : DataFrame de population\n")
  cat("  • constrains_x    : Modèle de contraintes\n\n")

  cat("Utilisez ces fonctions interactives :\n\n")

  cat("1. Afficher les bornes suggérées et les diagnostics :\n")
  cat("   cal_info <- show_calibration_info(design_lfs, popdataframe, constrains_x)\n\n")

  cat("2. Tester des bornes spécifiques :\n")
  cat("   calib_result <- test_calibration_bounds(cal_info, bounds = c(0.01, 6))\n\n")

  cat("3. Tester plusieurs bornes automatiquement :\n")
  cat("   results <- test_multiple_bounds(cal_info)\n\n")

  cat("4. Voir le guide interactif :\n")
  cat("   interactive_bounds_selection(cal_info)\n\n")

  cat("Une fois les bonnes bornes trouvées, vous pouvez :\n")
  cat("  • Soit modifier le script 04c avec les bonnes bornes\n")
  cat("  • Soit désactiver INTERACTIVE_BOUNDS_MODE et relancer ce script\n\n")

  cat("═══════════════════════════════════════════════════════════════════════════\n")
  cat("ARRÊT DU SCRIPT POUR MODE INTERACTIF\n")
  cat("═══════════════════════════════════════════════════════════════════════════\n\n")

  stop("Script arrêté en mode interactif. Testez vos bornes, puis relancez avec INTERACTIVE_BOUNDS_MODE = FALSE")
}


# ============================================================================
# ÉTAPE 4: EXÉCUTION DE LA CALIBRATION AVEC REGENESEES
# ============================================================================

cat("========================================================\n")
cat("  ÉTAPE 4: Calibration avec Regenesees                 \n")
cat("========================================================\n\n")

script_04c <- list.files(
  file.path(BASE_DIR, "scripts/04_calibration/QUARTERLY_WEIGHTING"),
  pattern = paste0("04c_Run_Quarterly_Calibration_with_Regenesees_", pathx, "\\.R"),
  recursive = TRUE,
  full.names = TRUE
)[1]

if (!is.na(script_04c) && file.exists(script_04c)) {
  cat("  → Exécution de la calibration...\n")
  cat("  (Cela peut prendre plusieurs minutes)\n\n")

  if (INTERACTIVE_BOUNDS_MODE) {
    cat("  ℹ Mode interactif : Vous pouvez tester les bornes avant la calibration\n\n")
  }

  source(script_04c)
  cat("✓ Calibration terminée avec succès\n\n")
} else {
  cat("⚠ Script 04c introuvable\n\n")
}


# ============================================================================
# ÉTAPE 5: ATTACHEMENT DES POIDS FINAUX AUX DONNÉES
# ============================================================================

cat("========================================================\n")
cat("  ÉTAPE 5: Attachement des poids finaux                \n")
cat("========================================================\n\n")

script_05 <- list.files(
  file.path(BASE_DIR, "scripts/04_calibration/QUARTERLY_WEIGHTING"),
  pattern = paste0("05_Attach_final_weights_to_full_sample_data_", pathx, "\\.R"),
  recursive = TRUE,
  full.names = TRUE
)[1]

if (!is.na(script_05) && file.exists(script_05)) {
  cat("  → Attachement des poids finaux aux données...\n")
  source(script_05)
  cat("✓ Poids finaux attachés\n\n")
} else {
  cat("⚠ Script 05 introuvable\n\n")
}


# ============================================================================
# ÉTAPE 6: CRÉATION DU TABLEAU RÉCAPITULATIF
# ============================================================================

cat("========================================================\n")
cat("  ÉTAPE 6: Création du tableau récapitulatif           \n")
cat("========================================================\n\n")

script_06 <- list.files(
  file.path(BASE_DIR, "scripts/04_calibration/QUARTERLY_WEIGHTING"),
  pattern = paste0("06_Create_Table1_", pathx, "\\.R"),
  recursive = TRUE,
  full.names = TRUE
)[1]

if (!is.na(script_06) && file.exists(script_06)) {
  cat("  → Génération du tableau récapitulatif...\n")
  source(script_06)
  cat("✓ Tableau créé\n\n")
} else {
  cat("⚠ Script 06 introuvable\n\n")
}


# ============================================================================
# ÉTAPE 7: CALCUL DE LA PRÉCISION
# ============================================================================

cat("========================================================\n")
cat("  ÉTAPE 7: Calcul de la précision                      \n")
cat("========================================================\n\n")

script_07 <- list.files(
  file.path(BASE_DIR, "scripts/04_calibration/QUARTERLY_WEIGHTING"),
  pattern = paste0("07f_Calculate_Precision_of_levels_with_Regenesees_ver3_", pathx, "\\.R"),
  recursive = TRUE,
  full.names = TRUE
)[1]

if (!is.na(script_07) && file.exists(script_07)) {
  cat("  → Calcul des erreurs standard et coefficients de variation...\n")
  source(script_07)
  cat("✓ Précision calculée\n\n")
} else {
  cat("⚠ Script 07 introuvable\n\n")
}


# ============================================================================
# FINALISATION
# ============================================================================

cat("\n")
cat("########################################################\n")
cat("########################################################\n")
cat("##                                                    ##\n")
cat("##        CALIBRATION TERMINÉE AVEC SUCCÈS !         ##\n")
cat("##                                                    ##\n")
cat("########################################################\n")
cat("########################################################\n\n")

cat("Résumé de l'exécution:\n")
cat("  - Trimestre:", TARGET_QUARTER, "\n")
cat("  - Schéma:", SCHEMA_ID, "\n")
cat("  - Année:", year, "\n")
cat("  - Trimestre:", quarter, "\n")
cat("  - Nombre de contraintes:", xnum, "\n\n")

cat("Fichiers de sortie principaux:\n")
cat("  - Poids finaux (DTA):", FILE_LFS_ILO_CAL_DTA_EXPORT, "\n")
cat("  - Poids finaux (RData):", FILE_LFS_ILO_CAL_RDATA, "\n")
cat("  - Résumé des poids:", FILE_LFS_CALIBRATION_SUMMARY_OF_FINAL_WEIGHTS_CSV, "\n")
cat("  - Erreurs standard:", LFS_STD_ERR_EMP_LEVELS_CSV, "\n\n")

cat("Pour exécuter une autre calibration:\n")
cat("  1. Modifiez TARGET_QUARTER et/ou SCHEMA_ID dans ce script\n")
cat("  2. Relancez: source('scripts/04_calibration/run_calibration.R')\n\n")

cat("########################################################\n\n")
