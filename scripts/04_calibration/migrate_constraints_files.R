########################################################################################################################
#                                                                                                                      #
#  Script de Migration des Fichiers de Contraintes                                                                    #
#                                                                                                                      #
#  Ce script migre les fichiers Excel de contraintes depuis l'ancienne structure                                      #
#  (QUARTERLY_WEIGHTING/année/trimestre/schéma/) vers la nouvelle structure                                           #
#  (QUARTERLY_WEIGHTING/constraints/schéma/)                                                                           #
#                                                                                                                      #
########################################################################################################################

# Charger la configuration
source("config/1_config.r")

cat("\n")
cat("########################################################\n")
cat("#  Migration des fichiers de contraintes              #\n")
cat("########################################################\n\n")

# Définir les répertoires
old_base_dir <- file.path(BASE_DIR, "scripts/04_calibration/QUARTERLY_WEIGHTING")
new_base_dir <- file.path(BASE_DIR, "scripts/04_calibration/QUARTERLY_WEIGHTING/constraints")

# Créer le répertoire de destination s'il n'existe pas
if (!dir.exists(new_base_dir)) {
  dir.create(new_base_dir, recursive = TRUE)
  cat("✓ Répertoire de destination créé:", new_base_dir, "\n\n")
}

# Rechercher tous les fichiers de contraintes
cat("Recherche des fichiers de contraintes...\n")
constraint_files <- list.files(
  old_base_dir,
  pattern = "01_Set_of_constraints_.*\\.xlsx",
  recursive = TRUE,
  full.names = TRUE
)

cat("  → Trouvé", length(constraint_files), "fichiers de contraintes\n\n")

# Extraire les schémas uniques
schemas <- unique(sub(".*01_Set_of_constraints_(.*)\\.xlsx", "\\1", basename(constraint_files)))
cat("Schémas identifiés:\n")
for (schema in schemas) {
  cat("  -", schema, "\n")
}
cat("\n")

# Créer un rapport de migration
migration_report <- data.frame(
  schema = character(),
  source_file = character(),
  dest_file = character(),
  status = character(),
  stringsAsFactors = FALSE
)

# Migrer chaque schéma
cat("Début de la migration...\n\n")

for (schema in schemas) {

  cat("========================================================\n")
  cat("Schéma:", schema, "\n")
  cat("========================================================\n")

  # Créer le répertoire pour ce schéma
  schema_dir <- file.path(new_base_dir, schema)
  if (!dir.exists(schema_dir)) {
    dir.create(schema_dir, recursive = TRUE)
    cat("  ✓ Répertoire créé:", schema_dir, "\n")
  }

  # Trouver le fichier source pour ce schéma
  source_files <- grep(paste0("01_Set_of_constraints_", schema, "\\.xlsx"),
                       constraint_files, value = TRUE)

  if (length(source_files) == 0) {
    cat("  ⚠ Aucun fichier trouvé pour ce schéma\n\n")
    next
  }

  # Prendre le fichier le plus récent si plusieurs existent
  if (length(source_files) > 1) {
    file_info <- file.info(source_files)
    source_file <- rownames(file_info)[which.max(file_info$mtime)]
    cat("  ℹ Plusieurs fichiers trouvés, utilisation du plus récent:\n")
    cat("   ", source_file, "\n")
  } else {
    source_file <- source_files[1]
  }

  # Définir le fichier de destination
  dest_file <- file.path(schema_dir, paste0("01_Set_of_constraints_", schema, ".xlsx"))

  # Copier le fichier
  tryCatch({
    if (file.exists(dest_file)) {
      cat("  ℹ Le fichier existe déjà dans la destination\n")
      cat("    Source:", source_file, "\n")
      cat("    Destination:", dest_file, "\n")

      # Comparer les dates de modification
      source_mtime <- file.info(source_file)$mtime
      dest_mtime <- file.info(dest_file)$mtime

      if (source_mtime > dest_mtime) {
        cat("  → Le fichier source est plus récent, copie...\n")
        file.copy(source_file, dest_file, overwrite = TRUE)
        status <- "Mis à jour"
        cat("  ✓ Fichier mis à jour\n")
      } else {
        status <- "Existant (non modifié)"
        cat("  → Fichier de destination déjà à jour\n")
      }
    } else {
      file.copy(source_file, dest_file)
      status <- "Copié"
      cat("  ✓ Fichier copié avec succès\n")
    }

    # Ajouter au rapport
    migration_report <- rbind(migration_report, data.frame(
      schema = schema,
      source_file = source_file,
      dest_file = dest_file,
      status = status,
      stringsAsFactors = FALSE
    ))

  }, error = function(e) {
    cat("  ✗ ERREUR lors de la copie:", e$message, "\n")
    migration_report <- rbind(migration_report, data.frame(
      schema = schema,
      source_file = source_file,
      dest_file = dest_file,
      status = paste("ERREUR:", e$message),
      stringsAsFactors = FALSE
    ))
  })

  cat("\n")
}

# Afficher le rapport
cat("########################################################\n")
cat("#  Rapport de migration                                #\n")
cat("########################################################\n\n")

cat("Résumé:\n")
cat("  - Total de schémas traités:", length(schemas), "\n")
cat("  - Fichiers copiés:", sum(migration_report$status == "Copié"), "\n")
cat("  - Fichiers mis à jour:", sum(migration_report$status == "Mis à jour"), "\n")
cat("  - Fichiers existants (non modifiés):", sum(migration_report$status == "Existant (non modifié)"), "\n")
cat("  - Erreurs:", sum(grepl("ERREUR", migration_report$status)), "\n\n")

# Sauvegarder le rapport
report_file <- file.path(BASE_DIR, "scripts/04_calibration/migration_report.csv")
write.csv(migration_report, report_file, row.names = FALSE)
cat("Rapport détaillé sauvegardé dans:", report_file, "\n\n")

# Afficher le rapport détaillé
cat("Détails:\n")
print(migration_report[, c("schema", "status")], row.names = FALSE)

cat("\n")
cat("########################################################\n")
cat("#  Migration terminée                                  #\n")
cat("########################################################\n\n")

cat("Prochaines étapes:\n")
cat("  1. Vérifier le rapport de migration ci-dessus\n")
cat("  2. Tester la nouvelle architecture avec:\n")
cat("     source('scripts/04_calibration/run_calibration.R')\n")
cat("  3. Une fois validée, vous pouvez archiver l'ancienne structure\n\n")
