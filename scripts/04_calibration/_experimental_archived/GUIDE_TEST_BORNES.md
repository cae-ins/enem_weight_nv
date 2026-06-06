# Guide de Test des Bornes de Calibration

## 🎯 Objectif

Ce guide explique comment utiliser le **mode interactif** pour tester différentes bornes de calibration avant de lancer la calibration complète. Ce processus est essentiel car les bornes appropriées peuvent varier selon les données de chaque trimestre.

---

## 🔑 Concepts Clés

### Qu'est-ce que les bornes de calibration ?

Les **bornes** (`bounds`) définissent l'intervalle acceptable pour les facteurs de correction des poids pendant la calibration avec la fonction `logit`.

- **Borne inférieure** (ex: 0.01) : Facteur de correction minimum autorisé
- **Borne supérieure** (ex: 6.0) : Facteur de correction maximum autorisé

### Pourquoi tester différentes bornes ?

1. **Les bornes suggérées peuvent être négatives** → Non utilisables
2. **Les données varient entre trimestres** → Besoin d'ajustement
3. **La convergence dépend des bornes** → Test itératif nécessaire
4. **Compromis qualité/faisabilité** → Bornes trop strictes = non-convergence

---

## 🚀 Utilisation du Mode Interactif

### Étape 1 : Activer le mode interactif

Dans `run_calibration.R`, modifier la ligne 48 :

```r
# Passer de FALSE à TRUE
INTERACTIVE_BOUNDS_MODE <- TRUE
```

### Étape 2 : Configurer le trimestre et le schéma

```r
TARGET_QUARTER <- "T1_2025"
SCHEMA_ID <- "180X_1D"
```

### Étape 3 : Lancer le script

```r
source("scripts/04_calibration/run_calibration.R")
```

Le script va exécuter les étapes 1-3 (chargement des données, préparation) puis **s'arrêter** avant la calibration pour vous permettre de tester les bornes.

---

## 🔍 Tester les Bornes Interactivement

### Fonction 1 : Afficher les bornes suggérées

```r
# Afficher les bornes suggérées et les diagnostics
cal_info <- show_calibration_info(design_lfs, popdataframe, constrains_x)
```

**Sortie :**
```
╔═══════════════════════════════════════════════════════════════════════════╗
║                   DIAGNOSTIC DE CALIBRATION                               ║
╚═══════════════════════════════════════════════════════════════════════════╝

📊 Calcul des bornes suggérées...

┌─────────────────────────────────────────────────────────────────────────┐
│ BORNES SUGGÉRÉES PAR bounds.hint()                                     │
├─────────────────────────────────────────────────────────────────────────┤
│  Borne inférieure :  -0.2500
│  Borne supérieure :  3.5000
│                                                                         │
│  ⚠ ATTENTION: La borne inférieure est NÉGATIVE !                       │
│               Vous devez spécifier des bornes manuelles.              │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ RECOMMANDATIONS POUR LES BORNES                                        │
├─────────────────────────────────────────────────────────────────────────┤
│  Bornes standards à tester:                                            │
│    • Conservateur : c(0.5, 1.5)                                        │
│    • Standard      : c(0.3, 2.0)                                       │
│    • Large         : c(0.1, 3.0)                                       │
│    • Très large    : c(0.01, 6.0)  ← Souvent utilisé                  │
└─────────────────────────────────────────────────────────────────────────┘
```

### Fonction 2 : Tester des bornes spécifiques

```r
# Tester des bornes manuelles
calib_result <- test_calibration_bounds(
  cal_info,
  bounds = c(0.01, 6),
  calfun = "logit"
)
```

**Sortie si succès :**
```
═══════════════════════════════════════════════════════════════════════════
  TEST DE CALIBRATION
═══════════════════════════════════════════════════════════════════════════

  Paramètres testés:
    • Bornes       : [ 0.01 ,  6 ]
    • Fonction     :  logit
    • Max itérations:  30
    • Epsilon      :  1e-04

  → Exécution de la calibration...

┌─────────────────────────────────────────────────────────────────────────┐
│ RÉSULTATS DE LA CALIBRATION                                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ✓ SUCCÈS : La calibration a CONVERGÉ pour tous les domaines !         │
│                                                                         │
│  Statistiques des poids finaux:                                        │
│    • Minimum   :  125.4532
│    • Médiane   :  1245.8900
│    • Moyenne   :  1456.2301
│    • Maximum   :  8945.1234
│    • Total     :  15000000
└─────────────────────────────────────────────────────────────────────────┘
```

