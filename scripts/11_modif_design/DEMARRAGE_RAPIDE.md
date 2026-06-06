# GUIDE DE DÉMARRAGE RAPIDE
# Simulation de réduction d'échantillon LFS

## 🚀 DÉMARRER EN 5 MINUTES

### Étape 1 : Préparez vos fichiers

Placez tous les fichiers R dans le même dossier :
- `simulation_reduction_lfs.R` (script principal)
- `guide_utilisation.R` (guide complet)
- `generer_donnees_exemple.R` (pour créer des données de test)
- `README.md` (documentation détaillée)

### Étape 2 : Tester avec des données d'exemple

```r
# Ouvrir R ou RStudio

# 1. Générer des données d'exemple
source("generer_donnees_exemple.R")
# Ceci crée : donnees_exemple_lfs.csv

# 2. Tester le script rapidement
resultats_test <- tester_script_complet()
# Ceci lance une simulation rapide (5 itérations) et affiche les résultats
```

### Étape 3 : Utiliser avec VOS données

```r
# 1. Charger le script
source("simulation_reduction_lfs.R")

# 2. Charger VOS données
mes_donnees <- read.csv("chemin/vers/mes_donnees_lfs.csv")

# 3. IMPORTANT : Remplacez par vos vrais noms de variables
NOM_UPE <- "upe_id"         # ← CHANGEZ ICI
NOM_MENAGE <- "menage_id"   # ← CHANGEZ ICI
NOM_INDIVIDU <- "individu_id" # ← CHANGEZ ICI

# 4. Préparer les données
donnees_prep <- preparer_donnees_base(
  donnees = mes_donnees,
  nom_upe = NOM_UPE,
  nom_menage = NOM_MENAGE,
  nom_individu = NOM_INDIVIDU
)

# 5. Lancer les simulations
resultats <- executer_simulations(
  donnees = donnees_prep$donnees,
  nom_upe = NOM_UPE,
  nom_menage = NOM_MENAGE,
  nom_individu = NOM_INDIVIDU,
  ratios_reduction = c(0.9, 0.8, 0.7, 0.6),
  nb_iterations = 30,
  total_menages_upe = 1000  # ← Remplacez par votre valeur
)

# 6. Analyser
synthese <- synthetiser_resultats(resultats, "taux_chomage")
print(synthese)
```

## 📊 CE QUE VOUS ALLEZ OBTENIR

Après l'exécution, vous aurez :

### Tableaux
- `synthese_precision_par_scenario.csv` : Précision pour chaque scénario
- `comparaison_cout_precision.csv` : Coût vs précision

### Graphiques
- `graphique_cv_par_scenario.png` : Évolution de la précision
- `graphique_cout_vs_precision.png` : Trade-off coût/précision
- `graphique_erreur_type.png` : Erreurs-types

### Rapport
- `rapport_final_simulation.txt` : Synthèse complète

## ⚙️ PARAMÈTRES À AJUSTER

### Variables essentielles à remplacer

Dans votre code, vous DEVEZ remplacer :

```r
# IDENTIFIANTS (noms de colonnes dans vos données)
NOM_UPE <- "votre_colonne_upe"
NOM_MENAGE <- "votre_colonne_menage"
NOM_INDIVIDU <- "votre_colonne_individu"

# COÛTS (en votre devise)
COUT_VISITE_UPE <- 500   # Coût moyen de visite d'une UPE
COUT_PAR_MENAGE <- 50    # Coût par ménage

# TAILLE DE LA POPULATION
TOTAL_MENAGES_UPE <- 1000  # Total de ménages dans chaque UPE
```

### Scénarios de réduction

Testez différents niveaux de réduction :

```r
# Réductions modérées (recommandé pour commencer)
RATIOS <- c(0.95, 0.90, 0.85, 0.80)

# Réductions plus importantes
RATIOS <- c(0.90, 0.80, 0.70, 0.60, 0.50)

# Réductions très fines (si vous voulez beaucoup de détails)
RATIOS <- seq(0.95, 0.60, by = -0.05)
```

### Nombre d'itérations

```r
# Pour tester rapidement (2-3 minutes)
ITERATIONS <- 5

# Pour résultats préliminaires (10-15 minutes)
ITERATIONS <- 10

# Pour résultats finaux robustes (30-60 minutes)
ITERATIONS <- 30
```

