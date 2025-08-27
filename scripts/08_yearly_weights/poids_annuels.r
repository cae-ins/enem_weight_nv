library(haven)
library(dplyr)
library(stringr)
library(fs)

source("config/1_config.r")

DATA_DIR <- file.path(BASE_DIR, "data")
WEIGHTS_DIR <- file.path(DATA_DIR, "04_weights")

message("🚀 Agrégation des poids individuels par interview_key x membres_id")
message("📊 Traitement uniquement des fichiers individu_calibrated_YYYY.dta")
message("📈 Calcul de la moyenne de FINAL_WEIGHT pour chaque couple unique")

# DIAGNOSTIC : Explorer la structure du répertoire
message("🔍 DIAGNOSTIC DE LA STRUCTURE DU RÉPERTOIRE")
message("📁 Répertoire exploré : ", WEIGHTS_DIR)

# Lister TOUS les éléments dans WEIGHTS_DIR
all_items <- dir_ls(WEIGHTS_DIR, recurse = FALSE)
message("📋 Tous les éléments trouvés : ", length(all_items))

if (length(all_items) > 0) {
  for (item in all_items) {
    item_type <- if (dir_exists(item)) "📁 Dossier" else "📄 Fichier"
    message("   ", item_type, " : ", basename(item))
  }
} else {
  message("   ❌ Répertoire vide ou inexistant")
}

# Lister spécifiquement les dossiers
all_dirs <- dir_ls(WEIGHTS_DIR, type = "directory")
message("\n📁 Dossiers trouvés : ", length(all_dirs))
for (d in all_dirs) {
  message("   - ", basename(d))
}

# Chercher les dossiers annuels avec le pattern strict
year_dirs <- dir_ls(WEIGHTS_DIR, type = "directory", regexp = "/\\d{4}$")
message("\n🎯 Dossiers correspondant au pattern '^\\d{4}")

message("📁 Dossiers annuels trouvés : ", paste(basename(year_dirs), collapse = ", "))

