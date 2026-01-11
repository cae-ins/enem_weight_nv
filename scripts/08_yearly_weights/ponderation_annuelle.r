library(haven)
library(dplyr)

# Définir l'année
annee <- 2024

# Définir le chemin de base
base_path <- "C:/Users/f.migone/Desktop/ENE_SURVEY_WEIGHTS/data/04_weights"

# Détecter automatiquement les trimestres disponibles pour l'année
trimestres_possibles <- c("T1", "T2", "T3", "T4")
trimestres_disponibles <- c()

cat("Recherche des trimestres disponibles pour l'année", annee, "...\n")

for (trimestre in trimestres_possibles) {
  chemin_dossier <- file.path(base_path, paste0(trimestre, "_", annee))
  chemin_fichier <- file.path(chemin_dossier, 
                              "calibrated_weights", 
                              paste0("individu_", trimestre, "_", annee, "_CAL.dta"))
  
  if (file.exists(chemin_fichier)) {
    trimestres_disponibles <- c(trimestres_disponibles, trimestre)
    cat("  ✓", trimestre, ":", annee, "disponible\n")
  } else {
    cat("  ✗", trimestre, ":", annee, "non trouvé\n")
  }
}

# Vérifier qu'au moins un trimestre est disponible
if (length(trimestres_disponibles) == 0) {
  stop("Aucun trimestre trouvé pour l'année ", annee)
}

cat("\nNombre de trimestres détectés :", length(trimestres_disponibles), "\n")
cat("Trimestres à charger :", paste(trimestres_disponibles, collapse = ", "), "\n\n")

# Créer une liste vide pour stocker les datasets
liste_df <- list()

# Lire chaque trimestre disponible
for (trimestre in trimestres_disponibles) {
  chemin <- file.path(base_path, 
                      paste0(trimestre, "_", annee), 
                      "calibrated_weights", 
                      paste0("individu_", trimestre, "_", annee, "_CAL.dta"))
  
  liste_df[[trimestre]] <- read_dta(chemin)
  cat("Chargement :", trimestre, "_", annee, "(", nrow(liste_df[[trimestre]]), "observations)\n")
}

# Combiner tous les datasets
df <- bind_rows(liste_df)
cat("\nTotal après combinaison :", nrow(df), "observations\n")

# Compter les valeurs manquantes dans FINAL_WEIGHT
nb_missing <- sum(is.na(df$FINAL_WEIGHT))
cat("Valeurs manquantes dans FINAL_WEIGHT :", nb_missing, "\n")

# Diviser FINAL_WEIGHT par le nombre de trimestres disponibles
nb_trimestres <- length(trimestres_disponibles)
df <- df %>%
  mutate(FINAL_WEIGHT = FINAL_WEIGHT / nb_trimestres)

cat("FINAL_WEIGHT divisé par", nb_trimestres, "\n")

# Garder uniquement les variables spécifiées
df <- df %>%
  select(INDKEY, interview_key, membres_id, HHKEY, PSUKEY, STRATAKEY, FINAL_WEIGHT)

# Créer le chemin de sortie
chemin_sortie <- file.path(base_path, 
                           annee, 
                           paste0("LFS_WEIGHTS_", annee, ".dta"))

# Créer le dossier de sortie s'il n'existe pas
dir.create(dirname(chemin_sortie), showWarnings = FALSE, recursive = TRUE)

# Sauvegarder le fichier
write_dta(df, chemin_sortie)
cat("\n✓ Fichier sauvegardé :", chemin_sortie, "\n")
cat("  Nombre d'observations :", nrow(df), "\n")
cat("  Nombre de variables :", ncol(df), "\n")
