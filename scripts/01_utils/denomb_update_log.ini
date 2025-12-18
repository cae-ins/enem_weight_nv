# ==============================================================================
# Script Name: denomb_updates.R
# Purpose: Process newly updated ZD counts from Denombrement_update
#          and create a harmonized dataset with household and individual counts
# Author: Ezechiel KOFFIE
# Date: 13-07-2025
# ==============================================================================


cat("\n")
cat("╔════════════════════════════════════════════════════════════════════╗\n")
cat("║  TRAITEMENT DES MISES À JOUR DE DÉNOMBREMENT                      ║\n")
cat("║  Script: denomb_updates.R                                         ║\n")
cat("╚════════════════════════════════════════════════════════════════════╝\n")
cat("\n")

# ------------------------------------------------------------------------------
# 1. Load Required Libraries
# ------------------------------------------------------------------------------
cat("════════════════════════════════════════════════════════════════════\n")
cat("📚 ÉTAPE 1: CHARGEMENT DES LIBRAIRIES\n")
cat("════════════════════════════════════════════════════════════════════\n\n")

library(dplyr)
cat("   ✅ dplyr chargé\n")
library(readxl)
cat("   ✅ readxl chargé\n")
library(stringr)
cat("   ✅ stringr chargé\n")
library(purrr)
cat("   ✅ purrr chargé\n")
library(haven)
cat("   ✅ haven chargé\n\n")

# ------------------------------------------------------------------------------
# 2. Set Base Paths
# ------------------------------------------------------------------------------
cat("════════════════════════════════════════════════════════════════════\n")
cat("📁 ÉTAPE 2: CONFIGURATION DES CHEMINS\n")
cat("════════════════════════════════════════════════════════════════════\n\n")

source("config/1_config.r")
cat("   ✅ Configuration chargée depuis config/1_config.r\n\n")

RAW_UPDATE_DIR <- file.path(BASE_DIR, "data", "01_raw", "Denombrement_update")
CLEANED_BASE_DIR <- file.path(BASE_DIR, "data", "02_Cleaned", "Denombrement")
ref_path <- file.path(BASE_DIR, "data", "03_processed", "RP_2021", "nb_men_indivs_ZD.dta")

cat("📂 Chemins configurés:\n")
cat("   - Dossier des mises à jour (RAW):\n")
cat("     ", RAW_UPDATE_DIR, "\n")
cat("   - Dossier des données nettoyées:\n")
cat("     ", CLEANED_BASE_DIR, "\n")
cat("   - Fichier de référence RP 2021:\n")
cat("     ", ref_path, "\n\n")

# ------------------------------------------------------------------------------
# 3. Identify All Excel Files and Associated Quarters
# ------------------------------------------------------------------------------
cat("════════════════════════════════════════════════════════════════════\n")
cat("🔍 ÉTAPE 3: IDENTIFICATION DES FICHIERS EXCEL\n")
cat("════════════════════════════════════════════════════════════════════\n\n")

update_files <- list.files(RAW_UPDATE_DIR, recursive = TRUE, pattern = "\\.xlsx$", full.names = TRUE)

cat("📊 Fichiers Excel trouvés:", length(update_files), "\n")
if (length(update_files) > 0) {
  cat("\n📄 Liste des fichiers:\n")
  for (i in seq_along(update_files)) {
    cat(sprintf("   %2d. %s\n", i, basename(update_files[i])))
  }
}
cat("\n")

extract_quarter <- function(path) {
  folder <- str_match(path, "Denombrement_update/(T\\d_\\d{4})")[,2]
  return(folder)
}

# ------------------------------------------------------------------------------
# 4. Read and Combine Excel Files
# ------------------------------------------------------------------------------
cat("════════════════════════════════════════════════════════════════════\n")
cat("📥 ÉTAPE 4: LECTURE ET COMBINAISON DES FICHIERS\n")
cat("════════════════════════════════════════════════════════════════════\n\n")

skipped_files <- c()

