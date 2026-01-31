# ==============================================================================
# GÉNÉRATION DE DONNÉES D'EXEMPLE POUR TESTER LE SCRIPT
# ==============================================================================
# Ce fichier crée des données fictives qui simulent une enquête LFS
# Utilisez-le pour tester le script avant d'utiliser vos vraies données
# ==============================================================================

library(dplyr)

# ==============================================================================
# PARAMÈTRES DES DONNÉES SIMULÉES
# ==============================================================================

set.seed(12345)  # Pour la reproductibilité

# Nombre d'UPEs
NB_UPES <- 100

# Nombre moyen de ménages par UPE (avec variation)
MENAGES_PAR_UPE_MOYEN <- 10
MENAGES_PAR_UPE_SD <- 2

# Taux de réponse des ménages (85%)
TAUX_REPONSE <- 0.85

# Nombre moyen de personnes par ménage
PERSONNES_PAR_MENAGE_MOYEN <- 3.5
PERSONNES_PAR_MENAGE_SD <- 1.5

# Total de ménages dans chaque UPE (pour calculer les probabilités)
TOTAL_MENAGES_UPE <- 1000

# ==============================================================================
# GÉNÉRATION DES UPES
# ==============================================================================

upes <- data.frame(
  upe_id = sprintf("UPE%03d", 1:NB_UPES),
  prob_upe = runif(NB_UPES, 0.008, 0.012),  # Probabilité de sélection UPE
  region = sample(c("Nord", "Sud", "Est", "Ouest", "Centre"), 
                  NB_UPES, replace = TRUE),
  zone = sample(c("Urbain", "Rural"), NB_UPES, 
                replace = TRUE, prob = c(0.6, 0.4))
)

# ==============================================================================
# GÉNÉRATION DES MÉNAGES
# ==============================================================================

generer_menages <- function(upe_row) {
  
  # Nombre de ménages sélectionnés dans cette UPE
  nb_menages_selectionnes <- max(5, round(rnorm(1, MENAGES_PAR_UPE_MOYEN, MENAGES_PAR_UPE_SD)))
  
  # Simuler le statut de réponse
  statut_reponse <- sample(
    c("complet", "non_reponse", "refus"),
    nb_menages_selectionnes,
    replace = TRUE,
    prob = c(TAUX_REPONSE, 0.10, 0.05)
  )
  
  menages <- data.frame(
    upe_id = upe_row$upe_id,
    menage_id = sprintf("%s_M%02d", upe_row$upe_id, 1:nb_menages_selectionnes),
    statut_reponse = statut_reponse,
    prob_menage_originale = nb_menages_selectionnes / TOTAL_MENAGES_UPE,
    region = upe_row$region,
    zone = upe_row$zone,
    prob_upe = upe_row$prob_upe
  )
  
  return(menages)
}

# Générer tous les ménages
liste_menages <- lapply(1:nrow(upes), function(i) generer_menages(upes[i,]))
menages <- bind_rows(liste_menages)

# ==============================================================================
# GÉNÉRATION DES INDIVIDUS
# ==============================================================================

generer_individus <- function(menage_row) {
  
  # Nombre de personnes dans le ménage
  nb_personnes <- max(1, round(rnorm(1, PERSONNES_PAR_MENAGE_MOYEN, PERSONNES_PAR_MENAGE_SD)))
  
  # Générer les âges (distribution réaliste)
  ages <- c(
    sample(25:65, 1),  # Chef de ménage
    if(nb_personnes > 1) sample(20:60, 1) else NULL,  # Conjoint
    if(nb_personnes > 2) sample(0:20, nb_personnes - 2, replace = TRUE) else NULL  # Enfants
  )
  
  individus <- data.frame(
    upe_id = menage_row$upe_id,
    menage_id = menage_row$menage_id,
    individu_id = sprintf("%s_P%02d", menage_row$menage_id, 1:nb_personnes),
    age = ages,
    statut_reponse = menage_row$statut_reponse,
    region = menage_row$region,
    zone = menage_row$zone,
    prob_upe = menage_row$prob_upe,
    prob_menage_originale = menage_row$prob_menage_originale
  )
  
  # Ajouter le sexe
  individus$sexe <- sample(c("Homme", "Femme"), nb_personnes, replace = TRUE)
  
  # Ajouter le niveau d'éducation
  individus$education <- sample(
    c("Aucun", "Primaire", "Secondaire", "Supérieur"),
    nb_personnes,
    replace = TRUE,
    prob = c(0.15, 0.30, 0.40, 0.15)
  )
  
  return(individus)
}

