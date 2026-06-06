# Guide de Démarrage Rapide - Nouvelle Architecture de Calibration

## 🎯 Objectif

Ce guide vous permet de démarrer rapidement avec la nouvelle architecture de calibration qui remplace les 237 fichiers dupliqués par une approche dynamique.

---

## ⚡ Démarrage en 3 étapes

### Étape 1 : Migration des fichiers (à faire une seule fois)

```r
# Exécuter le script de migration
source("scripts/04_calibration/migrate_constraints_files.R")
```

Ce script va :
- ✅ Rechercher tous les fichiers Excel de contraintes
- ✅ Les organiser dans la nouvelle structure
- ✅ Créer un rapport de migration

**Temps estimé :** 1-2 minutes

---

### Étape 2 : Première calibration test

```r
# Ouvrir le script principal
file.edit("scripts/04_calibration/run_calibration.R")

# Modifier les lignes 30-31 avec un trimestre/schéma existant
TARGET_QUARTER <- "T1_2025"    # Changez selon vos besoins
SCHEMA_ID <- "180X_1D"         # Changez selon vos besoins

# Exécuter
source("scripts/04_calibration/run_calibration.R")
```

**Temps estimé :** 5-10 minutes (selon les données)

---

### Étape 3 : Validation

Comparez les résultats avec l'ancienne méthode :

```r
# Vérifier que les fichiers de sortie ont été créés
list.files("data/07_QUARTERLY_WEIGHTING/2025/T1/180X_1D/")

# Charger et comparer les poids
old_weights <- haven::read_dta("chemin/vers/ancien/fichier.dta")
new_weights <- haven::read_dta("data/04_weights/T1_2025/calibrated_weights/individu_T1_2025_CAL.dta")

# Vérifier que les poids sont identiques
summary(old_weights$final_weight - new_weights$final_weight)
```

---

## 📖 Utilisation quotidienne

### Calibration simple

```r
# 1. Ouvrir le script
file.edit("scripts/04_calibration/run_calibration.R")

# 2. Modifier les paramètres
TARGET_QUARTER <- "T2_2025"    # Votre trimestre
SCHEMA_ID <- "312X_1D"         # Votre schéma

# 3. Exécuter
source("scripts/04_calibration/run_calibration.R")
```

### Calibration de plusieurs trimestres

```r
# Définir la liste des calibrations
calibrations <- data.frame(
  quarter = c("T1_2025", "T2_2025", "T3_2025"),
  schema = c("180X_1D", "180X_1D", "180X_1D")
)

# Boucler
for (i in 1:nrow(calibrations)) {
  TARGET_QUARTER <- calibrations$quarter[i]
  SCHEMA_ID <- calibrations$schema[i]
  source("scripts/04_calibration/run_calibration.R")
}
```

---

## 🔍 Schémas disponibles

Voir tous les schémas dans `config/schemas_calibration.csv` :

| Schéma | Contraintes | Usage typique |
|--------|-------------|---------------|
| `180X_1D` | 180 | Standard |
| `312X_1D` | 312 | Détaillé |
| `444X_1D` | 444 | Très détaillé |
| `156X_1D_ALLWR_np` | 156 | Tous ménages non-pondérés |

---

## 🛠️ Problèmes courants

### Problème 1 : "Schéma introuvable"

**Solution :**
```r
# Voir la liste des schémas disponibles
schemas <- read.csv("scripts/04_calibration/config/schemas_calibration.csv")
print(schemas$schema_id)
```

### Problème 2 : "Fichier de contraintes introuvable"

**Solution :**
```r
# Vérifier si le fichier existe
schema_id <- "180X_1D"
constraint_file <- file.path(
  "scripts/04_calibration/QUARTERLY_WEIGHTING/constraints",
  schema_id,
  paste0("01_Set_of_constraints_", schema_id, ".xlsx")
)
file.exists(constraint_file)

# Si FALSE, relancer la migration
source("scripts/04_calibration/migrate_constraints_files.R")
```

### Problème 3 : "Script XX introuvable"

**Cause :** Les scripts 01-07 doivent encore exister dans l'ancienne structure.

**Solution :**
```r
# Vérifier l'existence des scripts
schema_id <- "180X_1D"
year <- 2025
quarter <- 1
script_dir <- file.path(
  "scripts/04_calibration/QUARTERLY_WEIGHTING",
  year, paste0("T", quarter), schema_id
)
list.files(script_dir, pattern = "\\.R$")
```

---

## 📋 Checklist de validation

Après votre première calibration, vérifiez :

- [ ] Le script s'est exécuté sans erreur
- [ ] Les fichiers de sortie ont été créés dans `data/07_QUARTERLY_WEIGHTING/`
- [ ] Les fichiers de poids finaux existent dans `data/04_weights/.../calibrated_weights/`
- [ ] Les statistiques récapitulatives sont cohérentes
- [ ] Les poids sont identiques à l'ancienne méthode (pour validation)

---

## 💡 Astuces

### Astuce 1 : Logs détaillés

Le script affiche des messages détaillés à chaque étape. Surveillez ces messages pour détecter les problèmes.

### Astuce 2 : Sauvegarde de session

Après une calibration réussie, vous pouvez sauvegarder l'environnement R :
```r
save.image(file = paste0("calibration_", TARGET_QUARTER, "_", SCHEMA_ID, ".RData"))
```

### Astuce 3 : Réutiliser l'environnement

```r
# Charger les fonctions une seule fois
source("config/1_config.r")
source("scripts/04_calibration/functions/calibration_utils.R")

# Puis boucler sur plusieurs calibrations sans recharger
for (quarter in c("T1_2025", "T2_2025")) {
  cal_env <- initialize_calibration_env(quarter, "180X_1D")
  # ... exécuter les étapes ...
}
```

---

## 📞 Besoin d'aide ?

1. **Consultez le README complet :** `scripts/04_calibration/README_NOUVELLE_ARCHITECTURE.md`
2. **Vérifiez les logs :** Les messages affichés contiennent des informations de débogage
3. **Examinez le rapport de migration :** `scripts/04_calibration/migration_report.csv`

---

## 🎉 Prêt à commencer !

Vous avez maintenant tout ce qu'il faut pour utiliser la nouvelle architecture. Lancez-vous avec :

```r
source("scripts/04_calibration/run_calibration.R")
```

**Bonne calibration !** 🚀