read_and_tag_file <- function(file_path) {
  quarter <- extract_quarter(file_path)
  filename <- basename(file_path)
  
  cat("   📖 Lecture de:", filename, "\n")
  cat("      Trimestre associé:", quarter, "\n")
  
  df <- read_excel(file_path)
  cat("      Dimensions initiales:", nrow(df), "lignes x", ncol(df), "colonnes\n")
  
  if (!"IDSeg" %in% names(df)) {
    cat("      ⚠️  IGNORÉ: Colonne 'IDSeg' manquante\n\n")
    skipped_files <<- c(skipped_files, file_path)
    return(NULL)
  }
  
  df <- df %>%
    mutate(
      HH2          = as.character(HH2),
      HH3          = as.character(HH3),
      HH4          = as.character(HH4),
      HH8          = as.character(HH8),
      IDSeg        = as.numeric(zap_labels(IDSeg)),
      code_ilot    = as.numeric(zap_labels(code_ilot)),
      ilot__id     = as.numeric(zap_labels(ilot__id)),
      batiment__id = as.numeric(zap_labels(batiment__id)),
      menage__id   = as.numeric(zap_labels(menage__id)),
      adresse_menage = as.character(adresse_menage)
    ) %>%
    select(
      interview_key = interview__key,
      region        = HH2,
      depart        = HH3,
      souspref      = HH4,
      ZD            = HH8,
      segment       = IDSeg,
      code_ilot,
      ilot_id       = ilot__id,
      batiment_id   = batiment__id,
      menage_id     = menage__id,
      adresse_menage
    ) %>%
    mutate(quarter = quarter)
  
  cat("      ✅ Traité:", nrow(df), "enregistrements\n\n")
  
  return(df)
}

cat("🔄 Début de la lecture des fichiers...\n\n")
zd_info <- map_dfr(update_files, read_and_tag_file)

cat("📊 RÉSULTAT DE LA LECTURE:\n")
cat("   ✅ Total d'enregistrements combinés:", nrow(zd_info), "\n")
cat("   ✅ Fichiers traités avec succès:", length(update_files) - length(skipped_files), "\n")
if (length(skipped_files) > 0) {
  cat("   ⚠️  Fichiers ignorés:", length(skipped_files), "\n")
  for (file in skipped_files) {
    cat("      -", basename(file), "\n")
  }
}
cat("\n")

# ------------------------------------------------------------------------------
# 5. Reference Label Mapping
# ------------------------------------------------------------------------------
cat("════════════════════════════════════════════════════════════════════\n")
cat("🗺️  ÉTAPE 5: MAPPING DES CODES GÉOGRAPHIQUES\n")
cat("════════════════════════════════════════════════════════════════════\n\n")

cat("📥 Chargement du fichier de référence RP 2021...\n")
code_ref <- read_dta(ref_path) %>%
  select(region, region_label, depart, depart_label, souspref, souspref_label) %>%
  distinct() %>%
  mutate(across(ends_with("_label"), as.character))

cat("   ✅ Codes de référence chargés\n")
cat("      - Régions uniques:", n_distinct(code_ref$region), "\n")
cat("      - Départements uniques:", n_distinct(code_ref$depart), "\n")
cat("      - Sous-préfectures uniques:", n_distinct(code_ref$souspref), "\n\n")

cat("🔗 Application du mapping géographique...\n")
zd_info_avant <- nrow(zd_info)

zd_info <- zd_info %>%
  left_join(code_ref %>% distinct(region, region_label), by = c("region" = "region_label")) %>%
  left_join(code_ref %>% distinct(depart, depart_label), by = c("depart" = "depart_label")) %>%
  left_join(code_ref %>% distinct(souspref, souspref_label), by = c("souspref" = "souspref_label")) %>%
  transmute(
    interview_key,
    region    = as.double(zap_labels(region.y)),
    depart    = as.double(zap_labels(depart.y)),
    souspref  = as.double(zap_labels(souspref.y)),
    ZD        = as.character(ZD),
    segment,
    code_ilot,
    ilot_id,
    batiment_id,
    menage_id,
    adresse_menage,
    quarter
  )

