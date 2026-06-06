# SIMULATION DE RÉDUCTION D'ÉCHANTILLON LFS

## Vue d'ensemble

Ce projet contient des scripts R pour simuler l'impact de la réduction de la taille d'échantillon d'une enquête sur les forces de travail (LFS - Labour Force Survey) sur la précision des estimations et les coûts de collecte.

## Objectif

Le but est de trouver le meilleur équilibre entre :
- **Réduction des coûts** de collecte de données
- **Maintien de la précision** acceptable pour les indicateurs clés du marché du travail

## Principe de la simulation

L'approche consiste à :
1. **Garder le nombre d'UPEs inchangé** (pour maintenir la couverture géographique)
2. **Réduire le nombre de ménages par UPE** (pour réduire les coûts)
3. **Évaluer l'impact sur la précision** via des simulations répétées

Pourquoi cette approche ?
> Dans un plan d'échantillonnage à plusieurs degrés, presque toute la variation est générée au premier degré (les UPEs). Donc, maintenir le nombre d'UPEs préserve mieux la précision que de réduire les UPEs.

## Fichiers du projet

### Fichiers principaux
- **`simulation_reduction_lfs.R`** : Script principal avec toutes les fonctions
- **`guide_utilisation.R`** : Guide pas-à-pas pour utiliser les scripts
- **`README.md`** : Ce fichier (documentation)

### Fichiers générés (après exécution)
- `resultats_simulations_bruts.rds` : Résultats bruts de toutes les simulations
- `synthese_precision_par_scenario.csv` : Tableau de synthèse de la précision
- `comparaison_cout_precision.csv` : Comparaison coût vs précision
- `graphique_*.png` : Graphiques de visualisation
- `rapport_final_simulation.txt` : Rapport textuel

## Prérequis

### Packages R nécessaires

```r
install.packages(c("dplyr", "tidyr", "purrr", "survey", "ggplot2"))
```

### Données requises

Vos données LFS doivent contenir au minimum :
- **Identifiant UPE** (Unité Primaire d'Échantillonnage)
- **Identifiant ménage**
- **Identifiant individu**
- **Statut de réponse** (pour identifier les ménages répondants)
- **Probabilité de sélection de l'UPE**
- **Probabilité de sélection du ménage** (ou nombre de ménages sélectionnés/total)
- **Variables d'intérêt** (statut d'emploi, chômage, etc.)

### Informations sur les coûts

Vous devez connaître (au moins approximativement) :
- **Coût de visite d'une UPE** (déplacement intervieweurs + superviseurs)
- **Coût de collecte par ménage**

## Utilisation rapide

### 1. Préparer votre environnement

```r
# Charger le script principal
source("simulation_reduction_lfs.R")

# Charger vos données
donnees_lfs <- read.csv("vos_donnees.csv")
```

### 2. Définir vos paramètres

```r
# Identifiants
NOM_UPE <- "upe_id"
NOM_MENAGE <- "menage_id"
NOM_INDIVIDU <- "individu_id"

# Coûts
COUT_VISITE_UPE <- 500
COUT_PAR_MENAGE <- 50

# Total de ménages par UPE
TOTAL_MENAGES_UPE <- 1000

# Scénarios à tester
RATIOS <- c(0.9, 0.8, 0.7, 0.6)  # 90%, 80%, 70%, 60%
ITERATIONS <- 30
```

### 3. Exécuter la simulation

```r
# Préparer les données
donnees_prep <- preparer_donnees_base(
  donnees = donnees_lfs,
  nom_upe = NOM_UPE,
  nom_menage = NOM_MENAGE,
  nom_individu = NOM_INDIVIDU
)

# Lancer les simulations
resultats <- executer_simulations(
  donnees = donnees_prep$donnees,
  nom_upe = NOM_UPE,
  nom_menage = NOM_MENAGE,
  nom_individu = NOM_INDIVIDU,
  ratios_reduction = RATIOS,
  nb_iterations = ITERATIONS,
  total_menages_upe = TOTAL_MENAGES_UPE
)

# Analyser les résultats
synthese <- synthetiser_resultats(resultats, "taux_chomage")
comparaison <- comparer_scenarios(...)
graphiques <- creer_graphiques(synthese, comparaison)
```

### 4. Interpréter les résultats

Consultez les fichiers générés :
- **Tableaux CSV** : Pour les chiffres détaillés
- **Graphiques PNG** : Pour la visualisation
- **Rapport TXT** : Pour un résumé complet

## Méthodologie détaillée

### Étapes de la simulation (pour chaque scénario)

Pour chaque ratio de réduction (ex: 0.7 = 70%) :

1. **Calcul du nombre de ménages à garder par UPE**
   - Si 8 ménages ont répondu, on garde : 8 × 0.7 = 5.6 ≈ 5 ménages
   
2. **Sélection aléatoire des ménages**
   - Parmi les 8 ménages répondants, on en sélectionne 5 aléatoirement
   - On garde TOUS les membres de ces 5 ménages
   
