## Utilisation rapide — mettre en route le pipeline de pondérations

Avant d'exécuter le code, suivez ces deux préparations initiales :

1. Ajouter les données brutes du trimestre concerné  
   Placez les fichiers de données pour le trimestre concerné dans le dossier correspondant sous `data/01_raw/`. Par exemple, pour le trimestre T1 2025, mettez les fichiers dans `data/01_raw/T1_2025/` (ou respectez la convention de dossier utilisée dans votre dépôt).

2. Mettre à jour la variable de configuration `TARGET_QUARTER`  
   Ouvrez le fichier `config/1_config.r` et modifiez la variable `TARGET_QUARTER` pour indiquer le trimestre à traiter (ex. `"T1_2025"` ou la valeur attendue par votre configuration). Sauvegardez le fichier avant de lancer les scripts.

---

## Flux de travail (ordre des scripts à exécuter)

Les scripts sont organisés par étape. Exécutez-les dans l'ordre indiqué ci-dessous.

### (i) Préparation des données (scripts utilitaires)
Dans `scripts/01_utils/` exécuter, dans l'ordre, les scripts utilitaires principaux :

- `scripts/01_utils/1_concat_denomb.R`  
- `scripts/01_utils/2_denomb_updates.R`  
- `scripts/01_utils/3_assign_firstTrim_interview.R`  
- `scripts/01_utils/4_gen_interviewkey_map.R`  
- `scripts/01_utils/5_delete_individu_age_sexe.r`  

But : standardiser et concaténer les fichiers d'entrée, générer les clés d'entretien, et appliquer nettoyages initiaux. Vérifier les sorties dans `data/02_cleaned/` ou les chemins configurés.

Conseil : lancez ces scripts depuis RStudio (ouvrir et "Source") ou depuis la ligne de commande avec Rscript.

### (ii) Calcul des poids de base (ménages)
Dans `scripts/02_base_weights/`, exécuter dans l'ordre :

1. `scripts/02_base_weights/1_gen_weights_columns.R` — génère les colonnes / variables nécessaires pour le calcul des poids.  
2. `scripts/02_base_weights/2_calc_base_weights.R` — calcule les poids de base au niveau ménage.

Résultat attendu : fichiers de poids ménages sauvegardés (vérifier `data/04_weights/` ou le chemin de sortie configuré).

### (iii) Ajustement pour non-réponse
Dans `scripts/03_nonresponse/` :

- `scripts/03_nonresponse/1_adjust_weights_non_response.R`

But : ajuste les poids de base pour compenser la non-réponse. Vérifier les sorties et logs produits (souvent dans `logs/` ou `data/04_weights/`).

### (iv) Poids individus
De retour dans `scripts/02_base_weights/` :

- `scripts/02_base_weights/3_indivs_weights.R`

But : dérive les poids individuels à partir des poids ménages ajustés.

### (v) Calibration (pondération trimestrielle)
Dans `scripts/04_calibration/QUARTERLY_WEIGHTING/`, ouvrez le dossier correspondant à l'année et trimestre configurés (par ex. `2025/T1/`) et choisissez le dossier du design (ex. `180X_1D`, `312X_1D`, `444X_1D`, ...).

1. Localisez et exécutez le script maître : `00_Master_Calibration_<DESIGN>.R` (ex. `00_Master_Calibration_180X_1D.R`). Exécutez ce script attentivement jusqu'à la fin de l'étape 3 (les commentaires indiquent les points de contrôle). Les étapes 1→3 préparent les inputs et exécutent la calibration principale.

2. Étapes 4 et 5 : pour les étapes finales (formats X, attachement des poids finaux, exports et diagnostics), utilisez les scripts spécifiques présents dans le dossier pour les étapes 4 et 5, typiquement nommés :

- `04c_Run_Quarterly_Calibration_with_Regenesees_<DESIGN>.R`  

- `05_Attach_final_weights_to_full_sample_data_<DESIGN>.R`

But : exécuter les étapes 4 et 5 seulement après validation de l'étape 3. Vérifier les sorties dans `data/04_weights/` et les diagnostics dans `reports/` ou `logs/`.

---

## Exemples de commandes (PowerShell / R)

Exécuter un script R depuis PowerShell :

```powershell
Rscript.exe scripts/01_utils/1_concat_denomb.R
Rscript.exe scripts/02_base_weights/1_gen_weights_columns.R
Rscript.exe scripts/02_base_weights/2_calc_base_weights.R
```

Ou depuis une session R interactive :

```r
source("scripts/01_utils/1_concat_denomb.R")
source("scripts/02_base_weights/1_gen_weights_columns.R")
source("scripts/02_base_weights/2_calc_base_weights.R")
```

---

## Contrat rapide (inputs / outputs / critères de succès)

- Inputs : fichiers bruts placés sous `data/01_raw/<TRIMESTRE>/`, variable `TARGET_QUARTER` correctement définie dans `config/1_config.r`.  
- Outputs : jeux de poids (ménages et individus) dans `data/04_weights/`, fichiers de calibration et diagnostics dans `reports/` ou `logs/`.  
- Critères de succès : scripts s'exécutent sans erreur, fichiers de sortie attendus créés, diagnostics de calibration satisfaisants (convergence, totaux connus respectés).

---

## Vérifications et cas limites

- Vérifiez que `config/1_config.r` contient les bons chemins et que les packages R requis sont installés (ReGenesees, dplyr, haven, readxl, writexl, etc.).  
- Si un script échoue à cause d'un fichier manquant, vérifiez que les noms et emplacements dans `data/01_raw/` correspondent à ceux attendus par le script.  
- Pour des jeux volumineux, exécutez d'abord sur un petit sous-ensemble pour valider la chaîne.