cat("   ✅ Mapping appliqué\n")
cat("      Enregistrements:", zd_info_avant, "->", nrow(zd_info), "\n\n")

# ------------------------------------------------------------------------------
# 6. Aggregate Household Counts
# ------------------------------------------------------------------------------
cat("════════════════════════════════════════════════════════════════════\n")
cat("📊 ÉTAPE 6: AGRÉGATION DES COMPTAGES DE MÉNAGES\n")
cat("════════════════════════════════════════════════════════════════════\n\n")

cat("🔢 Calcul du nombre de ménages par segment...\n")
agg_data <- zd_info %>%
  group_by(region, depart, souspref, ZD, segment, quarter) %>%
  summarise(nb_mens_seg = n(), .groups = "drop") %>%
  left_join(
    zd_info %>%
      group_by(region, depart, souspref, ZD, quarter) %>%
      summarise(nb_mens_zd = n(), .groups = "drop"),
    by = c("region", "depart", "souspref", "ZD", "quarter")
  )

cat("   ✅ Agrégation par segment terminée\n")
cat("      - Segments uniques:", nrow(agg_data), "\n")
cat("      - Total ménages (tous segments):", sum(agg_data$nb_mens_seg, na.rm = TRUE), "\n")
cat("      - Moyenne ménages/segment:", round(mean(agg_data$nb_mens_seg, na.rm = TRUE), 2), "\n\n")

# ------------------------------------------------------------------------------
# 7. Extract Menage and Individual Info
# ------------------------------------------------------------------------------
cat("════════════════════════════════════════════════════════════════════\n")
cat("👥 ÉTAPE 7: EXTRACTION DES INFOS MÉNAGES ET INDIVIDUS\n")
cat("════════════════════════════════════════════════════════════════════\n\n")

normalize_column_names <- function(df) {
  names(df) <- tolower(gsub("__", "_", names(df)))
  return(df)
}

get_menage_data <- function(q) {
  cat("   📂 Traitement du trimestre:", q, "\n")
  
  cleaned_path <- file.path(CLEANED_BASE_DIR, q)
  cat("      Chemin:", cleaned_path, "\n")
  
  menage_file   <- list.files(cleaned_path, pattern = "^menage.*\\.dta$", full.names = TRUE)[1]
  batiment_file <- list.files(cleaned_path, pattern = "^batiment.*\\.dta$", full.names = TRUE)[1]
  ilot_file     <- list.files(cleaned_path, pattern = "^ilot.*\\.dta$", full.names = TRUE)[1]
  enem_file     <- list.files(cleaned_path, pattern = "^ENEM.*\\.dta$", full.names = TRUE)[1]
  
  if (any(is.na(c(menage_file, batiment_file, ilot_file, enem_file)))) {
    cat("      ⚠️  IGNORÉ: Un ou plusieurs fichiers manquants\n\n")
    return(NULL)
  }
  
  cat("      📥 Chargement des fichiers:\n")
  menage   <- read_dta(menage_file)   %>% normalize_column_names()
  cat("         ✅ menage:", nrow(menage), "lignes\n")
  
  batiment <- read_dta(batiment_file) %>% normalize_column_names()
  cat("         ✅ batiment:", nrow(batiment), "lignes\n")
  
  ilot     <- read_dta(ilot_file)     %>% normalize_column_names()
  cat("         ✅ ilot:", nrow(ilot), "lignes\n")
  
  enem     <- read_dta(enem_file)     %>% normalize_column_names()
  cat("         ✅ enem:", nrow(enem), "lignes\n")
  
  cat("      🔗 Fusion des tables...\n")
  menage_bat <- menage %>%
    left_join(batiment, by = c("interview_key", "ilot_id", "batiment_id")) %>%
    filter(!is.na(adresse))
  
  cat("         Menage + Batiment:", nrow(menage_bat), "lignes (avec adresse)\n")
  
  menage_bat <- menage_bat %>%
    left_join(ilot, by = c("interview_key", "ilot_id"))
  
  cat("         + Ilot:", nrow(menage_bat), "lignes\n")
  
  enem_select <- enem %>%
    select(interview_key, region = hh2, depart = hh3, souspref = hh4, ZD = hh8) %>%
    mutate(ZD = as.character(ZD))
  
  menage_full <- menage_bat %>%
    left_join(enem_select, by = "interview_key") %>%
    select(interview_key, region, depart, souspref, ZD,
           code_ilot, ilot_id, batiment_id, menage_id, adresse_menage, taille) %>%
    mutate(quarter = q, code_ilot = as.numeric(zap_labels(code_ilot)))
  
  cat("      ✅ Résultat final:", nrow(menage_full), "ménages complets\n")
  cat("         Total individus (taille):", sum(menage_full$taille, na.rm = TRUE), "\n\n")
  
  return(menage_full)
}

