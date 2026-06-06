# Nouvelle Architecture de Calibration Dynamique

## 📋 Vue d'ensemble

Cette nouvelle architecture remplace les **237 fichiers dupliqués** par une approche **paramétrée et dynamique** qui élimine la répétition de code et facilite grandement la maintenance.

### Problème résolu

**Avant :**
- 237 fichiers dupliqués dans `QUARTERLY_WEIGHTING/année/trimestre/schéma/`
- Chaque modification nécessitait de mettre à jour des dizaines de fichiers
- Risque élevé d'incohérences entre les versions
- Difficulté de maintenance croissante

**Maintenant :**
- 1 seul fichier de configuration (`config/schemas_calibration.csv`)
- 1 seul script orchestrateur (`run_calibration.R`)
- Modifications propagées instantanément à tous les trimestres/schémas
- Maintenance simplifiée et centralisée

---

## 🗂️ Structure des fichiers

```
scripts/04_calibration/
├── config/
│   └── schemas_calibration.csv          # Définition de tous les schémas
│
├── functions/
│   └── calibration_utils.R              # Fonctions utilitaires paramétrées
│
├── run_calibration.R                    # ⭐ SCRIPT PRINCIPAL
│
├── QUARTERLY_WEIGHTING/
│   ├── constraints/                     # Fichiers Excel de contraintes
│   │   ├── 180X_1D/
│   │   │   └── 01_Set_of_constraints_180X_1D.xlsx
│   │   ├── 312X_1D/
│   │   │   └── 01_Set_of_constraints_312X_1D.xlsx
│   │   └── ...
│   │
│   └── [année]/[trimestre]/[schéma]/    # Anciens scripts (à conserver temporairement)
│       ├── 01_Upload_Sample_Data_and_Known_Totals_in_R_XXX.R
│       ├── 02_Prepare_input_sample_data_for_regenesees_XXX.R
│       ├── 03_Prepare_input_pop_figures_for_regenesees_XXX.R
│       ├── 04c_Run_Quarterly_Calibration_with_Regenesees_XXX.R
│       ├── 05_Attach_final_weights_to_full_sample_data_XXX.R
│       ├── 06_Create_Table1_XXX.R
│       └── 07f_Calculate_Precision_of_levels_with_Regenesees_ver3_XXX.R
│
└── README_NOUVELLE_ARCHITECTURE.md      # Ce fichier
```

---

## 🚀 Utilisation

### Méthode 1 : Modification directe du script (recommandée)

1. **Ouvrir le script principal :**
   ```r
   # Dans RStudio
   file.edit("scripts/04_calibration/run_calibration.R")
   ```

2. **Modifier les paramètres** (lignes 30-40) :
   ```r
   TARGET_QUARTER <- "T1_2025"    # Trimestre souhaité
   SCHEMA_ID <- "180X_1D"         # Schéma de calibration
   USE_SR <- FALSE                # Sans réponse (généralement FALSE)
   ```

3. **Exécuter le script :**
   ```r
   source("scripts/04_calibration/run_calibration.R")
   ```

### Méthode 2 : Appel fonctionnel

```r
# Charger la configuration et les fonctions
source("config/1_config.r")
source("scripts/04_calibration/functions/calibration_utils.R")

# Initialiser l'environnement
cal_env <- initialize_calibration_env(
  target_quarter = "T2_2025",
  schema_id = "312X_1D"
)

# Ensuite, exécuter manuellement les étapes...
```

### Méthode 3 : Batch processing (plusieurs calibrations)

```r
# Définir les combinaisons à traiter
calibrations <- data.frame(
  quarter = c("T1_2025", "T1_2025", "T2_2025"),
  schema = c("180X_1D", "312X_1D", "180X_1D")
)

# Boucler sur les calibrations
for (i in 1:nrow(calibrations)) {
  TARGET_QUARTER <- calibrations$quarter[i]
  SCHEMA_ID <- calibrations$schema[i]

  cat("\n\n=== CALIBRATION", i, "/", nrow(calibrations), "===\n")
  source("scripts/04_calibration/run_calibration.R")
}
```

---

## 📊 Schémas disponibles

Les schémas sont définis dans `config/schemas_calibration.csv` :