# Traiter chaque année
for (year_dir in year_dirs) {
  year <- basename(year_dir)
  
  message("\n", rep("=", 60))
  message("🔄 TRAITEMENT DE L'ANNÉE : ", year)
  message(rep("=", 60))
  
  # Chercher le fichier individu calibré
  individu_file <- file.path(year_dir, paste0("individu_calibrated_", year, ".dta"))
  
  # Vérifier l'existence du fichier
  if (!file_exists(individu_file)) {
    message("❌ Fichier individu calibré manquant : ", basename(individu_file))
    next
  }
  
  message("✓ Fichier individu calibré trouvé : ", basename(individu_file))
  
  # Traitement du fichier
  tryCatch({
    message("\n📖 Lecture du fichier...")
    
    # Lire le fichier
    df <- read_dta(individu_file)
    
    message("   📊 Données originales : ", nrow(df), " lignes, ", ncol(df), " colonnes")
    
    # Vérifier la présence des colonnes nécessaires
    required_cols <- c("interview_key", "membres_id", "FINAL_WEIGHT")
    missing_cols <- required_cols[!required_cols %in% names(df)]
    
    if (length(missing_cols) > 0) {
      message("   ❌ Colonnes manquantes : ", paste(missing_cols, collapse = ", "))
      message("   📋 Colonnes disponibles : ", paste(names(df), collapse = ", "))
      next
    }
    
    message("   ✓ Colonnes requises présentes")
    
    # Diagnostic des données
    total_obs <- nrow(df)
    complete_obs <- sum(complete.cases(df[required_cols]))
    
    message("   📈 Observations complètes : ", complete_obs, "/", total_obs, 
            " (", round(100 * complete_obs / total_obs, 1), "%)")
    
    # Statistiques avant agrégation
    unique_keys <- length(unique(df$interview_key))
    unique_membres <- length(unique(df$membres_id))
    unique_couples_before <- nrow(distinct(df, interview_key, membres_id))
    
    message("   📊 Avant agrégation :")
    message("      - interview_key uniques : ", unique_keys)
    message("      - membres_id uniques : ", unique_membres)  
    message("      - Couples uniques : ", unique_couples_before)
    message("      - Observations totales : ", total_obs)
    message("      - Moyenne obs/couple : ", round(total_obs / unique_couples_before, 2))
    
    message("\n🔄 Agrégation en cours...")
    
    # Calculer la moyenne des poids par couple interview_key x membres_id
    df_aggregated <- df %>%
      # Garder seulement les observations complètes pour les variables clés
      filter(complete.cases(select(., all_of(required_cols)))) %>%
      # Grouper par le couple de variables
      group_by(interview_key, membres_id) %>%
      # Calculer les statistiques
      summarise(
        FINAL_WEIGHT_mean = mean(FINAL_WEIGHT, na.rm = TRUE),
        FINAL_WEIGHT_n = n(),
        FINAL_WEIGHT_min = min(FINAL_WEIGHT, na.rm = TRUE),
        FINAL_WEIGHT_max = max(FINAL_WEIGHT, na.rm = TRUE),
        FINAL_WEIGHT_sd = if_else(n() > 1, sd(FINAL_WEIGHT, na.rm = TRUE), 0),
        # Garder d'autres variables importantes (première occurrence)
        annee = first(annee, na_rm = TRUE),
        trimestre_info = paste(sort(unique(trimestre)), collapse = ","),
        source_files = paste(unique(source_file), collapse = ";"),
        .groups = "drop"
      ) %>%
      # Ajouter des métadonnées
      mutate(
        aggregation_date = Sys.Date(),
        year_processed = as.integer(year)
      )
    
    # Statistiques sur l'agrégation
    unique_couples_after <- nrow(df_aggregated)
    couples_with_multiple <- sum(df_aggregated$FINAL_WEIGHT_n > 1)
    max_obs_per_couple <- max(df_aggregated$FINAL_WEIGHT_n)
    
    message("   📊 Résultats agrégation :")
    message("      - Couples uniques après agrégation : ", unique_couples_after)
    message("      - Couples avec observations multiples : ", couples_with_multiple, 
            " (", round(100 * couples_with_multiple / unique_couples_after, 1), "%)")
    message("      - Maximum d'observations par couple : ", max_obs_per_couple)
    message("      - Moyenne d'observations par couple : ", 
            round(mean(df_aggregated$FINAL_WEIGHT_n), 2))
    
    # Statistiques sur les poids
    message("   📈 Statistiques des poids agrégés :")
    message("      - Moyenne générale : ", round(mean(df_aggregated$FINAL_WEIGHT_mean), 4))
    message("      - Médiane : ", round(median(df_aggregated$FINAL_WEIGHT_mean), 4))
    message("      - Min/Max : ", round(min(df_aggregated$FINAL_WEIGHT_mean), 4), 
            " / ", round(max(df_aggregated$FINAL_WEIGHT_mean), 4))
    
    # Sauvegarder le résultat
    message("\n💾 Sauvegarde du fichier agrégé...")
    
    output_file <- file.path(year_dir, paste0("individu_weights_aggregated_", year, ".dta"))
    
    write_dta(df_aggregated, output_file)
    
    # Statistiques du fichier créé
    file_info <- file.info(output_file)
    size_mb <- round(file_info$size / (1024^2), 2)
    
    message("   ✅ Fichier sauvegardé : ", basename(output_file))
    message("      - Lignes : ", nrow(df_aggregated))
    message("      - Colonnes : ", ncol(df_aggregated))
    message("      - Taille : ", size_mb, " MB")
    message("      - Réduction : ", round(100 * (1 - nrow(df_aggregated) / total_obs), 1), "% moins de lignes")
    
    # Créer un petit rapport de validation
    validation_report <- df_aggregated %>%
      summarise(
        total_couples = n(),
        couples_multi_obs = sum(FINAL_WEIGHT_n > 1),
        pct_multi_obs = round(100 * mean(FINAL_WEIGHT_n > 1), 1),
        mean_weight = round(mean(FINAL_WEIGHT_mean), 4),
        median_weight = round(median(FINAL_WEIGHT_mean), 4),
        trimestres_represented = length(unique(str_split(trimestre_info, ",", simplify = TRUE))),
        year = year
      )
    
    message("   📋 Validation :")
    message("      - Couples traités : ", validation_report$total_couples)
    message("      - % avec obs multiples : ", validation_report$pct_multi_obs, "%")
    message("      - Poids moyen : ", validation_report$mean_weight)
    
  }, error = function(e) {
    message("   ❌ Erreur lors du traitement de l'année ", year, " : ", e$message)
  })
}

