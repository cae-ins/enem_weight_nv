# ======================================================================
# FUSION DES BASES ITER AVEC LA BASE INDIVIDU T3 2025
# ======================================================================

library(dplyr)
library(haven)
library(future)
library(furrr)
library(writexl)

# ----------------------------------------------------------------------
# CONFIGURATION
# ----------------------------------------------------------------------

source("config/1_config.r")

DATA_DIR <- file.path(BASE_DIR, "data")
WEIGHTS_DIR <- file.path(DATA_DIR, "04_weights")
SIMULATION_DIR <- file.path(WEIGHTS_DIR, "simulation")
SIMULATION_QUARTER_DIR <- file.path(SIMULATION_DIR, TARGET_QUARTER)

RATIO_REDUCTION <- 0.50
N_ITER <- 30
SUFFIXE_SIMU <- paste0(TARGET_QUARTER, "_", RATIO_REDUCTION * 100, "pct")

# ----------------------------------------------------------------------
# I. CHARGER ET FILTRER LA BASE COMPLÈTE T3 2025
# ----------------------------------------------------------------------

cat("\n=== Chargement de la base T3 2025 ===\n")

BASE_COMPLETE_PATH <- file.path("data", "04_weights", "Base_Travail_BT_vf.dta")

# Charger la base complète
base_complete <- read_dta(BASE_COMPLETE_PATH)

cat("✓ Base complète chargée (", nrow(base_complete), "lignes)\n")

# Liste des variables à conserver
vars_to_keep <- c(
  # Variables de fusion
  "interview_key", "membres_id",
  # Variables indicateurs
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

# Filtrer pour T3 2025 et garder uniquement les variables nécessaires
LFS_ILO_IND_T3_2025 <- base_complete %>%
  filter(trimestre == "25T3") %>%
  select(any_of(vars_to_keep))  # any_of() pour ignorer les variables absentes

cat("✓ Base T3 2025 filtrée (", nrow(LFS_ILO_IND_T3_2025), "lignes, ", 
    ncol(LFS_ILO_IND_T3_2025), "colonnes)\n")

# Vérifier que les clés de fusion sont présentes
if (!all(c("interview_key", "membres_id") %in% names(LFS_ILO_IND_T3_2025))) {
  stop("Erreur: Variables de fusion manquantes dans la base T3 2025")
}

cat("✓ Variables de fusion présentes\n")

# Libérer la mémoire
rm(base_complete)

# Sauvegarder la base T3 2025 pour référence
write_dta(
  LFS_ILO_IND_T3_2025,
  file.path(SIMULATION_QUARTER_DIR, "LFS_ILO_IND_T3_2025.dta")
)

cat("✓ Base T3 2025 sauvegardée\n\n")

# ----------------------------------------------------------------------
# II. FONCTION DE FUSION POUR UNE ITÉRATION
# ----------------------------------------------------------------------

fuse_iteration_with_base <- function(iter) {
  
  iter_dir <- file.path(SIMULATION_QUARTER_DIR, paste0("iteration_", iter))
  
  cat("Fusion itération", iter, "...\n")
  
  # Charger la base iter calibrée
  base_iter <- read_dta(
    file.path(iter_dir, paste0("LFS_ILO_CAL_", TARGET_QUARTER, "_iter_", iter, ".dta"))
  )
  
  # Supprimer les variables qui causent des conflits avant la fusion
  variables_a_supprimer <- c("correction_factor_region_milieu")
  base_iter <- base_iter[, !names(base_iter) %in% variables_a_supprimer]
  
  # Vérifier que les clés de fusion sont présentes dans base_iter
  if (!all(c("interview_key", "membres_id") %in% names(base_iter))) {
    stop("Itération ", iter, ": Clés de fusion manquantes (interview_key, membres_id)")
  }
  
  # Fusionner avec la base T3 2025
  base_fusionnee <- base_iter %>%
    left_join(LFS_ILO_IND_T3_2025, by = c("interview_key", "membres_id"))
  
  # Vérifier la fusion
  if (nrow(base_fusionnee) != nrow(base_iter)) {
    warning("Itération ", iter, ": Le nombre de lignes a changé après fusion (avant: ",
            nrow(base_iter), ", après: ", nrow(base_fusionnee), ")")
  }
  
  # Sauvegarder la base fusionnée
  write_dta(
    base_fusionnee,
    file.path(iter_dir, paste0("LFS_ILO_CAL_IND_FUSED_", TARGET_QUARTER, "_iter_", iter, ".dta"))
  )
  
  cat("✓ Itération", iter, "fusionnée (", nrow(base_fusionnee), "lignes)\n")
  
  # Retourner résumé
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
# III. TEST SUR UNE ITÉRATION
# ----------------------------------------------------------------------

# test_fusion <- fuse_iteration_with_base(1)
# print(test_fusion)

# ----------------------------------------------------------------------
# IV. FUSION PARALLÈLE POUR TOUTES LES ITÉRATIONS
# ----------------------------------------------------------------------

N_CORES <- max(1, parallel::detectCores() - 1)
plan(multisession, workers = N_CORES)

cat("\n=== Lancement fusion parallèle sur", N_ITER, "itérations ===\n")
cat("Nombre de cœurs utilisés:", N_CORES, "\n\n")

# Partager la base T3 2025 pour toutes les itérations
LFS_ILO_IND_T3_2025_SHARED <- LFS_ILO_IND_T3_2025

resume_fusions <- future_map_dfr(
  1:N_ITER,
  fuse_iteration_with_base,
  .progress = TRUE,
  .options = furrr_options(seed = TRUE)
)

# Sauvegarder le résumé
write_dta(
  resume_fusions,
  file.path(SIMULATION_QUARTER_DIR, paste0("resume_fusions_", SUFFIXE_SIMU, ".dta"))
)

write_xlsx(
  resume_fusions,
  file.path(SIMULATION_QUARTER_DIR, paste0("resume_fusions_", SUFFIXE_SIMU, ".xlsx"))
)

print(resume_fusions)

cat("\n=== RÉSUMÉ FUSION ===\n")
cat("✓ Fusion appliquée avec succès sur", N_ITER, "itérations\n")
cat("Fusions réussies:", sum(resume_fusions$fusion_success), "/", N_ITER, "\n")
cat("\nFichiers créés: iteration_X/LFS_ILO_CAL_IND_FUSED_", TARGET_QUARTER, "_iter_X.dta\n")