3. **Mise à jour des probabilités**
   - Ancienne probabilité : 8/N (N = total ménages dans l'UPE)
   - Nouvelle probabilité : 5/N
   - Probabilité totale = prob_UPE × nouvelle_prob_ménage
   
4. **Calcul des poids**
   - Poids de base = 1 / probabilité totale
   - Application de la calibration habituelle
   
5. **Estimation de la précision**
   - Calcul des indicateurs d'intérêt
   - Calcul des erreurs-types
   - Calcul du coefficient de variation (CV)

6. **Répétition**
   - Cette procédure est répétée 20-30 fois
   - On calcule la moyenne et l'écart-type des CV
   - Cela donne une estimation robuste de la précision attendue

### Calcul des coûts

**Coût total** = (Nombre d'UPEs × Coût visite) + (Nombre total de ménages × Coût ménage)

**Réduction de coût** = (Coût actuel - Coût scénario) / Coût actuel × 100%

## Interprétation des indicateurs

### Coefficient de Variation (CV)

Le CV mesure la précision relative d'une estimation :

```
CV = (Erreur-type / Estimation) × 100%
```

**Seuils de qualité** :
- **CV < 5%** : Excellente précision ✅
- **CV 5-10%** : Bonne précision (publiable) ✅
- **CV 10-15%** : Précision modérée (à utiliser avec précaution) ⚠️
- **CV > 15%** : Précision faible (éviter de publier) ❌

### Erreur-type

L'erreur-type mesure la variabilité de l'estimation. Plus elle est faible, mieux c'est.

### Réduction de coût vs Précision

Le graphique "Coût vs Précision" vous aide à identifier :
- Les scénarios qui offrent de bonnes économies sans trop dégrader la précision
- Le point au-delà duquel la perte de précision devient inacceptable

## Recommandations pratiques

### Avant de commencer

1. **Vérifiez vos données**
   - Assurez-vous que tous les identifiants sont corrects
   - Vérifiez qu'il n'y a pas de valeurs manquantes dans les variables clés

2. **Estimez les coûts**
   - Calculez le coût moyen de visite d'une UPE
   - Calculez le coût moyen par ménage
   - Si possible, obtenez des coûts spécifiques par UPE

3. **Identifiez vos groupes clés**
   - Quels sont les sous-groupes de population importants ?
   - Sexe, âge, région, secteur d'activité ?

### Pendant la simulation

1. **Commencez avec peu d'itérations**
   - Testez avec 5 itérations d'abord pour vérifier que tout fonctionne
   - Ensuite augmentez à 20-30 pour les résultats finals

2. **Testez plusieurs scénarios**
   - Ne vous limitez pas à 4 ratios
   - Vous pouvez tester : 0.95, 0.90, 0.85, 0.80, 0.75, 0.70, etc.

3. **Vérifiez pour chaque groupe**
   - La précision globale peut être acceptable
   - Mais certains sous-groupes peuvent avoir une précision insuffisante

### Prise de décision

1. **Définissez vos critères**
   - CV maximum acceptable : par exemple 10%
   - Réduction de coût minimum souhaitée : par exemple 20%

2. **Analysez les trade-offs**
   - Un scénario à 80% peut donner 15% d'économie avec CV de 8%
   - Un scénario à 70% peut donner 25% d'économie avec CV de 12%
   - Lequel préférez-vous ?

3. **Considérez tous les indicateurs**
   - Ne vous basez pas uniquement sur un indicateur
   - Vérifiez la précision pour tous vos indicateurs clés

## Personnalisation

### Adapter la fonction de calibration

La fonction `calibrer_poids()` est fournie en version simplifiée. Pour utiliser votre procédure de calibration habituelle :

```r
calibrer_poids <- function(donnees, ...) {
  # Remplacez par votre procédure
  # Exemple avec des totaux de population connus
  
  design <- svydesign(...)
  
  # Calibration sur plusieurs variables
  design_cal <- calibrate(
    design,
    formula = ~ sexe + groupe_age + region,
    population = totaux_population
  )
  
  # Extraire les poids calibrés
  donnees$poids_final <- weights(design_cal)
  
  return(donnees)
}
```

### Ajouter des indicateurs

Dans `calculer_precision()`, ajoutez vos indicateurs spécifiques :

```r
# Taux d'activité
taux_activite <- svymean(~est_actif, design, na.rm = TRUE)

# Taux d'emploi par région
emploi_region <- svyby(~est_employe, ~region, design, svymean)

# Ratio emploi formel/informel
ratio <- svyratio(~emploi_formel, ~emploi_total, design)
```

### Analyser par sous-groupes

Pour évaluer la précision par groupe :

```r
# Modifier calculer_precision() pour inclure
resultats_hommes <- svymean(~est_chomeur, 
                           subset(design, sexe == "Homme"))
resultats_femmes <- svymean(~est_chomeur, 
                           subset(design, sexe == "Femme"))
resultats_jeunes <- svymean(~est_chomeur, 
                           subset(design, age < 25))
```

## Dépannage

### Problèmes courants

**Erreur : "Variable not found"**
- Vérifiez que les noms de variables sont corrects (respect de la casse)
- Utilisez `names(donnees_lfs)` pour voir toutes les variables

**Résultats aberrants**
- Vérifiez vos probabilités de sélection
- Assurez-vous que les poids sont corrects
- Vérifiez qu'il n'y a pas de valeurs extrêmes

**Simulations trop lentes**
- Réduisez le nombre d'itérations pour les tests
- Simplifiez la procédure de calibration
- Travaillez sur un sous-ensemble des données pour les tests

**CVs très élevés**
- Normal pour certains petits sous-groupes
- Envisagez de regrouper certaines catégories
- Considérez une réduction moins agressive

## Support et questions

Pour toute question ou problème :
1. Vérifiez d'abord la documentation ci-dessus
2. Consultez les commentaires dans le code
3. Testez avec un petit sous-ensemble de données
4. Vérifiez les types de variables (numeric, character, factor)

## Licence et crédits

Ce script implémente la méthodologie décrite dans le document de conseil technique pour la réduction de coûts d'enquêtes LFS tout en maintenant une précision acceptable.

---

**Version** : 1.0  
**Dernière mise à jour** : Janvier 2026  
**Langue** : Français / R
