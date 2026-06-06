# ======================================================================
# CALIBRATION PARALLÈLE SUR LES 30 ITÉRATIONS
# ======================================================================

library(dplyr)
library(haven)
library(future)
library(furrr)
library(ReGenesees)
library(readxl)
library(writexl)

# ----------------------------------------------------------------------
# CONFIGURATION
# ----------------------------------------------------------------------

source("config/1_config.r")

DATA_DIR <- file.path(BASE_DIR, "data")
WEIGHTS_DIR <- file.path(DATA_DIR, "04_weights")
SIMULATION_DIR <- file.path(WEIGHTS_DIR, "simulation")
SIMULATION_QUARTER_DIR <- file.path(SIMULATION_DIR, TARGET_QUARTER)
xnum <- 180  # Nombre total de variables X
RATIO_REDUCTION <- 0.50
N_ITER <- 30
SUFFIXE_SIMU <- paste0(TARGET_QUARTER, "_", RATIO_REDUCTION * 100, "pct")

######################################################################################################
#   0. Define important paths (fichiers d'entrée globaux uniquement)                                #
######################################################################################################

# Paths pour les totaux connus (fichier d'entrée commun)
FILE_POP_LFS_BY_REGION_SEX_2AGEGR_XLSX <- file.path(DATA_DIR, "06_POPULATION_ESTIMATES", "2025", "T3", "POP_LFS_BY_REGION_SEX_2AGEGR_2025_T3.xlsx")

# Path pour le script des contraintes
R_SCRIPT_NEW_FUNCTIONS_FOR_X_CONSTRAINS <- file.path(BASE_DIR, "scripts", "04_calibration", "QUARTERLY_WEIGHTING", "Other_R_functions_for_Regenesees", "Functions_to_Create _X_vector_and_X_Summary_Table.R")
######################################################################################################
#   I. Charger les totaux connus (commun à toutes les itérations)                                   #
######################################################################################################

POP_LFS_BY_REGION_SEX_2AGEGR <- read_xlsx(FILE_POP_LFS_BY_REGION_SEX_2AGEGR_XLSX)

# Charger les scripts nécessaires
source(R_SCRIPT_NEW_FUNCTIONS_FOR_X_CONSTRAINS)

# ----------------------------------------------------------------------
# PRÉPARATION DES TOTAUX CONNUS (une seule fois)
# ----------------------------------------------------------------------

prepare_known_totals <- function() {
  tmpKT <- POP_LFS_BY_REGION_SEX_2AGEGR
  tmpKT$DOMAIN <- as.character(tmpKT$Domain)
  tmpKT <- cbind(tmpKT, data.frame(matrix(0, nrow = nrow(tmpKT), ncol = xnum, byrow = FALSE)))
  
  # Assigner tmpKT à l'environnement global temporairement pour binary_180KT.r
  assign("tmpKT", tmpKT, envir = .GlobalEnv)
  
  # Appliquer binary_180KT.r (il modifie tmpKT dans l'environnement global)
  source("scripts/11_modif_design/binary_180KT.r")
  
  # Récupérer tmpKT modifié depuis l'environnement global
  tmpKT <- get("tmpKT", envir = .GlobalEnv)
  
  list_of_X <- paste(rep("X", xnum), seq(1, xnum), sep = "")
  tmpKT$DOMAIN <- as.character(1)
  
  LFS_KNOWN_TOTALS <- aggregate(tmpKT[, list_of_X], by = list(DOMAIN = tmpKT$DOMAIN), FUN = sum)
  LFS_KNOWN_TOTALS$DOMAIN <- as.factor(LFS_KNOWN_TOTALS$DOMAIN)
  
  # Nettoyer l'environnement global
  rm(tmpKT, envir = .GlobalEnv)
  
  # Sauvegarder les totaux connus dans le dossier simulation global
  save(LFS_KNOWN_TOTALS, 
       file = file.path(SIMULATION_QUARTER_DIR, paste0("LFS_KNOWN_TOTALS_", SUFFIXE_SIMU, ".RData")))
  write_xlsx(LFS_KNOWN_TOTALS, 
             file.path(SIMULATION_QUARTER_DIR, paste0("LFS_KNOWN_TOTALS_", SUFFIXE_SIMU, ".xlsx")))
  
  return(LFS_KNOWN_TOTALS)
}

