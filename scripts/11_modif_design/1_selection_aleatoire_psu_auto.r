# ======================================================================
# ÉTAPE 1: SÉLECTION ALÉATOIRE DES PSU (VERSION AUTOMATISÉE)
# ======================================================================
# Ce script est appelé par 0_MASTER_SIMULATION.r
# Il utilise les paramètres globaux PARAM_* définis dans le master
# ======================================================================

library(dplyr)
library(tidyr)
library(purrr)
library(haven)
library(arrow)
library(future)
library(furrr)
library(labelled)

# ----------------------------------------------------------------------
# RÉCUPÉRATION DES PARAMÈTRES DU MASTER
# ----------------------------------------------------------------------

# Vérifier que les paramètres existent
if (!exists("PARAM_TARGET_QUARTER")) {
  stop("Ce script doit être appelé depuis 0_MASTER_SIMULATION.r")
}

TARGET_QUARTER <- PARAM_TARGET_QUARTER
RATIO_REDUCTION <- PARAM_RATIO_REDUCTION
N_ITER <- PARAM_N_ITER
SUFFIXE_SIMU <- PARAM_SUFFIXE_SIMU

set.seed(PARAM_SEED)

# ----------------------------------------------------------------------
# CHEMINS
# ----------------------------------------------------------------------

FILE_LFS_ILO_CAL_DTA_EXPORT <- get_export_path(
  TARGET_QUARTER, quarter, year, use_sr = FALSE
)

cat("Chargement des données depuis:", FILE_LFS_ILO_CAL_DTA_EXPORT, "\n")

sample_data <- read_dta(FILE_LFS_ILO_CAL_DTA_EXPORT)

cat("Données chargées:", nrow(sample_data), "lignes\n")

# ----------------------------------------------------------------------
# CONVERSION DES LABELS STATA
# ----------------------------------------------------------------------

convert_haven_to_char <- function(df) {
  df %>%
    mutate(across(
      where(is.labelled),
      ~ as.character(as_factor(.))
    ))
}

sample_data <- convert_haven_to_char(sample_data)

# ----------------------------------------------------------------------
# BASE MÉNAGES INITIALE
# ----------------------------------------------------------------------

base_menages_initiale <- sample_data %>%
  group_by(PSUKEY, HHKEY) %>%
  slice(1) %>%
  ungroup()

cat("Base ménages:", nrow(base_menages_initiale), "ménages\n")

# Sauvegarde base ménage dédupliquée
write_parquet(
  base_menages_initiale,
  file.path(SIMULATION_QUARTER_DIR,
            paste0("menages_", SUFFIXE_SIMU, "_sans_doublons.parquet"))
)

write_dta(
  base_menages_initiale,
  file.path(SIMULATION_QUARTER_DIR,
            paste0("menages_", SUFFIXE_SIMU, "_sans_doublons.dta"))
)

# ----------------------------------------------------------------------
# NOMBRE À GARDER PAR PSU
# ----------------------------------------------------------------------

menages_par_psu <- base_menages_initiale %>%
  group_by(PSUKEY) %>%
  summarise(nb_menages_total = n(), .groups = "drop") %>%
  mutate(
    nb_a_garder_exact = nb_menages_total * RATIO_REDUCTION,
    nb_a_garder = pmax(1, ceiling(nb_a_garder_exact)),
    nb_a_retirer = nb_menages_total - nb_a_garder
  )

# ----------------------------------------------------------------------
# VÉRIFICATIONS
# ----------------------------------------------------------------------

cat("\n=== VÉRIFICATIONS ===\n")

psu_vides <- menages_par_psu %>% filter(nb_menages_total == 0)
if (nrow(psu_vides) > 0) {
  stop("PSU avec 0 ménages détectés")
}

psu_problemes <- menages_par_psu %>%
  filter(is.na(nb_a_garder) | nb_a_garder <= 0)
if (nrow(psu_problemes) > 0) {
  stop("PSU avec nb_a_garder problématique")
}

cat("✓ Nombre total de PSU:", nrow(menages_par_psu), "\n")
cat("✓ Tous les PSU ont au moins 1 ménage\n")
cat("✓ Réduction:", RATIO_REDUCTION * 100, "%\n")

# ----------------------------------------------------------------------
# CONFIGURATION PARALLÈLE
# ----------------------------------------------------------------------

N_CORES <- max(1, parallel::detectCores() - 1)
Sys.setenv("LC_ALL" = "C")
plan(multisession, workers = N_CORES)

cat("Utilisation de", N_CORES, "coeurs\n")

# Objets partagés
base_menages_shared <- base_menages_initiale
menages_par_psu_shared <- menages_par_psu
sample_data_shared <- sample_data
SIMU_ROOT <- SIMULATION_QUARTER_DIR
SUFFIXE <- SUFFIXE_SIMU

# ----------------------------------------------------------------------
# FONCTION : UNE ITÉRATION
# ----------------------------------------------------------------------

