# Index du projet ENE_SURVEY_WEIGHTS

Ce document donne une vue d'ensemble de la structure du projet, les répertoires principaux et le rôle général de chacun. Il sert de point d'entrée pour les contributeurs et facilite la navigation dans le dépôt.

## Présentation générale

Le projet contient les données, scripts et rapports liés au calcul des pondérations d'enquêtes (weights), ainsi que la documentation et les livrables. La convention de nommage privilégie des dossiers numériques pour les étapes de traitement (`01_raw`, `02_cleaned`, ...). Les scripts sont regroupés par étape de traitement dans `scripts/`.

## Fichiers racine importants

- `README.md` : documentation générale du projet (usage, prérequis, contact).
- `notes_weights.txt` : notes et remarques rapides concernant les pondérations.
- `00_index.md` : (ce fichier) index et description de la structure du projet.

## Répertoires principaux

- `Applications ENEM/` : scripts et données spécifiques aux applications ENEM (sous-arborescences `DATA/`, `DOC/`, `PROG/`).

- `Base_men_ZD - T3-2024 _ T1-2025/` : bases de données et fichiers Stata (`.dta`, `.do`) relatifs aux périodes indiquées. Contient des versions et fichiers sources bruts.

- `Base_segmenter_Arist_T3_2025/` : dossiers pour le travail de segmentation (versions et outputs associés).

- `Base_T2_2025_31_07_2025/` : jeu de données et fichiers d'enquête pour le trimestre T2 2025 (fichiers `.dta`, `Questionnaire/` avec `ddi.xml`).

- `bulletin/` : modèles, scripts et ressources pour produire les bulletins (documents, templates LaTeX, QMD pour Quarto/R Markdown).

- `codification/` : règles et dossiers de codification (ex : `T2_2025/Emploi_codif/`), utilisés pour catégoriser ou recoder des variables.

- `config/` : fichiers de configuration et paramètres (ex : `1_config.r`, `credentials.json`). Contient les variables d'environnement et accès — attention aux informations sensibles : ne pas committer `credentials.json` si elle contient des secrets.

- `dashboard/` : code et ressources pour tableaux de bord (Dash, Shiny, Quarto, ou équivalent). Sous-dossiers pour différents tableaux de bord trimestriels ou de suivi.

- `data/` : arborescence organisée par étapes du pipeline :
  - `01_raw/` : données brutes importées (ne pas modifier les fichiers originaux).
  - `02_cleaned/` : données nettoyées et réconciliées.
  - `03_processed/` : jeux de données transformés prêts pour l'analyse.
  - `04_weights/` : fichiers de pondérations produits.
  - `05_DERIVED_VARIABLES/` : variables dérivées calculées à partir des sources.
  - `06_POPULATION_ESTIMATES/` : estimations de population utilisées pour calibration.
  - `07_QUARTERLY_WEIGHTING/` : artefacts spécifiques au processus trimestriel.
  - `08_STANDARD_ERRORS/` : fichiers et résultats pour erreurs standards.
  - `09_TOTAL_NON_RESPONSE/` : outputs relatifs à la non-réponse totale.
  - `XX_Intro_to_R_and_ReGenesees/` : matériel pédagogique, exemples et notes.

- `logs/` : journaux d'exécution et traces de traitement.

- `reports/` : rapports générés, analyses, notes méthodologiques, contrôles qualité, et outputs par thème (`DERIVED_VARIABLES/`, `POPULATION_ESTIMATES/`, `WEIGHTING/`, ...).

- `save_temp/` : fichiers temporaires ou sauvegardes locales (ne pas considérer comme source unique des données).

- `scripts/` : scripts organisés par étapes du pipeline :
  - `01_utils/` : fonctions utilitaires et helpers (ex : `1_concat_denomb.R`).
  - `02_base_weights/` : étapes de création des bases de pondération.
  - `03_nonresponse/` : traitements pour la non-réponse.
  - `04_calibration/` : scripts de calibration des poids.
  - `05_quality_control/` : contrôles qualité et diagnostics.
  - `06_monitoring/` : surveillance et rapports intermédiaires.
  - `07_correction_quarter/` : corrections spécifiques par trimestre.
  - `08_yearly_weights/` : traitements annuels.
  - `09_create_indicators/` : génération d'indicateurs à partir des jeux pondérés.

## Conventions et bonnes pratiques

- Conserver les données brutes dans `data/01_raw/` et travailler sur des copies dans `02_cleaned/` et `03_processed/`.
- Versionner les scripts et ne pas committer de fichiers contenant des credentials ou des données sensibles.
- Documenter chaque script avec un petit en-tête (objectif, entrée, sortie, auteur, date).
- Utiliser `logs/` pour conserver les traces d'exécution et pouvoir reproduire les traitements.

## Où commencer pour contribuer

1. Lire `README.md` pour les prérequis (versions R, packages, variables d'environnement).
2. Consulter `config/1_config.r` pour les chemins et paramètres locaux.
3. Pour travailler sur les pondérations : parcourir `scripts/02_base_weights/`, `03_nonresponse/` et `04_calibration/`.
4. Vérifier les jeux de données dans `data/` (respecter l'ordre `01_raw` → `02_cleaned` → `03_processed`).

## Remarques finales