# Préparer les totaux connus une fois
cat("\n=== Préparation des totaux connus ===\n")
KNOWN_TOTALS_SHARED <- prepare_known_totals()
cat("✓ Totaux connus préparés\n")
cat("  Somme X1-X48:", sum(KNOWN_TOTALS_SHARED[, seq(2, 49)]), "\n")
cat("  Somme X49-X", xnum, ":", sum(KNOWN_TOTALS_SHARED[, seq(50, xnum + 1)]), "\n\n")

# ----------------------------------------------------------------------
# FONCTION : CALIBRATION POUR UNE ITÉRATION
# ----------------------------------------------------------------------

calibrate_one_iteration <- function(iter) {
  # Dossier de l'itération actuelle - TOUS LES FICHIERS VONT ICI
  iter_dir <- file.path(SIMULATION_QUARTER_DIR, paste0("iteration_", iter))
  
  cat("\n=== Début calibration itération", iter, "===\n")
  
  # -------- I. Charger les données individus enrichies --------
  individus_enrichis <- read_dta(
    file.path(iter_dir, paste0("individus_enrichis_iter_", iter, ".dta"))
  )

  # Supprimer FINAL_WEIGHT et FINAL_CORR_FACTOR s'ils existent déjà
  individus_enrichis <- individus_enrichis[, !names(individus_enrichis) %in% c("FINAL_WEIGHT", "FINAL_CORR_FACTOR")]
  
  # Créer le mapping régions texte -> codes
  region_mapping <- tibble::tribble(
    ~region_nom,         ~region_code,
    "ABIDJAN",           "10101",
    "YAMOUSSOUKRO",      "10207",
    "SAN-PEDRO",         "10309",
    "GBOKLE",            "10325",
    "NAWA",              "10331",
    "INDENIE-DJUABLIN",  "10405",
    "SUD-COMOE",         "10413",
    "KABADOUGOU",        "10510",
    "FOLON",             "10524",
    "LÔH-DJIBOUA",       "10615",
    "GÔH",               "10617",
    "HAUT-SASSANDRA",    "10702",
    "MARAHOUE",          "10712",
    "N'ZI",              "10811",
    "BELIER",            "10821",
    "IFFOU",             "10829",
    "MORONOU",           "10833",
    "AGNEBY-TIASSA",     "10916",
    "GRAND-PONTS",       "10926",
    "LA ME",             "10930",
    "TONKPI",            "11006",
    "CAVALLY",           "11018",
    "GUEMON",            "11027",
    "PORO",              "11103",
    "BAGOUE",            "11120",
    "TCHOLOGO",          "11132",
    "GBEKE",             "11204",
    "HAMBOL",            "11228",
    "WORODOUGOU",        "11314",
    "BAFING",            "11319",
    "BERE",              "11322",
    "GONTOUGO",          "11408",
    "BOUNKANI",          "11423"
  )
  
  # Créer le mapping milieu texte -> codes
  milieu_mapping <- tibble::tribble(
    ~milieu_nom, ~milieu_code,
    "Urbain",    1,
    "Rural",     2
  )
  
  # Créer le mapping sexe texte -> codes
  sexe_mapping <- tibble::tribble(
    ~sexe_nom,   ~sexe_code,
    "Masculin",  1,
    "Féminin",   2
  )
  
  # Ajouter la variable hh2_code
  individus_enrichis <- individus_enrichis %>%
    left_join(region_mapping, by = c("hh2" = "region_nom")) %>%
    rename(hh2_code = region_code)
  
  # Ajouter la variable milieu_code
  individus_enrichis <- individus_enrichis %>%
    left_join(milieu_mapping, by = c("milieu" = "milieu_nom")) %>%
    rename(milieu_code = milieu_code)
  
  # Ajouter la variable m5_code
  individus_enrichis <- individus_enrichis %>%
    left_join(sexe_mapping, by = c("m5" = "sexe_nom")) %>%
    rename(m5_code = sexe_code)
  
  # Vérifier si des régions n'ont pas été mappées
  regions_non_mappees <- individus_enrichis %>%
    filter(is.na(hh2_code)) %>%
    distinct(hh2) %>%
    pull(hh2)
  
  if (length(regions_non_mappees) > 0) {
    warning("Itération ", iter, ": Régions non mappées dans hh2: ", 
            paste(regions_non_mappees, collapse = ", "))
  }
  
  # Vérifier si des milieux n'ont pas été mappés
  milieux_non_mappes <- individus_enrichis %>%
    filter(is.na(milieu_code)) %>%
    distinct(milieu) %>%
    pull(milieu)
  
  if (length(milieux_non_mappes) > 0) {
    warning("Itération ", iter, ": Milieux non mappés: ", 
            paste(milieux_non_mappes, collapse = ", "))
  }
  
  # Vérifier si des sexes n'ont pas été mappés
  sexes_non_mappes <- individus_enrichis %>%
    filter(is.na(m5_code)) %>%
    distinct(m5) %>%
    pull(m5)
  
  if (length(sexes_non_mappes) > 0) {
    warning("Itération ", iter, ": Sexes non mappés dans m5: ", 
            paste(sexes_non_mappes, collapse = ", "))
  }
  
  cat("✓ Variables hh2_code, milieu_code et m5_code créées\n")
  
  # Vérifier que toutes les variables nécessaires sont présentes
  required_vars <- c("PSUKEY", "HHKEY", "INDKEY", "STRATAKEY", "hh2", "hh2_code", 
                     "milieu", "milieu_code", "m5", "m5_code", "ageannee", "corrected_weight_HH_sim")
  missing_vars <- setdiff(required_vars, names(individus_enrichis))
  
  if (length(missing_vars) > 0) {
    stop("Itération ", iter, ": Variables manquantes: ", 
         paste(missing_vars, collapse = ", "))
  }
  
  cat("✓ Toutes les variables nécessaires sont présentes\n")
    
  # -------- II. Préparer les données d'échantillon --------
  tmpSD <- individus_enrichis
  tmpSD$DOMAIN <- as.character(1)
  tmpSD <- cbind(tmpSD, data.frame(matrix(0, nrow = nrow(tmpSD), ncol = xnum, byrow = FALSE)))
  
  list_of_X <- paste(rep("X", xnum), seq(1, xnum), sep = "")
  
  # Assigner tmpSD à l'environnement global temporairement pour binary_180.r
  assign("tmpSD", tmpSD, envir = .GlobalEnv)
  
  # Appliquer binary_180.r (il modifie tmpSD dans l'environnement global)
  source("scripts/11_modif_design/binary_180.r")
  
  # Récupérer tmpSD modifié depuis l'environnement global
  tmpSD <- get("tmpSD", envir = .GlobalEnv)
  
  # Vérifier que les variables X ont été créées
  missing_X <- setdiff(list_of_X, names(tmpSD))
  if (length(missing_X) > 0) {
    rm(tmpSD, envir = .GlobalEnv)
    stop("Itération ", iter, ": Variables X manquantes après binary_180.r: ", 
         paste(head(missing_X, 5), collapse = ", "), 
         if(length(missing_X) > 5) paste("... et", length(missing_X) - 5, "autres") else "")
  }
  
  # Vérifier que les X contiennent des 1 (pas que des 0)
  X_sums <- colSums(tmpSD[, list_of_X], na.rm = TRUE)
  X_empty <- names(X_sums[X_sums == 0])
  if (length(X_empty) > 0) {
    warning("Itération ", iter, ": ", length(X_empty), " variables X sont vides (que des 0): ",
            paste(head(X_empty, 5), collapse = ", "),
            if(length(X_empty) > 5) paste("... (", length(X_empty) - 5, " autres)") else "")
  }
  
  cat("✓ Variables X créées:", length(list_of_X), "variables\n")
  cat("  - Variables X non vides:", length(list_of_X) - length(X_empty), "/", length(list_of_X), "\n")
  
  # Créer sample_data avec le poids corrigé comme poids de base
  sample_data <- tmpSD[, c("hh2", "milieu", "DOMAIN", "STRATAKEY", "PSUKEY", "HHKEY", "INDKEY", 
                          "m5", list_of_X)]
  
  # Utiliser corrected_weight_HH_sim comme poids de départ
  sample_data$d_weights <- tmpSD$corrected_weight_HH_sim
  
  # Nettoyer l'environnement global
  rm(tmpSD, envir = .GlobalEnv)
  
  # Préparer les facteurs
  sample_data$DOMAIN <- as.factor(sample_data$DOMAIN)
  sample_data$STRATAKEY <- as.factor(sample_data$STRATAKEY)
  sample_data$PSUKEY <- as.factor(sample_data$PSUKEY)
  sample_data$HHKEY <- as.factor(sample_data$HHKEY)
  sample_data$INDKEY <- as.factor(sample_data$INDKEY)
  sample_data$ONES <- 1
  
  # Sauvegarder sample_data dans iter_dir avec trimestre et itération
  LFS_SAMPLE_DATA <- sample_data
  save(LFS_SAMPLE_DATA, 
       file = file.path(iter_dir, paste0("LFS_SAMPLE_DATA_", TARGET_QUARTER, "_iter_", iter, ".RData")))
  
  # Calculer et sauvegarder les résumés des X
  LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE <- aggregate(
    x = LFS_SAMPLE_DATA[, list_of_X], 
    by = list(DOMAIN = LFS_SAMPLE_DATA$DOMAIN), 
    FUN = sum
  )
  save(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE, 
       file = file.path(iter_dir, paste0("LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE_", 
                                          TARGET_QUARTER, "_iter_", iter, ".RData")))
  write_xlsx(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE, 
             file.path(iter_dir, paste0("LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE_", 
                                        TARGET_QUARTER, "_iter_", iter, ".xlsx")))
  
  cat("✓ Sample data sauvegardé\n")
  
  # -------- III. Définir le design --------
  design_lfs <- e.svydesign(
    data = sample_data, 
    ids = ~ PSUKEY + HHKEY, 
    strata = ~ STRATAKEY, 
    weights = ~ d_weights, 
    fpc = NULL, 
    self.rep.str = NULL, 
    check.data = TRUE
  )
  
  cat("✓ Design défini\n")
  
  # -------- IV. Calibration --------
  constrains_x <- constraints_model(xnum)
  
  poptemplate <- pop.template(
    data = KNOWN_TOTALS_SHARED, 
    calmodel = constrains_x, 
    partition = ~ DOMAIN
  )
  
  popdataframe <- fill.template(
    universe = KNOWN_TOTALS_SHARED, 
    template = poptemplate, 
    mem.frac = 5
  )
  
  bounds.h <- bounds.hint(
    design = design_lfs, 
    df.population = popdataframe, 
    calmodel = constrains_x, 
    partition = ~ DOMAIN
  )
  
  cat("✓ Début calibration...\n")
  
  calib_lfs <- e.calibrate(
    design = design_lfs, 
    df.population = popdataframe, 
    calmodel = constrains_x,
    partition = ~ DOMAIN, 
    calfun = "logit", 
    bounds = c(0.01, 6),
    aggregate.stage = NULL, 
    maxit = 30,
    epsilon = 1e-4, 
    force = TRUE
  )
  
  # Récupérer le statut de calibration
  calibration_status_code <- as.numeric(ecal.status[1])
  
  if (calibration_status_code == 0) {
    cat("✓ Calibration réussie (ecal.status = 0)\n")
  } else {
    warning("Itération ", iter, ": Calibration avec statut non optimal (ecal.status = ", 
            calibration_status_code, ")")
  }
  
  # -------- V. Extraire les poids finaux --------
  sample_data$FINAL_WEIGHT <- weights(calib_lfs)
  sample_data$FINAL_CORR_FACTOR <- sample_data$FINAL_WEIGHT / sample_data$d_weights
  
  # Sauvegarder les poids calibrés dans iter_dir avec trimestre et itération
  LFS_CALIBRATION_FINAL_WEIGHTS <- sample_data
  save(LFS_CALIBRATION_FINAL_WEIGHTS, 
       file = file.path(iter_dir, paste0("LFS_CALIBRATION_FINAL_WEIGHTS_", 
                                         TARGET_QUARTER, "_iter_", iter, ".RData")))
  
  # -------- VI. Vérification des totaux calibrés --------
  library(expss)
  
  # Définir last_X pour le calcul
  last_X <- paste0('X', xnum)
  
  tab_sample <- sample_data %>%
    tab_rows(mdset(X49 %to% get("last_X")), mdset(X1 %to% X48)) %>%
    tab_cols(DOMAIN) %>%
    tab_weight(FINAL_WEIGHT) %>%
    tab_stat_sum %>%
    tab_pivot() %>%
    as.data.frame() %>%
    rename(Somme_final_weight = names(.)[2]) %>%
    select(Somme_final_weight)
  
  table_check <- cbind(POP_LFS_BY_REGION_SEX_2AGEGR, tab_sample) %>%
    mutate(
      ecart = abs(Nombre - Somme_final_weight),
      checking = ifelse(ecart > 100, "> 100", "")
    )
  
  n_depassements <- sum(table_check$checking == "> 100", na.rm = TRUE)
  
  if (n_depassements == 0) {
    cat("✓ Tous les totaux calibrés sont dans la marge acceptée (écart ≤ 100)\n")
  } else {
    warning("Itération ", iter, ": ", n_depassements, " dépassements détectés (écart > 100)")
  }
  
  # Sauvegarder le tableau de vérification
  write_xlsx(table_check, 
             file.path(iter_dir, paste0("table_check_calibration_", TARGET_QUARTER, "_iter_", iter, ".xlsx")))
  
  # -------- VII. Fusionner avec les données originales --------
  tmp_FINAL_WEIGHTS <- sample_data[, c("INDKEY", "FINAL_CORR_FACTOR", "FINAL_WEIGHT")]
  
  LFS_ILO_CAL <- individus_enrichis %>%
    left_join(tmp_FINAL_WEIGHTS, by = "INDKEY")
  
  # -------- VIII. Sauvegarder dans iter_dir avec trimestre et itération --------
  write_dta(LFS_ILO_CAL, 
            file.path(iter_dir, paste0("LFS_ILO_CAL_", TARGET_QUARTER, "_iter_", iter, ".dta")))
  
  # Sauvegarder aussi les poids seuls
  write_dta(tmp_FINAL_WEIGHTS, 
            file.path(iter_dir, paste0("FINAL_WEIGHTS_", TARGET_QUARTER, "_iter_", iter, ".dta")))
  
  cat("✓ Calibration itération", iter, "terminée avec succès\n")
  
  # -------- IX. Retourner résumé --------
  tibble::tibble(
    iteration = iter,
    n_individus = nrow(LFS_ILO_CAL),
    mean_d_weight = round(mean(sample_data$d_weights, na.rm = TRUE), 2),
    mean_final_weight = round(mean(sample_data$FINAL_WEIGHT, na.rm = TRUE), 2),
    mean_corr_factor = round(mean(sample_data$FINAL_CORR_FACTOR, na.rm = TRUE), 3),
    min_final_weight = round(min(sample_data$FINAL_WEIGHT, na.rm = TRUE), 2),
    max_final_weight = round(max(sample_data$FINAL_WEIGHT, na.rm = TRUE), 2),
    n_X_empty = length(X_empty),
    ecal_status = calibration_status_code,
    n_depassements = n_depassements,
    calibration_success = (calibration_status_code == 0 & n_depassements == 0)
  )
}
# ----------------------------------------------------------------------
# OPTION 1: TEST SUR UNE ITÉRATION
# ----------------------------------------------------------------------