run_one_iteration <- function(iter) {

  temps_debut <- Sys.time()

  set.seed(1000 + iter)

  iter_dir <- file.path(SIMU_ROOT, paste0("iteration_", iter))
  dir.create(iter_dir, showWarnings = FALSE, recursive = TRUE)

  liste_psu <- split(base_menages_shared, base_menages_shared$PSUKEY)

  # Tirage aléatoire par PSU
  menages_tires <- purrr::map_dfr(names(liste_psu), function(psu_id) {

    menages_psu <- liste_psu[[psu_id]]

    nb_garder_vec <- menages_par_psu_shared$nb_a_garder[
      menages_par_psu_shared$PSUKEY == psu_id
    ]

    if (length(nb_garder_vec) == 0) {
      stop("PSUKEY ", psu_id, " non trouvé")
    }

    nb_garder <- as.numeric(nb_garder_vec[1])

    if (nrow(menages_psu) > 0 && !is.na(nb_garder) && nb_garder > 0) {
      dplyr::slice_sample(
        menages_psu,
        n = min(nb_garder, nrow(menages_psu))
      )
    } else {
      stop("Erreur pour PSUKEY ", psu_id)
    }
  })

  if (nrow(menages_tires) == 0) {
    stop("menages_tires est vide à l'itération ", iter)
  }

  # Base PSU avec effectifs réels
  base_psu_sim <- menages_tires %>%
    group_by(PSUKEY) %>%
    summarise(nb_enq_sim = n(), .groups = "drop")

  base_psu_enrichie <- base_menages_shared %>%
    left_join(base_psu_sim, by = "PSUKEY") %>%
    select(
      PSUKEY, STRATAKEY, HHKEY, INDKEY,
      region = hh2,
      depart = hh3,
      souspref = hh4,
      ZD = hh8,
      segment,
      milieu,
      date_ref,
      nb_indivs_seg,
      nb_mens_seg,
      nb_men_reg,
      nb_indivs_zd,
      nb_mens_zd,
      quarter_phase,
      nb_mens_enq,
      nb_indivs_enq,
      nb_indivs_enq_pot,
      nb_indivs_enq_elig,
      nb_indivs_milieu,
      nb_mens_milieu,
      rgmen,
      first_trim,
      pi_zd,
      nb_enq_sim
    ) %>%
    distinct(PSUKEY, .keep_all = TRUE)

  var_label(base_psu_enrichie$nb_enq_sim) <- "Nombre de ménages tirés dans la simulation"
  var_label(base_psu_enrichie$pi_zd) <- "Probabilité d'inclusion au niveau ZD"

  # Sauvegardes (avec taux de réduction dans le nom)
  arrow::write_parquet(
    base_psu_enrichie,
    file.path(iter_dir, paste0("base_psu_enrichie_", SUFFIXE, "_iter_", iter, ".parquet"))
  )

  haven::write_dta(
    base_psu_enrichie,
    file.path(iter_dir, paste0("base_psu_enrichie_", SUFFIXE, "_iter_", iter, ".dta"))
  )

  arrow::write_parquet(
    menages_tires,
    file.path(iter_dir, paste0("menages_tires_", SUFFIXE, "_iter_", iter, ".parquet"))
  )

  haven::write_dta(
    menages_tires,
    file.path(iter_dir, paste0("menages_tires_", SUFFIXE, "_iter_", iter, ".dta"))
  )

  # Fusion avec base ménages
  base_menages_match <- base_menages_shared %>%
    dplyr::semi_join(menages_tires, by = c("PSUKEY", "HHKEY"))

  arrow::write_parquet(
    base_menages_match,
    file.path(iter_dir, paste0("menages_match_", SUFFIXE, "_iter_", iter, ".parquet"))
  )

  haven::write_dta(
    base_menages_match,
    file.path(iter_dir, paste0("menages_match_", SUFFIXE, "_iter_", iter, ".dta"))
  )

  # Base individus réduite
  individus_reduits <- sample_data_shared %>%
    dplyr::semi_join(base_menages_match, by = c("PSUKEY", "HHKEY"))

  arrow::write_parquet(
    individus_reduits,
    file.path(iter_dir, paste0("individus_reduits_", SUFFIXE, "_iter_", iter, ".parquet"))
  )

  haven::write_dta(
    individus_reduits,
    file.path(iter_dir, paste0("individus_reduits_", SUFFIXE, "_iter_", iter, ".dta"))
  )

  temps_fin <- Sys.time()
  duree_secondes <- as.numeric(difftime(temps_fin, temps_debut, units = "secs"))

  # Statistiques
  age_moyen <- mean(as.numeric(individus_reduits$ageannee), na.rm = TRUE)
  age_median <- median(as.numeric(individus_reduits$ageannee), na.rm = TRUE)
  age_sd <- sd(as.numeric(individus_reduits$ageannee), na.rm = TRUE)

  tibble::tibble(
    iteration = iter,
    n_psu = dplyr::n_distinct(menages_tires$PSUKEY),
    n_menages = nrow(menages_tires),
    n_individus = nrow(individus_reduits),
    age_moyen = round(age_moyen, 2),
    age_median = round(age_median, 2),
    age_sd = round(age_sd, 2),
    duree_sec = round(duree_secondes, 2)
  )
}

# ----------------------------------------------------------------------
# EXÉCUTION
# ----------------------------------------------------------------------

cat("\nLancement de", N_ITER, "itérations en parallèle...\n")

temps_total_debut <- Sys.time()

resume_iterations <- future_map_dfr(
  1:N_ITER,
  run_one_iteration,
  .progress = TRUE
)

temps_total_fin <- Sys.time()
duree_totale <- difftime(temps_total_fin, temps_total_debut, units = "mins")

# Sauvegarde résumé
write_parquet(
  resume_iterations,
  file.path(SIMULATION_QUARTER_DIR,
            paste0("resume_30_iterations_", SUFFIXE_SIMU, ".parquet"))
)

write_dta(
  resume_iterations,
  file.path(SIMULATION_QUARTER_DIR,
            paste0("resume_30_iterations_", SUFFIXE_SIMU, ".dta"))
)

cat("\n=== RÉSUMÉ ÉTAPE 1 ===\n")
cat("Durée:", round(as.numeric(duree_totale), 2), "minutes\n")
cat("Ménages par itération:", round(mean(resume_iterations$n_menages)), "\n")
cat("Individus par itération:", round(mean(resume_iterations$n_individus)), "\n")
