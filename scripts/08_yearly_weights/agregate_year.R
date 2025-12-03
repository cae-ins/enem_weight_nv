library(haven)
library(dplyr)
library(stringr)
library(fs)

source("config/1_config.r")

DATA_DIR <- file.path(BASE_DIR, "data")
WEIGHTS_DIR <- file.path(DATA_DIR, "04_weights")

# Types qui nécessitent une agrégation (dans calibrated_weights)
types_to_aggregate <- c("individu")

message("🚀 Agrégation des fichiers calibrés par année")
message("📋 Types à agréger : ", paste(types_to_aggregate, collapse = ", "))
message("ℹ️  Les autres types (base_weights, inconsistent_rows, menage) sont déjà dans base_weights/")

# Obtenir tous les dossiers trimestriels
dirs <- dir_ls(WEIGHTS_DIR, type = "directory", regexp = "T[1-4]_\\d{4}$")
message("📁 Dossiers trimestriels trouvés : ", length(dirs))

# Pour chaque type à agréger
for (ftype in types_to_aggregate) {
  message("\n", rep("=", 50))
  message("🔄 TRAITEMENT DU TYPE : ", toupper(ftype))
  message(rep("=", 50))
  
  # Liste pour stocker tous les DataFrames à fusionner
  all_data_list <- list()
  
  # Parcourir chaque dossier trimestriel
  for (d in dirs) {
    # Extraire trimestre et année du nom du dossier
    trimestre <- str_extract(basename(d), "^T[1-4]")
    annee <- str_extract(basename(d), "\\d{4}$")
    
    message("\n📂 Dossier : ", basename(d))
    
    # Chercher dans le sous-dossier calibrated_weights
    calibrated_dir <- file.path(d, "calibrated_weights")
    
    if (!dir_exists(calibrated_dir)) {
      message("   ❌ Sous-dossier 'calibrated_weights' non trouvé")
      # Lister les sous-dossiers disponibles
      subdirs <- dir_ls(d, type = "directory")
      if (length(subdirs) > 0) {
        message("   📋 Sous-dossiers disponibles : ")
        for(sd in subdirs) {
          message("      - ", basename(sd))
        }
      }
      next
    }
    
    message("   📁 Recherche dans : calibrated_weights/")
    
    # Lister tous les fichiers .dta dans calibrated_weights
    all_files <- dir_ls(calibrated_dir, regexp = "\\.dta$", recurse = FALSE)
    
    if (length(all_files) == 0) {
      message("   ❌ Aucun fichier .dta trouvé dans calibrated_weights/")
      next
    }
    
    # Filtrer les fichiers par type
    matching_files <- all_files[str_detect(basename(all_files), 
                                          regex(ftype, ignore_case = TRUE))]
    
    if (length(matching_files) == 0) {
      message("   ❌ Aucun fichier de type '", ftype, "' trouvé")
      message("   📋 Fichiers disponibles dans calibrated_weights/ : ")
      for(f in all_files) {
        message("      - ", basename(f))
      }
      next
    }
    
    message("   📋 Fichiers .dta trouvés pour ", ftype, " : ", length(matching_files))
    for(f in matching_files) {
      message("      - ", basename(f))
    }
    
    # Lire et fusionner tous les fichiers de ce type dans ce trimestre
    tryCatch({
      # Lire tous les fichiers correspondants
      trimester_data_list <- list()
      
      for (file_path in matching_files) {
        file_df <- read_dta(file_path) %>%
          mutate(source_file = basename(file_path))
        
        trimester_data_list[[length(trimester_data_list) + 1]] <- file_df
        message("      ✓ Lu : ", basename(file_path), " (", nrow(file_df), " lignes)")
      }
      
      # Fusionner tous les fichiers de ce trimestre pour ce type
      if (length(trimester_data_list) == 1) {
        df <- trimester_data_list[[1]]
      } else {
        df <- bind_rows(trimester_data_list)
        message("      🔗 Fusion de ", length(trimester_data_list), " fichiers du trimestre")
      }
      
      # Ajouter les métadonnées
      df <- df %>%
        mutate(
          trimestre = trimestre,
          annee = as.integer(annee),
          source_dir = basename(d),
          type = ftype
        )
      
      # Ajouter à la liste globale
      all_data_list[[length(all_data_list) + 1]] <- df
      
      message("   ✅ Succès : ", nrow(df), " lignes, ", ncol(df), " colonnes")
      
    }, error = function(e) {
      message("   ❌ Erreur lecture : ", e$message)
    })
  }
  
  # Fusion de tous les DataFrames pour ce type
  if (length(all_data_list) > 0) {
    message("\n🔗 FUSION DES DONNÉES POUR ", toupper(ftype))
    message("   📊 Nombre de trimestres à fusionner : ", length(all_data_list))
    
    tryCatch({
      # Utiliser bind_rows pour fusionner tous les DataFrames
      combined_data <- bind_rows(all_data_list)
      
      message("   ✅ Fusion réussie : ", nrow(combined_data), " lignes totales")
      
      # Grouper par année pour sauvegarder
      years <- unique(combined_data$annee)
      message("   📅 Années présentes : ", paste(years, collapse = ", "))
      
      for (year in years) {
        year_data <- combined_data %>% 
          filter(annee == year)
        
        # Calculer le nombre de trimestres pour cette année
        nb_trimestres <- length(unique(year_data$trimestre))
        message("\n   🧮 Calcul du poids annuel pour ", year)
        message("      - Nombre de trimestres : ", nb_trimestres)
        
        # Créer la variable poids_annuel dynamiquement
        var_name <- paste0("poids_annuel_", year)
        
        # Vérifier si FINAL_WEIGHTS existe (avec différentes casses possibles)
        weight_col <- NULL
        possible_names <- c("FINAL_WEIGHT")
        
        for (col_name in possible_names) {
          if (col_name %in% names(year_data)) {
            weight_col <- col_name
            break
          }
        }
        
        if (!is.null(weight_col)) {
          # Calculer le poids annuel
          year_data <- year_data %>%
            mutate(!!var_name := !!sym(weight_col) / nb_trimestres)
          
          message("      ✅ Variable '", var_name, "' créée")
          message("      📊 Formule : ", weight_col, " / ", nb_trimestres)
          
          # Statistiques sur le poids annuel
          stats_poids <- year_data %>%
            summarise(
              min = min(!!sym(var_name), na.rm = TRUE),
              mean = mean(!!sym(var_name), na.rm = TRUE),
              max = max(!!sym(var_name), na.rm = TRUE),
              na_count = sum(is.na(!!sym(var_name)))
            )
          
          message("      📈 Stats ", var_name, " :")
          message("         Min  : ", round(stats_poids$min, 4))
          message("         Mean : ", round(stats_poids$mean, 4))
          message("         Max  : ", round(stats_poids$max, 4))
          if (stats_poids$na_count > 0) {
            message("         NA   : ", stats_poids$na_count)
          }
          
        } else {
          message("      ⚠️  Colonne FINAL_WEIGHTS non trouvée")
          message("      📋 Colonnes disponibles : ", paste(head(names(year_data), 10), collapse = ", "), "...")
        }
        
        # Créer le dossier de l'année si nécessaire
        year_dir <- file.path(WEIGHTS_DIR, as.character(year))
        dir_create(year_dir)
        
        # Nom du fichier de sortie
        output_file <- file.path(year_dir, paste0(ftype, "_calibrated_", year, ".dta"))
        
        # Sauvegarder
        tryCatch({
          write_dta(year_data, output_file)
          message("   💾 Sauvegardé : ", basename(output_file))
          message("      - Lignes : ", nrow(year_data))
          message("      - Colonnes : ", ncol(year_data))
          message("      - Trimestres : ", paste(sort(unique(year_data$trimestre)), collapse = ", "))
          
        }, error = function(e) {
          message("   ❌ Erreur sauvegarde : ", e$message)
        })
      }
      
    }, error = function(e) {
      message("   ❌ Erreur lors de la fusion : ", e$message)
    })
    
  } else {
    message("   ⚠️  Aucune donnée trouvée pour le type : ", ftype)
  }
}