**Sortie si échec :**
```
┌─────────────────────────────────────────────────────────────────────────┐
│ RÉSULTATS DE LA CALIBRATION                                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ✗ ÉCHEC : La calibration N'A PAS CONVERGÉ pour certains domaines      │
│                                                                         │
│  Domaines sans convergence:                                            │
│    • Domaine 3 - Code de retour: 1
│    • Domaine 7 - Code de retour: 1
│                                                                         │
│  💡 Recommandation: Élargir les bornes et réessayer                    │
└─────────────────────────────────────────────────────────────────────────┘
```

### Fonction 3 : Tester plusieurs bornes automatiquement

```r
# Tester plusieurs combinaisons automatiquement
results <- test_multiple_bounds(
  cal_info,
  bounds_list = list(
    c(0.5, 1.5),   # Conservateur
    c(0.3, 2.0),   # Standard
    c(0.1, 3.0),   # Large
    c(0.01, 6.0),  # Très large
    c(0.01, 10.0)  # Extrême
  )
)
```

**Sortie :**
```
╔═══════════════════════════════════════════════════════════════════════════╗
║              TEST AUTOMATIQUE DE PLUSIEURS BORNES                         ║
╚═══════════════════════════════════════════════════════════════════════════╝

Nombre de combinaisons à tester: 5

─────────────────────────────────────────────────────────────────────────
Test 1 / 5
...
✗ ÉCHEC

─────────────────────────────────────────────────────────────────────────
Test 2 / 5
...
✗ ÉCHEC

─────────────────────────────────────────────────────────────────────────
Test 3 / 5
...
✓ SUCCÈS trouvé avec les bornes [ 0.1 ,  3 ]
  Vous pouvez arrêter ici ou continuer pour tester d'autres bornes.

═══════════════════════════════════════════════════════════════════════════
  RÉSUMÉ DES TESTS
═══════════════════════════════════════════════════════════════════════════

✗ Bornes [ 0.5 ,  1.5 ] :  ÉCHEC
✗ Bornes [ 0.3 ,  2 ] :  ÉCHEC
✓ Bornes [ 0.1 ,  3 ] :  SUCCÈS
```

### Fonction 4 : Tester d'autres fonctions de calibration

```r
# Tester avec la fonction linéaire (pas de bornes nécessaires)
calib_linear <- test_calibration_bounds(
  cal_info,
  calfun = "linear"
)

# Tester avec la fonction raking
calib_raking <- test_calibration_bounds(
  cal_info,
  calfun = "raking"
)
```

### Fonction 5 : Contrôle de qualité complet (CRUCIAL!)

**Après avoir trouvé des bornes qui convergent**, vous devez vérifier la **qualité de la calibration** :

```r
# 1. Calculer le tableau de synthèse des contraintes X
X_Summary_Table <- X_Summaries(
  numX = xnum,
  des_size = design_size,
  des_initial = design_lfs,
  des_total = popdataframe,
  des_final = calib_result,
  L_trsld_corr_fact = 0.95,
  H_trsld_corr_fact = 1.65,
  L_trsld_sample_size = 30,
  calc_tot = TRUE
)

# 2. Lancer le contrôle de qualité complet
quality_results <- run_complete_quality_check(
  calib_result,
  X_Summary_Table,
  threshold_diff = 100  # Seuil : écarts ≤ 100 unités
)

# 3. Générer un rapport (optionnel)
generate_quality_report(quality_results, output_file = "rapport_qualite.txt")
```

**Sortie du contrôle qualité :**