# Générer tous les individus (seulement pour les ménages répondants)
menages_repondants <- menages %>% filter(statut_reponse == "complet")
liste_individus <- lapply(1:nrow(menages_repondants), 
                          function(i) generer_individus(menages_repondants[i,]))
individus <- bind_rows(liste_individus)

# ==============================================================================
# GÉNÉRER LES VARIABLES D'EMPLOI
# ==============================================================================

# Définir le statut d'emploi selon l'âge
individus <- individus %>%
  mutate(
    # En âge de travailler (15-64 ans)
    en_age_travail = age >= 15 & age <= 64,
    
    # Statut d'activité (seulement pour ceux en âge de travailler)
    est_actif = ifelse(
      en_age_travail,
      sample(c(TRUE, FALSE), n(), replace = TRUE, 
             prob = c(0.65, 0.35)),  # Taux d'activité ~65%
      FALSE
    ),
    
    # Statut d'emploi (parmi les actifs)
    est_employe = ifelse(
      est_actif,
      sample(c(TRUE, FALSE), n(), replace = TRUE, 
             prob = c(0.90, 0.10)),  # Taux de chômage ~10% des actifs
      FALSE
    ),
    
    # Définir le statut de chômage
    est_chomeur = est_actif & !est_employe,
    
    # Type d'emploi (pour les employés)
    type_emploi = ifelse(
      est_employe,
      sample(c("Formel", "Informel", "Indépendant"), 
             n(), replace = TRUE,
             prob = c(0.40, 0.35, 0.25)),
      NA
    ),
    
    # Secteur d'activité (pour les employés)
    secteur = ifelse(
      est_employe,
      sample(c("Agriculture", "Industrie", "Services"), 
             n(), replace = TRUE,
             prob = c(0.25, 0.30, 0.45)),
      NA
    )
  )

# ==============================================================================
# CALCULER LES POIDS ORIGINAUX
# ==============================================================================

individus <- individus %>%
  mutate(
    # Probabilité totale de sélection
    prob_totale = prob_upe * prob_menage_originale,
    
    # Poids de base
    poids_base = 1 / prob_totale,
    
    # Poids original (pour cet exemple, identique au poids de base)
    # Dans la réalité, ce serait après calibration
    poids_original = poids_base
  )

# ==============================================================================
# SAUVEGARDER LES DONNÉES D'EXEMPLE
# ==============================================================================

cat("\n")
cat("================================================================================\n")
cat("DONNÉES D'EXEMPLE GÉNÉRÉES\n")
cat("================================================================================\n\n")

cat("Résumé des données:\n")
cat("------------------\n")
cat("Nombre d'UPEs:", n_distinct(individus$upe_id), "\n")
cat("Nombre de ménages répondants:", n_distinct(individus$menage_id), "\n")
cat("Nombre d'individus:", nrow(individus), "\n")
cat("Taux d'activité global:", 
    sprintf("%.1f%%", mean(individus$est_actif, na.rm = TRUE) * 100), "\n")
cat("Taux d'emploi (parmi actifs):", 
    sprintf("%.1f%%", mean(individus$est_employe[individus$est_actif], na.rm = TRUE) * 100), "\n")
cat("Taux de chômage (parmi actifs):", 
    sprintf("%.1f%%", mean(individus$est_chomeur[individus$est_actif], na.rm = TRUE) * 100), "\n\n")

# Sauvegarder les données
write.csv(individus, "donnees_exemple_lfs.csv", row.names = FALSE)
saveRDS(individus, "donnees_exemple_lfs.rds")

cat("Fichiers sauvegardés:\n")
cat("  - donnees_exemple_lfs.csv\n")
cat("  - donnees_exemple_lfs.rds\n\n")

# ==============================================================================
# EXEMPLE SIMPLE D'UTILISATION AVEC CES DONNÉES
# ==============================================================================

cat("================================================================================\n")
cat("EXEMPLE D'UTILISATION AVEC CES DONNÉES\n")
cat("================================================================================\n\n")

