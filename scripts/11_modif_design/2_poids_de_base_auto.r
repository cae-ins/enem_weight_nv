# ======================================================================
# ÉTAPE 2: CALCUL DES POIDS DE BASE (VERSION AUTOMATISÉE)
# ======================================================================
# Ce script est appelé par 0_MASTER_SIMULATION.r
# Il utilise les paramètres globaux PARAM_* définis dans le master
# ======================================================================

library(dplyr)
library(haven)
library(future)
library(furrr)
library(labelled)

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
NB_MENS_ENQ <- PARAM_NB_MENS_ENQ_BASE
NB_MENS_ENQ_SIM <- PARAM_NB_MENS_ENQ_SIM

# ----------------------------------------------------------------------
# FONCTIONS DE CALCUL
# ----------------------------------------------------------------------

compute_pi_hh <- function(nb_mens_seg) {
  if (is.na(nb_mens_seg) || nb_mens_seg == 0)
    return(NA_real_)
  (NB_MENS_ENQ_SIM / nb_mens_seg) * (1 / 6)
}

compute_pi_HH <- function(pi_zd, pi_hh) {
  ifelse(is.na(pi_zd) | is.na(pi_hh), NA_real_, pi_zd * pi_hh)
}

append_base_weights <- function(data, resurvey = TRUE) {
  data <- data %>%
    mutate(
      pi_hh_sim     = mapply(compute_pi_hh, nb_mens_seg),
      pi_HH_sim     = compute_pi_HH(pi_zd, pi_hh_sim),
      base_weight_HH_sim    = ifelse(!is.na(pi_HH_sim) & pi_HH_sim != 0, 1 / pi_HH_sim, NA_real_)
    )

  data <- data %>%
    set_variable_labels(
      pi_hh_sim       = "Probabilité d'inclusion du ménage dans le segment (simulé)",
      pi_HH_sim       = "Probabilité d'inclusion combinée ZD × HH (simulé)",
      base_weight_HH_sim = "Poids de base des ménages du segment (simulé)"
    )

  return(data)
}

adjust_non_response_HH <- function(data, EXPECTED_HH_PER_SEG = NB_MENS_ENQ_SIM, group_vars = c("region")) {
  if (!all(c("nb_enq_sim", "nb_mens_seg", "base_weight_HH_sim") %in% names(data))) {
    stop("Variables manquantes: 'nb_enq_sim', 'nb_mens_seg', 'base_weight_HH_sim'.")
  }

  data <- data %>%
    mutate(
       nb_men_theo_sim = EXPECTED_HH_PER_SEG
    ) %>%
    group_by(across(all_of(group_vars))) %>%
    mutate(
      nb_mens_theo_region_sim = sum(nb_men_theo_sim, na.rm = TRUE),
      nb_mens_enq_region_sim = sum(nb_enq_sim, na.rm = TRUE)
    ) %>%
    ungroup() %>%
    mutate(
      correction_factor_region_sim = case_when(
        nb_mens_enq_region_sim == 0 ~ NA_real_,
        TRUE ~ nb_mens_theo_region_sim / nb_mens_enq_region_sim
      ),
      corrected_weight_HH_sim = base_weight_HH_sim * correction_factor_region_sim
    ) %>%
    set_variable_labels(
      nb_mens_enq_region_sim = "Effectif interviewé par région",
      correction_factor_region_sim = "Facteur de correction (potentiel / effectif) par région",
      corrected_weight_HH_sim = "Poids de base corrigé par région (ménages)"
    )

  return(data)
}

# ----------------------------------------------------------------------
# FONCTION : TRAITER UNE ITÉRATION
# ----------------------------------------------------------------------