test_result <- calibrate_one_iteration(1)
# print(test_result)

# ----------------------------------------------------------------------
# OPTION 2: EXÉCUTION PARALLÈLE
# ----------------------------------------------------------------------

N_CORES <- max(1, parallel::detectCores() - 1)
plan(multisession, workers = N_CORES)

cat("\n=== Lancement calibration parallèle sur", N_ITER, "itérations ===\n")
cat("Nombre de cœurs utilisés:", N_CORES, "\n\n")

resume_calibrations <- future_map_dfr(
  1:N_ITER,
  calibrate_one_iteration,
  .progress = TRUE,
  .options = furrr_options(seed = TRUE)
)

# Sauvegarder le résumé dans le dossier simulation global
write_dta(
  resume_calibrations,
  file.path(SIMULATION_QUARTER_DIR, paste0("resume_calibrations_", SUFFIXE_SIMU, ".dta"))
)

write_xlsx(
  resume_calibrations,
  file.path(SIMULATION_QUARTER_DIR, paste0("resume_calibrations_", SUFFIXE_SIMU, ".xlsx"))
)

print(resume_calibrations[1:30,c("iteration", "mean_final_weight", "mean_corr_factor", "ecal_status", "n_depassements", "calibration_success")],n=30)
cat("\n=== RÉSUMÉ FINAL ===\n")
cat("✓ Calibration appliquée avec succès sur", N_ITER, "itérations\n")