cat("Vous pouvez maintenant tester le script avec ces commandes:\n\n")

cat('# 1. Charger le script principal
source("simulation_reduction_lfs.R")

# 2. Charger les données d\'exemple
donnees_lfs <- read.csv("donnees_exemple_lfs.csv")

# 3. Préparer les données
donnees_prep <- preparer_donnees_base(
  donnees = donnees_lfs,
  nom_upe = "upe_id",
  nom_menage = "menage_id",
  nom_individu = "individu_id"
)

# 4. Lancer une simulation rapide (seulement 5 itérations pour test)
resultats_test <- executer_simulations(
  donnees = donnees_prep$donnees,
  nom_upe = "upe_id",
  nom_menage = "menage_id",
  nom_individu = "individu_id",
  ratios_reduction = c(0.9, 0.8, 0.7),
  nb_iterations = 5,  # Peu d\'itérations pour test rapide
  total_menages_upe = 1000,
  nom_prob_upe = "prob_upe"
)

# 5. Analyser les résultats
synthese_test <- synthetiser_resultats(resultats_test, "taux_chomage")
print(synthese_test)
')

cat("\n")
cat("================================================================================\n")
cat("NOTES IMPORTANTES\n")
cat("================================================================================\n\n")

cat("Ces données sont FICTIVES et générées aléatoirement.\n")
cat("Les paramètres (taux d\'activité, taux de chômage, etc.) sont approximatifs.\n")
cat("Utilisez vos vraies données LFS pour les analyses réelles.\n\n")

cat("Structure des données générées:\n")
cat("-------------------------------\n")
print(str(individus))

cat("\n")
cat("Aperçu des premières lignes:\n")
cat("----------------------------\n")
print(head(individus, 10))

cat("\n")
cat("================================================================================\n")

# ==============================================================================
# FONCTION POUR TESTER RAPIDEMENT LE SCRIPT
# ==============================================================================

tester_script_complet <- function() {
  
  cat("\n")
  cat("LANCEMENT D'UN TEST COMPLET DU SCRIPT...\n")
  cat("========================================\n\n")
  
  # Charger le script
  source("simulation_reduction_lfs.R")
  
  # Charger les données
  donnees_lfs <- readRDS("donnees_exemple_lfs.rds")
  
  # Préparer
  donnees_prep <- preparer_donnees_base(
    donnees = donnees_lfs,
    nom_upe = "upe_id",
    nom_menage = "menage_id",
    nom_individu = "individu_id"
  )
  
  # Simuler (version rapide avec peu d'itérations)
  cat("\nLancement des simulations (version rapide)...\n")
  resultats <- executer_simulations(
    donnees = donnees_prep$donnees,
    nom_upe = "upe_id",
    nom_menage = "menage_id",
    nom_individu = "individu_id",
    ratios_reduction = c(0.9, 0.8, 0.7),
    nb_iterations = 5,
    total_menages_upe = 1000,
    nom_prob_upe = "prob_upe"
  )
  
  # Analyser
  cat("\nAnalyse des résultats...\n")
  synthese <- synthetiser_resultats(resultats, "taux_chomage")
  
  # Comparer
  cat("\nComparaison des scénarios...\n")
  comparaison <- comparer_scenarios(
    donnees_originales = donnees_prep$donnees,
    resultats_simulations = resultats,
    synthese_precision = synthese,
    nom_upe = "upe_id",
    nom_menage = "menage_id",
    cout_visite_upe = 500,
    cout_menage = 50
  )
  
  # Graphiques
  cat("\nCréation des graphiques...\n")
  graphiques <- creer_graphiques(synthese, comparaison)
  
  cat("\n")
  cat("TEST TERMINÉ AVEC SUCCÈS!\n")
  cat("========================\n\n")
  cat("Les résultats montrent que le script fonctionne correctement.\n")
  cat("Vous pouvez maintenant l'utiliser avec vos vraies données.\n\n")
  
  return(list(
    resultats = resultats,
    synthese = synthese,
    comparaison = comparaison,
    graphiques = graphiques
  ))
}

cat("\n")
cat("Pour lancer un test complet automatique, utilisez:\n")
cat("  resultats_test <- tester_script_complet()\n\n")
