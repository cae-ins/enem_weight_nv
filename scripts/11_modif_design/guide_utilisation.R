# ==============================================================================
# GUIDE PRATIQUE D'UTILISATION
# Script de simulation de réduction d'échantillon LFS
# ==============================================================================

# AVANT DE COMMENCER
# -------------------
# Assurez-vous d'avoir :
# 1. Vos données LFS chargées
# 2. Les noms exacts de vos variables (upe_id, menage_id, individu_id)
# 3. Les coûts de collecte (visite UPE + coût par ménage)
# 4. Le nombre total de ménages par UPE

# ==============================================================================
# ÉTAPE 1 : CHARGER LE SCRIPT PRINCIPAL
# ==============================================================================

source("simulation_reduction_lfs.R")

# ==============================================================================
# ÉTAPE 2 : CHARGER VOS DONNÉES
# ==============================================================================

# Option A : Depuis un fichier CSV
donnees_lfs <- read.csv("vos_donnees_lfs.csv")

# Option B : Depuis un fichier RDS
# donnees_lfs <- readRDS("vos_donnees_lfs.rds")

# Option C : Depuis SPSS, Stata, etc.
# library(haven)
# donnees_lfs <- read_sav("vos_donnees_lfs.sav")
# donnees_lfs <- read_dta("vos_donnees_lfs.dta")

# ==============================================================================
# ÉTAPE 3 : DÉFINIR VOS PARAMÈTRES
# ==============================================================================

# IMPORTANT : Remplacez ces valeurs par vos noms de variables réels !

# Noms des identifiants
NOM_UPE <- "upe_id"              # ← CHANGEZ ICI
NOM_MENAGE <- "menage_id"        # ← CHANGEZ ICI
NOM_INDIVIDU <- "individu_id"    # ← CHANGEZ ICI

# Paramètres de coût
COUT_VISITE_UPE <- 500    # Coût moyen de visite d'une UPE (en votre devise)
COUT_PAR_MENAGE <- 50     # Coût de collecte par ménage

# Nombre total de ménages dans chaque UPE
# Option 1 : Valeur unique (si similaire pour toutes les UPEs)
TOTAL_MENAGES_UPE <- 1000

# Option 2 : Valeurs spécifiques par UPE (si vous les connaissez)
# TOTAL_MENAGES_UPE <- c(
#   "UPE001" = 1200,
#   "UPE002" = 950,
#   "UPE003" = 1100,
#   # ... etc
# )

# Scénarios de réduction à tester
RATIOS <- c(0.9, 0.8, 0.7, 0.6)  # 90%, 80%, 70%, 60% de l'échantillon actuel

# Nombre d'itérations (recommandé : 20-30)
ITERATIONS <- 30

# ==============================================================================
# ÉTAPE 4 : PRÉPARER VOS DONNÉES
# ==============================================================================

# Cette étape filtre les ménages répondants et compte les ménages par UPE

donnees_prep <- preparer_donnees_base(
  donnees = donnees_lfs,
  nom_upe = NOM_UPE,
  nom_menage = NOM_MENAGE,
  nom_individu = NOM_INDIVIDU
)

# Vérifier les données préparées
cat("\nRésumé des données préparées:\n")
print(head(donnees_prep$comptage_menages))

# ==============================================================================
# ÉTAPE 5 : CRÉER LES VARIABLES NÉCESSAIRES POUR LES CALCULS
# ==============================================================================

# IMPORTANT : Adaptez cette section selon vos variables

# Exemple : Créer les indicateurs d'emploi/chômage si nécessaire
donnees_prep$donnees <- donnees_prep$donnees %>%
  mutate(
    # Exemple : Indicateur de chômage
    # est_chomeur = ifelse(statut_emploi == "chomeur", 1, 0),
    
    # Exemple : Indicateur d'emploi
    # est_employe = ifelse(statut_emploi == "employe", 1, 0),
    
    # Si vous n'avez pas ces variables, créez-les selon vos données
  )

# ==============================================================================
# ÉTAPE 6 : LANCER LES SIMULATIONS
# ==============================================================================

cat("\n")
cat("LANCEMENT DES SIMULATIONS...\n")
cat("Cela peut prendre plusieurs minutes selon la taille de vos données.\n\n")

# Lancer toutes les simulations
resultats_simulations <- executer_simulations(
  donnees = donnees_prep$donnees,
  nom_upe = NOM_UPE,
  nom_menage = NOM_MENAGE,
  nom_individu = NOM_INDIVIDU,
  ratios_reduction = RATIOS,
  nb_iterations = ITERATIONS,
  total_menages_upe = TOTAL_MENAGES_UPE,
  nom_prob_upe = "prob_upe"  # ← Changez si votre variable a un autre nom
)