process_base_psu <- function(iter) {

  iter_dir <- file.path(SIMULATION_QUARTER_DIR, paste0("iteration_", iter))

  # Charger la base PSU enrichie (avec taux dans le nom)
  base_psu_enrichie <- read_dta(
    file.path(iter_dir, paste0("base_psu_enrichie_", SUFFIXE_SIMU, "_iter_", iter, ".dta"))
  )

  # Calcul des poids de base
  base_psu_enrichie <- append_base_weights(
    data = base_psu_enrichie,
    resurvey = TRUE
  )

  # Ajustement pour la non-réponse
  base_psu_enrichie <- adjust_non_response_HH(
    data = base_psu_enrichie,
    EXPECTED_HH_PER_SEG = NB_MENS_ENQ_SIM,
    group_vars = c("region")
  )

  # Préparer pour fusion
  base_psu_pour_fusion <- base_psu_enrichie %>%
    select(
      PSUKEY,
      nb_enq_sim,
      pi_hh_sim, pi_HH_sim, base_weight_HH_sim,
      nb_men_theo_sim, nb_mens_theo_region_sim, nb_mens_enq_region_sim,
      correction_factor_region_sim, corrected_weight_HH_sim
    )

  # Charger et fusionner avec base ménages (avec taux dans le nom)
  menages_match <- read_dta(
    file.path(iter_dir, paste0("menages_match_", SUFFIXE_SIMU, "_iter_", iter, ".dta"))
  )

  menages_enrichis <- menages_match %>%
    left_join(base_psu_pour_fusion, by = "PSUKEY")

  write_dta(
    menages_enrichis,
    file.path(iter_dir, paste0("menages_enrichis_", SUFFIXE_SIMU, "_iter_", iter, ".dta"))
  )

  # Charger et fusionner avec base individus (avec taux dans le nom)
  individus_reduits <- read_dta(
    file.path(iter_dir, paste0("individus_reduits_", SUFFIXE_SIMU, "_iter_", iter, ".dta"))
  )

  menages_pour_individus <- menages_enrichis %>%
    select(
      PSUKEY, HHKEY,
      nb_enq_sim,
      pi_hh_sim, pi_HH_sim, base_weight_HH_sim,
      nb_men_theo_sim, nb_mens_theo_region_sim, nb_mens_enq_region_sim,
      correction_factor_region_sim, corrected_weight_HH_sim
    )

  individus_enrichis <- individus_reduits %>%
    left_join(menages_pour_individus, by = c("PSUKEY", "HHKEY"))

  write_dta(
    individus_enrichis,
    file.path(iter_dir, paste0("individus_enrichis_", SUFFIXE_SIMU, "_iter_", iter, ".dta"))
  )

  write_dta(
    base_psu_enrichie,
    file.path(iter_dir, paste0("base_psu_enrichie_", SUFFIXE_SIMU, "_iter_", iter, ".dta"))
  )

  # Résumé
  tibble::tibble(
    iteration = iter,
    n_psu = nrow(base_psu_enrichie),
    n_menages = nrow(menages_enrichis),
    n_individus = nrow(individus_enrichis),
    n_regions = n_distinct(base_psu_enrichie$region),
    mean_base_weight_HH = round(mean(base_psu_enrichie$base_weight_HH_sim, na.rm = TRUE), 2),
    mean_corrected_weight_HH = round(mean(base_psu_enrichie$corrected_weight_HH_sim, na.rm = TRUE), 2),
    diff_weight_mean = round(mean(base_psu_enrichie$corrected_weight_HH_sim, na.rm = TRUE) -
                             mean(base_psu_enrichie$base_weight_HH_sim, na.rm = TRUE), 2),
    ratio_weights = round(mean(base_psu_enrichie$corrected_weight_HH_sim, na.rm = TRUE) /
                          mean(base_psu_enrichie$base_weight_HH_sim, na.rm = TRUE), 3)
  )
}

# ----------------------------------------------------------------------
# EXÉCUTION PARALLÈLE
# ----------------------------------------------------------------------

N_CORES <- max(1, parallel::detectCores() - 1)
plan(multisession, workers = N_CORES)

cat("Calcul des poids de base sur", N_ITER, "itérations...\n")

resume_transformations <- future_map_dfr(
  1:N_ITER,
  process_base_psu,
  .progress = TRUE
)

# Sauvegarde
write_dta(
  resume_transformations,
  file.path(SIMULATION_QUARTER_DIR,
            paste0("resume_transformations_", SUFFIXE_SIMU, ".dta"))
)

cat("\n=== RÉSUMÉ ÉTAPE 2 ===\n")
cat("Poids de base moyen:", round(mean(resume_transformations$mean_base_weight_HH), 2), "\n")
cat("Poids corrigé moyen:", round(mean(resume_transformations$mean_corrected_weight_HH), 2), "\n")
cat("Ratio moyen poids corrigé/base:", round(mean(resume_transformations$ratio_weights), 3), "\n")
