# ======================================================================
# ÉTAPE 4: FUSION AVEC DONNÉES INDIVIDUELLES (VERSION AUTOMATISÉE)
# ======================================================================
# Ce script est appelé par 0_MASTER_SIMULATION.r
# Il utilise les paramètres globaux PARAM_* définis dans le master
# ======================================================================

library(dplyr)
library(haven)
library(future)
library(furrr)
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

# ----------------------------------------------------------------------
# CHARGEMENT DE LA BASE COMPLÈTE
# ----------------------------------------------------------------------

cat("Chargement de la base complète...\n")

BASE_COMPLETE_PATH <- file.path("data", "04_weights", "Base_Travail_BT_vf.dta")
base_complete <- read_dta(BASE_COMPLETE_PATH)

cat("Base complète chargée:", nrow(base_complete), "lignes\n")

# Variables à conserver
vars_to_keep <- c(
  "interview_key", "membres_id",
  "pmencor_ind_annuel", "age", "grp_age", "grpe_age5", "grp_age3", "groupe_age4",
  "groupe_age5", "groupe_age6", "groupe_age7", "jeune15_24", "jeune15_35",
  "jeune15_40", "sexe", "scolarise", "niveau_instruction", "niv_inst_ag1",
  "niv_inst_ag2", "niv_inst_ag3", "classe_atteint", "nbr_annee_etude",
  "haut_diplome", "milieu_residence", "milieu_resid2", "region", "district",
  "type_logement", "nature_murs", "statut_occupation", "mode_eclairage",
  "cat_profEP", "cat_profES", "PAT", "emp_present", "emp_absent", "pop_emp",
  "pop_emp_dich", "secteur_institutionnel", "secteur_institionnel2",
  "secteur_institutionnel3", "aucun_emp", "futures_staters", "pop_chomage",
  "pop_chomage_dich", "statut_MO", "MO", "MO_dich", "Non_dispo", "aucune_rech",
  "MOPOT", "MOPOT_dich", "MOPOT_bis", "workers_decu", "Non_demand", "MOE",
  "MOE_dich", "hor_eff", "sous_emp", "SU1", "SU2", "SU3", "SU4", "emp_vul",
  "emp_prec", "no_education", "no_formation", "Formation_pro", "NEETs",
  "NEET15_24", "NEET15_35", "NEET15_40", "NEET15_24_bis", "NEET15_35_bis",
  "NEET15_40_bis", "pluriactivite", "sit_empEP", "duree_contrat", "sit_empEP2",
  "sit_empEP3", "CISE_18_new", "CISE_18_niv2", "sit_empEP_Autorite",
  "CISE_18_informel", "CISE_18_informel_Emp", "emploi_principale", "codecorrigé",
  "emploi_secondaire", "Codif_à_considerer", "_merge", "filtre_wkt1a",
  "filtre_wkt13a", "filtre_wkt10a", "wkt1a", "wkt10a", "wkt13a",
  "out_temps_wkt1a", "med_cluster_wkt1a", "wkt1a_corrige", "med_cluster1_wkt1a",
  "med_cluster2_wkt1a", "med_cluster3_wkt1a", "out_temps_wkt10a",
  "med_cluster_wkt10a", "wkt10a_corrige", "med_cluster1_wkt10a",
  "med_cluster2_wkt10a", "med_cluster3_wkt10a", "out_temps_wkt13a",
  "med_cluster_wkt13a", "wkt13a_corrige", "med_cluster1_wkt13a",
  "med_cluster2_wkt13a", "med_cluster3_wkt13a", "pmencor_ind"
)

# Filtrer pour le trimestre cible
# Convertir TARGET_QUARTER en format attendu (ex: "2025_T3" -> "25T3")
quarter_filter <- gsub("20(\\d{2})_T(\\d)", "\\1T\\2", TARGET_QUARTER)

LFS_ILO_IND_TARGET <- base_complete %>%
  filter(trimestre == quarter_filter) %>%
  select(any_of(vars_to_keep))

