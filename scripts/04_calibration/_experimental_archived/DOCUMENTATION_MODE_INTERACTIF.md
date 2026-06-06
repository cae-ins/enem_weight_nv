# Documentation Complète : Mode Interactif de Calibration et Contrôle Qualité

**Version :** 2.0
**Date :** 11 janvier 2026
**Auteur :** Équipe de développement ENE-M
**Public :** Utilisateurs du système de pondération ENE

---

## Table des Matières

1. [Introduction](#1-introduction)
2. [Vue d'ensemble du système](#2-vue-densemble-du-système)
3. [Installation et configuration](#3-installation-et-configuration)
4. [Mode interactif : Guide pas à pas](#4-mode-interactif--guide-pas-à-pas)
5. [Contrôle qualité : Guide complet](#5-contrôle-qualité--guide-complet)
6. [Cas d'usage réels](#6-cas-dusage-réels)
7. [Résolution de problèmes](#7-résolution-de-problèmes)
8. [Bonnes pratiques](#8-bonnes-pratiques)
9. [Référence des fonctions](#9-référence-des-fonctions)
10. [FAQ](#10-faq)

---

## 1. Introduction

### 1.1 Problématique

Dans le processus de calibration des poids de l'enquête ENE, vous rencontrez souvent ces défis :

1. **Test itératif des bornes** : Les bornes suggérées par `bounds.hint()` peuvent être négatives ou inadaptées
2. **Convergence vs Qualité** : Une calibration peut converger (return.code = 0) mais produire des écarts régionaux importants
3. **Processus manuel** : Modifier le script, relancer tout, attendre les résultats

### 1.2 Solution apportée

Le **mode interactif** et les **contrôles de qualité** automatisés permettent :

- ✅ Tester rapidement différentes bornes sans relancer tout le pipeline
- ✅ Vérifier automatiquement que les écarts régionaux ≤ 100 unités
- ✅ Obtenir des diagnostics clairs et actionnables
- ✅ Documenter facilement les choix de calibration

### 1.3 Architecture

```
scripts/04_calibration/
├── run_calibration.R                           # Script principal (modifié)
├── functions/
│   ├── calibration_utils.R                     # Fonctions utilitaires (existant)
│   ├── calibration_interactive.R               # 🆕 Fonctions de test interactif
│   └── calibration_quality_checks.R            # 🆕 Contrôles de qualité
└── DOCUMENTATION_MODE_INTERACTIF.md            # Ce document
```

---

## 2. Vue d'ensemble du Système

### 2.1 Workflow traditionnel (AVANT)

```
1. Modifier TARGET_QUARTER et SCHEMA_ID dans run_calibration.R
2. Exécuter le script complet (5-10 minutes)
3. Attendre que le script 04c se lance
4. Voir si ça converge
5. Si échec : modifier les bornes dans 04c, TOUT relancer
6. Répéter jusqu'à convergence
7. Vérifier manuellement les écarts dans X_Summary_Table
```

**Problèmes :**
- ⏳ Chaque test prend 5-10 minutes
- 🔄 Processus très répétitif
- ⚠️ Risque d'oublier le contrôle qualité

### 2.2 Workflow avec mode interactif (MAINTENANT)

```
1. Activer INTERACTIVE_BOUNDS_MODE = TRUE
2. Exécuter run_calibration.R (prépare les données, puis s'arrête)
3. Tester interactivement plusieurs bornes (< 1 minute par test)
4. Lancer le contrôle qualité automatique
5. Valider et appliquer les bonnes bornes
6. Relancer en mode automatique
```

**Avantages :**
- ⚡ Tests quasi-instantanés
- 🎯 Contrôle qualité standardisé
- 📊 Diagnostics clairs et visuels

---

## 3. Installation et Configuration

### 3.1 Fichiers requis

Assurez-vous que ces fichiers existent :

```bash
scripts/04_calibration/
├── run_calibration.R                   # Doit contenir INTERACTIVE_BOUNDS_MODE
├── functions/
│   ├── calibration_interactive.R       # Nouveau fichier
│   └── calibration_quality_checks.R    # Nouveau fichier
```

### 3.2 Vérification de l'installation

```r
# Dans R ou RStudio
source("config/1_config.r")

# Vérifier que les fonctions sont disponibles
file.exists(file.path(BASE_DIR, "scripts/04_calibration/functions/calibration_interactive.R"))
# Doit retourner TRUE

file.exists(file.path(BASE_DIR, "scripts/04_calibration/functions/calibration_quality_checks.R"))
# Doit retourner TRUE
```

### 3.3 Configuration de base

Dans `run_calibration.R`, vérifier les lignes 30-48 :

```r
# ============================================================================
# CONFIGURATION PRINCIPALE
# ============================================================================

TARGET_QUARTER <- "T1_2025"           # À MODIFIER selon vos besoins
SCHEMA_ID <- "180X_1D"                # À MODIFIER selon vos besoins
USE_SR <- FALSE                       # Généralement FALSE
INTERACTIVE_BOUNDS_MODE <- TRUE       # 🆕 TRUE pour mode interactif, FALSE pour automatique
```

---

## 4. Mode Interactif : Guide Pas à Pas

### 4.1 Activation du mode interactif

#### Étape 1 : Ouvrir `run_calibration.R`

```r
# Dans RStudio
file.edit("scripts/04_calibration/run_calibration.R")
```

#### Étape 2 : Configurer les paramètres

Modifier les lignes suivantes :

```r
TARGET_QUARTER <- "T1_2025"           # Votre trimestre
SCHEMA_ID <- "180X_1D"                # Votre schéma
INTERACTIVE_BOUNDS_MODE <- TRUE       # ← ACTIVER le mode interactif
```

#### Étape 3 : Lancer le script

```r
source("scripts/04_calibration/run_calibration.R")
```

**Ce qui se passe :**
1. Le script charge les librairies
2. Charge la configuration
3. Initialise l'environnement
4. Exécute les étapes 1-3 (chargement et préparation des données)
5. **S'ARRÊTE** avant l'étape 4 (calibration)

**Sortie attendue :**

```
########################################################
# Chargement des librairies nécessaires...            #
########################################################

✓ Toutes les librairies chargées avec succès

========================================================
  ÉTAPE 1: Chargement des données
========================================================

  → Exécution du script de chargement des données...
✓ Données chargées avec succès

========================================================
  ÉTAPE 2: Préparation des données échantillon
========================================================

  → Préparation des données échantillon pour Regenesees...
✓ Données échantillon préparées

========================================================
  ÉTAPE 3: Préparation des totaux de population
========================================================

  → Préparation des totaux de population...
✓ Totaux de population préparés

╔═══════════════════════════════════════════════════════════════════════════╗
║                   MODE INTERACTIF ACTIVÉ                                  ║
╚═══════════════════════════════════════════════════════════════════════════╝

Le script va maintenant s'arrêter pour vous permettre de tester les bornes
de calibration avant de lancer la calibration complète.

Les objets suivants sont disponibles dans votre environnement :
  • design_lfs      : Objet design créé avec e.svydesign
  • popdataframe    : DataFrame de population
  • constrains_x    : Modèle de contraintes

Utilisez ces fonctions interactives :

1. Afficher les bornes suggérées et les diagnostics :
   cal_info <- show_calibration_info(design_lfs, popdataframe, constrains_x)

2. Tester des bornes spécifiques :
   calib_result <- test_calibration_bounds(cal_info, bounds = c(0.01, 6))

3. Tester plusieurs bornes automatiquement :
   results <- test_multiple_bounds(cal_info)

4. Voir le guide interactif :
   interactive_bounds_selection(cal_info)

═══════════════════════════════════════════════════════════════════════════
ARRÊT DU SCRIPT POUR MODE INTERACTIF
═══════════════════════════════════════════════════════════════════════════

Error in eval(expr, envir, enclos): Script arrêté en mode interactif. Testez vos bornes, puis relancez avec INTERACTIVE_BOUNDS_MODE = FALSE
```

**Note :** L'erreur est **normale**, c'est l'arrêt volontaire du script.

---

### 4.2 Diagnostic initial des bornes

#### Fonction : `show_calibration_info()`

**Syntaxe :**
```r
cal_info <- show_calibration_info(design_lfs, popdataframe, constrains_x)
```

**Objectif :** Obtenir les bornes suggérées et des recommandations

**Exemple de sortie :**

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
│                                                                         │
│  Bornes standards à tester:                                            │
│    • Conservateur : c(0.5, 1.5)                                        │
│    • Standard      : c(0.3, 2.0)                                       │
│    • Large         : c(0.1, 3.0)                                       │
│    • Très large    : c(0.01, 6.0)  ← Souvent utilisé                  │
│                                                                         │
│  Fonction de calibration:                                              │
│    • 'logit' (recommandé, nécessite des bornes)                        │
│    • 'linear' (pas de bornes nécessaires, mais moins contrôle)        │
│    • 'raking' (pas de bornes nécessaires)                              │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

**Interprétation :**
- ✅ **Si bornes positives** : Vous pouvez les tester directement
- ⚠️ **Si borne inférieure négative** : Vous DEVEZ utiliser des bornes manuelles
- ⚠️ **Si borne supérieure > 10** : Peut indiquer des problèmes de données

**Variable retournée :**
`cal_info` est une liste contenant :
- `bounds_suggested` : Bornes suggérées (peut être NULL ou négatives)
- `design` : Objet design
- `popdataframe` : DataFrame de population
- `constrains_x` : Modèle de contraintes

---

### 4.3 Test de bornes spécifiques

#### Fonction : `test_calibration_bounds()`

**Syntaxe :**
```r
calib_result <- test_calibration_bounds(
  cal_info,
  bounds = c(0.01, 6),      # Bornes à tester
  calfun = "logit",          # Fonction de calibration
  maxit = 30,                # Nombre max d'itérations
  epsilon = 1e-4,            # Critère de convergence
  verbose = TRUE             # Afficher les détails
)
```

**Paramètres :**
- `cal_info` : Résultat de `show_calibration_info()`
- `bounds` : Vecteur de 2 valeurs `c(min, max)`
- `calfun` : `"logit"` (recommandé), `"linear"`, ou `"raking"`
- `maxit` : Nombre maximum d'itérations (défaut: 30)
- `epsilon` : Seuil de convergence (défaut: 0.0001)
- `verbose` : Afficher les messages de diagnostic

**Exemple 1 : Test réussi**

```r
calib_result <- test_calibration_bounds(cal_info, bounds = c(0.01, 6))
```

**Sortie :**

```
═══════════════════════════════════════════════════════════════════════════
  TEST DE CALIBRATION
═══════════════════════════════════════════════════════════════════════════

  Paramètres testés:
    • Bornes       : [ 0.01 ,  6 ]
    • Fonction     :  logit
    • Max itérations:  30
    • Epsilon      :  0.0001

  → Exécution de la calibration...

┌─────────────────────────────────────────────────────────────────────────┐
│ RÉSULTATS DE LA CALIBRATION                                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ✓ SUCCÈS : La calibration a CONVERGÉ pour tous les domaines !         │
│                                                                         │
│  Statistiques des poids finaux:                                        │
│    • Minimum   :  125.4532
│    • Q1        :  845.2100
│    • Médiane   :  1245.8900
│    • Moyenne   :  1456.2301
│    • Q3        :  1987.4532
│    • Maximum   :  8945.1234
│    • Total     :  15000000
│                                                                         │
│  ⚙ Vérification de la calibration (check.cal):                         │
│    →  Population totals are matched.
└─────────────────────────────────────────────────────────────────────────┘
```

**Exemple 2 : Test échoué**

```r
calib_result <- test_calibration_bounds(cal_info, bounds = c(0.8, 1.2))
```

**Sortie :**

```
═══════════════════════════════════════════════════════════════════════════
  TEST DE CALIBRATION
═══════════════════════════════════════════════════════════════════════════

  Paramètres testés:
    • Bornes       : [ 0.8 ,  1.2 ]
    • Fonction     :  logit
    • Max itérations:  30
    • Epsilon      :  0.0001

  → Exécution de la calibration...

┌─────────────────────────────────────────────────────────────────────────┐
│ RÉSULTATS DE LA CALIBRATION                                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ✗ ÉCHEC : La calibration N'A PAS CONVERGÉ pour certains domaines      │
│                                                                         │
│  Domaines sans convergence:                                            │
│    • Domaine 3 - Code de retour: 1
│    • Domaine 7 - Code de retour: 1
│    • Domaine 12 - Code de retour: 1
│                                                                         │
│  💡 Recommandation: Élargir les bornes et réessayer                    │
└─────────────────────────────────────────────────────────────────────────┘
```

**Actions selon le résultat :**
- ✅ **Si succès** : Passer à l'étape 4.4 (contrôle qualité) ⚠️ **OBLIGATOIRE**
- ✗ **Si échec** : Élargir les bornes et retester

---

### 4.4 Test automatique de plusieurs bornes

#### Fonction : `test_multiple_bounds()`

**Syntaxe :**
```r
results <- test_multiple_bounds(
  cal_info,
  bounds_list = list(
    c(0.5, 1.5),
    c(0.3, 2.0),
    c(0.1, 3.0),
    c(0.01, 6.0),
    c(0.01, 10.0)
  ),
  calfun = "logit"
)
```

**Objectif :** Tester automatiquement plusieurs combinaisons de bornes et trouver celle qui fonctionne

**Exemple :**

```r
results <- test_multiple_bounds(cal_info)
```

**Sortie :**

```
╔═══════════════════════════════════════════════════════════════════════════╗
║              TEST AUTOMATIQUE DE PLUSIEURS BORNES                         ║
╚═══════════════════════════════════════════════════════════════════════════╝

Nombre de combinaisons à tester: 5

─────────────────────────────────────────────────────────────────────────
Test 1 / 5

═══════════════════════════════════════════════════════════════════════════
  TEST DE CALIBRATION
═══════════════════════════════════════════════════════════════════════════

  Paramètres testés:
    • Bornes       : [ 0.5 ,  1.5 ]
    ...

┌─────────────────────────────────────────────────────────────────────────┐
│  ✗ ÉCHEC : La calibration N'A PAS CONVERGÉ pour certains domaines      │
└─────────────────────────────────────────────────────────────────────────┘

─────────────────────────────────────────────────────────────────────────
Test 2 / 5

═══════════════════════════════════════════════════════════════════════════
  TEST DE CALIBRATION
═══════════════════════════════════════════════════════════════════════════

  Paramètres testés:
    • Bornes       : [ 0.3 ,  2 ]
    ...

┌─────────────────────────────────────────────────────────────────────────┐
│  ✗ ÉCHEC : La calibration N'A PAS CONVERGÉ pour certains domaines      │
└─────────────────────────────────────────────────────────────────────────┘

─────────────────────────────────────────────────────────────────────────
Test 3 / 5

═══════════════════════════════════════════════════════════════════════════
  TEST DE CALIBRATION
═══════════════════════════════════════════════════════════════════════════

  Paramètres testés:
    • Bornes       : [ 0.1 ,  3 ]
    ...

┌─────────────────────────────────────────────────────────────────────────┐
│  ✓ SUCCÈS : La calibration a CONVERGÉ pour tous les domaines !         │
└─────────────────────────────────────────────────────────────────────────┘

✓ SUCCÈS trouvé avec les bornes [ 0.1 ,  3 ]
  Vous pouvez arrêter ici ou continuer pour tester d'autres bornes.

═══════════════════════════════════════════════════════════════════════════
  RÉSUMÉ DES TESTS
═══════════════════════════════════════════════════════════════════════════

✗ Bornes [ 0.5 ,  1.5 ] :  ÉCHEC
✗ Bornes [ 0.3 ,  2 ] :  ÉCHEC
✓ Bornes [ 0.1 ,  3 ] :  SUCCÈS
```

**Utilisation des résultats :**

```r
# Récupérer la calibration réussie
successful_calibration <- NULL
successful_bounds <- NULL

for (i in seq_along(results)) {
  if (results[[i]]$success) {
    successful_calibration <- results[[i]]$calib_obj
    successful_bounds <- results[[i]]$bounds
    break
  }
}

if (!is.null(successful_calibration)) {
  cat("✓ Bornes trouvées:", successful_bounds, "\n")
  # Passer à l'étape suivante: contrôle qualité
} else {
  cat("✗ Aucune borne n'a fonctionné\n")
}
```

---

## 5. Contrôle Qualité : Guide Complet

### 5.1 Pourquoi le contrôle qualité est CRITIQUE

⚠️ **ATTENTION : Une calibration peut CONVERGER mais être de MAUVAISE QUALITÉ**

```
Convergence (ecal.status) ≠ Qualité acceptable
```

**Ce qui peut arriver :**
1. ✓ Tous les domaines ont `return.code = 0` → Convergence réussie
2. ✗ Mais certains écarts régionaux > 100 unités → **Qualité insuffisante**
3. ❌ Résultat : Estimations régionales faussées

**Règle d'or :**
```
Convergence + Écarts régionaux ≤ 100 = Calibration acceptable
```

---

### 5.2 Calculer X_Summary_Table

**Prérequis :** Vous avez un objet `calib_result` qui a convergé

**Syntaxe :**
```r
X_Summary_Table <- X_Summaries(
  numX = xnum,                 # Nombre de contraintes (ex: 180)
  des_size = design_size,      # Design avec ONES
  des_initial = design_lfs,    # Design initial
  des_total = popdataframe,    # DataFrame de population
  des_final = calib_result,    # Objet calibré
  L_trsld_corr_fact = 0.95,    # Seuil bas correction
  H_trsld_corr_fact = 1.65,    # Seuil haut correction
  L_trsld_sample_size = 30,    # Seuil taille échantillon
  calc_tot = TRUE              # Calculer totaux
)
```

**Exemple complet :**

```r
# Charger les fonctions nécessaires
source(R_SCRIPT_NEW_FUNCTIONS_FOR_X_CONSTRAINS)

# Créer design_size si pas déjà fait
design_size <- e.svydesign(
  data = sample_data,
  ids = ~ PSUKEY + HHKEY,
  strata = ~ STRATAKEY,
  weights = ~ ONES,  # Variable avec des 1
  fpc = NULL,
  self.rep.str = NULL,
  check.data = TRUE
)

# Calculer X_Summary_Table
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

# Vérifier
dim(X_Summary_Table)  # Doit avoir xnum lignes
names(X_Summary_Table)  # Doit contenir "Diff_Known_Tot_Final_Est"
```

---

### 5.3 Contrôle qualité complet

#### Fonction : `run_complete_quality_check()`

**Syntaxe :**
```r
quality_results <- run_complete_quality_check(
  calib_result,
  X_Summary_Table,
  threshold_diff = 100,        # Seuil écarts régionaux
  threshold_corr_low = 0.5,    # Seuil bas facteurs correction
  threshold_corr_high = 2.0,   # Seuil haut facteurs correction
  verbose = TRUE               # Afficher diagnostics
)
```

**Exemple :**

```r
quality <- run_complete_quality_check(
  calib_result,
  X_Summary_Table,
  threshold_diff = 100
)
```

**Sortie :**

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
│                                                                         │
│  Seuil de tolérance      :  100 unités                                  │
│  Contraintes testées     :  180                                         │
│  Contraintes hors seuil  :  0                                           │
│                                                                         │
│  ✓✓✓ CONTRÔLE RÉUSSI !                                                  │
│                                                                         │
│  Tous les écarts sont ≤  100  unités                                   │
│  La calibration est de QUALITÉ ACCEPTABLE                              │
│                                                                         │
│  Statistiques des écarts absolus:                                      │
│    • Minimum    :  0.00
│    • Q1         :  2.45
│    • Médiane    :  12.30
│    • Q3         :  35.67
│    • Maximum    :  87.42
│    • Moyenne    :  18.56
└─────────────────────────────────────────────────────────────────────────┘

3️⃣  Vérification des facteurs de correction...
    • Facteurs <  0.5   :  0 / 180
    • Facteurs >  2  :  3 / 180
    ⚠ Certains facteurs de correction sont extrêmes

4️⃣  Vérification des tailles d'échantillon...
    • Contraintes avec petit échantillon:  12 / 180
    ℹ  6.7% des contraintes ont un échantillon réduit

═══════════════════════════════════════════════════════════════════════════
                        SYNTHÈSE DU CONTRÔLE QUALITÉ
═══════════════════════════════════════════════════════════════════════════

  ✅ CALIBRATION DE QUALITÉ ACCEPTABLE

  ✓ Convergence réussie
  ✓ Écarts régionaux dans les limites (≤  100  unités)
  ✓ Facteurs de correction dans les limites

  → La calibration peut être utilisée pour l'analyse.

═══════════════════════════════════════════════════════════════════════════
```

**Utiliser les résultats :**

```r
# Vérifier si la calibration est acceptable
if (quality$overall_success) {
  cat("✅ Calibration validée\n")
  # Vous pouvez utiliser ces bornes
} else {
  cat("⚠ Calibration non acceptable\n")
  # Tester d'autres bornes
}

# Accéder aux détails
quality$convergence$all_converged         # TRUE/FALSE
quality$regional_discrepancies$success    # TRUE/FALSE
quality$regional_discrepancies$n_exceeding  # Nombre de contraintes hors seuil
quality$regional_discrepancies$max_diff   # Écart maximum
```

---

### 5.4 Contrôle rapide des écarts régionaux

Si vous voulez uniquement vérifier les écarts régionaux :

#### Fonction : `check_regional_discrepancies()`

**Syntaxe :**
```r
regional_check <- check_regional_discrepancies(
  X_Summary_Table,
  threshold = 100,
  verbose = TRUE
)
```

**Exemple :**

```r
regional_check <- check_regional_discrepancies(X_Summary_Table, threshold = 100)

if (regional_check$success) {
  cat("✓ Tous les écarts ≤ 100\n")
} else {
  cat("✗", regional_check$n_exceeding, "contraintes dépassent le seuil\n")
  # Voir les détails
  print(regional_check$problem_constraints)
}
```

---

### 5.5 Générer un rapport de qualité

#### Fonction : `generate_quality_report()`

**Syntaxe :**
```r
generate_quality_report(
  quality_results,
  output_file = "rapport_qualite_T1_2025_180X_1D.txt"
)
```

**Exemple :**

```r
# Générer et sauvegarder le rapport
generate_quality_report(
  quality,
  output_file = file.path(
    BASE_DIR,
    "logs",
    paste0("qualite_", TARGET_QUARTER, "_", SCHEMA_ID, ".txt")
  )
)
```

**Contenu du rapport :**

```
═══════════════════════════════════════════════════════════════
      RAPPORT DE CONTRÔLE QUALITÉ DE LA CALIBRATION
═══════════════════════════════════════════════════════════════

Date: 2026-01-11 15:30:45

1. CONVERGENCE
───────────────────────────────────────────────────────────────
  Statut: ✓ RÉUSSIE

2. ÉCARTS RÉGIONAUX
───────────────────────────────────────────────────────────────
  Seuil: 100 unités
  Contraintes testées: 180
  Contraintes hors seuil: 0
  Écart maximum: 87.42
  Écart moyen: 18.56
  Statut: ✓ ACCEPTABLE

3. FACTEURS DE CORRECTION
───────────────────────────────────────────────────────────────
  Minimum: 0.5234
  Médiane: 0.9876
  Moyenne: 1.0123
  Maximum: 2.1234
  Facteurs extrêmes bas: 0
  Facteurs extrêmes hauts: 3

═══════════════════════════════════════════════════════════════
CONCLUSION
═══════════════════════════════════════════════════════════════

  ✅ CALIBRATION DE QUALITÉ ACCEPTABLE

  Tous les écarts régionaux sont acceptables

═══════════════════════════════════════════════════════════════
```

---

## 6. Cas d'Usage Réels

### Cas 1 : Bornes suggérées positives et qualité acceptable

**Contexte :** Trimestre T2 2025, schéma 312X_1D

```r
# 1. Activer mode interactif
INTERACTIVE_BOUNDS_MODE <- TRUE
TARGET_QUARTER <- "T2_2025"
SCHEMA_ID <- "312X_1D"
source("scripts/04_calibration/run_calibration.R")

# 2. Diagnostic
cal_info <- show_calibration_info(design_lfs, popdataframe, constrains_x)
# → Bornes suggérées: [0.35, 2.5] ✓ Positives

# 3. Tester les bornes suggérées
calib_result <- test_calibration_bounds(cal_info, bounds = c(0.35, 2.5))
# → ✓ Convergence réussie

# 4. Contrôle qualité
X_Summary_Table <- X_Summaries(numX=xnum, des_size=design_size,
                               des_initial=design_lfs, des_total=popdataframe,
                               des_final=calib_result, L_trsld_corr_fact=0.95,
                               H_trsld_corr_fact=1.65, L_trsld_sample_size=30,
                               calc_tot=TRUE)

quality <- run_complete_quality_check(calib_result, X_Summary_Table, threshold_diff=100)
# → ✓ Qualité acceptable

# 5. Documenter
cat("Trimestre:", TARGET_QUARTER, "\n")
cat("Schéma:", SCHEMA_ID, "\n")
cat("Bornes validées: c(0.35, 2.5)\n")
cat("Écart max:", quality$regional_discrepancies$max_diff, "\n")

# 6. Modifier le script 04c
# Ouvrir scripts/04_calibration/QUARTERLY_WEIGHTING/.../04c_...R
# Ligne 339 : bounds = c(0.35, 2.5)

# 7. Relancer en mode automatique
INTERACTIVE_BOUNDS_MODE <- FALSE
source("scripts/04_calibration/run_calibration.R")
```

---

### Cas 2 : Bornes suggérées négatives, besoin de plusieurs tests

**Contexte :** Trimestre T4 2024, schéma 444X_1D, données difficiles

```r
# 1. Activer mode interactif
INTERACTIVE_BOUNDS_MODE <- TRUE
TARGET_QUARTER <- "T4_2024"
SCHEMA_ID <- "444X_1D"
source("scripts/04_calibration/run_calibration.R")

# 2. Diagnostic
cal_info <- show_calibration_info(design_lfs, popdataframe, constrains_x)
# → Bornes suggérées: [-0.15, 4.2] ✗ Négative !

# 3. Tester automatiquement plusieurs bornes
results <- test_multiple_bounds(cal_info, bounds_list = list(
  c(0.5, 1.5),   # Conservateur
  c(0.3, 2.0),   # Standard
  c(0.1, 3.0),   # Large
  c(0.01, 6.0),  # Très large
  c(0.01, 10.0)  # Extrême
))
# → Trouve que c(0.1, 3.0) converge

# 4. Récupérer la calibration réussie
calib_result <- NULL
for (i in seq_along(results)) {
  if (results[[i]]$success) {
    calib_result <- results[[i]]$calib_obj
    bounds_found <- results[[i]]$bounds
    break
  }
}

# 5. Contrôle qualité CRITIQUE
X_Summary_Table <- X_Summaries(numX=xnum, des_size=design_size,
                               des_initial=design_lfs, des_total=popdataframe,
                               des_final=calib_result, L_trsld_corr_fact=0.95,
                               H_trsld_corr_fact=1.65, L_trsld_sample_size=30,
                               calc_tot=TRUE)

quality <- run_complete_quality_check(calib_result, X_Summary_Table, threshold_diff=100)

# 6. Analyser le résultat
if (quality$overall_success) {
  cat("✅ Bornes validées:", bounds_found, "\n")
  cat("Écart max:", quality$regional_discrepancies$max_diff, "unités\n")

  # Générer rapport
  generate_quality_report(quality, paste0("qualite_", TARGET_QUARTER, "_", SCHEMA_ID, ".txt"))

  # Modifier 04c avec ces bornes
  cat("\nModifier le script 04c avec: bounds = c(", bounds_found[1], ", ", bounds_found[2], ")\n")
} else {
  cat("⚠ Calibration non acceptable\n")
  cat("Écarts hors seuil:", quality$regional_discrepancies$n_exceeding, "\n")
  cat("Écart max:", quality$regional_discrepancies$max_diff, "unités\n")

  # Essayer des bornes encore plus larges ou une autre fonction
  cat("\nRecommandations:\n")
  cat("1. Essayer c(0.01, 20)\n")
  cat("2. Essayer calfun='linear'\n")
  cat("3. Vérifier la qualité des données\n")
}
```

---

### Cas 3 : Aucune convergence, utilisation de fonction alternative

**Contexte :** Trimestre T1 2025, schéma 816X_1D, beaucoup de contraintes

```r
# 1. Activer mode interactif
INTERACTIVE_BOUNDS_MODE <- TRUE
TARGET_QUARTER <- "T1_2025"
SCHEMA_ID <- "816X_1D"
source("scripts/04_calibration/run_calibration.R")

# 2. Tester plusieurs bornes
results <- test_multiple_bounds(cal_info)
# → Tous les tests échouent

# 3. Essayer des bornes extrêmes
calib_result <- test_calibration_bounds(cal_info, bounds = c(0.001, 20))
# → Toujours échec

# 4. Essayer une autre fonction de calibration
calib_linear <- test_calibration_bounds(cal_info, calfun = "linear")
# → ✓ Converge avec 'linear' !

# 5. Contrôle qualité
X_Summary_Table <- X_Summaries(numX=xnum, des_size=design_size,
                               des_initial=design_lfs, des_total=popdataframe,
                               des_final=calib_linear, L_trsld_corr_fact=0.95,
                               H_trsld_corr_fact=1.65, L_trsld_sample_size=30,
                               calc_tot=TRUE)

quality <- run_complete_quality_check(calib_linear, X_Summary_Table, threshold_diff=100)

if (quality$overall_success) {
  cat("✅ Solution trouvée avec calfun='linear'\n")
  # Modifier 04c :
  # calfun = "linear"
  # bounds = NULL  (pas de bornes avec linear)
} else {
  cat("⚠ Problème persistant\n")
  cat("→ Revoir les données ou le schéma de calibration\n")
}
```

---

## 7. Résolution de Problèmes

### Problème 1 : "Object 'design_lfs' not found"

**Cause :** Le mode interactif s'est arrêté avant la création des objets

**Solution :**
```r
# Exécuter manuellement les scripts préliminaires
PROG_DIR <- file.path(BASE_DIR, "scripts/04_calibration/QUARTERLY_WEIGHTING", year, paste0("T", quarter), pathx)

source(file.path(PROG_DIR, paste0("01_Upload_Sample_Data_and_Known_Totals_in_R_", pathx, ".R")))
source(file.path(PROG_DIR, paste0("02_Prepare_input_sample_data_for_regenesees_", pathx, ".R")))
source(file.path(PROG_DIR, paste0("03_Prepare_input_pop_figures_for_regenesees_", pathx, ".R")))

# Puis utiliser les fonctions interactives
cal_info <- show_calibration_info(design_lfs, popdataframe, constrains_x)
```

---

### Problème 2 : Aucune borne ne converge

**Diagnostic :**
```r
# Vérifier la qualité des données
summary(sample_data)
summary(popdataframe)

# Vérifier les cohérences
sum(weights(design_lfs))  # Doit être proche de la population totale
sum(rowSums(popdataframe[, -1]))  # Population totale
```

**Solutions possibles :**
1. **Revoir les données d'entrée** : Valeurs aberrantes, manquantes
2. **Revoir le schéma** : Trop de contraintes pour la taille d'échantillon
3. **Utiliser une autre fonction** : `linear` ou `raking` au lieu de `logit`
4. **Consulter un expert** : Problème structurel possible

---

### Problème 3 : Convergence mais écarts > 100

**Exemple :**
```r
quality <- run_complete_quality_check(calib_result, X_Summary_Table, threshold_diff=100)
# → quality$overall_success = FALSE
# → 15 contraintes avec écarts > 100
```

**Actions :**
```r
# 1. Voir les contraintes problématiques
problem_constraints <- quality$regional_discrepancies$problem_constraints
print(problem_constraints)

# 2. Analyser l'écart maximum
max_diff <- quality$regional_discrepancies$max_diff
cat("Écart maximum:", max_diff, "unités\n")

if (max_diff < 200) {
  # Écarts modérés : ajuster les bornes
  cat("→ Essayer d'élargir légèrement les bornes\n")
  calib_result <- test_calibration_bounds(cal_info, bounds = c(0.005, 8))

} else if (max_diff < 500) {
  # Écarts importants : problème de calibration
  cat("→ Essayer d'autres bornes ou une autre fonction\n")
  calib_linear <- test_calibration_bounds(cal_info, calfun = "linear")

} else {
  # Écarts très importants : problème de données
  cat("→ Vérifier les données d'entrée et les totaux de population\n")
}
```

---

### Problème 4 : Fonction X_Summaries introuvable

**Cause :** Les fonctions auxiliaires ne sont pas chargées

**Solution :**
```r
# Charger explicitement le fichier de fonctions
R_SCRIPT_NEW_FUNCTIONS_FOR_X_CONSTRAINS <- file.path(
  BASE_DIR,
  "scripts/04_calibration/QUARTERLY_WEIGHTING/Other_R_functions_for_Regenesees/Functions_to_Create _X_vector_and_X_Summary_Table.R"
)

source(R_SCRIPT_NEW_FUNCTIONS_FOR_X_CONSTRAINS)

# Puis réessayer
X_Summary_Table <- X_Summaries(...)
```

---

## 8. Bonnes Pratiques

### 8.1 Documenter les bornes utilisées

**Créer un fichier de suivi :**

`scripts/04_calibration/HISTORIQUE_BORNES.csv`

```csv
trimestre,schema_id,bounds_min,bounds_max,calfun,convergence,ecart_max,notes,date,validateur
T1_2025,180X_1D,0.01,6,logit,oui,87.42,Bornes suggérées négatives,2025-01-15,F. Migone
T2_2025,180X_1D,0.35,2.5,logit,oui,45.23,Bornes suggérées fonctionnent,2025-04-10,F. Migone
T3_2025,180X_1D,0.1,3,logit,oui,92.15,Ajustement nécessaire,2025-07-12,F. Migone
T4_2024,444X_1D,NA,NA,linear,oui,78.90,Pas de bornes avec linear,2024-10-15,A. Dupont
```

**Ajouter une entrée :**
```r
new_entry <- data.frame(
  trimestre = TARGET_QUARTER,
  schema_id = SCHEMA_ID,
  bounds_min = bounds_found[1],
  bounds_max = bounds_found[2],
  calfun = "logit",
  convergence = "oui",
  ecart_max = quality$regional_discrepancies$max_diff,
  notes = "Première calibration du schéma",
  date = Sys.Date(),
  validateur = Sys.getenv("USER")
)

# Lire, ajouter, sauvegarder
historique <- if (file.exists("scripts/04_calibration/HISTORIQUE_BORNES.csv")) {
  read.csv("scripts/04_calibration/HISTORIQUE_BORNES.csv")
} else {
  data.frame()
}

historique <- rbind(historique, new_entry)
write.csv(historique, "scripts/04_calibration/HISTORIQUE_BORNES.csv", row.names = FALSE)
```

---

### 8.2 Workflow standard recommandé

**Pour un NOUVEAU trimestre d'un schéma existant :**

```r
# 1. Consulter l'historique
historique <- read.csv("scripts/04_calibration/HISTORIQUE_BORNES.csv")
dernieres_bornes <- historique[historique$schema_id == SCHEMA_ID, ]
tail(dernieres_bornes, 1)

# 2. Essayer les bornes du trimestre précédent
calib_result <- test_calibration_bounds(cal_info,
                                        bounds = c(last_bounds_min, last_bounds_max))

# 3. Si succès, contrôler qualité et valider
# 4. Si échec, passer en mode test interactif complet
```

**Pour un NOUVEAU schéma :**

```r
# 1. Mode interactif obligatoire
INTERACTIVE_BOUNDS_MODE <- TRUE

# 2. Diagnostic complet
cal_info <- show_calibration_info(design_lfs, popdataframe, constrains_x)

# 3. Test automatique de plusieurs bornes
results <- test_multiple_bounds(cal_info)

# 4. Contrôle qualité CRITIQUE
# 5. Documentation dans HISTORIQUE_BORNES.csv
```

---

### 8.3 Checklist de validation avant production

**Avant d'utiliser une calibration :**

- [ ] ✅ Convergence réussie (return.code = 0 pour tous les domaines)
- [ ] ✅ **Contrôle qualité effectué** (écarts régionaux ≤ 100)
- [ ] ✅ Facteurs de correction vérifiés (pas de valeurs extrêmes)
- [ ] ✅ Poids finaux dans des limites raisonnables
- [ ] ✅ Bornes documentées dans HISTORIQUE_BORNES.csv
- [ ] ✅ Script 04c mis à jour avec les bornes validées
- [ ] ✅ Rapport qualité généré et archivé
- [ ] ✅ Validation par un expert métier (si besoin)

---

### 8.4 Seuils recommandés

**Écarts régionaux :**
- **Standard :** 100 unités (recommandé pour ENE)
- **Strict :** 50 unités (pour analyses très précises)
- **Tolérant :** 200 unités (pour données difficiles, avec validation métier)

**Facteurs de correction :**
- **Idéal :** [0.7, 1.5]
- **Acceptable :** [0.5, 2.0]
- **Tolérable :** [0.3, 3.0] (nécessite validation)

**Bornes de calibration :**
- **Conservateur :** [0.5, 1.5] - Qualité maximale, convergence difficile
- **Standard :** [0.3, 2.0] - Bon compromis
- **Large :** [0.1, 3.0] - Plus de flexibilité
- **Très large :** [0.01, 6.0] - Solution de dernier recours

---

## 9. Référence des Fonctions

### 9.1 Fonctions interactives

| Fonction | Fichier | Description |
|----------|---------|-------------|
| `show_calibration_info()` | calibration_interactive.R | Affiche bornes suggérées et diagnostics |
| `test_calibration_bounds()` | calibration_interactive.R | Teste une combinaison de bornes |
| `test_multiple_bounds()` | calibration_interactive.R | Teste plusieurs bornes automatiquement |
| `interactive_bounds_selection()` | calibration_interactive.R | Guide interactif d'utilisation |

### 9.2 Fonctions de contrôle qualité

| Fonction | Fichier | Description |
|----------|---------|-------------|
| `check_regional_discrepancies()` | calibration_quality_checks.R | Vérifie écarts régionaux ≤ seuil |
| `run_complete_quality_check()` | calibration_quality_checks.R | Contrôle qualité complet (4 tests) |
| `generate_quality_report()` | calibration_quality_checks.R | Génère rapport texte |

### 9.3 Paramètres détaillés

**`show_calibration_info(design_lfs, popdataframe, constrains_x)`**

Paramètres :
- `design_lfs` : Objet e.svydesign avec design weights
- `popdataframe` : DataFrame de population (résultat de fill.template)
- `constrains_x` : Modèle de contraintes (résultat de constraints_model)

Retourne :
- Liste avec `bounds_suggested`, `design`, `popdataframe`, `constrains_x`

---

**`test_calibration_bounds(cal_info, bounds, calfun, maxit, epsilon, verbose)`**

Paramètres :
- `cal_info` : Liste retournée par show_calibration_info()
- `bounds` : Vecteur c(min, max), ex: c(0.01, 6)
- `calfun` : "logit" (défaut), "linear", ou "raking"
- `maxit` : Nombre max d'itérations (défaut: 30)
- `epsilon` : Critère de convergence (défaut: 1e-4)
- `verbose` : TRUE pour afficher détails

Retourne :
- Objet calibré ou NULL si échec
- Attributs: `converged`, `bounds_used`, `calfun_used`

---

**`test_multiple_bounds(cal_info, bounds_list, calfun)`**

Paramètres :
- `cal_info` : Liste retournée par show_calibration_info()
- `bounds_list` : Liste de vecteurs de bornes
- `calfun` : "logit" (défaut), "linear", ou "raking"

Retourne :
- Liste de résultats pour chaque test
- Chaque élément: `bounds`, `success`, `calib_obj`

---

**`check_regional_discrepancies(X_Summary_Table, threshold, verbose)`**

Paramètres :
- `X_Summary_Table` : Tableau de synthèse (résultat de X_Summaries)
- `threshold` : Seuil d'écart acceptable en unités (défaut: 100)
- `verbose` : TRUE pour afficher détails

Retourne :
- Liste avec `success`, `n_exceeding`, `max_diff`, `problem_constraints`, etc.

---

**`run_complete_quality_check(calib_result, X_Summary_Table, threshold_diff, threshold_corr_low, threshold_corr_high, verbose)`**

Paramètres :
- `calib_result` : Objet calibré
- `X_Summary_Table` : Tableau de synthèse
- `threshold_diff` : Seuil écarts régionaux (défaut: 100)
- `threshold_corr_low` : Seuil bas facteurs (défaut: 0.5)
- `threshold_corr_high` : Seuil haut facteurs (défaut: 2.0)
- `verbose` : TRUE pour afficher détails

Retourne :
- Liste avec `overall_success`, `convergence`, `regional_discrepancies`, etc.

---

**`generate_quality_report(quality_results, output_file)`**

Paramètres :
- `quality_results` : Résultats de run_complete_quality_check()
- `output_file` : Chemin fichier de sortie (optionnel)

Retourne :
- Vecteur de lignes du rapport (invisible)
- Sauvegarde fichier si output_file fourni

---

## 10. FAQ

**Q1 : Dois-je toujours faire le contrôle qualité ?**

**R :** OUI, ABSOLUMENT. La convergence seule ne garantit pas la qualité. Le contrôle des écarts régionaux est critique.

---

**Q2 : Combien de temps prend un test de bornes ?**

**R :** Moins de 1 minute en général (vs 5-10 minutes pour relancer tout le pipeline).

---

**Q3 : Puis-je utiliser le mode interactif pour tous les trimestres ?**

**R :** Non, utilisez-le surtout pour :
- Nouveaux schémas
- Premier trimestre d'un schéma
- Quand les bornes habituelles ne fonctionnent plus

Pour les trimestres suivants, utilisez les bornes déjà validées.

---

**Q4 : Que faire si aucune borne ne converge ?**

**R :**
1. Essayer calfun="linear" ou "raking"
2. Vérifier la qualité des données
3. Consulter un expert métier
4. Revoir le schéma de calibration (peut-être trop de contraintes)

---

**Q5 : Le seuil de 100 unités est-il fixe ?**

**R :** Non, c'est un paramètre ajustable. 100 est la valeur standard pour ENE, mais vous pouvez utiliser 50 (plus strict) ou 200 (plus tolérant) selon le contexte.

---

**Q6 : Comment documenter mes choix de calibration ?**

**R :**
1. Maintenir HISTORIQUE_BORNES.csv à jour
2. Générer rapport qualité avec generate_quality_report()
3. Archiver les rapports dans logs/
4. Commenter les choix inhabituels

---

**Q7 : Puis-je automatiser complètement le processus ?**

**R :** Partiellement. `test_multiple_bounds()` automatise la recherche de bornes, mais le contrôle qualité et la validation finale nécessitent toujours votre jugement.

---

**Q8 : Le mode interactif fonctionne-t-il en mode batch ?**

**R :** Oui, mais l'intérêt est limité. Le mode interactif est conçu pour un usage en session R interactive (RStudio).

---

**Q9 : Que faire si le contrôle qualité échoue ?**

**R :**
1. Voir les contraintes problématiques
2. Analyser l'écart maximum
3. Si < 200 : tester d'autres bornes
4. Si > 200 : vérifier les données d'entrée
5. Documenter et consulter un expert si besoin

---

**Q10 : Comment revenir à l'ancienne méthode ?**

**R :** Désactiver le mode interactif :
```r
INTERACTIVE_BOUNDS_MODE <- FALSE
```
Le script fonctionnera comme avant.

---

## Conclusion

Ce système de **mode interactif** et de **contrôle qualité automatisé** vous permet de :

1. ⚡ **Tester rapidement** différentes bornes de calibration
2. ✅ **Garantir la qualité** avec des contrôles standardisés
3. 📊 **Documenter** vos choix de calibration
4. 🎯 **Sécuriser** votre workflow de pondération

**Règle d'or à retenir :**
```
Convergence + Écarts régionaux ≤ 100 = Calibration validée
```

Pour toute question, consulter :
- `GUIDE_TEST_BORNES.md` - Guide pratique
- `RESUME_AMELIORATIONS_CALIBRATION.md` - Vue d'ensemble
- Ce document - Référence complète

---

**Document maintenu par :** Équipe de développement ENE-M
**Dernière mise à jour :** 11 janvier 2026
**Version :** 2.0
**Statut :** ✅ Validé et Opérationnel