## 🎯 OBJECTIF DU SCRIPT

Le script simule ce qui se passerait si vous :
- Gardiez le MÊME nombre d'UPEs (couverture géographique inchangée)
- Réduisiez le nombre de MÉNAGES par UPE (économies de coûts)

Il calcule pour chaque scénario :
- La réduction de coût en %
- La précision des estimations (Coefficient de Variation)
- L'erreur-type moyenne

## 📖 INTERPRÉTER LES RÉSULTATS

### Coefficient de Variation (CV)

Le CV vous dit si votre estimation est précise :

✅ **CV < 5%** → Excellente précision
✅ **CV 5-10%** → Bonne précision (publiable)
⚠️ **CV 10-15%** → Précision modérée
❌ **CV > 15%** → Précision faible

### Exemple de résultats

```
Scénario    Réduction coût    CV moyen
----------------------------------------
Actuel      0%                6.2%
90%         8%                6.5%
80%         16%               7.3%
70%         24%               8.8%
60%         32%               11.2%
```

**Interprétation** : 
- Le scénario à 80% économise 16% de coûts
- La précision reste bonne (CV = 7.3%)
- C'est probablement un bon compromis !

## 🔍 VÉRIFICATIONS IMPORTANTES

Avant de prendre une décision, vérifiez :

### 1. Vérifiez pour TOUS vos indicateurs clés

```r
# Taux de chômage
synthese_chomage <- synthetiser_resultats(resultats, "taux_chomage")

# Taux d'emploi
synthese_emploi <- synthetiser_resultats(resultats, "taux_emploi")

# etc.
```

### 2. Vérifiez pour vos SOUS-GROUPES importants

Modifiez `calculer_precision()` pour inclure :
- Précision par sexe
- Précision par groupe d'âge
- Précision par région
- etc.

### 3. Regardez le graphique "Coût vs Précision"

Ce graphique montre visuellement où se trouve le meilleur équilibre.

## 🆘 BESOIN D'AIDE ?

### Problèmes fréquents

**"Variable not found"**
→ Vérifiez les noms de vos colonnes avec `names(mes_donnees)`

**"CVs très élevés"**
→ Normal pour les petits sous-groupes
→ Testez des réductions moins agressives

**"Script trop lent"**
→ Réduisez le nombre d'itérations pour tester (5-10)
→ Testez d'abord sur un sous-ensemble de données

**"Résultats bizarres"**
→ Vérifiez vos probabilités de sélection
→ Vérifiez qu'il n'y a pas de valeurs manquantes

## 📚 DOCUMENTATION COMPLÈTE

Pour plus de détails, consultez :
- `README.md` : Documentation complète
- `guide_utilisation.R` : Guide détaillé avec tous les commentaires
- `simulation_reduction_lfs.R` : Code source avec explications

## ✅ CHECKLIST AVANT DÉCISION FINALE

Avant de recommander un scénario de réduction :

- [ ] J'ai testé avec au moins 20 itérations
- [ ] J'ai vérifié la précision pour TOUS mes indicateurs clés
- [ ] J'ai vérifié la précision pour mes sous-groupes importants
- [ ] J'ai calculé les coûts réels de collecte
- [ ] J'ai regardé le graphique coût vs précision
- [ ] J'ai identifié le scénario avec le meilleur équilibre
- [ ] Le CV reste < 10% pour mes indicateurs principaux
- [ ] J'ai documenté ma décision et mes hypothèses

## 💡 CONSEILS PRATIQUES

1. **Commencez petit** : Testez d'abord avec 5 itérations et 2-3 scénarios
2. **Validez les résultats** : Comparez avec l'échantillon actuel
3. **Soyez conservateur** : Préférez garder un peu plus de précision
4. **Documentez** : Notez toutes vos hypothèses et choix
5. **Consultez** : Discutez des résultats avec votre équipe

## 📞 PROCHAINES ÉTAPES

1. ✅ Tester avec données d'exemple
2. ✅ Adapter à vos vraies données
3. ✅ Lancer les simulations complètes
4. ✅ Analyser les résultats
5. ✅ Choisir le meilleur scénario
6. ✅ Documenter la décision
7. ✅ Implémenter le nouveau plan d'échantillonnage

---

**Bonne chance avec vos simulations !**

Pour toute question, relisez d'abord le README.md qui contient
beaucoup plus de détails et d'exemples.