cat("Base filtrée:", nrow(LFS_ILO_IND_TARGET), "lignes,", ncol(LFS_ILO_IND_TARGET), "colonnes\n")

if (!all(c("interview_key", "membres_id") %in% names(LFS_ILO_IND_TARGET))) {
  stop("Variables de fusion manquantes")
}

rm(base_complete)

# Sauvegarde de référence (avec SUFFIXE_SIMU = trimestre + taux)
write_dta(
  LFS_ILO_IND_TARGET,
  file.path(SIMULATION_QUARTER_DIR, paste0("LFS_ILO_IND_", SUFFIXE_SIMU, ".dta"))
)

cat("✓ Base de référence sauvegardée\n")

# ----------------------------------------------------------------------
# FONCTION DE FUSION
# ----------------------------------------------------------------------

fuse_iteration_with_base <- function(iter) {

  iter_dir <- file.path(SIMULATION_QUARTER_DIR, paste0("iteration_", iter))

  # Charger la base iter calibrée (avec SUFFIXE_SIMU = trimestre + taux)
  base_iter <- read_dta(
    file.path(iter_dir, paste0("LFS_ILO_CAL_", SUFFIXE_SIMU, "_iter_", iter, ".dta"))
  )

  # Supprimer les variables conflictuelles
  variables_a_supprimer <- c("correction_factor_region_milieu")
  base_iter <- base_iter[, !names(base_iter) %in% variables_a_supprimer]

  if (!all(c("interview_key", "membres_id") %in% names(base_iter))) {
    stop("Itération ", iter, ": Clés de fusion manquantes")
  }

  # Fusion
  base_fusionnee <- base_iter %>%
    left_join(LFS_ILO_IND_TARGET, by = c("interview_key", "membres_id"))

  if (nrow(base_fusionnee) != nrow(base_iter)) {
    warning("Itération ", iter, ": Nombre de lignes modifié après fusion")
  }

  # Sauvegarde (avec SUFFIXE_SIMU = trimestre + taux)
  write_dta(
    base_fusionnee,
    file.path(iter_dir, paste0("LFS_ILO_CAL_IND_FUSED_", SUFFIXE_SIMU, "_iter_", iter, ".dta"))
  )

  tibble::tibble(
    iteration = iter,
    n_lignes_iter = nrow(base_iter),
    n_lignes_fused = nrow(base_fusionnee),
    n_colonnes_iter = ncol(base_iter),
    n_colonnes_fused = ncol(base_fusionnee),
    fusion_success = (nrow(base_fusionnee) == nrow(base_iter))
  )
}

# ----------------------------------------------------------------------
# EXÉCUTION PARALLÈLE
# ----------------------------------------------------------------------

N_CORES <- max(1, parallel::detectCores() - 1)
plan(multisession, workers = N_CORES)

cat("\nLancement fusion parallèle sur", N_ITER, "itérations...\n")

LFS_ILO_IND_TARGET_SHARED <- LFS_ILO_IND_TARGET

resume_fusions <- future_map_dfr(
  1:N_ITER,
  fuse_iteration_with_base,
  .progress = TRUE,
  .options = furrr_options(seed = TRUE)
)

# Sauvegarde
write_dta(
  resume_fusions,
  file.path(SIMULATION_QUARTER_DIR, paste0("resume_fusions_", SUFFIXE_SIMU, ".dta"))
)

write_xlsx(
  resume_fusions,
  file.path(SIMULATION_QUARTER_DIR, paste0("resume_fusions_", SUFFIXE_SIMU, ".xlsx"))
)

cat("\n=== RÉSUMÉ ÉTAPE 4 ===\n")
cat("Fusions réussies:", sum(resume_fusions$fusion_success), "/", N_ITER, "\n")
cat("Colonnes ajoutées:", resume_fusions$n_colonnes_fused[1] - resume_fusions$n_colonnes_iter[1], "\n")