quarters <- unique(zd_info$quarter)
cat("🔄 Trimestres à traiter:", paste(quarters, collapse = ", "), "\n\n")

menage_data <- map_dfr(quarters, get_menage_data)

cat("📊 RÉSULTAT DE L'EXTRACTION:\n")
cat("   ✅ Total ménages extraits:", nrow(menage_data), "\n")
cat("   ✅ Total individus:", sum(menage_data$taille, na.rm = TRUE), "\n\n")

# ------------------------------------------------------------------------------
# 8. Merge Menage Info to ZD and Aggregate Individuals
# ------------------------------------------------------------------------------
cat("════════════════════════════════════════════════════════════════════\n")
cat("🔗 ÉTAPE 8: FUSION ET AGRÉGATION DES INDIVIDUS\n")
cat("════════════════════════════════════════════════════════════════════\n\n")

cat("🔗 Fusion des infos ménages avec ZD...\n")
zd_info_indivs <- zd_info %>%
  left_join(menage_data, by = c("region", "depart", "souspref", "ZD", "code_ilot", 
                                "ilot_id", "batiment_id", "menage_id", "adresse_menage", "quarter"))

cat("   ✅ Fusion complétée:", nrow(zd_info_indivs), "enregistrements\n\n")

cat("🔢 Agrégation des individus par segment et ZD...\n")
zd_info_final <- zd_info_indivs %>%
  group_by(region, depart, souspref, ZD, segment, quarter) %>%
  summarise(nb_indivs_seg = sum(taille, na.rm = TRUE), .groups = "drop") %>%
  left_join(
    zd_info_indivs %>%
      group_by(region, depart, souspref, ZD, quarter) %>%
      summarise(nb_indivs_zd = sum(taille, na.rm = TRUE), .groups = "drop"),
    by = c("region", "depart", "souspref", "ZD", "quarter")
  ) %>%
  left_join(
    agg_data,
    by = c("region", "depart", "souspref", "ZD", "segment", "quarter")
  )

cat("   ✅ Dataset final avec individus créé\n")
cat("      - Segments uniques:", nrow(zd_info_final), "\n")
cat("      - Total individus (segments):", sum(zd_info_final$nb_indivs_seg, na.rm = TRUE), "\n")
cat("      - Total individus (ZD):", sum(unique(zd_info_final[c("ZD", "quarter", "nb_indivs_zd")])$nb_indivs_zd, na.rm = TRUE), "\n\n")

# ------------------------------------------------------------------------------
# 9. Final Dataset Formatting
# ------------------------------------------------------------------------------
cat("════════════════════════════════════════════════════════════════════\n")
cat("✨ ÉTAPE 9: FORMATAGE FINAL DU DATASET\n")
cat("════════════════════════════════════════════════════════════════════\n\n")