# Sauvegarder les résultats bruts (au cas où)
saveRDS(resultats_simulations, "resultats_simulations_bruts.rds")

# ==============================================================================
# ÉTAPE 7 : ANALYSER LES RÉSULTATS
# ==============================================================================

# Synthétiser les résultats pour votre indicateur principal
# CHANGEZ "taux_chomage" selon votre indicateur

synthese <- synthetiser_resultats(
  resultats_simulations = resultats_simulations,
  nom_indicateur = "taux_chomage"  # ← CHANGEZ ICI selon votre indicateur
)

# Sauvegarder la synthèse
write.csv(synthese, "synthese_precision_par_scenario.csv", row.names = FALSE)

# ==============================================================================
# ÉTAPE 8 : COMPARER COÛTS ET PRÉCISION
# ==============================================================================

comparaison <- comparer_scenarios(
  donnees_originales = donnees_prep$donnees,
  resultats_simulations = resultats_simulations,
  synthese_precision = synthese,
  nom_upe = NOM_UPE,
  nom_menage = NOM_MENAGE,
  cout_visite_upe = COUT_VISITE_UPE,
  cout_menage = COUT_PAR_MENAGE
)

# Sauvegarder la comparaison
write.csv(comparaison, "comparaison_cout_precision.csv", row.names = FALSE)

# ==============================================================================
# ÉTAPE 9 : CRÉER LES GRAPHIQUES
# ==============================================================================

graphiques <- creer_graphiques(
  synthese_precision = synthese,
  comparaison_scenarios = comparaison
)

# Afficher les graphiques
print(graphiques$cv_plot)
print(graphiques$cout_precision_plot)
print(graphiques$erreur_type_plot)

# Sauvegarder les graphiques
ggsave("graphique_cv_par_scenario.png", 
       graphiques$cv_plot, 
       width = 10, height = 6, dpi = 300)

ggsave("graphique_cout_vs_precision.png", 
       graphiques$cout_precision_plot, 
       width = 10, height = 6, dpi = 300)

ggsave("graphique_erreur_type.png", 
       graphiques$erreur_type_plot, 
       width = 10, height = 6, dpi = 300)

# ==============================================================================
# ÉTAPE 10 : GÉNÉRER LE RAPPORT FINAL
# ==============================================================================

generer_rapport(
  synthese_precision = synthese,
  comparaison_scenarios = comparaison,
  fichier_sortie = "rapport_final_simulation.txt"
)

cat("\n")
cat("================================================================================\n")
cat("SIMULATION TERMINÉE AVEC SUCCÈS!\n")
cat("================================================================================\n\n")
cat("Fichiers générés:\n")
cat("  - resultats_simulations_bruts.rds\n")
cat("  - synthese_precision_par_scenario.csv\n")
cat("  - comparaison_cout_precision.csv\n")
cat("  - graphique_cv_par_scenario.png\n")
cat("  - graphique_cout_vs_precision.png\n")
cat("  - graphique_erreur_type.png\n")
cat("  - rapport_final_simulation.txt\n\n")

# ==============================================================================
# ÉTAPE 11 : INTERPRÉTER LES RÉSULTATS
# ==============================================================================

cat("COMMENT INTERPRÉTER LES RÉSULTATS:\n")
cat("-----------------------------------\n\n")
cat("1. COEFFICIENT DE VARIATION (CV):\n")
cat("   - CV < 5%  : Excellente précision\n")
cat("   - CV 5-10% : Bonne précision (acceptable pour publication)\n")
cat("   - CV 10-15%: Précision modérée (utiliser avec précaution)\n")
cat("   - CV > 15% : Précision faible (éviter de publier)\n\n")

cat("2. RÉDUCTION DE COÛT:\n")
cat("   - Regardez le tableau 'comparaison_cout_precision.csv'\n")
cat("   - Comparez la colonne 'reduction_cout_pct' avec 'cv_moyen'\n")
cat("   - Cherchez le meilleur équilibre coût-précision\n\n")

cat("3. DÉCISION:\n")
cat("   - Choisissez le scénario qui maintient un CV acceptable\n")
cat("   - tout en maximisant la réduction de coût\n")
cat("   - Vérifiez aussi pour vos sous-groupes de population importants\n\n")

# ==============================================================================
# ANALYSE POUR DES SOUS-GROUPES SPÉCIFIQUES
# ==============================================================================

# Si vous voulez analyser la précision pour des groupes spécifiques
# (par exemple, par sexe, par région, etc.), vous pouvez modifier
# la fonction calculer_precision() pour inclure ces calculs.

# Exemple : Analyser par sexe, groupe d'âge, etc.
# Vous devrez adapter le code dans calculer_precision() pour ajouter:
# - Estimations par sexe
# - Estimations par groupe d'âge
# - Estimations par région
# etc.

cat("================================================================================\n\n")