```
═══════════════════════════════════════════════════════════════════════════
           CONTRÔLE COMPLET DE QUALITÉ DE LA CALIBRATION
═══════════════════════════════════════════════════════════════════════════

1️⃣  Vérification de la convergence (ecal.status)...
    ✓ Tous les domaines ont convergé (return.code = 0)

2️⃣  Contrôle des écarts régionaux (seuil:  100  unités)...
╔═══════════════════════════════════════════════════════════════════════════╗
║        CONTRÔLE DES ÉCARTS AU NIVEAU DES AGRÉGATIONS RÉGIONALES          ║
╚═══════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────┐
│ RÉSULTATS DU CONTRÔLE                                                   │
├─────────────────────────────────────────────────────────────────────────┤
│  Seuil de tolérance      :  100 unités                                  │
│  Contraintes testées     :  180                                         │
│  Contraintes hors seuil  :  0                                           │
│                                                                         │
│  ✓✓✓ CONTRÔLE RÉUSSI !                                                  │
│  Tous les écarts sont ≤  100  unités                                   │
│  La calibration est de QUALITÉ ACCEPTABLE                              │
└─────────────────────────────────────────────────────────────────────────┘

3️⃣  Vérification des facteurs de correction...
    • Facteurs <  0.5   :  0 / 180
    • Facteurs >  2  :  2 / 180
    ⚠ Certains facteurs de correction sont extrêmes

═══════════════════════════════════════════════════════════════════════════
                        SYNTHÈSE DU CONTRÔLE QUALITÉ
═══════════════════════════════════════════════════════════════════════════

  ✅ CALIBRATION DE QUALITÉ ACCEPTABLE

  ✓ Convergence réussie
  ✓ Écarts régionaux dans les limites (≤  100  unités)
  ✓ Facteurs de correction dans les limites

  → La calibration peut être utilisée pour l'analyse.
```

### Fonction 6 : Contrôle rapide des écarts régionaux uniquement

Si vous voulez juste vérifier les écarts régionaux :

```r
# Contrôle rapide avec seuil personnalisé
regional_check <- check_regional_discrepancies(
  X_Summary_Table,
  threshold = 100,  # Modifier si besoin (ex: 50, 200)
  verbose = TRUE
)

# Résultat
if (regional_check$success) {
  cat("✓ Tous les écarts sont acceptables\n")
} else {
  cat("✗", regional_check$n_exceeding, "contraintes dépassent le seuil\n")
}
```

---

## 📝 Workflow Complet

### Scénario 1 : Bornes suggérées positives et convergence

```r
# 1. Afficher les bornes
cal_info <- show_calibration_info(design_lfs, popdataframe, constrains_x)

# 2. Les bornes suggérées sont [0.35, 2.5] → Tester
calib_result <- test_calibration_bounds(cal_info, bounds = c(0.35, 2.5))
# ✓ Convergence réussie !

# 3. IMPORTANT : Vérifier la qualité (contrôle des écarts régionaux)
X_Summary_Table <- X_Summaries(numX=xnum, des_size=design_size, des_initial=design_lfs,
                               des_total=popdataframe, des_final=calib_result,
                               L_trsld_corr_fact=0.95, H_trsld_corr_fact=1.65,
                               L_trsld_sample_size=30, calc_tot=TRUE)

quality <- run_complete_quality_check(calib_result, X_Summary_Table, threshold_diff=100)
# ✓ Écarts régionaux acceptables !

# 4. Modifier le script 04c avec ces bornes validées
# Dans le script 04c, ligne 339 :
# bounds = c(0.35, 2.5)

# 5. Désactiver le mode interactif et relancer
# Dans run_calibration.R : INTERACTIVE_BOUNDS_MODE <- FALSE
# source("scripts/04_calibration/run_calibration.R")
```

### Scénario 2 : Bornes suggérées négatives

```r
# 1. Afficher les bornes
cal_info <- show_calibration_info(design_lfs, popdataframe, constrains_x)
# → Bornes suggérées : [-0.25, 3.5] ✗ NÉGATIVE

# 2. Tester plusieurs bornes automatiquement
results <- test_multiple_bounds(cal_info)
# → Trouve que c(0.1, 3.0) fonctionne

# 3. Valider avec cette borne
calib_result <- test_calibration_bounds(cal_info, bounds = c(0.1, 3.0))
# ✓ Convergence réussie !

# 4. CRITIQUE : Contrôler la qualité
X_Summary_Table <- X_Summaries(numX=xnum, des_size=design_size, des_initial=design_lfs,
                               des_total=popdataframe, des_final=calib_result,
                               L_trsld_corr_fact=0.95, H_trsld_corr_fact=1.65,
                               L_trsld_sample_size=30, calc_tot=TRUE)

quality <- run_complete_quality_check(calib_result, X_Summary_Table, threshold_diff=100)

# Si quality$overall_success == TRUE :
# → ✓ Calibration de qualité acceptable

# 5. Modifier le script 04c avec les bornes validées
# bounds = c(0.1, 3.0)

# 6. Relancer en mode automatique
```

### Scénario 3 : Aucune borne ne converge