cat("🔧 Sélection et formatage des colonnes...\n")
final_dataset <- zd_info_final %>%
  select(
    region, depart, souspref, ZD, segment,
    nb_indivs_seg, nb_mens_seg, nb_indivs_zd, nb_mens_zd, quarter
  ) %>%
  mutate(
    ZD = str_pad(as.character(ZD), width = 4, side = "left", pad = "0")
  )

cat("   ✅ Formatage terminé\n")
cat("      - ZD formatés (padding à 4 chiffres)\n\n")

# ------------------------------------------------------------------------------
# 10. Save Final Dataset with Timestamp
# ------------------------------------------------------------------------------
cat("════════════════════════════════════════════════════════════════════\n")
cat("💾 ÉTAPE 10: SAUVEGARDE DES DATASETS\n")
cat("════════════════════════════════════════════════════════════════════\n\n")

timestamp <- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")
output_filename <- paste0("denombrement_update_", timestamp, ".dta")
output_path <- file.path(BASE_DIR, "data", "02_Cleaned", "Denombrement_update", output_filename)

cat("📊 STATISTIQUES DU DATASET FINAL:\n")
cat("   - Nombre total d'enregistrements:", nrow(final_dataset), "\n")
cat("   - Nombre de colonnes:", ncol(final_dataset), "\n")
cat("   - Trimestres inclus:", paste(unique(final_dataset$quarter), collapse = ", "), "\n")
cat("   - ZD uniques:", n_distinct(final_dataset$ZD), "\n")
cat("   - Segments uniques:", n_distinct(paste(final_dataset$ZD, final_dataset$segment)), "\n\n")

cat("📊 Création du subset (segment = 1)...\n")
subset_dataset <- final_dataset %>%
  filter(segment == 1)

cat("   ✅ Subset créé:", nrow(subset_dataset), "enregistrements\n\n")

# ------------------------------------------------------------------------------
# 11. Final save
# ------------------------------------------------------------------------------
cat("💾 Sauvegarde des fichiers...\n")
cat("   Fichier de sortie:", output_filename, "\n")
cat("   Chemin complet:", output_path, "\n\n")

cat("📋 Structure du dataset complet:\n")
glimpse(final_dataset)
cat("\n")

cat("📋 Structure du dataset segment 1:\n")
glimpse(subset_dataset)
cat("\n")

# Chemin pour le dataset complet
output_path_full <- file.path(BASE_DIR, "data", "02_Cleaned", "Denombrement_update", 
                              paste0("denombrement_update_full_", timestamp, ".dta"))

# Chemin pour le dataset segment 1 (nom original conservé)
output_path <- file.path(BASE_DIR, "data", "02_Cleaned", "Denombrement_update", output_filename)

cat("💾 Écriture du dataset complet...\n")
cat("   Chemin:", output_path_full, "\n")
write_dta(final_dataset, output_path_full)
cat("   ✅ Dataset complet sauvegardé:", nrow(final_dataset), "enregistrements\n\n")

cat("💾 Écriture du dataset segment 1...\n")
cat("   Chemin:", output_path, "\n")
write_dta(subset_dataset, output_path)
cat("   ✅ Dataset segment 1 sauvegardé:", nrow(subset_dataset), "enregistrements\n\n")

cat("╔════════════════════════════════════════════════════════════════════╗\n")
cat("║  ✅ TRAITEMENT TERMINÉ AVEC SUCCÈS                                ║\n")
cat("╚════════════════════════════════════════════════════════════════════╝\n")
cat("\n")

cat("📊 RÉSUMÉ FINAL:\n")
cat("   ✅ Fichiers Excel traités:", length(update_files) - length(skipped_files), "/", length(update_files), "\n")
cat("   ✅ Trimestres traités:", length(quarters), "\n")
cat("   ✅ Enregistrements finaux (complet):", nrow(final_dataset), "\n")
cat("   ✅ Enregistrements finaux (segment 1):", nrow(subset_dataset), "\n")
cat("   📁 Fichiers de sortie:\n")
cat("      - Dataset complet:", basename(output_path_full), "\n")
cat("      - Dataset segment 1:", output_filename, "\n\n")