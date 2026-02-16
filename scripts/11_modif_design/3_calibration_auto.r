# ======================================================================
# ÉTAPE 3: CALIBRATION (VERSION AUTOMATISÉE)
# ======================================================================
# Ce script est appelé par 0_MASTER_SIMULATION.r
# Il utilise les paramètres globaux PARAM_* définis dans le master
# ======================================================================

library(dplyr)
library(haven)
library(future)
library(furrr)
library(ReGenesees)
library(readxl)
library(writexl)

# ----------------------------------------------------------------------
# RÉCUPÉRATION DES PARAMÈTRES DU MASTER
# ----------------------------------------------------------------------

if (!exists("PARAM_TARGET_QUARTER")) {
  stop("Ce script doit être appelé depuis 0_MASTER_SIMULATION.r")
}

TARGET_QUARTER <- PARAM_TARGET_QUARTER
RATIO_REDUCTION <- PARAM_RATIO_REDUCTION
N_ITER <- PARAM_N_ITER
SUFFIXE_SIMU <- PARAM_SUFFIXE_SIMU

xnum <- 180  # Nombre total de variables X

# ----------------------------------------------------------------------
# CHEMINS
# ----------------------------------------------------------------------

FILE_POP_LFS_BY_REGION_SEX_2AGEGR_XLSX <- file.path(DATA_DIR, "06_POPULATION_ESTIMATES", "2025", "T3", "POP_LFS_BY_REGION_SEX_2AGEGR_2025_T3.xlsx")
R_SCRIPT_NEW_FUNCTIONS_FOR_X_CONSTRAINS <- file.path(BASE_DIR, "scripts", "04_calibration", "QUARTERLY_WEIGHTING", "Other_R_functions_for_Regenesees", "Functions_to_Create _X_vector_and_X_Summary_Table.R")

# ----------------------------------------------------------------------
# CHARGEMENT DES TOTAUX CONNUS
# ----------------------------------------------------------------------

cat("Chargement des totaux connus...\n")

POP_LFS_BY_REGION_SEX_2AGEGR <- read_xlsx(FILE_POP_LFS_BY_REGION_SEX_2AGEGR_XLSX)
source(R_SCRIPT_NEW_FUNCTIONS_FOR_X_CONSTRAINS)

# ----------------------------------------------------------------------
# PRÉPARATION DES TOTAUX CONNUS
# ----------------------------------------------------------------------

prepare_known_totals <- function() {
  tmpKT <- POP_LFS_BY_REGION_SEX_2AGEGR
  tmpKT$DOMAIN <- as.character(tmpKT$Domain)
  tmpKT <- cbind(tmpKT, data.frame(matrix(0, nrow = nrow(tmpKT), ncol = xnum, byrow = FALSE)))

  assign("tmpKT", tmpKT, envir = .GlobalEnv)
  source("scripts/11_modif_design/binary_180KT.r")
  tmpKT <- get("tmpKT", envir = .GlobalEnv)

  list_of_X <- paste(rep("X", xnum), seq(1, xnum), sep = "")
  tmpKT$DOMAIN <- as.character(1)

  LFS_KNOWN_TOTALS <- aggregate(tmpKT[, list_of_X], by = list(DOMAIN = tmpKT$DOMAIN), FUN = sum)
  LFS_KNOWN_TOTALS$DOMAIN <- as.factor(LFS_KNOWN_TOTALS$DOMAIN)

  rm(tmpKT, envir = .GlobalEnv)

  save(LFS_KNOWN_TOTALS,
       file = file.path(SIMULATION_QUARTER_DIR, paste0("LFS_KNOWN_TOTALS_", SUFFIXE_SIMU, ".RData")))
  write_xlsx(LFS_KNOWN_TOTALS,
             file.path(SIMULATION_QUARTER_DIR, paste0("LFS_KNOWN_TOTALS_", SUFFIXE_SIMU, ".xlsx")))

  return(LFS_KNOWN_TOTALS)
}

cat("Préparation des totaux connus...\n")
KNOWN_TOTALS_SHARED <- prepare_known_totals()
cat("✓ Totaux connus préparés\n")

# ----------------------------------------------------------------------
# MAPPINGS
# ----------------------------------------------------------------------

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

milieu_mapping <- tibble::tribble(
  ~milieu_nom, ~milieu_code,
  "Urbain",    1,
  "Rural",     2
)

sexe_mapping <- tibble::tribble(
  ~sexe_nom,   ~sexe_code,
  "Masculin",  1,
  "Féminin",   2
)

# ----------------------------------------------------------------------
# FONCTION : CALIBRATION POUR UNE ITÉRATION
# ----------------------------------------------------------------------