message("\n", rep("=", 70))
message("🎉 AGRÉGATION DES POIDS INDIVIDUELS TERMINÉE")
message(rep("=", 70))

# Rapport final global
message("\n📊 RAPPORT FINAL :")

# Compter les fichiers créés
total_files <- 0
total_size_mb <- 0

for (year_dir in year_dirs) {
  year <- basename(year_dir)
  
  # Fichiers agrégés individuels
  agg_file <- file.path(year_dir, paste0("individu_weights_aggregated_", year, ".dta"))
  
  if (file_exists(agg_file)) {
    file_info <- file.info(agg_file)
    size_mb <- round(file_info$size / (1024^2), 2)
    
    message("📅 ", year, " : ", basename(agg_file), " (", size_mb, " MB)")
    
    total_files <- total_files + 1
    total_size_mb <- total_size_mb + size_mb
  }
}

if (total_files > 0) {
  message("\n✅ Résumé :")
  message("   - Fichiers créés : ", total_files)
  message("   - Taille totale : ", round(total_size_mb, 2), " MB")
  
  message("\n📍 Structure finale :")
  message("   WEIGHTS_DIR/YYYY/")
  message("   ├── individu_calibrated_YYYY.dta        ← Fichier source")
  message("   └── individu_weights_aggregated_YYYY.dta ← Fichier agrégé")
  
  message("\n🔍 Variables dans le fichier agrégé :")
  message("   - interview_key, membres_id : Clés d'identification")
  message("   - FINAL_WEIGHT_mean : MOYENNE des poids (variable principale)")
  message("   - FINAL_WEIGHT_n : Nombre d'observations par couple")
  message("   - FINAL_WEIGHT_min/max : Valeurs min/max des poids")
  message("   - FINAL_WEIGHT_sd : Écart-type des poids")
  message("   - trimestre_info : Liste des trimestres représentés")
  message("   - source_files : Fichiers sources utilisés")
  
} else {
  message("❌ Aucun fichier agrégé n'a été créé")
}

message("\n🎯 Objectif atteint : Un poids moyen unique par couple interview_key x membres_id") : ", length(year_dirs))

if (length(year_dirs) == 0) {
  message("❌ Aucun dossier annuel trouvé avec le pattern strict")
  message("💡 Les fichiers individu_calibrated_YYYY.dta ont-ils été créés par le script précédent ?")
  message("💡 Vérifiez si les dossiers YYYY existent dans : ", WEIGHTS_DIR)
  
  # Chercher les fichiers calibrés dans d'autres endroits
  message("\n🔍 Recherche de fichiers individu_calibrated_*.dta...")
  calibrated_files <- dir_ls(WEIGHTS_DIR, regexp = "individu_calibrated_.*\\.dta$", recurse = TRUE)
  
  if (length(calibrated_files) > 0) {
    message("✓ Fichiers calibrés trouvés :")
    for (f in calibrated_files) {
      message("   - ", f)
    }
    
    message("\n💡 Suggestion : Les fichiers calibrés existent mais pas dans des dossiers YYYY/")
    message("   Relancez le premier script pour créer la structure correcte")
  } else {
    message("❌ Aucun fichier individu_calibrated_*.dta trouvé nulle part")
    message("💡 Vous devez d'abord lancer le script d'agrégation calibrateFINAL_WEIGHT")
  }
  
  stop("🛑 Arrêt du script - Structure de dossiers incorrecte")
}

message("📁 Dossiers annuels trouvés : ", paste(basename(year_dirs), collapse = ", "))