| Schema ID | Contraintes | Description |
|-----------|-------------|-------------|
| 180X_1D | 180 | Calibration standard avec 180 contraintes |
| 182X_1D | 182 | Calibration avec 182 contraintes |
| 312X_1D | 312 | Calibration avec 312 contraintes |
| 444X_1D | 444 | Calibration avec 444 contraintes |
| 156X_1D_ALLWR_np | 156 | Calibration 156 contraintes tous ménages non-pondérés |
| 222X_1D_ALLWR_np | 222 | Calibration 222 contraintes tous ménages non-pondérés |
| 288X_1D_ALLWR_np | 288 | Calibration 288 contraintes tous ménages non-pondérés |
| 312X_1D_ALLWR_np | 312 | Calibration 312 contraintes tous ménages non-pondérés |
| 444X_1D_ALLWR_np | 444 | Calibration 444 contraintes tous ménages non-pondérés |
| 816X_1D_ALLWR_np | 816 | Calibration 816 contraintes tous ménages non-pondérés |
| 8X_33D_ALLWR_np | 8 | Calibration 8 contraintes 33 domaines |

---

## 🔧 Fonctions utilitaires principales

### `initialize_calibration_env(target_quarter, schema_id)`

Initialise tout l'environnement de calibration :
- Parse le trimestre cible
- Charge la configuration du schéma
- Construit tous les chemins de fichiers
- Crée les répertoires nécessaires
- Retourne une liste avec toutes les variables

**Exemple :**
```r
cal_env <- initialize_calibration_env("T1_2025", "180X_1D")
# Accès aux variables
cal_env$year          # 2025
cal_env$quarter       # 1
cal_env$xnum          # 180
cal_env$paths$FILE_LFS_ILO_CAL_DTA  # Chemin du fichier de sortie
```

### `load_schema_config(schema_id)`

Charge la configuration d'un schéma spécifique depuis `schemas_calibration.csv`.

### `build_calibration_paths(year, quarter, target_quarter, pathx, setx)`

Construit tous les chemins de fichiers pour une calibration donnée.

### `parse_target_quarter(target_quarter)`

Parse un trimestre au format "TX_YYYY" et retourne année, trimestre, et chaîne originale.

---

## ➕ Ajouter un nouveau schéma

1. **Ajouter une ligne dans `config/schemas_calibration.csv` :**
   ```csv
   999X_1D,999,999X_1D,999X_1D,Description du nouveau schéma,01_Set_of_constraints_999X_1D.xlsx
   ```

2. **Créer le répertoire pour les contraintes :**
   ```r
   dir.create("scripts/04_calibration/QUARTERLY_WEIGHTING/constraints/999X_1D")
   ```

3. **Ajouter le fichier Excel de contraintes :**
   - Copier un fichier existant comme template
   - Le renommer `01_Set_of_constraints_999X_1D.xlsx`
   - Le placer dans le répertoire créé

4. **Utiliser le nouveau schéma :**
   ```r
   TARGET_QUARTER <- "T1_2025"
   SCHEMA_ID <- "999X_1D"
   source("scripts/04_calibration/run_calibration.R")
   ```

---

## 📁 Organisation des fichiers de contraintes

Les fichiers Excel de contraintes doivent être organisés ainsi :

```
QUARTERLY_WEIGHTING/constraints/
├── 180X_1D/
│   └── 01_Set_of_constraints_180X_1D.xlsx
├── 182X_1D/
│   └── 01_Set_of_constraints_182X_1D.xlsx
├── 312X_1D/
│   └── 01_Set_of_constraints_312X_1D.xlsx
└── ...
```

**Note :** Les anciens fichiers dans `QUARTERLY_WEIGHTING/année/trimestre/schéma/` peuvent être conservés pour référence mais ne sont plus nécessaires pour l'exécution.

---

## 🔄 Migration depuis l'ancienne structure

### Étape 1 : Organiser les fichiers Excel

Exécuter le script de migration (à créer) :
```r
source("scripts/04_calibration/migrate_constraints_files.R")
```

Ce script va :
- Identifier tous les fichiers `01_Set_of_constraints_*.xlsx`
- Les copier dans la nouvelle structure `constraints/`
- Créer un rapport des fichiers migrés

### Étape 2 : Tester la nouvelle architecture

```r
# Tester avec un trimestre/schéma existant
TARGET_QUARTER <- "T1_2025"
SCHEMA_ID <- "180X_1D"
source("scripts/04_calibration/run_calibration.R")
```

### Étape 3 : Vérifier les résultats

Comparer les résultats avec l'ancienne méthode :
- Vérifier que les poids sont identiques
- Comparer les fichiers de sortie
- Valider les statistiques récapitulatives

