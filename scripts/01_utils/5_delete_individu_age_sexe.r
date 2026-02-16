################################################################################
# Script Name: delete_individu_age_sexe.R
# Purpose:     For each quarter, delete individual with no sex, no ages and no
#              household or household with no individuals.
# Author:      Franck MIGONE
# Date:        2025-12-11
################################################################################

# Chargement des packages
library(dplyr)
library(haven)
library(glue)
options(cli.config = NULL)

source("config/1_config.r")

# Définir le chemin d'accès
INPUT_ROOT <- file.path(BASE_DIR, "data", "02_Cleaned")
individu_path <- file.path(INPUT_ROOT, "Individu", TARGET_QUARTER)

INPUT_ROOT <- file.path(BASE_DIR, "data", "03_Processed")
menage_path <- file.path(INPUT_ROOT, "Menage", TARGET_QUARTER)


menage_file <- list.files(menage_path, pattern = "^menage.*\\.dta$", full.names = TRUE)[1]
individu_file <- list.files(individu_path, pattern = "^individu.*\\.dta$", full.names = TRUE)[1]

# Vérification de l'existence des fichiers
if (is.null(menage_file) || is.na(menage_file)) {
  stop("Fichier menage non trouvé dans: ", menage_path)
}
if (is.null(individu_file) || is.na(individu_file)) {
  stop("Fichier individu non trouvé dans: ", individu_path)
}

# Lire les bases
menage <- read_dta(menage_file)
individu <- read_dta(individu_file)

# Helper function to normalize column names
normalize_column_names <- function(df) {
  names(df) <- names(df) %>%
    tolower() %>%
    gsub("__", "_", .)
  return(df)
}

menage <- normalize_column_names(menage)
individu <- normalize_column_names(individu)

# Supprimer les colonnes dupliquées dans menage si nécessaire
if (any(duplicated(names(menage)))) {
  cat("Colonnes dupliquées détectées dans menage, suppression...\n")
  menage <- menage[, !duplicated(names(menage))]
}

# Statistiques initiales
cat(glue("\n=== STATISTIQUES INITIALES ===\n"))
cat(glue("Ménages: {nrow(menage)}\n"))
cat(glue("Individus: {nrow(individu)}\n"))
nrow(menage)
nrow(individu)
join_key <- "interview_key"

# ------------------------------------------------------------------------------
# ÉTAPE 1: Nettoyage des individus (âge, sexe)
# ------------------------------------------------------------------------------
cat(glue("\n=== ÉTAPE 1: Nettoyage des individus ===\n"))

individu_avant_nettoyage <- nrow(individu)
names(individu)[duplicated(names(individu))]
table(names(individu)) |> sort(decreasing = TRUE)
names(individu) <- make.unique(names(individu))

individu_cleaned <- individu %>%
  filter(!is.na(ageannee)) %>%
  filter(!is.na(m5)) %>%
  filter(ageannee != -9998)

cat("Individus supprimés (âge/sexe manquants): {individu_avant_nettoyage - nrow(individu_cleaned)}\n")
cat("Individus restants: {nrow(individu_cleaned)}\n")

# ------------------------------------------------------------------------------
# ÉTAPE 2: Supprimer les individus sans ménages
# ------------------------------------------------------------------------------
cat("\n=== ÉTAPE 2: Suppression des individus sans ménages ===\n")

menage_keys <- menage[[join_key]]
individu_avant_filtre <- nrow(individu_cleaned)

individu_avec_menage <- individu_cleaned %>%
  filter(!!sym(join_key) %in% menage_keys)

cat("Individus supprimés (sans ménage): {individu_avant_filtre - nrow(individu_avec_menage)}\n")
cat("Individus restants: {nrow(individu_avec_menage)}\n")
nrow(individu_avec_menage)
# ------------------------------------------------------------------------------
# ÉTAPE 3: Supprimer les ménages sans individus
# ------------------------------------------------------------------------------
cat(glue("\n=== ÉTAPE 3: Suppression des ménages sans individus ===\n"))

individu_keys <- individu_avec_menage[[join_key]]
menage_avant_filtre <- nrow(menage)

menage_avec_individus <- menage %>%
  filter(!!sym(join_key) %in% individu_keys)

cat(glue("Ménages supprimés (sans individus): {menage_avant_filtre - nrow(menage_avec_individus)}\n"))
cat(glue("Ménages restants: {nrow(menage_avec_individus)}\n"))

# ------------------------------------------------------------------------------
# Statistiques finales
# ------------------------------------------------------------------------------
cat(glue("\n=== STATISTIQUES FINALES ===\n"))
cat(glue("Ménages finaux: {nrow(menage_avec_individus)} (perte: {nrow(menage) - nrow(menage_avec_individus)})\n"))
cat(glue("Individus finaux: {nrow(individu_avec_menage)} (perte: {nrow(individu) - nrow(individu_avec_menage)})\n"))
cat(glue("Taux de rétention ménages: {round(nrow(menage_avec_individus)/nrow(menage)*100, 2)}%\n"))
cat(glue("Taux de rétention individus: {round(nrow(individu_avec_menage)/nrow(individu)*100, 2)}%\n"))

# ------------------------------------------------------------------------------
# Sauvegarde des fichiers nettoyés
# ------------------------------------------------------------------------------
cat(glue("\n=== SAUVEGARDE ===\n"))
names(menage_avec_individus) <- gsub("[^A-Za-z0-9_]", "_", names(menage_avec_individus))
names(individu_avec_menage) <- gsub("[^A-Za-z0-9_]", "_", names(individu_avec_menage))


INPUT_ROOT <- file.path(BASE_DIR, "data", "03_Processed")
menage_path <- file.path(INPUT_ROOT, "Menage", TARGET_QUARTER)
individu_path <- file.path(INPUT_ROOT, "Individu", TARGET_QUARTER)
individu_file <- file.path(individu_path, sprintf("individu_%s.dta", TARGET_QUARTER))
menage_file <- file.path(menage_path, sprintf("menage_%s.dta", TARGET_QUARTER))
write_dta(menage_avec_individus, menage_file)
write_dta(individu_avec_menage, individu_file)

cat(glue("Fichiers sauvegardés:\n"))
cat(glue("  - {menage_file}\n"))
cat(glue("  - {individu_file}\n"))
cat(glue("\n✓ Nettoyage terminé avec succès!\n"))