calibrate_one_iteration <- function(iter) {
  iter_dir <- file.path(SIMULATION_QUARTER_DIR, paste0("iteration_", iter))

  # Charger les données (avec taux dans le nom)
  individus_enrichis <- read_dta(
    file.path(iter_dir, paste0("individus_enrichis_", SUFFIXE_SIMU, "_iter_", iter, ".dta"))
  )

  individus_enrichis <- individus_enrichis[, !names(individus_enrichis) %in% c("FINAL_WEIGHT", "FINAL_CORR_FACTOR")]

  # Ajouter les codes
  individus_enrichis <- individus_enrichis %>%
    left_join(region_mapping, by = c("hh2" = "region_nom")) %>%
    rename(hh2_code = region_code) %>%
    left_join(milieu_mapping, by = c("milieu" = "milieu_nom")) %>%
    left_join(sexe_mapping, by = c("m5" = "sexe_nom")) %>%
    rename(m5_code = sexe_code)

  # Préparer les données d'échantillon
  tmpSD <- individus_enrichis
  tmpSD$DOMAIN <- as.character(1)
  tmpSD <- cbind(tmpSD, data.frame(matrix(0, nrow = nrow(tmpSD), ncol = xnum, byrow = FALSE)))

  list_of_X <- paste(rep("X", xnum), seq(1, xnum), sep = "")

  assign("tmpSD", tmpSD, envir = .GlobalEnv)
  source("scripts/11_modif_design/binary_180.r")
  tmpSD <- get("tmpSD", envir = .GlobalEnv)

  X_sums <- colSums(tmpSD[, list_of_X], na.rm = TRUE)
  X_empty <- names(X_sums[X_sums == 0])

  sample_data <- tmpSD[, c("hh2", "milieu", "DOMAIN", "STRATAKEY", "PSUKEY", "HHKEY", "INDKEY",
                          "m5", list_of_X)]
  sample_data$d_weights <- tmpSD$corrected_weight_HH_sim

  rm(tmpSD, envir = .GlobalEnv)

  sample_data$DOMAIN <- as.factor(sample_data$DOMAIN)
  sample_data$STRATAKEY <- as.factor(sample_data$STRATAKEY)
  sample_data$PSUKEY <- as.factor(sample_data$PSUKEY)
  sample_data$HHKEY <- as.factor(sample_data$HHKEY)
  sample_data$INDKEY <- as.factor(sample_data$INDKEY)
  sample_data$ONES <- 1

  # Design
  design_lfs <- e.svydesign(
    data = sample_data,
    ids = ~ PSUKEY + HHKEY,
    strata = ~ STRATAKEY,
    weights = ~ d_weights,
    fpc = NULL,
    self.rep.str = NULL,
    check.data = TRUE
  )

  # Calibration
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

  calibration_status_code <- as.numeric(ecal.status[1])

  # Poids finaux
  sample_data$FINAL_WEIGHT <- weights(calib_lfs)
  sample_data$FINAL_CORR_FACTOR <- sample_data$FINAL_WEIGHT / sample_data$d_weights

  # Vérification
  library(expss)
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

  write_xlsx(table_check,
             file.path(iter_dir, paste0("table_check_calibration_", SUFFIXE_SIMU, "_iter_", iter, ".xlsx")))

  # Fusion finale
  tmp_FINAL_WEIGHTS <- sample_data[, c("INDKEY", "FINAL_CORR_FACTOR", "FINAL_WEIGHT")]

  LFS_ILO_CAL <- individus_enrichis %>%
    left_join(tmp_FINAL_WEIGHTS, by = "INDKEY")

  write_dta(LFS_ILO_CAL,
            file.path(iter_dir, paste0("LFS_ILO_CAL_", SUFFIXE_SIMU, "_iter_", iter, ".dta")))

  write_dta(tmp_FINAL_WEIGHTS,
            file.path(iter_dir, paste0("FINAL_WEIGHTS_", SUFFIXE_SIMU, "_iter_", iter, ".dta")))

  # Résumé
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
# EXÉCUTION
# ----------------------------------------------------------------------

# Test sur itération 1
cat("Test calibration sur itération 1...\n")
test_result <- calibrate_one_iteration(1)

# Exécution parallèle
N_CORES <- max(1, parallel::detectCores() - 1)
plan(multisession, workers = N_CORES)

cat("\nLancement calibration parallèle sur", N_ITER, "itérations...\n")

resume_calibrations <- future_map_dfr(
  1:N_ITER,
  calibrate_one_iteration,
  .progress = TRUE,
  .options = furrr_options(seed = TRUE)
)

# Sauvegarde
write_dta(
  resume_calibrations,
  file.path(SIMULATION_QUARTER_DIR, paste0("resume_calibrations_", SUFFIXE_SIMU, ".dta"))
)

write_xlsx(
  resume_calibrations,
  file.path(SIMULATION_QUARTER_DIR, paste0("resume_calibrations_", SUFFIXE_SIMU, ".xlsx"))
)

# Résumé
n_success <- sum(resume_calibrations$calibration_success, na.rm = TRUE)

cat("\n=== RÉSUMÉ ÉTAPE 3 ===\n")
cat("Calibrations réussies:", n_success, "/", N_ITER, "(", round(100 * n_success / N_ITER, 1), "%)\n")
cat("Poids final moyen:", round(mean(resume_calibrations$mean_final_weight), 2), "\n")
cat("Facteur de correction moyen:", round(mean(resume_calibrations$mean_corr_factor), 3), "\n")