# Traiter chaque année
for (year_dir in year_dirs) {
  year <- basename(year_dir)
  
  message("\n", rep("=", 60))
  message("🔄 TRAITEMENT DE L'ANNÉE : ", year)
  message(rep("=", 60))
  
  # Chercher le fichier individu calibré
  individu_file <- file.path(year_dir, paste0("individu_calibrated_", year, ".dta"))
  
  # Vérifier l'existence du fichier
  if (!file_exists(individu_file)) {
    message("❌ Fichier individu calibré manquant : ", basename(individu_file))
    next
  }
  
  message("✓ Fichier individu calibré trouvé : ", basename(individu_file))
  
  # Traitement du fichier
  tryCatch({
    message("\n📖 Lecture du fichier...")
    
    # Lire le fichier
    df <- read_dta(individu_file)
    
    message("   📊 Données originales : ", nrow(df), " lignes, ", ncol(df), " colonnes")
    
    # Vérifier la présence des colonnes nécessaires
    required_cols <- c("interview_key", "membres_id", "FINAL_WEIGHT")
    missing_cols <- required_cols[!required_cols %in% names(df)]
    
    if (length(missing_cols) > 0) {
      message("   ❌ Colonnes manquantes : ", paste(missing_cols, collapse = ", "))
      message("   📋 Colonnes disponibles : ", paste(names(df), collapse = ", "))
      next
    }
    
    message("   ✓ Colonnes requises présentes")
    
    # Diagnostic des données
    total_obs <- nrow(df)
    complete_obs <- sum(complete.cases(df[required_cols]))
    
    message("   📈 Observations complètes : ", complete_obs, "/", total_obs, 
            " (", round(100 * complete_obs / total_obs, 1), "%)")
    
    # Statistiques avant agrégation
    unique_keys <- length(unique(df$interview_key))
    unique_membres <- length(unique(df$membres_id))
    unique_couples_before <- nrow(distinct(df, interview_key, membres_id))
    
    message("   📊 Avant agrégation :")
    message("      - interview_key uniques : ", unique_keys)
    message("      - membres_id uniques : ", unique_membres)  
    message("      - Couples uniques : ", unique_couples_before)
    message("      - Observations totales : ", total_obs)
    message("      - Moyenne obs/couple : ", round(total_obs / unique_couples_before, 2))
    
    message("\n🔄 Agrégation en cours...")
    
    # Calculer la moyenne des poids par couple interview_key x membres_id
    df_aggregated <- df %>%
      # Garder seulement les observations complètes pour les variables clés
      filter(complete.cases(select(., all_of(required_cols)))) %>%
      # Grouper par le couple de variables
      group_by(interview_key, membres_id) %>%
      # Calculer les statistiques
      summarise(
        FINAL_WEIGHT_mean = mean(FINAL_WEIGHT, na.rm = TRUE),
        FINAL_WEIGHT_n = n(),
        FINAL_WEIGHT_min = min(FINAL_WEIGHT, na.rm = TRUE),
        FINAL_WEIGHT_max = max(FINAL_WEIGHT, na.rm = TRUE),
        FINAL_WEIGHT_sd = if_else(n() > 1, sd(FINAL_WEIGHT, na.rm = TRUE), 0),
        # Garder d'autres variables importantes (première occurrence)
        annee = first(annee, na_rm = TRUE),
        trimestre_info = paste(sort(unique(trimestre)), collapse = ","),
        source_files = paste(unique(source_file), collapse = ";"),
        .groups = "drop"
      ) %>%
      # Ajouter des métadonnées
      mutate(
        aggregation_date = Sys.Date(),
        year_processed = as.integer(year)
      )
    
    # Statistiques sur l'agrégation
    unique_couples_after <- nrow(df_aggregated)
    couples_with_multiple <- sum(df_aggregated$FINAL_WEIGHT_n > 1)
    max_obs_per_couple <- max(df_aggregated$FINAL_WEIGHT_n)
    
    message("   📊 Résultats agrégation :")
    message("      - Couples uniques après agrégation : ", unique_couples_after)
    message("      - Couples avec observations multiples : ", couples_with_multiple, 
            " (", round(100 * couples_with_multiple / unique_couples_after, 1), "%)")
    message("      - Maximum d'observations par couple : ", max_obs_per_couple)
    message("      - Moyenne d'observations par couple : ", 
            round(mean(df_aggregated$FINAL_WEIGHT_n), 2))
    
    # Statistiques sur les poids
    message("   📈 Statistiques des poids agrégés :")
    message("      - Moyenne générale : ", round(mean(df_aggregated$FINAL_WEIGHT_mean), 4))
    message("      - Médiane : ", round(median(df_aggregated$FINAL_WEIGHT_mean), 4))
    message("      - Min/Max : ", round(min(df_aggregated$FINAL_WEIGHT_mean), 4), 
            " / ", round(max(df_aggregated$FINAL_WEIGHT_mean), 4))
    
    # Sauvegarder le résultat
    message("\n💾 Sauvegarde du fichier agrégé...")
    
    output_file <- file.path(year_dir, paste0("individu_weights_aggregated_", year, ".dta"))
    
    write_dta(df_aggregated, output_file)
    
    # Statistiques du fichier créé
    file_info <- file.info(output_file)
    size_mb <- round(file_info$size / (1024^2), 2)
    
    message("   ✅ Fichier sauvegardé : ", basename(output_file))
    message("      - Lignes : ", nrow(df_aggregated))
    message("      - Colonnes : ", ncol(df_aggregated))
    message("      - Taille : ", size_mb, " MB")
    message("      - Réduction : ", round(100 * (1 - nrow(df_aggregated) / total_obs), 1), "% moins de lignes")
    
    # Créer un petit rapport de validation
    validation_report <- df_aggregated %>%
      summarise(
        total_couples = n(),
        couples_multi_obs = sum(FINAL_WEIGHT_n > 1),
        pct_multi_obs = round(100 * mean(FINAL_WEIGHT_n > 1), 1),
        mean_weight = round(mean(FINAL_WEIGHT_mean), 4),
        median_weight = round(median(FINAL_WEIGHT_mean), 4),
        trimestres_represented = length(unique(str_split(trimestre_info, ",", simplify = TRUE))),
        year = year
      )
    
    message("   📋 Validation :")
    message("      - Couples traités : ", validation_report$total_couples)
    message("      - % avec obs multiples : ", validation_report$pct_multi_obs, "%")
    message("      - Poids moyen : ", validation_report$mean_weight)
    
  }, error = function(e) {
    message("   ❌ Erreur lors du traitement de l'année ", year, " : ", e$message)
  })
}