```r
# 1. Tester toutes les bornes standards
results <- test_multiple_bounds(cal_info)
# → Tous les tests échouent

# 2. Tester des bornes encore plus larges
calib_result <- test_calibration_bounds(cal_info, bounds = c(0.001, 20))
# → Toujours échec

# 3. Essayer une autre fonction de calibration
calib_linear <- test_calibration_bounds(cal_info, calfun = "linear")
# → Peut fonctionner sans bornes

# 4. Ou bien revoir les données / contraintes
# → Problème possible dans les données ou le schéma de calibration
```

---

## 💡 Conseils Pratiques

### Choix des bornes

1. **Commencer large** : `c(0.01, 6)` est un bon point de départ
2. **Si convergence** : Essayer de resserrer les bornes pour meilleure qualité
3. **Si non-convergence** : Élargir progressivement
4. **Surveiller les poids extrêmes** : Vérifier min/max des poids finaux

### Contrôle de qualité (CRUCIAL !)

⚠️ **ATTENTION** : La convergence seule **NE SUFFIT PAS** ! Vous devez **TOUJOURS** effectuer le contrôle de qualité des écarts régionaux.

**Workflow complet :**
```
1. Test des bornes → Convergence réussie (ecal.status)
2. Contrôle qualité → Écarts régionaux ≤ 100 unités  ← OBLIGATOIRE !
3. Validation → Calibration acceptable
```

**Pourquoi ce contrôle est critique ?**
- Une calibration peut **converger** (return.code = 0) mais produire des écarts importants au niveau régional
- Ces écarts peuvent fausser les estimations régionales
- Le seuil de 100 unités est une **règle de qualité** établie pour votre enquête

### Indicateurs de qualité

- **Convergence** : Tous les domaines doivent avoir return.code = 0 (prérequis)
- **Écarts régionaux** : **TOUS** les écarts doivent être ≤ 100 unités (test critique)
- **Facteurs de correction** : Idéalement entre 0.7 et 1.5
- **Poids extrêmes** : Éviter les poids trop grands ou trop petits

### Quand s'inquiéter

- ⚠️ Borne inférieure < 0 (impossible)
- ⚠️ Borne supérieure > 20 (données problématiques)
- ⚠️ Aucune convergence même avec bornes larges
- ⚠️ Poids finaux avec variance très élevée

---

## 📚 Documentation des Bornes Utilisées

Il est **fortement recommandé** de documenter les bornes utilisées pour chaque trimestre :

### Créer un fichier de suivi

`scripts/04_calibration/HISTORIQUE_BORNES.csv` :

```csv
trimestre,schema_id,bounds_min,bounds_max,calfun,convergence,notes,date
T1_2025,180X_1D,0.01,6,logit,oui,Bornes suggérées négatives,2025-01-15
T2_2025,180X_1D,0.1,3,logit,oui,Bornes suggérées [0.15-2.8] trop strictes,2025-04-10
T3_2025,180X_1D,0.35,2.5,logit,oui,Bornes suggérées fonctionnent directement,2025-07-12
```

---

## 🆘 Dépannage

### Problème : "Object 'design_lfs' not found"

**Cause :** Le mode interactif s'est arrêté avant que les objets ne soient créés.

**Solution :** Les objets sont créés dans les scripts 01-03. Si le mode interactif s'arrête trop tôt, exécutez manuellement les scripts :

```r
# Exécuter les scripts préliminaires
source(script_01)
source(script_02)
source(script_03)

# Puis utiliser les fonctions interactives
cal_info <- show_calibration_info(design_lfs, popdataframe, constrains_x)
```

### Problème : Convergence impossible

**Causes possibles :**
1. Données problématiques (valeurs manquantes, incohérences)
2. Contraintes trop nombreuses pour la taille d'échantillon
3. Population de référence incompatible

**Solutions :**
1. Vérifier la qualité des données en amont
2. Revoir le schéma de calibration (moins de contraintes)
3. Utiliser une fonction de calibration sans bornes (`linear`, `raking`)

---

## ✅ Après avoir trouvé les bonnes bornes

1. **Documenter les bornes** dans votre fichier de suivi
2. **Modifier le script 04c** avec les bornes validées
3. **Désactiver le mode interactif** : `INTERACTIVE_BOUNDS_MODE <- FALSE`
4. **Relancer la calibration complète** : `source("scripts/04_calibration/run_calibration.R")`
5. **Vérifier les résultats** : statistiques des poids, facteurs de correction

---

**Version :** 1.0
**Date :** Janvier 2026