message("\n", rep("=", 60))
message("🎉 AGRÉGATION TERMINÉE")
message(rep("=", 60))

# Rapport final
message("\n📊 RAPPORT FINAL :")
message("✅ Fichiers calibrés agrégés par année")
message("✅ Variables poids_annuel_YYYY créées (FINAL_WEIGHTS / nb_trimestres)")
message("📁 Les autres fichiers restent dans base_weights/ (pas d'agrégation nécessaire)")

# Lister les fichiers créés
output_dirs <- dir_ls(WEIGHTS_DIR, type = "directory", regexp = "^\\d{4}$")

if (length(output_dirs) > 0) {
  message("\n📂 Fichiers calibrés créés :")
  
  total_files <- 0
  for (year_dir in output_dirs) {
    year <- basename(year_dir)
    # Ne lister que les fichiers calibrés créés
    calibrated_files <- dir_ls(year_dir, regexp = "_calibrated_.*\\.dta$")
    
    if (length(calibrated_files) > 0) {
      message("   📅 ", year, " :")
      for (f in calibrated_files) {
        file_info <- file.info(f)
        size_mb <- round(file_info$size / (1024^2), 2)
        message("      - ", basename(f), " (", size_mb, " MB)")
        total_files <- total_files + 1
      }
    }
  }
  
  message("\n✅ Total : ", total_files, " fichiers calibrés agrégés créés")
  
} else {
  message("❌ Aucun fichier calibré n'a été créé")
}

message("\n📍 Structure finale :")
message("   WEIGHTS_DIR/")
message("   ├── base_weights/           ← Fichiers déjà prêts")
message("   │   ├── base_weights_*.dta")
message("   │   ├── inconsistent_rows_*.dta")
message("   │   └── menage_*.dta")
message("   └── YYYY/                   ← Fichiers calibrés agrégés")
message("       ├── individu_calibrated_YYYY.dta  (+ poids_annuel_YYYY)")
message("       └── SR_individu_calibrated_YYYY.dta  (+ poids_annuel_YYYY)")