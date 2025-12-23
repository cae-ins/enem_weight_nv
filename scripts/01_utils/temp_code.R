# Charger les packages nécessaires
library(haven)      # Pour lire les fichiers Stata
library(dplyr)      # Pour la manipulation des données
df = read_dta("data/Base_Travail_BT.dta")
# Lire le fichier Stata

# Créer le dossier temp dans data s'il n'existe pas
dir.create("data/temp", showWarnings = FALSE, recursive = TRUE)

# Créer les dossiers pour les versions raw et simple dans data/temp
dir.create("data/temp/raw", showWarnings = FALSE)
dir.create("data/temp/simple", showWarnings = FALSE)

# Obtenir les trimestres uniques
trimestres <- unique(data$trimestre)

# Boucle pour chaque trimestre
for (t in trimestres) {
  # Filtrer les données pour le trimestre courant
  data_trimestre <- data %>% filter(trimestre == t)
  
  # Nom du fichier basé sur le format individu_TX_YYYY
  # Utilise directement la valeur de la variable trimestre
  nom_fichier <- paste0("individu_", t)
  
  # Sauvegarder la version RAW (format Stata)
  write_dta(data_trimestre, 
            path = file.path("data/temp/raw", paste0(nom_fichier, "_raw.dta")))
  
  # Créer la version SIMPLE en supprimant les colonnes qui commencent par FINAL
  data_simple <- data_trimestre %>% 
    select(-starts_with("FINAL"))
  
  # Sauvegarder la version SIMPLE (format Stata sans colonnes FINAL*)
  write_dta(data_simple, 
            path = file.path("data/temp/simple", paste0(nom_fichier, "_simple.dta")))
  
  cat("Trimestre", t, "traité:", nom_fichier, "créé\n")
}

cat("\nTraitement terminé!\n")
cat("Fichiers raw dans le dossier 'data/temp/raw/'\n")
cat("Fichiers simple dans le dossier 'data/temp/simple/'\n")

