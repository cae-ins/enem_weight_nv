# Calibration

Architecture active: anciens codes de calibration par trimestre et schema.

Point d'entree de production:

```r
source("scripts/04_calibration/QUARTERLY_WEIGHTING/<annee>/<trimestre>/<schema>/00_Master_Calibration_<schema>.R")
```

Exemple:

```r
source("scripts/04_calibration/QUARTERLY_WEIGHTING/2026/T1/180X_1D/00_Master_Calibration_180X_1D.R")
```

Le dossier `_experimental_archived/` contient l'essai d'architecture dynamique autour de
`run_calibration.R`. Cette experimentation est conservee pour reference, mais elle n'est
pas le flux actif.