# Compter les calibrations réussies
n_success <- sum(resume_calibrations$calibration_success, na.rm = TRUE)
cat("Calibrations réussies:", n_success, "/", N_ITER, "(", round(100 * n_success / N_ITER, 1), "%)\n")

cat("\nStatistiques des poids finaux:\n")
cat("  Poids moyen:\n")
cat("    - Min:", min(resume_calibrations$mean_final_weight), "\n")
cat("    - Max:", max(resume_calibrations$mean_final_weight), "\n")
cat("    - Moyenne:", round(mean(resume_calibrations$mean_final_weight), 2), "\n")
cat("    - Variance:", round(var(resume_calibrations$mean_final_weight), 2), "\n")
cat("    - Écart-type:", round(sd(resume_calibrations$mean_final_weight), 2), "\n")

cat("\nFacteur de correction:\n")
cat("  - Min:", min(resume_calibrations$mean_corr_factor), "\n")
cat("  - Max:", max(resume_calibrations$mean_corr_factor), "\n")
cat("  - Moyen:", round(mean(resume_calibrations$mean_corr_factor), 3), "\n")
cat("  - Variance:", round(var(resume_calibrations$mean_corr_factor), 6), "\n")
cat("  - Écart-type:", round(sd(resume_calibrations$mean_corr_factor), 4), "\n")

