# ======================================================================
# SIMULATION DE RÉDUCTION D'ÉCHANTILLON LFS – 30 ITÉRATIONS PARALLÈLES
# TOUT EST SAUVEGARDÉ À L'INTÉRIEUR DE CHAQUE ITÉRATION
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
# 0) CONFIGURATION
# ----------------------------------------------------------------------

source("config/1_config.r")

FILE_LFS_ILO_CAL_DTA_EXPORT <- get_export_path(
  TARGET_QUARTER, quarter, year, use_sr = FALSE
)

DATA_DIR <- file.path(BASE_DIR, "data")
WEIGHTS_DIR <- file.path(DATA_DIR, "04_weights")

SIMULATION_DIR <- file.path(WEIGHTS_DIR, "simulation")
SIMULATION_QUARTER_DIR <- file.path(SIMULATION_DIR, TARGET_QUARTER)

dir.create(SIMULATION_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(SIMULATION_QUARTER_DIR, showWarnings = FALSE, recursive = TRUE)

sample_data <- read_dta(FILE_LFS_ILO_CAL_DTA_EXPORT)

# ----------------------------------------------------------------------
# PARAMÈTRES
# ----------------------------------------------------------------------

RATIO_REDUCTION <- 0.75
N_ITER <- 30
set.seed(123)

SUFFIXE_SIMU <- paste0(TARGET_QUARTER, "_", RATIO_REDUCTION * 100, "pct")

# ----------------------------------------------------------------------
# CONVERSION DES LABELS STATA (INDISPENSABLE POUR PARALLÈLE)
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
# BASE MÉNAGES INITIALE (1 ligne par ménage)
# ----------------------------------------------------------------------

base_menages_initiale <- sample_data %>%
  group_by(PSUKEY, HHKEY) %>%
  slice(1) %>%
  ungroup()

# Sauvegarde base ménage dédupliquée (référence commune)
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
# NOMBRE À GARDER PAR PSU (commun à toutes les itérations)
# ----------------------------------------------------------------------

menages_par_psu <- base_menages_initiale %>%
  group_by(PSUKEY) %>%
  summarise(nb_menages_total = n(), .groups = "drop") %>%
  mutate(
    nb_a_garder_exact = nb_menages_total * RATIO_REDUCTION,
    nb_a_garder = pmax(1, ceiling(nb_a_garder_exact)),  # minimum 1
    nb_a_retirer = nb_menages_total - nb_a_garder
  )

# ----------------------------------------------------------------------
# VÉRIFICATIONS DE COHÉRENCE DES DONNÉES
# ----------------------------------------------------------------------

cat("\n=== VÉRIFICATIONS DE COHÉRENCE ===\n\n")

# 1) Vérifier qu'il n'y a pas de PSU vides
psu_vides <- menages_par_psu %>% filter(nb_menages_total == 0)
if (nrow(psu_vides) > 0) {
  cat("ERREUR: PSU avec 0 ménages détectés:\n")
  print(psu_vides)
  stop("Il y a des PSU sans ménages. Vérifiez vos données.")
}

# 2) Vérifier qu'il n'y a pas de nb_a_garder NA ou <= 0
psu_problemes <- menages_par_psu %>% 
  filter(is.na(nb_a_garder) | nb_a_garder <= 0)
if (nrow(psu_problemes) > 0) {
  cat("ERREUR: PSU avec nb_a_garder problématique:\n")
  print(psu_problemes)
  stop("Il y a des PSU avec nb_a_garder NA ou <= 0. Vérifiez vos données.")
}

# 3) Vérifier que tous les PSU de base_menages_initiale sont dans menages_par_psu
psu_dans_base <- unique(base_menages_initiale$PSUKEY)
psu_dans_calcul <- menages_par_psu$PSUKEY
psu_manquants <- setdiff(psu_dans_base, psu_dans_calcul)

if (length(psu_manquants) > 0) {
  cat("ERREUR: PSU présents dans base_menages mais absents de menages_par_psu:\n")
  print(psu_manquants)
  stop("Incohérence entre base_menages_initiale et menages_par_psu.")
}

# 4) Afficher un résumé
cat("✓ Nombre total de PSU:", nrow(menages_par_psu), "\n")
cat("✓ Tous les PSU ont au moins 1 ménage\n")
cat("✓ Tous les nb_a_garder sont valides (>= 1)\n")
cat("✓ Cohérence entre base_menages et menages_par_psu vérifiée\n")

cat("\nRésumé de la réduction:\n")
print(summary(menages_par_psu %>% select(nb_menages_total, nb_a_garder, nb_a_retirer)))

cat("\n=== FIN DES VÉRIFICATIONS ===\n\n")

# ----------------------------------------------------------------------
# CONFIGURATION PARALLÈLE
# ----------------------------------------------------------------------

N_CORES <- max(1, parallel::detectCores() - 1)
Sys.setenv("LC_ALL" = "C")
plan(multisession, workers = N_CORES)

# objets partagés
base_menages_shared <- base_menages_initiale
menages_par_psu_shared <- menages_par_psu
sample_data_shared <- sample_data
SIMU_ROOT <- SIMULATION_QUARTER_DIR
SUFFIXE <- SUFFIXE_SIMU

# ----------------------------------------------------------------------
# FONCTION : UNE ITÉRATION COMPLÈTE (TIRAGE + FUSION + SAUVEGARDES)
# ----------------------------------------------------------------------

run_one_iteration <- function(iter) {

  # -------- Début du chronométrage --------
  temps_debut <- Sys.time()
  
  set.seed(1000 + iter)

  # create folder for this iteration
  iter_dir <- file.path(SIMU_ROOT, paste0("iteration_", iter))
  dir.create(iter_dir, showWarnings = FALSE, recursive = TRUE)

  liste_psu <- split(base_menages_shared, base_menages_shared$PSUKEY)

  # -------- 1) Tirage aléatoire par PSU --------
  menages_tires <- purrr::map_dfr(names(liste_psu), function(psu_id) {

    menages_psu <- liste_psu[[psu_id]]

    # CORRECTION: Ne pas convertir en numeric, comparer directement
    nb_garder_vec <- menages_par_psu_shared$nb_a_garder[
      menages_par_psu_shared$PSUKEY == psu_id
    ]

    # S'assurer qu'on a exactement une valeur
    if (length(nb_garder_vec) == 0) {
      stop("PSUKEY ", psu_id, " non trouvé dans menages_par_psu à l'itération ", iter)
    }
    
    nb_garder <- as.numeric(nb_garder_vec[1])

    # Après les vérifications, cette condition devrait toujours être vraie
    if (nrow(menages_psu) > 0 && !is.na(nb_garder) && nb_garder > 0) {
      dplyr::slice_sample(
        menages_psu,
        n = min(nb_garder, nrow(menages_psu))
      )
    } else {
      stop("Erreur inattendue pour PSUKEY ", psu_id, " à l'itération ", iter,
           "\n  nrow(menages_psu) = ", nrow(menages_psu),
           "\n  nb_garder = ", nb_garder)
    }
  })

  # Vérification supplémentaire
  if (nrow(menages_tires) == 0) {
    stop("Erreur: menages_tires est vide à l'itération ", iter)
  }

  # -------- 1b) Créer base PSU avec effectifs réels --------
  base_psu_sim <- menages_tires %>%
    group_by(PSUKEY) %>%
    summarise(nb_enq_sim = n(), .groups = "drop")

# Fusionner avec la base ménages et garder les variables nécessaires
base_psu_enrichie <- base_menages_shared %>%
  left_join(base_psu_sim, by = "PSUKEY") %>%
  select(
    # Clés
    PSUKEY, STRATAKEY, HHKEY, INDKEY,
    # Variables demandées avec renommage
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
    # Variable ajoutée par la simulation
    nb_enq_sim
  ) %>%
  distinct(PSUKEY, .keep_all = TRUE)

var_label(base_psu_enrichie$nb_enq_sim) <- "Nombre de ménages tirés dans la simulation"
var_label(base_psu_enrichie$pi_zd) <- "Probabilité d'inclusion au niveau ZD"

  # Sauvegarder la base PSU enrichie
  arrow::write_parquet(
    base_psu_enrichie,
    file.path(iter_dir,
              paste0("base_psu_enrichie_iter_", iter, ".parquet"))
  )
  
  haven::write_dta(
    base_psu_enrichie,
    file.path(iter_dir,
              paste0("base_psu_enrichie_iter_", iter, ".dta"))
  )

  # Save raw draw
  arrow::write_parquet(
    menages_tires,
    file.path(iter_dir,
              paste0("menages_tires_iter_", iter, ".parquet"))
  )

  haven::write_dta(
    menages_tires,
    file.path(iter_dir,
              paste0("menages_tires_iter_", iter, ".dta"))
  )

  # -------- 2) Fusion with full household base --------
  base_menages_match <- base_menages_shared %>%
    dplyr::semi_join(menages_tires, by = c("PSUKEY", "HHKEY"))

  arrow::write_parquet(
    base_menages_match,
    file.path(iter_dir,
              paste0("menages_match_iter_", iter, ".parquet"))
  )

  haven::write_dta(
    base_menages_match,
    file.path(iter_dir,
              paste0("menages_match_iter_", iter, ".dta"))
  )

  # -------- 3) Reduced individual file --------
  individus_reduits <- sample_data_shared %>%
    dplyr::semi_join(base_menages_match, by = c("PSUKEY", "HHKEY"))

  arrow::write_parquet(
    individus_reduits,
    file.path(iter_dir,
              paste0("individus_reduits_iter_", iter, ".parquet"))
  )

  haven::write_dta(
    individus_reduits,
    file.path(iter_dir,
              paste0("individus_reduits_iter_", iter, ".dta"))
  )

  # -------- Fin du chronométrage --------
  temps_fin <- Sys.time()
  duree_secondes <- as.numeric(difftime(temps_fin, temps_debut, units = "secs"))

  # -------- 4) Return statistics for final table --------
  # Calcul de l'âge moyen et autres statistiques pour différencier les échantillons
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
# LANCER LES 30 ITÉRATIONS EN PARALLÈLE
# ----------------------------------------------------------------------

temps_total_debut <- Sys.time()

resume_iterations <- future_map_dfr(
  1:N_ITER,
  run_one_iteration,
  .progress = TRUE
)

temps_total_fin <- Sys.time()
duree_totale <- difftime(temps_total_fin, temps_total_debut, units = "mins")

# Sauvegarde tableau récapitulatif global
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

print(resume_iterations)

# Vérifier la variance entre itérations
cat("\nVariabilité entre itérations:\n")
cat("Age moyen: min =", min(resume_iterations$age_moyen), 
    "max =", max(resume_iterations$age_moyen), "\n")
cat("Écart-type des âges moyens:", sd(resume_iterations$age_moyen), "\n")

# -------- Statistiques de temps --------
cat("\n=== STATISTIQUES DE TEMPS ===\n")
cat("Temps total d'exécution:", round(duree_totale, 2), "minutes\n")
cat("Temps moyen par itération:", round(mean(resume_iterations$duree_sec), 2), "secondes\n")
cat("Temps min par itération:", round(min(resume_iterations$duree_sec), 2), "secondes\n")
cat("Temps max par itération:", round(max(resume_iterations$duree_sec), 2), "secondes\n")
cat("Écart-type des temps:", round(sd(resume_iterations$duree_sec), 2), "secondes\n")

# Sauvegarde tableau récapitulatif global
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

print(resume_iterations)

# Vérifier la variance entre itérations
cat("\nVariabilité entre itérations:\n")
cat("Age moyen: min =", min(resume_iterations$age_moyen), 
    "max =", max(resume_iterations$age_moyen), "\n")
cat("Écart-type des âges moyens:", sd(resume_iterations$age_moyen), "\n")
# Visualiser la distribution des âges moyens
library(ggplot2)

ggplot(resume_iterations, aes(x = iteration, y = age_moyen)) +
  geom_line() +
  geom_point() +
  labs(title = "Âge moyen par itération",
       x = "Itération", 
       y = "Âge moyen") +
  theme_minimal()

# Ou un histogramme
ggplot(resume_iterations, aes(x = age_moyen)) +
  geom_histogram(bins = 15, fill = "steelblue", color = "white") +
  labs(title = "Distribution des âges moyens sur 30 itérations",
       x = "Âge moyen",
       y = "Fréquence") +
  theme_minimal()

# Tableau complet
print(resume_iterations)