message("\n", rep("=", 70))
message("🎉 AGRÉGATION DES POIDS INDIVIDUELS TERMINÉE")
message(rep("=", 70))

# Rapport final global
message("\n📊 RAPPORT FINAL :")

# Compter les fichiers créés
total_files <- 0
total_size_mb <- 0

for (year_dir in year_dirs) {
  year <- basename(year_dir)
  
  # Fichiers agrégés individuels
  agg_file <- file.path(year_dir, paste0("individu_weights_aggregated_", year, ".dta"))
  
  if (file_exists(agg_file)) {
    file_info <- file.info(agg_file)
    size_mb <- round(file_info$size / (1024^2), 2)
    
    message("📅 ", year, " : ", basename(agg_file), " (", size_mb, " MB)")
    
    total_files <- total_files + 1
    total_size_mb <- total_size_mb + size_mb
  }
}

if (total_files > 0) {
  message("\n✅ Résumé :")
  message("   - Fichiers créés : ", total_files)
  message("   - Taille totale : ", round(total_size_mb, 2), " MB")
  
  message("\n📍 Structure finale :")
  message("   WEIGHTS_DIR/YYYY/")
  message("   ├── individu_calibrated_YYYY.dta        ← Fichier source")
  message("   └── individu_weights_aggregated_YYYY.dta ← Fichier agrégé")
  
  message("\n🔍 Variables dans le fichier agrégé :")
  message("   - interview_key, membres_id : Clés d'identification")
  message("   - FINAL_WEIGHT_mean : MOYENNE des poids (variable principale)")
  message("   - FINAL_WEIGHT_n : Nombre d'observations par couple")
  message("   - FINAL_WEIGHT_min/max : Valeurs min/max des poids")
  message("   - FINAL_WEIGHT_sd : Écart-type des poids")
  message("   - trimestre_info : Liste des trimestres représentés")
  message("   - source_files : Fichiers sources utilisés")
  
} else {
  message("❌ Aucun fichier agrégé n'a été créé")
}

message("\n🎯 Objectif atteint : Un poids moyen unique par couple interview_key x membres_id")