cat("\nPoids minimum (sur toutes les itérations):\n")
cat("  - Min:", min(resume_calibrations$min_final_weight), "\n")
cat("  - Max:", max(resume_calibrations$min_final_weight), "\n")
cat("  - Moyenne:", round(mean(resume_calibrations$min_final_weight), 2), "\n")
cat("  - Variance:", round(var(resume_calibrations$min_final_weight), 2), "\n")

cat("\nPoids maximum (sur toutes les itérations):\n")
cat("  - Min:", min(resume_calibrations$max_final_weight), "\n")
cat("  - Max:", max(resume_calibrations$max_final_weight), "\n")
cat("  - Moyenne:", round(mean(resume_calibrations$max_final_weight), 2), "\n")
cat("  - Variance:", round(var(resume_calibrations$max_final_weight), 2), "\n")

cat("\nStatut de calibration (ecal_status):\n")
cat("  - Nombre avec ecal_status = 0:", sum(resume_calibrations$ecal_status == 0, na.rm = TRUE), "\n")
cat("  - Nombre avec ecal_status ≠ 0:", sum(resume_calibrations$ecal_status != 0, na.rm = TRUE), "\n")

cat("\nDépassements (écart > 100):\n")
cat("  - Min:", min(resume_calibrations$n_depassements), "\n")
cat("  - Max:", max(resume_calibrations$n_depassements), "\n")
cat("  - Moyenne:", round(mean(resume_calibrations$n_depassements), 2), "\n")
cat("  - Nombre d'itérations sans dépassement:", sum(resume_calibrations$n_depassements == 0), "\n")

cat("\nVariables X vides:\n")
cat("  - Min:", min(resume_calibrations$n_X_empty), "\n")
cat("  - Max:", max(resume_calibrations$n_X_empty), "\n")
cat("  - Moyenne:", round(mean(resume_calibrations$n_X_empty), 2), "\n")

cat("\nFichiers sauvegardés:\n")
cat("  - Résumé:", file.path(SIMULATION_QUARTER_DIR, paste0("resume_calibrations_", SUFFIXE_SIMU, ".dta")), "\n")
cat("  - Par itération: iteration_X/LFS_ILO_CAL_", TARGET_QUARTER, "_iter_X.dta\n")

