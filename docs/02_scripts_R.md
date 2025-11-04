# Analyse des scripts R — scripts/01_utils/

Ce document décrit chaque script `.R` présent dans le dossier `scripts/01_utils/` : rôle, fonctions principales, jeux de données lus/écrits, dépendances et étapes de transformation. Le but est de fournir une référence rapide pour les développeurs et analystes.

## Sommaire

- [1_concat_denomb.R](#1_concat_denombr)
- [concat_denomb.R](#concat_denombr)
- [2_denomb_updates.R](#2_denomb_updatesr)
- [3_assign_firstTrim_interview.R](#3_assign_firsttrim_interviewr)
- [4_gen_interviewkey_map.R](#4_gen_interviewkey_mapr)
- [update_interviewkey_map.R](#update_interviewkey_mapr)
- [harm_rp_ene.R](#harm_rp_enere)
- [extract_rp2021_vars.R](#extract_rp2021_varsr)
- [calc_nb_men_indiv_ZD.R](#calc_nb_men_indiv_zdr)

---

## 1_concat_denomb.R

Chemin : `scripts/01_utils/1_concat_denomb.R`

- Rôle du script
  - Parcourir récursivement un répertoire parent (`data/01_raw/Denombrement/T2_2025`), identifier les fichiers Stata `.dta` portant le même nom dans différents sous-dossiers, puis concaténer verticalement (stack) ces fichiers en harmonisant la structure (union des colonnes). Sauvegarde des fichiers résultants dans `data/02_cleaned/Denombrement/T2_2025`.

- Fonctions / blocs principaux
  - Lecture des `.dta` : `read_dta()` (haven)
  - Nettoyage des noms : `janitor::clean_names()`
  - Indexation des fichiers : `fs::dir_info()` puis group_by par nom de fichier
  - Harmonisation des colonnes (union + ajout de colonnes manquantes avec NA)
  - Concaténation : `dplyr::bind_rows()`
  - Écriture : `write_dta()` (haven)

- Jeux de données lus / écrits
  - Entrée : tous les fichiers `.dta` sous `data/01_raw/Denombrement/T2_2025` (par nom de fichier)
  - Sortie : fichiers `.dta` consolidés dans `data/02_cleaned/Denombrement/T2_2025` (même nom de fichier)

- Dépendances (packages)
  - haven, dplyr, purrr, fs, stringr, janitor

- Étapes de transformation
  1. Indexer les `.dta` par nom de fichier.
  2. Lire chaque jeu, nettoyer les noms.
  3. Calculer l'union des noms de variables.
  4. Ajouter les colonnes manquantes (NA) afin d'aligner les variables.
  5. Concaténer par lignes.
  6. Sauvegarder le résultat.

Remarque : les fonctions détectées ont été intégrées directement sous chaque section de script ci‑dessus (voir les sous‑sections "Fonctions" ajoutées). Si vous voulez que j'ajoute en plus les extraits de code complet des fonctions (pour relecture/QA), dites "oui" et je les insérerai sous chaque script.
  - Boucle sur les dossiers trimestriels `T\d_YYYY` ; lecture du fichier `menage_<quarter>.dta`
  - Ajout de la variable `firsttriminterview` via `case_when` (logique selon `rgmen` et correspondance `v1interviewkey`)
  - Écriture des fichiers mis à jour dans `data/03_Processed/Menage/<quarter>/menage_<quarter>.dta`

- Jeux de données lus / écrits
  - Entrée : `data/02_Cleaned/Menage/T*/menage_<quarter>.dta`
  - Mapping : `data/03_Processed/Tracking_ID/interview_key_mapping_YYYY-MM-DD.dta` (dernier fichier)
  - Sortie : `data/03_Processed/Menage/<quarter>/menage_<quarter>.dta` (avec variable `firsttriminterview` ajoutée)

- Dépendances (packages)
  - dplyr, fs, haven, janitor, stringr, lubridate

- Étapes de transformation
  1. Localiser le fichier mapping le plus récent.
  2. Pour chaque dossier trimestre, lire `menage_*.dta` et créer `firsttriminterview` selon règles métier.
  3. Sauvegarder les fichiers mis à jour dans `data/03_Processed/Menage/`.

### Fonctions

- Fonctions nommées : aucune détectée.  
- Le script utilise une logique procédurale et des transformations `dplyr` pour créer `firsttriminterview` (chaque étape est documentée en commentaires dans le script).

---

## 4_gen_interviewkey_map.R

Chemin : `scripts/01_utils/4_gen_interviewkey_map.R`

- Rôle du script
  - Générer une table de liaison contenant, pour chaque `interview_key`, la première occurrence (quarter) où il a été enquêté, en scannant les répertoires `data/02_Cleaned/Menage/T*` dans l'ordre chronologique.

- Fonctions / blocs principaux
  - Détermination et ordonnancement des dossiers trimestriels (`dir_ls`, extraction du numéro de trimestre et de l'année)
  - Lecture des fichiers `menage*.dta` par trimestre, nettoyage (`clean_names`) et extraction des variables d'intérêt (`interview_key`, `v1interviewkey`, `date1`, `quarter_label`, etc.)
  - Concaténation `bind_rows()` de toutes les périodes et sauvegarde du mapping final en `data/03_Processed/Tracking_ID/interview_key_mapping.dta`

- Jeux de données lus / écrits
  - Entrée : `data/02_Cleaned/Menage/T*/menage_*.dta`
  - Sortie : `data/03_Processed/Tracking_ID/interview_key_mapping.dta`

- Dépendances (packages)
  - dplyr, fs, stringr, janitor, haven, lubridate, readr

- Étapes de transformation
  1. Lister et ordonner chronologiquement les dossiers trimestriels.
  2. Lire chaque fichier ménage, normaliser et extraire les champs utiles.
  3. Concaténer et sauvegarder la table de mapping.

### Fonctions

- Fonctions nommées : aucune détectée (script procédural).  
- Le script implémente des utilitaires inline pour ordonner les dossiers et sélectionner les variables disponibles avant `bind_rows()`.

---

## update_interviewkey_map.R

Chemin : `scripts/01_utils/update_interviewkey_map.R`

- Rôle du script
  - Mettre à jour le mapping `interview_key_mapping` en détectant de nouveaux dossiers trimestriels non encore traités, lire les fichiers `menage` pour ces nouvelles périodes, concaténer aux enregistrements existants, dédupliquer et sauvegarder la version mise à jour avec un timestamp. Met aussi à jour un log `quarters_processed_YYYY-MM-DD.xlsx`.

- Fonctions / blocs principaux
  - Lecture du log `quarters_processed_*.xlsx` (si présent) pour connaître les trimestres déjà traités
  - Détection des nouveaux trimestres
  - Lecture sélective des variables disponibles par fichier `menage` (vérification d'existence des variables requises)
  - Assemblage `bind_rows`, déduplication `distinct(interview_key, .keep_all = TRUE)`
  - Sauvegarde du mapping mis à jour (`interview_key_mapping_<date>.dta`) et du log `quarters_processed_<date>.xlsx`

- Jeux de données lus / écrits
  - Entrées : `data/02_Cleaned/Menage/T*/menage_*.dta`, logs Excel `data/03_Processed/Tracking_ID/quarters_processed_*.xlsx`, et mapping existant `interview_key_mapping_*.dta` si présent
  - Sorties : `data/03_Processed/Tracking_ID/<date>/interview_key_mapping_<date>.dta` et `quarters_processed_<date>.xlsx`

- Dépendances (packages)
  - dplyr, fs, stringr, janitor, haven, lubridate, readxl, writexl

- Étapes de transformation
  1. Charger le log des trimestres traités.
  2. Détecter de nouveaux dossiers trimestriels.
  3. Lire les `menage` des nouveaux trimestres, garder les variables disponibles.
  4. Combiner avec le mapping existant et dédupliquer par `interview_key`.
  5. Sauvegarder mapping et log mis à jour.

### Fonctions

- Fonctions nommées : aucune détectée (script procédural).  
- Composants clés : lecture du log Excel (`readxl`), détection de nouveaux dossiers (`fs`), lecture conditionnelle des variables disponibles et `distinct()` pour dédupliquer.

---

## harm_rp_ene.R

Chemin : `scripts/01_utils/harm_rp_ene.R`

- Rôle du script
  - Harmoniser la base RP (recensement/échantillon RP_2021) avec les codes et libellés ENE à l'aide d'une table d'équivalence (Excel `VF_BASE_ILOT_12012024_VF_work_Geovf.xlsx`). Produit un fichier `nb_men_indivs_ZD.dta` harmonisé prêt pour servir de référence.

- Fonctions / blocs principaux
  - Lecture des fichiers : `read_dta()` pour RP, `read_excel()` pour la table d'équivalence
  - Transformation : création d'une clé composite (REGION, DEPART, SOUSPREFID, ZD), padding des codes ZD, conversion/rename de variables
  - Jointure `left_join()` sur la table de mapping pour obtenir Num/NumLibelle pour région/département/sous-préfecture
  - Attribution d'étiquettes `labelled()` (package labelled)
  - Écriture : `write_dta()` vers `data/03_processed/RP_2021/nb_men_indivs_ZD.dta`

- Jeux de données lus / écrits
  - Entrée : `data/03_processed/RP_2021/nb_men_indiv_RP.dta` (source RP) et `data/01_raw/Equivalence/VF_BASE_ILOT_12012024_VF_work_Geovf.xlsx` (mapping)
  - Sortie : `data/03_processed/RP_2021/nb_men_indivs_ZD.dta`

- Dépendances (packages)
  - haven, readxl, dplyr, labelled, tibble, tidyr, stringr

- Étapes de transformation
  1. Charger RP et mapping Excel.
  2. Nettoyer/convertir colonnes Cod* en integer.
  3. Construire clé `SOUSPREFID` et formater ZD (padding à 4 caractères).
  4. Joindre la table d'équivalence et filtrer (`drop_na`).
  5. Renommer et étiqueter les variables, sauvegarder.

### Fonctions

- Fonctions nommées : aucune détectée (pipeline procédural).  
- Blocs réutilisables : lecture du mapping Excel, transformation/padding des codes ZD, `left_join()` pour lier codes géographiques et `labelled()` pour ajouter les étiquettes.

---

## extract_rp2021_vars.R

Chemin : `scripts/01_utils/extract_rp2021_vars.R`

- Rôle du script
  - Extraire un sous-ensemble de variables depuis un gros fichier SPSS (.sav) (chemin codé `D:/RP_2021/Bases_Menage_RGPH2024_EMPLOI.sav`) et exporter ce sous-ensemble en `.dta` et `.csv`.

- Fonctions / blocs principaux
  - `read_sav()` (haven) avec `col_select = all_of(vars_to_extract)` pour charger uniquement les variables souhaitées
  - `write_dta()` et `readr::write_csv()` pour exporter les résultats

- Jeux de données lus / écrits
  - Entrée : fichier `.sav` externe (chemin absolu `D:/RP_2021/...sav`)
  - Sorties : `data/02_cleaned/RP_2021/Bases_Menage_RGPH2021_GPS.dta` et `.csv`

- Dépendances (packages)
  - haven, readr

- Étapes de transformation
  1. Définir la liste de variables à extraire.
  2. Lire uniquement ces variables depuis le .sav (gain de mémoire/temps).
  3. Sauvegarder en Stata et CSV dans le dossier `data/02_cleaned/RP_2021`.

### Fonctions

- Fonctions nommées : aucune détectée (script utilitaire).  
- Composants : usage de `read_sav()` avec `col_select` pour charger un sous-ensemble de variables, puis `write_dta()` / `write_csv()` pour export.

---

## calc_nb_men_indiv_ZD.R

Chemin : `scripts/01_utils/calc_nb_men_indiv_ZD.R`

- Rôle du script
  - À partir d'un fichier ménage nettoyé (`Bases_Menage_RGPH2021.dta`), agréger par dimensions géographiques (REGION, DEPART, SOUSPREFID, P05) pour calculer le nombre total d'individus (somme `TAILLE_MENAGE`) et le nombre de ménages (`n_distinct(ID_Menage)`). Sauvegarde en `.csv` et `.dta`.

- Fonctions / blocs principaux
  - Lecture : `read_dta()`
  - Transformation : `mutate()` pour formater P05 en code ZD 4 caractères, `group_by()` / `summarise()` pour les agrégations
  - Etiquetage : `labelled()` pour ajouter des labels descriptifs
  - Sauvegarde : `write_csv()` et `write_dta()`

- Jeux de données lus / écrits
  - Entrée : `data/02_cleaned/RP_2021/Bases_Menage_RGPH2021.dta`
  - Sortie : `data/03_processed/RP_2021/Nb_men_indiv_ZD.csv` et `Nb_men_indiv_ZD.dta`

- Dépendances (packages)
  - dplyr, readr, haven, stringr

- Étapes de transformation
  1. Lire le fichier ménage nettoyé.
  2. Formater P05 en code ZD (padding à 4 caractères).
  3. Grouper et calculer `Nb_individus` (somme taille) et `Nb_menages` (n_distinct).
  4. Ajouter labels et sauvegarder en CSV et DTA.

### Fonctions

- Fonctions nommées : aucune détectée (script d'agrégation).  
- Composants réutilisables : `mutate()` pour formater P05, `group_by()` / `summarise()` pour agrégations, `labelled()` pour ajouter des étiquettes.

---

## Dossier: scripts/02_base_weights/

Les scripts de ce dossier forment le cœur du calcul des poids de base. J'ai relu chaque fichier et résumé ci‑dessous le rôle précis, les fonctions nommées, les entrées/sorties et le flux de traitement observé.

### 1_gen_weights_columns.R

- Chemin : `scripts/02_base_weights/1_gen_weights_columns.R`
- Rôle : construire le tableau de travail (`final_data` / `weights_columns_<QUARTER>.dta`) contenant toutes les variables nécessaires au calcul des probabilités d'inclusion et des poids (effectifs ZD/segment, nb ménages/enquêtes, régions/milieu, dates de référence, variables de contrôle d'incohérence, etc.). Ce script assemble les données provenant du dénombrement, des fichiers ménage/individu du trimestre, et des fichiers de référence RP_2021.
- Fonctions nommées (extraites) :
  - Fonctions (extraits du script) :

```r
appliquer_correction_trimestre <- function(df, trimestre, dossier_scripts = "scripts/07_correction_quarter") {
  nom_fichier <- file.path(dossier_scripts, paste0("correction_", trimestre, ".r"))

---

### Détails — Calibration T1 2025 : scripts par design

Ci-dessous j'ajoute, pour chaque design présent dans `QUARTERLY_WEIGHTING/2025/T1/`, la liste des scripts et les fonctions nommées détectées. Contrainte respectée : quand une fonction nommée est définie dans un script, j'insère son code complet ci-dessous (extraits stricts des fichiers sources).

#### 180X_1D

- Chemin du dossier : `scripts/04_calibration/QUARTERLY_WEIGHTING/2025/T1/180X_1D/`
- Fichiers observés :
  - `00_Master_Calibration_180X_1D.R` (script maître, paramétrage et orchestration)
  - `01_Upload_Sample_Data_and_Known_Totals_in_R_180X_1D.R` (lecture DER et totaux population)
  - `02_Prepare_input_sample_data_for_regenesees_180X_1D.R` (prépare LFS_SAMPLE_DATA, crée X1..X180)
  - `03_Prepare_input_pop_figures_for_regenesees_180X_1D.R` (prépare LFS_KNOWN_TOTALS à partir des totaux population)
  - `04c_Run_Quarterly_Calibration_with_Regenesees_180X_1D.R` (lance ReGenesees, calcule poids finaux et diagnostics)
  - `04f_XFormats_180X_1D.R` (tableau de labels/formats pour X1..X180)
  - `05_Attach_final_weights_to_full_sample_data_180X_1D.R` (joint les poids finaux au DER et exporte)

- Fonctions nommées observées (extraits de `00_Master_Calibration_180X_1D.R`) :

```r
parse_target_quarter <- function(target_quarter) {
  
  # Check if input is valid
  if (is.null(target_quarter) || !is.character(target_quarter)) {
    stop("target_quarter must be a character string")
  }
  
  # Check format (should be like "T1_2025", "T2_2024", etc.)
  if (!grepl("^T[1-4]_[0-9]{4}$", target_quarter)) {
    stop("target_quarter format should be 'TX_YYYY' where X is 1-4 and YYYY is a 4-digit year")
  }
  
  # Extract quarter number and year
  parts <- strsplit(target_quarter, "_")[[1]]
  quarter_part <- parts[1]  # "T1", "T2", etc.
  year_part <- parts[2]     # "2025", "2024", etc.
  
  # Extract just the number from quarter part
  quarter <- as.numeric(gsub("T", "", quarter_part))
  year <- as.numeric(year_part)
  
  # Return as a named list
  result <- list(
    quarter = quarter,
    year = year,
    original = target_quarter
  )
  
  # Print results
  cat("Parsed target quarter:\n")
  cat("Quarter:", quarter, "\n")
  cat("Year:", year, "\n")
  
  return(result)
}
```

```r
get_weights_path <- function(target_quarter, use_sr = FALSE) {
  # Choisir le préfixe selon SR ou pas
  prefix <- if (use_sr) "SR_individu_" else "individu_"
  
  file.path(BASE_DIR,
    "data", "04_weights", target_quarter, "base_weights",
    paste0(prefix, target_quarter, ".dta")
  )
}
```

```r
# Version plus flexible avec option SR
get_export_path <- function(target_quarter, quarter, year, use_sr = FALSE) {
  prefix <- if (use_sr) "SR_individu" else "individu"
  
  file.path(BASE_DIR, 
    "data", "04_weights", target_quarter, "calibrated_weights",
    paste0(prefix, "_T", quarter, "_", year, "_CAL.dta")
  )
}
```

> Remarque : les autres scripts du dossier (01, 02, 03, 04c, 04f, 05) sont essentiellement procéduraux — ils ne définissent pas de fonctions nommées mais construisent les objets R requis (LFS_SAMPLE_DATA, LFS_KNOWN_TOTALS, fichiers de sorties, X_Summary_Table, diagnostics ReGenesees). Le fichier `04f_XFormats_180X_1D.R` contient une large table d'étiquettes `X_Labels` (mapping X -> libellés lisibles) qui est importante pour les sorties.

#### 312X_1D

- Chemin du dossier : `scripts/04_calibration/QUARTERLY_WEIGHTING/2025/T1/312X_1D/`
- Fichiers observés :
  - `00_Master_Calibration_312X_1D.R` (script maître)
  - `01_Upload_Sample_Data_and_Known_Totals_in_R_312X_1D.R`
  - `02_Prepare_input_sample_data_for_regenesees_312X_1D.R`
  - `03_Prepare_input_pop_figures_for_regenesees_312X_1D.R`
  - `04c_Run_Quarterly_Calibration_with_Regenesees_312X_1D.R`
  - `04f_XFormats_312X_1D.R`
  - `05_Attach_final_weights_to_full_sample_data_312X_1D.R`

- Fonctions nommées observées (extraits de `00_Master_Calibration_312X_1D.R`) :

```r
parse_target_quarter <- function(target_quarter) {
  
  # Check if input is valid
  if (is.null(target_quarter) || !is.character(target_quarter)) {
    stop("target_quarter must be a character string")
  }
  
  # Check format (should be like "T1_2025", "T2_2024", etc.)
  if (!grepl("^T[1-4]_[0-9]{4}$", target_quarter)) {
    stop("target_quarter format should be 'TX_YYYY' where X is 1-4 and YYYY is a 4-digit year")
  }
  
  # Extract quarter number and year
  parts <- strsplit(target_quarter, "_")[[1]]
  quarter_part <- parts[1]  # "T1", "T2", etc.
  year_part <- parts[2]     # "2025", "2024", etc.
  
  # Extract just the number from quarter part
  quarter <- as.numeric(gsub("T", "", quarter_part))
  year <- as.numeric(year_part)
  
  # Return as a named list
  result <- list(
    quarter = quarter,
    year = year,
    original = target_quarter
  )
  
  # Print results
  cat("Parsed target quarter:\n")
  cat("Quarter:", quarter, "\n")
  cat("Year:", year, "\n")
  
  return(result)
}
```

```r
get_weights_path <- function(target_quarter, use_sr = FALSE) {
  # Choisir le préfixe selon SR ou pas
  prefix <- if (use_sr) "SR_individu_" else "individu_"
  
  file.path(BASE_DIR,
    "data", "04_weights", target_quarter, "base_weights",
    paste0(prefix, target_quarter, ".dta")
  )
}
```

```r
get_export_path <- function(target_quarter, quarter, year, use_sr = FALSE) {
  prefix <- if (use_sr) "SR_individu" else "individu"
  
  file.path(BASE_DIR, 
    "data", "04_weights", target_quarter, "calibrated_weights",
    paste0(prefix, "_T", quarter, "_", year, "_CAL.dta")

  ##### Extraits importants insérés (180X_1D)

  Ci-dessous quelques extraits clairs des scripts 02..05 (T1_2025/180X_1D) — j'ai choisi les blocs les plus utiles pour la revue : création de la liste X, initialisation des X dans l'échantillon, construction des totaux connus et un extrait du mapping des labels X (04f). Les scripts complets restent dans le repo; si vous voulez que j'insère intégralement chaque script ici, dites-le et je le ferai en batch.

  — Extrait de `02_Prepare_input_sample_data_for_regenesees_180X_1D.R` (création des X dans l'échantillon)

  ```r
  # initialisation : ajouter xnum colonnes X (toutes à 0)
  tmpSD <- cbind(tmpSD, data.frame(matrix(0, nrow = nrow(tmpSD), ncol = xnum, byrow = FALSE)))

  # liste des noms X
  list_of_X  <- paste(rep("X", xnum), seq(1, xnum), sep = "")

  # exemples d'assignations (pattern répété jusqu'à X180)
  tmpSD$X1[ tmpSD$ageannee >= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu == 1 & tmpSD$m5 == 1 ] <- 1
  tmpSD$X2[ tmpSD$ageannee >= 15 & tmpSD$ageannee <= 19 & tmpSD$milieu == 1 & tmpSD$m5 == 1 ] <- 1
  tmpSD$X3[ tmpSD$ageannee >= 20 & tmpSD$ageannee <= 24 & tmpSD$milieu == 1 & tmpSD$m5 == 1 ] <- 1
  # ...
  tmpSD$X180[ tmpSD$ageannee >= 15 & tmpSD$m5 == 2 & tmpSD$hh2 == 10833 ] <- 1

  # construction finale du dataframe utilisé par Regenesees
  LFS_SAMPLE_DATA <- tmpSD[, c("hh2", "milieu", "DOMAIN", "STRATAKEY", "PSUKEY", "HHKEY", "INDKEY", "m5", list_of_X, "d_weights")]
  ```

  — Extrait de `03_Prepare_input_pop_figures_for_regenesees_180X_1D.R` (construction des totaux connus à partir du fichier population)

  ```r
  # initialisation : ajouter xnum colonnes X (toutes à 0)
  tmpKT <- cbind(tmpKT, data.frame(matrix(0, nrow = nrow(tmpKT), ncol = xnum, byrow = FALSE)))

  # exemples d'assignations (pattern répété jusqu'à X180)
  tmpKT$X1[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "0_14" & tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ] <- tmpKT$Nombre[ ... ]
  tmpKT$X2[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "15_19" & tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ] <- tmpKT$Nombre[ ... ]
  # ...
  tmpKT$X180[ tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Sexe == 2 ] <- tmpKT$Nombre[ ... ]

  # créer list_of_X pour l'usage suivant
  list_of_X <- paste(rep("X", xnum), seq(1, xnum), sep = "")
  ```

  — Extrait de `04c_Run_Quarterly_Calibration_with_Regenesees_180X_1D.R` (points clefs)

  ```r
  # chargement objets préparés
  load(FILE_LFS_SAMPLE_DATA_RDATA)
  load(FILE_LFS_KNOWN_TOTALS_RDATA)

  # préparation du design
  design_lfs <- e.svydesign(data = sample_data, ids = ~ PSUKEY + HHKEY, strata = ~ STRATAKEY, weights = ~ d_weights)

  # chargement des fonctions additionnelles et construction du modèle de contraintes
  source(R_SCRIPT_NEW_FUNCTIONS_FOR_X_CONSTRAINS)
  constrains_x <- constraints_model(xnum)

  # création du poptemplate et remplissage
  poptemplate  <- pop.template(data = known_totals, calmodel = constrains_x, partition = ~ DOMAIN)
  popdataframe <- fill.template(universe = known_totals, template = poptemplate, mem.frac = 5)

  # calibration (exemple)
  calib_lfs <- e.calibrate(design = design_lfs, df.population = popdataframe, calmodel = constrains_x, partition = ~ DOMAIN, calfun = "logit", bounds = c(0.3, 4.5))

  # vérifications et extractions des poids finaux
  check.cal(calib_lfs)
  final_weights <- weights(calib_lfs)
  ```

  — Extrait de `04f_XFormats_180X_1D.R` (mapping des labels X — début)

  ```r
  X_Summary_Table$X_Labels[X_Summary_Table$X_Constraints=="X1"] <- "X1: ABIDJAN SEX 1 AGE 0_14"
  X_Summary_Table$X_Labels[X_Summary_Table$X_Constraints=="X2"] <- "X2: ABIDJAN SEX 1 AGE 15_plus"
  X_Summary_Table$X_Labels[X_Summary_Table$X_Constraints=="X3"] <- "X3: ABIDJAN SEX 2 AGE 0_14"
  # ... (suite jusqu'à X180)
  ```

  — Extrait de `05_Attach_final_weights_to_full_sample_data_180X_1D.R` (attachement et export)

  ```r
  load(FILE_LFS_ILO_DER_RDATA)
  load(FILE_LFS_CALIBRATION_FINAL_WEIGHTS_RDATA)

  tmp_FINAL_WEIGHTS <- LFS_CALIBRATION_FINAL_WEIGHTS[, c("INDKEY", "FINAL_CORR_FACTOR", "FINAL_WEIGHT")]
  LFS_ILO_CAL <- merge(LFS_ILO_DER, tmp_FINAL_WEIGHTS, by = "INDKEY")
  save(LFS_ILO_CAL, file = FILE_LFS_ILO_CAL_RDATA)
  write_dta(LFS_ILO_CAL, path = FILE_LFS_ILO_CAL_DTA_EXPORT)
  ```

  Ces extraits montrent les patterns récurrents : initialisation X (matrice de zéros), remplissage suivant conditions (age/milieu/sex/region), construction du poptemplate, calibration via `e.calibrate` et attachement des poids finaux. Si vous voulez, j'insère ensuite l'intégralité des blocs (02, 03 et 04f complets) dans `01_scripts_R.md` — dites "oui, tout insérer" ou "non, insérer seulement les fichiers XFormats complets".
  )
}
```

> Remarque : comme pour 180X_1D, la majorité des autres fichiers (01..05, 04f) sont procéduraux et créent/écrivent des objets (LFS_SAMPLE_DATA, LFS_KNOWN_TOTALS, X_Summary_Table, etc.).

#### 444X_1D

- Chemin du dossier : `scripts/04_calibration/QUARTERLY_WEIGHTING/2025/T1/444X_1D/`
- Fichiers observés :
  - `00_Master_Calibration_444X_1D.R` (script maître)
  - `01_Upload_Sample_Data_and_Known_Totals_in_R_444X_1D.R`
  - `02_Prepare_input_sample_data_for_regenesees_444X_1D.R`
  - `03_Prepare_input_pop_figures_for_regenesees_444X_1D.R`
  - `04c_Run_Quarterly_Calibration_with_Regenesees_444X_1D.R`
  - `04f_XFormats_444X_1D.R`
  - `05_Attach_final_weights_to_full_sample_data_444X_1D.R`

- Fonctions nommées observées (extraits de `00_Master_Calibration_444X_1D.R`) :

```r
parse_target_quarter <- function(target_quarter) {
  
  # Check if input is valid
  if (is.null(target_quarter) || !is.character(target_quarter)) {
    stop("target_quarter must be a character string")
  }
  
  # Check format (should be like "T1_2025", "T2_2024", etc.)
  if (!grepl("^T[1-4]_[0-9]{4}$", target_quarter)) {
    stop("target_quarter format should be 'TX_YYYY' where X is 1-4 and YYYY is a 4-digit year")
  }
  
  # Extract quarter number and year
  parts <- strsplit(target_quarter, "_")[[1]]
  quarter_part <- parts[1]  # "T1", "T2", etc.
  year_part <- parts[2]     # "2025", "2024", etc.
  
  # Extract just the number from quarter part
  quarter <- as.numeric(gsub("T", "", quarter_part))
  year <- as.numeric(year_part)
  
  # Return as a named list
  result <- list(
    quarter = quarter,
    year = year,
    original = target_quarter
  )
  
  # Print results
  cat("Parsed target quarter:\n")
  cat("Quarter:", quarter, "\n")
  cat("Year:", year, "\n")
  
  return(result)
}
```

```r
get_weights_path <- function(target_quarter, use_sr = FALSE) {
  # Choisir le préfixe selon SR ou pas
  prefix <- if (use_sr) "SR_individu_" else "individu_"
  
  file.path(BASE_DIR,
    "data", "04_weights", target_quarter, "base_weights",
    paste0(prefix, target_quarter, ".dta")
  )
}
```

```r
get_export_path <- function(target_quarter, quarter, year, use_sr = FALSE) {
  prefix <- if (use_sr) "SR_individu" else "individu"
  
  file.path(BASE_DIR, 
    "data", "04_weights", target_quarter, "calibrated_weights",
    paste0(prefix, "_T", quarter, "_", year, "_CAL.dta")
  )
}
```

> Remarque générale pour T1 2025 : les trois scripts `00_Master_Calibration_*.R` contiennent des petites fonctions utilitaires identiques (parse_target_quarter, get_weights_path, get_export_path) qui facilitent le paramétrage et la génération des chemins. Les étapes 01..05 réalisent la construction des objets LFS_SAMPLE_DATA, LFS_KNOWN_TOTALS, l'appel à ReGenesees (e.calibrate / constraints_model / pop.template) et l'attachement des poids finaux. Enfin, `04f_XFormats_*.R` contient la table lisible des X (labels) utilisée pour les exports et diagnostics.

### Extraits importants insérés (312X_1D)

Ci-dessous quelques extraits utiles tirés des scripts `02..05` pour le design `312X_1D` (T1_2025). J'ai retenu les blocs structurels — initialisation des X, construction des totaux connus, appel à ReGenesees, et attachement des poids — sans répéter les centaines d'assignations individuelles.

— Extrait de `02_Prepare_input_sample_data_for_regenesees_312X_1D.R` (création des X dans l'échantillon)

```r
# initialisation : ajouter xnum colonnes X (toutes à 0)
tmpSD <- cbind(tmpSD, data.frame(matrix(0, nrow = nrow(tmpSD), ncol = xnum, byrow = FALSE)))

# liste des noms X
list_of_X  <- paste0("X", seq_len(xnum))

# pattern d'assignation (exemples)
tmpSD$X1[ tmpSD$ageannee >= 0 & tmpSD$ageannee <= 4 & tmpSD$milieu == 1 & tmpSD$region == "ABIDJAN" ] <- 1
tmpSD$X2[ tmpSD$ageannee >= 5 & tmpSD$ageannee <= 9 & tmpSD$milieu == 1 & tmpSD$region == "ABIDJAN" ] <- 1
# ... (assignations répétées jusqu'à X312)

LFS_SAMPLE_DATA <- tmpSD[, c("hh2","milieu","DOMAIN","STRATAKEY","PSUKEY","HHKEY","INDKEY","m5", list_of_X, "d_weights")]
```

— Extrait de `03_Prepare_input_pop_figures_for_regenesees_312X_1D.R` (totaux connus)

```r
# initialisation : ajouter xnum colonnes X (toutes à 0) au tableau de population
tmpKT <- cbind(tmpKT, data.frame(matrix(0, nrow = nrow(tmpKT), ncol = xnum, byrow = FALSE)))

# affecter les totaux à partir de la colonne Nombre selon region/age/sex/milieu
tmpKT$X1[ tmpKT$region == "NATIONAL" & tmpKT$groupe_age == "0_4" & tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ] <- tmpKT$Nombre[ ... ]
# ...
list_of_X <- paste0("X", seq_len(xnum))
```

— Extrait de `04c_Run_Quarterly_Calibration_with_Regenesees_312X_1D.R`

```r
load(FILE_LFS_SAMPLE_DATA_RDATA)
load(FILE_LFS_KNOWN_TOTALS_RDATA)

design_lfs <- e.svydesign(data = sample_data, ids = ~ PSUKEY + HHKEY, strata = ~ STRATAKEY, weights = ~ d_weights)
source(R_SCRIPT_NEW_FUNCTIONS_FOR_X_CONSTRAINS)
constrains_x <- constraints_model(xnum)

poptemplate  <- pop.template(data = known_totals, calmodel = constrains_x, partition = ~ DOMAIN)
popdataframe <- fill.template(universe = known_totals, template = poptemplate, mem.frac = 5)

calib_lfs <- e.calibrate(design = design_lfs, df.population = popdataframe, calmodel = constrains_x, partition = ~ DOMAIN, calfun = "logit", bounds = c(0.3, 4.5))
final_weights <- weights(calib_lfs)
```

— Extrait de `05_Attach_final_weights_to_full_sample_data_312X_1D.R`

```r
load(FILE_LFS_ILO_DER_RDATA)
load(FILE_LFS_CALIBRATION_FINAL_WEIGHTS_RDATA)

tmp_FINAL_WEIGHTS <- LFS_CALIBRATION_FINAL_WEIGHTS[, c("INDKEY", "FINAL_CORR_FACTOR", "FINAL_WEIGHT")]
LFS_ILO_CAL <- merge(LFS_ILO_DER, tmp_FINAL_WEIGHTS, by = "INDKEY", all.x = TRUE)
save(LFS_ILO_CAL, file = FILE_LFS_ILO_CAL_RDATA)
write_dta(LFS_ILO_CAL, path = FILE_LFS_ILO_CAL_DTA_EXPORT)
```

### Extraits importants insérés (444X_1D)

Même format d'extraits pour le design `444X_1D` — patterns identiques, seul `xnum` change (ici 444) et la granularité des groupes d'âge/région/milieu diffère.

— Extrait de `02_Prepare_input_sample_data_for_regenesees_444X_1D.R`

```r
# initialisation : ajouter xnum colonnes X (toutes à 0)
tmpSD <- cbind(tmpSD, data.frame(matrix(0, nrow = nrow(tmpSD), ncol = xnum, byrow = FALSE)))
list_of_X  <- paste0("X", seq_len(xnum))
# assignations d'exemple (pattern répété jusqu'à X444)
tmpSD$X1[ tmpSD$ageannee >= 0 & tmpSD$ageannee <= 2 & tmpSD$milieu == 1 ] <- 1
tmpSD$X2[ tmpSD$ageannee >= 3 & tmpSD$ageannee <= 4 & tmpSD$milieu == 1 ] <- 1
# ...
```

— Extrait de `03_Prepare_input_pop_figures_for_regenesees_444X_1D.R`

```r
tmpKT <- cbind(tmpKT, data.frame(matrix(0, nrow = nrow(tmpKT), ncol = xnum, byrow = FALSE)))
tmpKT$X1[ tmpKT$region == "NATIONAL" & tmpKT$groupe_age == "0_2" & tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ] <- tmpKT$Nombre[ ... ]
# ...
list_of_X <- paste0("X", seq_len(xnum))
```

— Extrait de `04c_Run_Quarterly_Calibration_with_Regenesees_444X_1D.R` (calibration)

```r
load(FILE_LFS_SAMPLE_DATA_RDATA)
load(FILE_LFS_KNOWN_TOTALS_RDATA)
design_lfs <- e.svydesign(data = sample_data, ids = ~ PSUKEY + HHKEY, strata = ~ STRATAKEY, weights = ~ d_weights)
source(R_SCRIPT_NEW_FUNCTIONS_FOR_X_CONSTRAINS)
constrains_x <- constraints_model(xnum)
poptemplate  <- pop.template(data = known_totals, calmodel = constrains_x, partition = ~ DOMAIN)
popdataframe <- fill.template(universe = known_totals, template = poptemplate, mem.frac = 5)
calib_lfs <- e.calibrate(design = design_lfs, df.population = popdataframe, calmodel = constrains_x, partition = ~ DOMAIN, calfun = "logit")
final_weights <- weights(calib_lfs)
```

— Extrait de `05_Attach_final_weights_to_full_sample_data_444X_1D.R`

```r
load(FILE_LFS_ILO_DER_RDATA)
load(FILE_LFS_CALIBRATION_FINAL_WEIGHTS_RDATA)
tmp_FINAL_WEIGHTS <- LFS_CALIBRATION_FINAL_WEIGHTS[, c("INDKEY", "FINAL_CORR_FACTOR", "FINAL_WEIGHT")]
LFS_ILO_CAL <- merge(LFS_ILO_DER, tmp_FINAL_WEIGHTS, by = "INDKEY", all.x = TRUE)
save(LFS_ILO_CAL, file = FILE_LFS_ILO_CAL_RDATA)
write_dta(LFS_ILO_CAL, path = FILE_LFS_ILO_CAL_DTA_EXPORT)
```

---


  if (!exists("apply_T4_2024_correction", mode = "function")) {
    if (file.exists(nom_fichier)) {
      message("Chargement du script de correction : ", nom_fichier)
      source(nom_fichier)
    } else {
      warning("Le fichier de correction '", nom_fichier, "' est introuvable.")
      return(df)
    }
  }

  if (exists("apply_T4_2024_correction", mode = "function")) {
    message("Application de la correction pour le trimestre : ", trimestre)
    return(df %>% apply_T4_2024_correction())
  } else {
    warning("La fonction correction_reaffectation_menage() n'est pas disponible même après chargement.")
    return(df)
  }
}

normalize_column_names  <- function(df) {
  names(df) <- names(df) %>%
    tolower() %>%
    gsub("__", "_", .)
  return(df)
}

get_quarter_phase <- function(date_ref) {
  date_ref <- as.Date(date_ref)
  year <- lubridate::year(date_ref)
  month <- lubridate::month(date_ref)
  quarter <- ceiling(month / 3)
  phase <- case_when(
    year == 2024 & quarter == 2                     ~ 1,
    (year == 2024 & quarter == 3) |  (year == 2024 & quarter == 4) |
      (year == 2025 & quarter == 1)                 ~ 2,
    year == 2025 & quarter == 2                     ~ 3,
    (year > 2025) |
      (year == 2025 & quarter %in% c(3, 4))         ~ 4,
    TRUE                                            ~ NA_integer_
  )
  return(phase)
}
```
- Entrées :
  - `data/03_Processed/RP_2021/nb_men_indivs_ZD.dta` (effectifs RP par ZD)
  - fichiers ménage/individu du trimestre courant (`data/03_Processed/Menage/<TARGET_QUARTER>`, `data/03_Processed/Individu/<TARGET_QUARTER>`)
  - fichiers denombrement nettoyés (sourced via `scripts/02_base_weights/4_construct_denombrement.r`)
  - éventuellement `data/02_Cleaned/Denombrement_update/*.dta` pour mises à jour
- Sorties :
  - `data/04_weights/Menage/<TARGET_QUARTER>/weights_columns_<TARGET_QUARTER>.dta` (final_data écrit en fin de script)
- Packages utilisés : dplyr, tidyr, readr, haven, readxl, labelled, lubridate, stringr, rlang
- Étapes principales :
  1. Charger RP et fichiers ménage/individu.
  2. Calculer comptages ménage / individu par segment et ZD (nb_mens_enq, nb_indivs_enq, nb_indivs_enq_elig).
  3. Joindre les effectifs RP par ZD et les poids régionaux.
  4. Appliquer éventuelles mises à jour (Denombrement_update) et corrections trimestrielles via `appliquer_correction_trimestre()`.
  5. Calculer variables dérivées (nb_indivs_milieu, quarter_phase, labels d'incohérences) et sauvegarder.

### inc_probs_functions.R

- Chemin : `scripts/02_base_weights/inc_probs_functions.R`
- Rôle : utilitaires purs pour calculer des probabilités d'inclusion et le nombre de ZD à prendre en compte selon la chronologie.
 - Fonctions (extraits du script) :

```r
quarters_since_q2_2024 <- function(reference_date = Sys.Date()) {
  start_quarter <- as.Date("2024-04-01")
  months_diff <- as.numeric(difftime(reference_date, start_quarter, units = "days")) %/% 30.44
  quarters_passed <- floor(months_diff / 3)
  return(quarters_passed + 1)
}

calc_nb_zdc <- function(region, reference_date = Sys.Date()) {
  quarter_number <- quarters_since_q2_2024(reference_date)
  if (toupper(region) == "ABIDJAN") {
    return(13 * quarter_number)
  } else {
    return(7 * quarter_number)
  }
}

calc_proba_inclusion_zd <- function(region, nb_indiv_zd, nb_indiv_strat, nb_zd_strat) {
  if (region == "ABIDJAN") {
    proba <- 104 * (nb_indiv_zd / nb_indiv_strat) * (nb_zd_strat / 104)
  } else {
    proba <- 56 * (nb_indiv_zd / nb_indiv_strat) * (nb_zd_strat / 56)
  }
  return(proba)
}

calc_proba_inclusion_menage <- function(nb_enq_ti, nb_total_segment) {
  proba <- (nb_enq_ti / nb_total_segment) * (1 / 6)
  return(proba)
}
```
- Entrées/sorties : fonctions utilitaires, pas d'écriture directe de fichiers. Doit être sourcé par les scripts de préparation de colonnes.

### 2_calc_base_weights.R (et calc_base_weights_2.R)

- Chemin : `scripts/02_base_weights/2_calc_base_weights.R` (et variantes `calc_base_weights_2.R`)
- Rôle : transformer les effectifs et probabilités en poids de base (1 / pi), gérer les segments incohérents/exclus et produire `base_weights_<TARGET_QUARTER>.dta`.
- Fonctions nommées et logique observée :
 - Fonctions (extraits du script `2_calc_base_weights.R`) :

```r
count_seg_drop <- function(file_path, target_codes) {
  data <- read_dta(file_path)
  codes <- as.integer(data$incoherence_code)
  total_count <- sum(codes %in% target_codes, na.rm = TRUE)
  return(total_count)
}

get_seg_drop <- function(file_path, target_codes) {
  data <- read_dta(file_path)
  data <- data %>%
    mutate(incoherence_code = as.integer(incoherence_code))
  filtered_data <- data %>%
    filter(incoherence_code %in% target_codes)
  segment_info <- filtered_data %>%
    select(region, depart, souspref, ZD, segment) %>%
    distinct()
  return(segment_info)
}

compute_nb_zd_strat <- function(data) {
  nb_zd_summary <- data %>%
    group_by(region) %>%
    summarise(
      nb_zd_strat    = n(),
      nb_zd_strat_wr = sum(rgmen == 1, na.rm = TRUE),
      .groups = "drop"
    )
  data <- data %>%
    left_join(nb_zd_summary, by = "region") %>%
    mutate(
      nb_zd_strat    = ifelse(is.na(nb_zd_strat), 0, nb_zd_strat),
      nb_zd_strat_wr = ifelse(is.na(nb_zd_strat_wr), 0, nb_zd_strat_wr)
    ) %>%
    set_variable_labels(
      nb_zd_strat    = "Nombre de ZD présentes dans l'échantillon par région",
      nb_zd_strat_wr = "Nombre de ZD présentes dans l'échantillon par région (rgmen == 1)"
    )
  return(data)
}

compute_pi_zd <- function(region, nb_mens_seg, nb_men_reg, nb_zd_strat) {
  if (any(is.na(c(region, nb_mens_seg, nb_men_reg, nb_zd_strat))))
    return(NA_real_)
  multiplier <- ifelse(region == 10101, 104, 56)
  multiplier * ((nb_mens_seg * 6)/ nb_men_reg) * (nb_zd_strat / multiplier)
}

compute_pi_hh <- function(nb_mens_seg) {
  if (is.na(nb_mens_seg) || nb_mens_seg == 0)
    return(NA_real_)
  (NB_MENS_ENQ / nb_mens_seg) * (1 / 6)
}

compute_pi_HH <- function(pi_zd, pi_hh) {
  ifelse(is.na(pi_zd) | is.na(pi_hh), NA_real_, pi_zd * pi_hh)
}

append_base_weights <- function(data, resurvey = TRUE) {
  required_cols <- c("region",  "nb_men_reg", 
                     "nb_zd_strat", "nb_mens_seg")
  if (resurvey) {
    required_cols <- c(required_cols, "proportion")
  }
  missing <- setdiff(required_cols, names(data))
  if (length(missing) > 0) {
    stop(paste("Missing required columns:", paste(missing, collapse = ", ")))
  }
  data <- data %>%
    mutate(
      pi_zd     = mapply(compute_pi_zd,region, nb_mens_seg, nb_men_reg, nb_zd_strat),
      pi_zd_wr  = mapply(compute_pi_zd, region, nb_mens_seg, nb_men_reg, nb_zd_strat_wr),
      pi_hh     = mapply(compute_pi_hh, nb_mens_seg),
      pi_HH     = compute_pi_HH(pi_zd, pi_hh),
      pi_HH_wr  = compute_pi_HH(pi_zd_wr, pi_hh),
      base_weight_HH    = ifelse(!is.na(pi_HH) & pi_HH != 0, 1 / pi_HH, NA_real_),
      base_weight_HH_WR = ifelse(!is.na(pi_HH_wr) & pi_HH_wr != 0, 1 / pi_HH_wr, NA_real_)
    )
  data <- data %>%
    set_variable_labels(
      pi_zd       = "Probabilité d'inclusion au niveau de la ZD",
      pi_zd_wr    = "Probabilité d'inclusion au niveau de la ZD (Trimestre en cours uniquement)",
      pi_hh       = "Probabilité d'inclusion du ménage dans le segment",
      pi_HH       = "Probabilité d'inclusion combinée ZD × HH",
      pi_HH_wr    = "Probabilité d'inclusion combinée ZD × HH (Trimestre en cours uniquement)",
      base_weight_HH = "Poids de base des ménages du segment",
      base_weight_HH_WR = "Poids de base des ménages du segment (Trimestre en cours uniquement)"
    )
  return(data)
}
```

  - Fonctions (extraits du script `calc_base_weights_2.R`, variante) :

```r
compute_pi_zd <- function(region, nb_indivs_zd, nb_indivs_reg, nb_zd_strat) {
  if (is.na(region) || is.na(nb_indivs_zd) || is.na(nb_indivs_reg) || is.na(nb_zd_strat)) return(NA_real_)
  if (nb_indivs_reg == 0) return(NA_real_)
  multiplier <- ifelse(region == 10101, 104, 56)
  pi_zd <- multiplier * (nb_indivs_zd / nb_indivs_reg) * (nb_zd_strat / multiplier)
  return(pi_zd)
}

compute_pi_zd_without_resurvey <- function(region, nb_indivs_zd, nb_indivs_reg) {
  if (is.na(region) || is.na(nb_indivs_zd) || is.na(nb_indivs_reg)) return(NA_real_)
  if (nb_indivs_reg == 0) return(NA_real_)
  multiplier <- ifelse(region == 10101, 104, 56)
  pi_zd <- multiplier * (nb_indivs_zd / nb_indivs_reg) / multiplier
  return(pi_zd)
}

compute_pi_men1 <- function(nb_mens_enq, nb_mens_seg) {
  if (is.na(nb_mens_enq) || is.na(nb_mens_seg) || nb_mens_seg == 0) return(NA_real_)
  return((nb_mens_enq / nb_mens_seg) * (1 / 6))
}

compute_pi_men2 <- function(proportion, nb_mens_enq, nb_mens_seg) {
  if (is.na(proportion) || is.na(nb_mens_enq) || is.na(nb_mens_seg) || nb_mens_seg == 0) return(NA_real_)
  return(proportion * (nb_mens_enq / nb_mens_seg) * (1 / 6))
}

compute_pi_final <- function(pi_zd, pi_hh) {
  ifelse(is.na(pi_zd) | is.na(pi_hh), NA, pi_zd * pi_hh)
}

append_base_weights <- function(data) {
  required_cols <- c("region", "depart", "souspref", "ZD", "segment",
                     "nb_indivs_zd", "nb_indivs_reg", "nb_zd_strat",
                     "nb_mens_seg")
  missing_cols <- setdiff(required_cols, colnames(data))
  if (length(missing_cols) > 0) {
    stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
  }
  data <- data %>%
    mutate(
      pi_zd = mapply(compute_pi_zd, region, nb_indivs_zd, nb_indivs_reg, nb_zd_strat),
      pi_zd_wr = mapply(compute_pi_zd_without_resurvey, region, nb_indivs_zd, nb_indivs_reg),
      pi_men1 = mapply(compute_pi_men1, nb_mens_enq, nb_mens_seg),
      pi_final_men1 = compute_pi_final(pi_zd, pi_men1),
      pi_final_men1_wr = compute_pi_final(pi_zd_wr, pi_men1),
      base_weight_men1 = ifelse(!is.na(pi_final_men1) & pi_final_men1 != 0, 1 / pi_final_men1, NA_real_),
      base_weight_men1_wr = ifelse(!is.na(pi_final_men1_wr) & pi_final_men1_wr != 0, 1 / pi_final_men1_wr, NA_real_)
    )
  return(data)
}
```
- Entrées : `weights_columns_<TARGET_QUARTER>.dta` (généré par `1_gen_weights_columns.R`).
- Sorties : `data/04_weights/<TARGET_QUARTER>/base_weights/base_weights_<TARGET_QUARTER>.dta` (et rapports QC, fichiers d'incohérence éventuellement mis à jour).
- Packages : dplyr, haven, labelled
- Étapes : lecture du tableau de colonnes, suppression des segments à exclure, contrôle qualité (check_duplicates), application de corrections trimestrielles (sourcing d'un script de correction), calcul des pi et des poids, écriture du fichier final.

### 3_indivs_weights.R

- Chemin : `scripts/02_base_weights/3_indivs_weights.R`
- Rôle : attacher les poids calculés (ménage et individu) aux fichiers microdata `menage` et `individu` et écrire les versions pondérées.
- Fonctions / routines observées :
  - Fonctions (extraits du script) :

```r
normalize_column_names <- function(df) {
  names(df) <- names(df) %>%
    tolower() %>%
    gsub("__", "_", .)
  df
}

clean_names <- function(df) {
  names(df) <- gsub("\\.", "_", names(df))
  df
}
```

  - Le script joint `weights_data` (base_weights) aux fichiers ménage/individu via clés de correspondance (hh2→region, hh3→depart, hh4→souspref, hh8→ZD), assigne `d_weights` et crée une version SR (poids pour trimestre en cours) puis écrit les fichiers.
- Entrées : `base_weights_<TARGET_QUARTER>.dta`, `data/03_Processed/Menage/<TARGET_QUARTER>/menage_*.dta`, `data/03_Processed/Individu/<TARGET_QUARTER>/individu_*.dta`.
- Sorties : fichiers `menage_<TARGET_QUARTER>.dta`, `individu_<TARGET_QUARTER>.dta`, `SR_individu_<TARGET_QUARTER>.dta` dans `data/04_weights/<TARGET_QUARTER>/base_weights/`.

### gen_weights_columns_2.R (variantes)

- Chemin : `scripts/02_base_weights/gen_weights_columns_2.R` (exemple de variante)
- Rôle : version alternative de `1_gen_weights_columns.R` (mêmes objectifs, différences de paramétrage/prefixes/gestion des chemins). Utilise `inc_probs_functions.R` via `source()` pour calculer `nb_zd_strat`.
- Observations : contient paramètres embarqués (`BASE_DIR`, `TARGET_QUARTER`) — utile comme script autonome pour tests ou backfills.

---

## Dossier: scripts/03_nonresponse/

Les scripts présents dans `scripts/03_nonresponse/` traitent l'ajustement des poids pour la non-réponse et la construction de matrices de suivi (follow-up) entre trimestres.

### 1_adjust_weights_non_response.R

- Chemin : `scripts/03_nonresponse/1_adjust_weights_non_response.R`
- Rôle du script
  - Ajuster les poids de base au niveau du segment pour tenir compte de la non-réponse des ménages. Calcule des facteurs d'ajustement et des poids ajustés/corrigés par région×milieu.

- Fonctions / blocs principaux
  - Fonction (extrait du script) :

```r
adjust_non_response_HH <- function(data, EXPECTED_HH_PER_SEG = 12, group_vars = c("region")) {
  
  if (!all(c("nb_mens_enq", "nb_mens_seg", "base_weight_HH") %in% names(data))) {
    stop("Missing one or more required columns: 'nb_mens_enq', 'nb_mens_seg', 'base_weight_HH'.")
  }
  
  data <- data %>%
    mutate(
      potentiel_de_collecte = case_when(
        is.na(nb_mens_seg) ~ NA_real_,
        nb_mens_seg < EXPECTED_HH_PER_SEG ~ nb_mens_seg,
        TRUE ~ EXPECTED_HH_PER_SEG
      ),
      nb_men_theo = EXPECTED_HH_PER_SEG
    ) %>%
    group_by(across(all_of(group_vars))) %>%
    mutate(
      potentiel_region_milieu = sum(potentiel_de_collecte, na.rm = TRUE),
      nb_mens_theo_region_milieu = sum(nb_men_theo, na.rm = TRUE),
      nb_mens_enq_region_milieu = sum(nb_mens_enq, na.rm = TRUE)
    ) %>%
    ungroup() %>%
    mutate(
      adjustment_factor_HH = case_when(
        is.na(nb_mens_enq) | nb_mens_enq == 0 ~ NA_real_,
        nb_mens_seg < EXPECTED_HH_PER_SEG ~ nb_mens_seg / nb_mens_enq,
        TRUE ~ EXPECTED_HH_PER_SEG / nb_mens_enq
      ),
      adjusted_weight_HH = base_weight_HH * adjustment_factor_HH,
      adjusted_weight_HH_WR = base_weight_HH_WR * adjustment_factor_HH,
      correction_factor_region_milieu = case_when(
        nb_mens_enq_region_milieu == 0 ~ NA_real_,
        TRUE ~ nb_mens_theo_region_milieu / nb_mens_enq_region_milieu
      ),
      corrected_weight_HH = base_weight_HH * correction_factor_region_milieu,
      corrected_weight_HH_WR = base_weight_HH_WR * correction_factor_region_milieu
    ) %>%
    set_variable_labels(
      potentiel_de_collecte = "Potentiel de collecte (segment)",
      potentiel_region_milieu = "Potentiel de collecte par région & milieu",
      nb_mens_enq_region_milieu = "Effectif interviewé par région & milieu",
      adjustment_factor_HH = "Facteur d'ajustement des non-réponses (ménages)",
      adjusted_weight_HH = "Poids de base ajusté des non-réponses (ménages)",
      adjusted_weight_HH_WR = "Poids de base ajusté des non-réponses (ménages) [Trimestre en cours]",
      correction_factor_region_milieu = "Facteur de correction (potentiel / effectif) par région & milieu",
      corrected_weight_HH = "Poids de base corrigé par région & milieu (ménages)",
      corrected_weight_HH_WR = "Poids de base corrigé par région & milieu (ménages) [Trimestre en cours]"
    )
  
  return(data)
}
```

- Jeux de données lus / écrits
  - Entrée/Sortie : `data/04_weights/<TARGET_QUARTER>/base_weights/base_weights_<TARGET_QUARTER>.dta`
  - Écrit aussi des versions mises à jour pour `menage` / `individu` selon le pipeline (paths définis dans le script)

- Dépendances (packages)
  - dplyr, haven, labelled, ggplot2, plotly, gridExtra

- Étapes de transformation
  1. Calculer `potentiel_de_collecte`, `nb_men_theo` et agrégats par région×milieu.
  2. Déterminer `adjustment_factor_HH` et `adjusted_weight_HH`.
  3. Calculer `correction_factor_region_milieu` puis `corrected_weight_HH`.
  4. Sauvegarder les poids ajustés.

### comp_followup_matrix.R

- Chemin : `scripts/03_nonresponse/comp_followup_matrix.R`
- Rôle du script
  - Construire une matrice de suivi (follow-up) qui montre, pour chaque ZD/segment, la proportion de resurveys provenant d'une première enquête précédente (jonction v1interviewkey → interview_key). Produit des matrices par couple (first_quarter, current_quarter).

- Fonctions / blocs principaux
  - Lecture du mapping `interview_key_mapping_*.dta` (dernier dossier `Tracking_ID`).
  - Calcul des totaux de premières interviews (`first_interviews`) et des resurveys, jonction pour lier resurveys à leur first_quarter, calcul de proportions.
  - Ajout d'entrées diagonales (self-links) et export du tableau final.

- Jeux de données lus / écrits
  - Entrée : `data/03_Processed/Tracking_ID/<latest>/interview_key_mapping_*.dta`
  - Sortie : `followup_matrix_<timestamp>.dta` dans le même dossier `Tracking_ID` (dernier sous-dossier)

- Dépendances (packages)
  - dplyr, readxl, writexl, fs, janitor, haven, stringr, tidyr

- Étapes de transformation
  1. Localiser le dernier sous-dossier `Tracking_ID` et charger le mapping.
  2. Séparer premières interviews et resurveys.
  3. Joindre resurveys à la table des premières interviews pour retrouver `first_quarter`.
  4. Calculer proportions (resurvey_count / first_total) et ajouter diagonale = 1.
  5. Sauvegarder la matrice de suivi.


## Remarques générales et suggestions

- Beaucoup de scripts reposent sur `source("config/1_config.r")` pour définir `BASE_DIR` et d'autres chemins ; vérifier que `config/1_config.r` est à jour et chargé correctement selon l'environnement de développement.
- Plusieurs scripts écrivent des fichiers avec timestamp ou dans des dossiers datés — utile pour historiser mais attention à la gestion de stockage et aux conventions de lecture ultérieure (scripts de lecture utilisent `which.max(file_info(...)$modification_time)` pour retrouver la version la plus récente).
- Suggestions d'améliorations peu risquées :
  - Centraliser les chemins et une liste des packages requis dans `config/1_config.r` (ou un `requirements.R`) pour faciliter l'installation.
  - Ajouter des en-têtes standard aux scripts (usage, entrées/sorties, paramètres) déjà présent mais à homogénéiser.
  - Pour les scripts de concaténation, prévoir un mode `dry-run` ou `verbose = TRUE/FALSE` pour tests.

---

## Fichiers analysés

Tous les fichiers analysés se trouvent dans `scripts/01_utils/`.


---

---

## Dossier: scripts/04_calibration/QUARTERLY_WEIGHTING — Trimestre choisi : T1_2025

Remarque : ci-dessous sont documentés les scripts utilisés pour la calibration trimestrielle (exemple choisi : T1 2025). Le répertoire contient plusieurs « designs » (ex. `312X_1D`, `444X_1D`, `180X_1D`) ; chaque design suit la même séquence d'étapes paramétrées.

Résumé global (T1 2025)

- Rôle général
  - Calculer les poids finaux par calibration (ReGenesees) en joignant données d'échantillon et totaux connus (population) puis attacher les poids finaux aux microdonnées.

- Designs présents pour T1 2025
  - `312X_1D`, `444X_1D`, `180X_1D` (chaque dossier contient les étapes 01..05 et un `00_Master_Calibration_*`)

- Dépendances (packages récurrents)
  - ReGenesees (calibration et calcul d'erreurs), dplyr, readxl, writexl, haven, expss, summarytools, rstudioapi, writexl, excel.link

- Entrées typiques
  - Données d'échantillon dérivées : `data/05_DERIVED_VARIABLES/<year>/T<q>/...` (fichiers `_DER`)
  - Estimations de population / totaux connus : `data/06_POPULATION_ESTIMATES/<year>/T<q>/...` (CSV/XLSX/DTA)
  - Poids de base et jeux d'entrée : `data/04_weights/<TARGET_QUARTER>/base_weights/individu_<TARGET_QUARTER>.dta` (ou SR version)

- Sorties typiques
  - Objets R sauvegardés (.RData) contenant les tableaux dérivés et le DER complet
  - Fichiers Excel/CSV avec tableaux de totaux et diagnostics
  - Poids finaux attachés aux fichiers microdata (scripts `05_Attach_final_weights_to_full_sample_data_*.R`)

- Séquence de scripts (pattern pour chaque design)
  1. `01_Upload_Sample_Data_and_Known_Totals_in_R_*` — Charger les DER et les totaux officiels, vérifier et sauvegarder objets R.
  2. `02_Prepare_input_sample_data_for_regenesees_*` — Construire les variables d'échantillon nécessaires, formater et nettoyer l'échantillon pour Regenesees.
  3. `03_Prepare_input_pop_figures_for_regenesees_*` — Construire les vecteurs X (contraintes) à partir des totaux populationnels (national / région / milieu / sexe / groupes d'âge selon le design).
  4. `04c_Run_Quarterly_Calibration_with_Regenesees_*` (et variantes `04f_XFormats_*`) — Lancer ReGenesees pour résoudre la calibration (paramètres X, options), calculer poids finaux, CVs et DEFFs, et produire diagnostics.
  5. `05_Attach_final_weights_to_full_sample_data_*` — Joindre les poids finaux aux microdonnées et sauvegarder le DER pondéré.
  6. `00_Master_Calibration_*` — Script maître paramétré qui orchestre les étapes ci-dessus, documente les chemins et paramètres, et fournit des instructions d'exécution.

- Extrait des éléments observés dans les `00_Master_Calibration_*` (312X/444X/180X T1 2025)
  - Fort commentaire et documentation (auteur, version, chemins attendus).
  - Paramétrage de `TARGET_QUARTER` via `parse_target_quarter()` et `source("config/1_config.r")`.
  - Déclaration de `xnum`, `setx`, `pathx` pour définir le nombre de contraintes et suffixes de fichiers.
  - Définition des chemins des entrées (`data/05_DERIVED_VARIABLES`, `data/06_POPULATION_ESTIMATES`) et des sorties.
  - Activation des packages (`ReGenesees`, `dplyr`, `haven`, `expss`, `readxl`, `writexl`, ...).

- Observations pratiques / recommandations
  - Ces scripts sont fortement parameterized ; assurez-vous que `TARGET_QUARTER` est défini dans l'environnement (ou via `config/1_config.r`).
  - ReGenesees doit être installé (GitHub) et la version compatible avec les scripts.
  - Les scripts supposent la présence des dossiers de population/DER ; validez les chemins avant d'exécuter.
  - Les sorties peuvent être volumineuses (RData, tableaux Excel) — prévoir espace disque.

### household_calibration.R (script central de calage pour poids HH)

- Chemin : `scripts/04_calibration/household_calibration.R`
- Rôle : préparer et appliquer le calage (calibration) au niveau ménage en utilisant des totaux populationnels (structures de ménages urbain/rural) et en calculant des facteurs de calage (margin factors) par région × milieu ; sauvegarde les poids ajustés dans le dossier `data/04_weights/<TARGET_QUARTER>/base_weights/`.
- Fonctions nommées observées :
  - Fonctions (extraits du script) :

```r
aggregate_base_weights <- function(data) {
  weights_by_region <- data %>%
    group_by(region) %>%
    summarise(
      base_weight_HH_reg    = sum(base_weight_HH * nb_mens_enq, na.rm = TRUE),
      base_weight_HH_WR_reg = sum(base_weight_HH_WR * nb_mens_enq, na.rm = TRUE),
      .groups = "drop"
    )
  weights_by_milieu <- data %>%
    group_by(region, milieu) %>%
    summarise(
      base_weight_HH_milieu    = sum(base_weight_HH * nb_mens_enq, na.rm = TRUE),
      base_weight_HH_WR_milieu = sum(base_weight_HH_WR * nb_mens_enq, na.rm = TRUE),
      .groups = "drop"
    )
  data <- data %>%
    left_join(weights_by_region, by = "region") %>%
    left_join(weights_by_milieu, by = c("region", "milieu"))
  return(data)
}

compute_margin_factors <- function(data) {
  data <- data %>%
    mutate(margin_factor_HH = case_when(
      milieu == 1 ~ Urbain_Pop_Menage * base_weight_HH_reg / base_weight_HH_milieu,
      milieu == 2 ~ Rural_Pop_Menage  * base_weight_HH_reg / base_weight_HH_milieu,
      TRUE ~ NA_real_
    ),
    margin_factor_HH_WR = case_when(
      milieu == 1 ~ Urbain_Pop_Menage * base_weight_HH_WR_reg / base_weight_HH_WR_milieu,
      milieu == 2 ~ Rural_Pop_Menage  * base_weight_HH_WR_reg / base_weight_HH_WR_milieu,
      TRUE ~ NA_real_
    )
    ) %>%
    set_variable_labels(
      margin_factor_HH    = "Facteur de calage des poids HH",
      margin_factor_HH_WR = "Facteur de calage des poids HH (Trimestre en cours)"
    )
}
```
- Entrées :
  - `data/04_weights/<TARGET_QUARTER>/base_weights/base_weights_<TARGET_QUARTER>.dta` (poids de base)
  - `data/04_weights/struct_menage_rp<YY>.xlsx` (marges urbain/rural selon année)
- Sorties : écriture du dataset `base_weights_<TARGET_QUARTER>.dta` mis à jour avec variables de marge et factors; aperçu via `glimpse()` avant sauvegarde.
- Packages : dplyr, haven, labelled, readxl
- Étapes :
  1. Charger `base_weights` et les marges de population par région (Urbain/Rural).
  2. Calculer agrégats de poids par région et par (region,milieu).
  3. Fusionner les agrégats et calculer `margin_factor_HH` et `margin_factor_HH_WR` selon le milieu.
  4. Sauvegarder le jeu de poids mis à jour.


---

## Note finale

J'ai documenté les scripts `scripts/01_utils/` et ajouté les sections pour `scripts/03_nonresponse/`. J'ai aussi extrait et résumé la structure de calibration pour le trimestre T1 2025 (dossiers `312X_1D`, `444X_1D`, `180X_1D`) — si vous voulez, je peux maintenant :

- Générer un tableau récapitulatif (CSV/MD) listant tous les scripts R du projet avec colonnes (chemin, rôle court, packages, entrées, sorties).
- Extraire automatiquement les en-têtes (premières ~30 lignes) de tous les scripts `QUARTERLY_WEIGHTING/2025/T1/*` et les sauvegarder dans un dossier `docs/` pour consultation.

---

Fin du document.

---

## Fonctions par script (récapitulatif)

Ci-dessous se trouve une carte claire des fonctions nommées détectées dans les scripts R analysés, classées par dossier et fichier. Pour chaque fonction : nom, arguments principaux (si détectés) et rôle bref en français.

### scripts/01_utils/

- 1_concat_denomb.R / concat_denomb.R
  - Fonctions nommées : aucune (utilisation de fonctions anonymes via lapply).  
  - Rôle : lecture des `.dta`, nettoyage (`janitor::clean_names`), harmonisation des colonnes (union + ajout de colonnes manquantes) et concaténation verticale.

- 2_denomb_updates.R
  - Fonctions (extraits du script) :

```r
extract_quarter <- function(path) {
  folder <- str_match(path, "Denombrement_update/(T\\d_\\d{4})")[,2]
  return(folder)
}

read_and_tag_file <- function(file_path) {
  quarter <- extract_quarter(file_path)
  df <- read_excel(file_path)
  
  if (!"IDSeg" %in% names(df)) {
    skipped_files <<- c(skipped_files, file_path)
    return(NULL)
  }
  
  df <- df %>%
    mutate(
      HH2          = as.character(HH2),
      HH3          = as.character(HH3),
      HH4          = as.character(HH4),
      HH8          = as.character(HH8),
      IDSeg        = as.numeric(zap_labels(IDSeg)),
      code_ilot    = as.numeric(zap_labels(code_ilot)),
      ilot__id     = as.numeric(zap_labels(ilot__id)),
      batiment__id = as.numeric(zap_labels(batiment__id)),
      menage__id   = as.numeric(zap_labels(menage__id)),
      adresse_menage = as.character(adresse_menage)
    ) %>%
    select(
      interview_key = interview__key,
      region        = HH2,
      depart        = HH3,
      souspref      = HH4,
      ZD            = HH8,
      segment       = IDSeg,
      code_ilot,
      ilot_id       = ilot__id,
      batiment_id   = batiment__id,
      menage_id     = menage__id,
      adresse_menage
    ) %>%
    mutate(quarter = quarter)
  
  return(df)
}

normalize_column_names <- function(df) {
  names(df) <- tolower(gsub("__", "_", names(df)))
  return(df)
}

get_menage_data <- function(q) {
  cleaned_path <- file.path(CLEANED_BASE_DIR, q)
  
  menage_file   <- list.files(cleaned_path, pattern = "^menage.*\\.dta$", full.names = TRUE)[1]
  batiment_file <- list.files(cleaned_path, pattern = "^batiment.*\\.dta$", full.names = TRUE)[1]
  ilot_file     <- list.files(cleaned_path, pattern = "^ilot.*\\.dta$", full.names = TRUE)[1]
  enem_file     <- list.files(cleaned_path, pattern = "^ENEM.*\\.dta$", full.names = TRUE)[1]
  
  if (any(is.na(c(menage_file, batiment_file, ilot_file, enem_file)))) {
    message(paste("Skipping quarter", q, ": One or more files are missing"))
    return(NULL)
  }
  
  menage   <- read_dta(menage_file)   %>% normalize_column_names()
  batiment <- read_dta(batiment_file) %>% normalize_column_names()
  ilot     <- read_dta(ilot_file)     %>% normalize_column_names()
  enem     <- read_dta(enem_file)     %>% normalize_column_names()
  
  menage_bat <- menage %>%
    left_join(batiment, by = c("interview_key", "ilot_id", "batiment_id")) %>%
    filter(!is.na(adresse))
  
  menage_bat <- menage_bat %>%
    left_join(ilot, by = c("interview_key", "ilot_id"))
  
  enem_select <- enem %>%
    select(interview_key, region = hh2, depart = hh3, souspref = hh4, ZD = hh8) %>%
    mutate(ZD = as.character(ZD))
  
  menage_full <- menage_bat %>%
    left_join(enem_select, by = "interview_key") %>%
    select(interview_key, region, depart, souspref, ZD,
           code_ilot, ilot_id, batiment_id, menage_id, adresse_menage, taille) %>%
    mutate(quarter = q, code_ilot = as.numeric(zap_labels(code_ilot)))
  
  return(menage_full)
}
```

- 3_assign_firstTrim_interview.R
  - Fonctions nommées : aucune détectée. Le script implémente une boucle/transform logique pour ajouter `firsttriminterview` en s'appuyant sur le mapping `interview_key`.

- 4_gen_interviewkey_map.R
  - Fonctions nommées : aucune détectée (le script orchestre la lecture/concaténation chronologique des fichiers `menage` pour construire le mapping).  

- update_interviewkey_map.R
  - Fonctions nommées : aucune détectée (script procédural pour détecter nouveaux trimestres, fusionner mapping et sauvegarder).  

- harm_rp_ene.R
  - Fonctions nommées : aucune détectée (pipeline d'harmonisation RP → ENE).  

- extract_rp2021_vars.R
  - Fonctions nommées : aucune détectée (script utilitaire pour extraire variables depuis un `.sav`).  

- calc_nb_men_indiv_ZD.R
  - Fonctions nommées : aucune détectée (script d'agrégation par ZD pour RP_2021).

### scripts/02_base_weights/

- 1_gen_weights_columns.R
  - Fonctions détectées / usuelles :  
    - `appliquer_correction_trimestre(...)` (nom approximatif) : applique des corrections spécifiques au trimestre sur les colonnes de pondération.  
    - `get_quarter_phase(...)` / `normalize_column_names(...)` : utilitaires de parsing et normalisation (si présents dans le script).
  - Rôle : préparation des colonnes nécessaires au calcul des poids (harmonisation, agrégations, corrections trimestrielles).

- inc_probs_functions.R
  - `quarters_since_q2_2024(date_or_quarter)` : calcule le nombre de trimestres écoulés depuis Q2 2024 (utilisé pour ajustements temporels).  
  - `calc_nb_zdc(...)` : calcule les effectifs ZD corrigés selon règles métier.  
  - `calc_proba_inclusion_zd(...)` : retourne la probabilité d'inclusion au niveau ZD.  
  - `calc_proba_inclusion_menage(...)` : probabilité d'inclusion au niveau ménage (en s'appuyant sur pi_zd et autres paramètres).

- 2_calc_base_weights.R
  - Fonctions détectées :  
    - `compute_nb_zd_strat(...)` / `compute_pi_zd(...)` : calculs et agrégations par strate/ZD pour obtenir probabilités d'inclusion.  
    - `compute_pi_hh(...)` / `compute_pi_HH(...)` : probabilité d'inclusion au ménage (diverses variantes selon formulation).  
    - `append_base_weights(...)` : routine d'assemblage/étiquetage des poids calculés pour écriture.
  - Rôle : transformer probabilités en poids (1/pi), gérer segments exclus, contrôles qualité et étiquetage.

- 3_indivs_weights.R
  - Fonctions détectées :  
    - routines de jointure / mapping pour attacher `base_weight_HH` et `base_weight_individu` aux fichiers ménage/individu.  
  - Rôle : joindre les poids calculés aux micro-données et sauvegarder les fichiers finaux.

- gen_weights_columns_2.R (variantes)
  - Même nature que `1_gen_weights_columns.R` (fonctions et utilitaires similaires, parfois renommés pour corrections spécifiques).

### scripts/03_nonresponse/

- 1_adjust_weights_non_response.R
  - `adjust_non_response_HH(data, EXPECTED_HH_PER_SEG = 12, group_vars = c("region"))` : ajuste les poids à l'échelle ménage/segment pour compenser la non-réponse, calcule `potentiel_de_collecte`, `nb_men_theo`, `adjustment_factor_HH`, `adjusted_weight_HH`, `corrected_weight_HH`, etc.

- comp_followup_matrix.R
  - Fonctions détectées : aucune nommée ; le script construit la matrice de suivi (follow-up) via transformations `dplyr`/`tidyr` (jonctions entre `first_interviews` et `resurveys`).

### scripts/04_calibration/

- household_calibration.R
  - `aggregate_base_weights(data)` : agrège les poids de base par région et par milieu (somme pondérée par nb_mens_enq) et prépare les totaux pour calage.
  - `compute_margin_factors(data)` : calcule les facteurs de calage (margin factors) par milieu en utilisant les marges populationnelles (Urbain/Rural) et les agrégats de poids.

---

Si vous voulez que je :

- remplace les paragraphes existants dans chaque section détaillée du document (par exemple sous `## 1_concat_denomb.R`) par ces descriptions de fonctions précises ; ou
- que j'extraie automatiquement le code complet des fonctions trouvées et les colle (en extrait) sous chaque section (utile pour relecture/QA),

dites-moi la préférence — je peux appliquer la mise à jour automatiquement.
