# ==============================================================================
# SIMULATION DE RÉDUCTION DE TAILLE D'ÉCHANTILLON - ENQUÊTE LFS
# ==============================================================================
# Objectif: Simuler l'impact de la réduction du nombre de ménages par ZD
#           sur la précision des estimations tout en maintenant le nombre de ZD
# ==============================================================================

# Chargement des bibliothèques nécessaires
library(dplyr)
library(tidyr)
library(purrr)
library(survey)
library(ggplot2)
library(haven)
library(arrow)
# ==============================================================================
# ÉTAPE 0 : CONFIGURATION ET CHARGEMENT DES DONNÉES
# ==============================================================================

# Définir le répertoire de travail
source("config/1_config.r")
FILE_LFS_ILO_CAL_DTA_EXPORT <- get_export_path(TARGET_QUARTER, quarter, year, use_sr = FALSE)
DATA_DIR <- file.path(BASE_DIR, "data")
WEIGHTS_DIR <- file.path(DATA_DIR, "04_weights")

# Créer le dossier pour les simulations
SIMULATION_DIR <- file.path(WEIGHTS_DIR, "simulation")
SIMULATION_QUARTER_DIR <- file.path(SIMULATION_DIR, TARGET_QUARTER)

# Créer les dossiers s'ils n'existent pas
dir.create(SIMULATION_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(SIMULATION_QUARTER_DIR, showWarnings = FALSE, recursive = TRUE)

# Charger les données de l'enquête LFS
sample_data <- read_dta(FILE_LFS_ILO_CAL_DTA_EXPORT)
dim(sample_data)

# ==============================================================================
# PARAMÈTRES
# ==============================================================================

# Ratio de réduction à tester (exemple: 0.7 = garder 70% des ménages)
RATIO_REDUCTION <- 0.75

# Graine aléatoire pour la reproductibilité
set.seed(123)

# ==============================================================================
# ÉTAPE 1 : CRÉER UN DOUBLON DE LA BASE
# ==============================================================================

donnees_simulation <- sample_data

# ==============================================================================
# ÉTAPE 2 : RESTREINDRE AU NIVEAU MÉNAGE (une ligne = un ménage)
# ==============================================================================

base_menages <- donnees_simulation %>%
  group_by(PSUKEY, HHKEY) %>%
  slice(1) %>%  # Garder une seule ligne par ménage
  ungroup()

cat("Nombre de ménages:", nrow(base_menages), "\n")
cat("Nombre de PSU:", n_distinct(base_menages$PSUKEY), "\n")

# ==============================================================================
# ÉTAPE 3 : CALCULER LE NOMBRE DE MÉNAGES À GARDER PAR PSU
# ==============================================================================

# Compter les ménages par PSU
menages_par_psu <- base_menages %>%
  group_by(PSUKEY) %>%
  summarise(
    nb_menages_total = n(),
    .groups = "drop"
  ) %>%
  mutate(
    # Calculer le nombre à garder (x% des ménages)
    nb_a_garder_exact = nb_menages_total * RATIO_REDUCTION,
    
    # Arrondir à l'entier supérieur
    nb_a_garder = ceiling(nb_a_garder_exact),
    
    # Calculer le nombre à retirer
    nb_a_retirer = nb_menages_total - nb_a_garder
  )

print(head(menages_par_psu))

# ==============================================================================
# ÉTAPE 4 : SÉLECTIONNER ALÉATOIREMENT LES MÉNAGES À GARDER DANS CHAQUE PSU
# ==============================================================================

# Convertir PSUKEY en numérique pour éviter les problèmes de type
menages_par_psu <- menages_par_psu %>%
  mutate(PSUKEY = as.numeric(PSUKEY))

base_menages <- base_menages %>%
  mutate(PSUKEY = as.numeric(PSUKEY))

# Créer une liste par PSU, échantillonner, puis recombiner
liste_psu <- split(base_menages, base_menages$PSUKEY)

menages_selectionnes <- lapply(names(liste_psu), function(psu_id) {

  menages_psu <- liste_psu[[psu_id]]

  # récupérer le nombre à garder pour cette PSU
  nb_garder <- menages_par_psu$nb_a_garder[
    menages_par_psu$PSUKEY == as.numeric(psu_id)
  ]

  if (nrow(menages_psu) > 0 && length(nb_garder) > 0 && nb_garder > 0) {

    menages_psu %>%
      slice_sample(n = min(nb_garder, nrow(menages_psu))) %>%
      select(PSUKEY, HHKEY)

  } else {
    NULL
  }

}) %>% bind_rows()

cat("\nMénages gardés:", nrow(menages_selectionnes), "\n")
cat("Réduction effective:", 
    round((1 - nrow(menages_selectionnes)/nrow(base_menages)) * 100, 1), "%\n")

# ==============================================================================
# ÉTAPE 5 : FILTRER LA BASE COMPLÈTE (individus) POUR NE GARDER QUE 
#           LES INDIVIDUS DES MÉNAGES SÉLECTIONNÉS
# ==============================================================================

donnees_reduites <- donnees_simulation %>%
  semi_join(menages_selectionnes, by = c("PSUKEY", "HHKEY"))

cat("\nIndividus gardés:", nrow(donnees_reduites), "\n")
cat("Individus originaux:", nrow(donnees_simulation), "\n")
cat("Réduction:", 
    round((1 - nrow(donnees_reduites)/nrow(donnees_simulation)) * 100, 1), "%\n")

# ==============================================================================
# RÉSUMÉ
# ==============================================================================

cat("\n========================================\n")
cat("RÉSUMÉ DE LA RÉDUCTION\n")
cat("========================================\n")
cat("Ratio de réduction demandé:", RATIO_REDUCTION, "\n")
cat("PSU (inchangé):", n_distinct(donnees_reduites$PSUKEY), "\n")
cat("Ménages avant:", nrow(base_menages), "\n")
cat("Ménages après:", nrow(menages_selectionnes), "\n")
cat("Individus avant:", nrow(donnees_simulation), "\n")
cat("Individus après:", nrow(donnees_reduites), "\n")

# ==============================================================================
# SAUVEGARDE DES DONNÉES RÉDUITES
# ==============================================================================

# Nom du fichier avec le ratio de réduction
fichier_parquet <- file.path(SIMULATION_QUARTER_DIR, 
                             paste0("donnees_reduites_", RATIO_REDUCTION * 100, "pct.parquet"))

fichier_stata <- file.path(SIMULATION_QUARTER_DIR, 
                           paste0("donnees_reduites_", RATIO_REDUCTION * 100, "pct.dta"))

# Sauvegarder en parquet
write_parquet(donnees_reduites, fichier_parquet)
cat("\n✓ Données sauvegardées (Parquet) dans:", fichier_parquet, "\n")

# Sauvegarder en format Stata
write_dta(donnees_reduites, fichier_stata)
cat("✓ Données sauvegardées (Stata) dans:", fichier_stata, "\n")