### Étape 4 : Archiver l'ancienne structure (optionnel)

Une fois la validation terminée, vous pouvez archiver les anciens scripts :
```r
# Créer une archive
zip("scripts/04_calibration/ARCHIVE_old_quarterly_scripts.zip",
    "scripts/04_calibration/QUARTERLY_WEIGHTING/2024",
    "scripts/04_calibration/QUARTERLY_WEIGHTING/2025")

# Supprimer les anciens fichiers (ATTENTION: à faire seulement après validation complète)
# unlink("scripts/04_calibration/QUARTERLY_WEIGHTING/2024", recursive = TRUE)
# unlink("scripts/04_calibration/QUARTERLY_WEIGHTING/2025", recursive = TRUE)
```

---

## 🐛 Dépannage

### Erreur : "Schéma introuvable"

**Cause :** Le `SCHEMA_ID` spécifié n'existe pas dans `config/schemas_calibration.csv`

**Solution :**
1. Vérifier l'orthographe du `SCHEMA_ID`
2. Ouvrir `config/schemas_calibration.csv` pour voir les schémas disponibles
3. Ajouter le schéma s'il est nouveau

### Erreur : "Fichier de contraintes introuvable"

**Cause :** Le fichier Excel `01_Set_of_constraints_XXX.xlsx` n'existe pas

**Solution :**
1. Vérifier que le fichier existe dans `QUARTERLY_WEIGHTING/constraints/[schema_id]/`
2. Copier le fichier depuis l'ancienne structure si nécessaire
3. Vérifier le nom du fichier dans `config/schemas_calibration.csv`

### Erreur : "Script XX introuvable"

**Cause :** Les scripts de traitement (01-07) n'existent pas pour ce trimestre/schéma

**Solution :**
1. Les scripts doivent encore exister dans `QUARTERLY_WEIGHTING/[année]/[trimestre]/[schéma]/`
2. Vérifier que les scripts existent pour le trimestre spécifié
3. Si nécessaire, copier les scripts depuis un trimestre similaire

### Les résultats sont différents de l'ancienne méthode

**Solution :**
1. Vérifier que les mêmes données d'entrée sont utilisées
2. Comparer les valeurs de `xnum`, `setx`, `pathx` entre ancienne et nouvelle méthode
3. Vérifier les chemins de fichiers générés
4. Examiner les logs pour identifier les différences

---

## 📈 Avantages de la nouvelle architecture

### 1. Maintenance simplifiée
- **Avant :** Modifier 237 fichiers pour un changement de logique
- **Maintenant :** Modifier 1 seul fichier (`run_calibration.R`)

### 2. Cohérence garantie
- **Avant :** Risque d'incohérences entre trimestres/schémas
- **Maintenant :** Logique identique pour tous (définie une seule fois)

### 3. Ajout de nouveaux trimestres facilité
- **Avant :** Copier-coller 7-8 fichiers et modifier manuellement
- **Maintenant :** Simplement exécuter avec les nouveaux paramètres

### 4. Traçabilité améliorée
- **Avant :** Historique git difficile à suivre (237 fichiers)
- **Maintenant :** Changements clairement visibles dans 1-2 fichiers

### 5. Réduction de l'espace disque
- **Avant :** Duplication massive de code (~5 MB de scripts identiques)
- **Maintenant :** Code unique (~50 KB) + configuration (10 KB)

### 6. Facilité de test
- **Avant :** Tester les modifications nécessitait de valider 237 fichiers
- **Maintenant :** Tester une seule logique centralisée

---

## 📝 Notes importantes

1. **Compatibilité :** La nouvelle architecture utilise les mêmes scripts de traitement (01-07) que l'ancienne, donc les résultats doivent être identiques.

2. **Transition progressive :** Vous pouvez garder l'ancienne structure en place pendant la période de transition et de validation.

3. **Documentation des scripts :** Les scripts 01-07 sont toujours nécessaires car ils contiennent la logique métier spécifique. Seul le script Master a été remplacé par `run_calibration.R`.

4. **Fichiers Excel :** Les fichiers de contraintes Excel sont spécifiques à chaque schéma et doivent être conservés.

---

## 🆘 Support

Pour toute question ou problème :
1. Consulter ce README
2. Examiner les logs d'exécution
3. Vérifier la configuration dans `config/schemas_calibration.csv`
4. Contacter l'équipe de développement

---

**Date de création :** Janvier 2026
**Version :** 1.0
**Auteur :** Équipe de développement ENE-M
