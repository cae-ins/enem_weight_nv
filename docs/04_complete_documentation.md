# Documentation Complète du Projet ENE_SURVEY_WEIGHTS

Ce document fournit une vue d'ensemble détaillée du fonctionnement du projet, des formules mathématiques utilisées pour la pondération, et une explication des fonctions principales.

## 1. Introduction et Objectif

Le projet **ENE_SURVEY_WEIGHTS** a pour but de calculer les pondérations (poids) pour l'Enquête Nationale sur l'Emploi (ENE). L'objectif est de permettre l'extrapolation des résultats de l'échantillon à l'ensemble de la population cible.

Le processus suit une approche standard de sondage :

1.  **Poids de base** : Calculés à partir des probabilités d'inclusion (plan de sondage).
2.  **Ajustement pour non-réponse** : Correction des poids pour compenser les ménages n'ayant pas répondu.
3.  **Calibration (Calage)** : Ajustement final sur des totaux de population connus (recensement/projections) pour assurer la cohérence sociodémographique.

## 2. Mode de Fonctionnement Global

Le projet est organisé en "pipeline" de traitement de données, où chaque étape lit des données d'un dossier, effectue des transformations, et sauvegarde le résultat dans le dossier suivant.

### Structure des Données (`data/`)

- `01_raw/` : Données brutes (fichiers Stata `.dta` issus de la collecte).
- `02_cleaned/` : Données nettoyées et harmonisées.
- `03_processed/` : Données transformées, prêtes pour le calcul (ajout de variables dérivées).
- `04_weights/` : Fichiers contenant les poids calculés à différentes étapes (base, ajustés, calibrés).

### Flux de Traitement (`scripts/`)

1.  **01_utils/** : Scripts utilitaires pour la concaténation et la préparation des fichiers de dénombrement et de ménages.
2.  **02_base_weights/** : Calcul des probabilités d'inclusion et des poids initiaux.
3.  **03_nonresponse/** : Calcul des facteurs d'ajustement pour la non-réponse totale.
4.  **04_calibration/** : Procédure de calage (calibration) utilisant le package `ReGenesees`.
5.  **05_quality_control/** : Vérification de la cohérence des poids et des données.

---

## 3. Formules et Méthodologie de Pondération

### 3.1. Probabilités d'Inclusion (Poids de Base)

Les poids de base sont l'inverse des probabilités d'inclusion. Le plan de sondage est à plusieurs degrés (ZD, Segment, Ménage).

#### A. Probabilité d'inclusion de la Zone de Dénombrement (ZD) - $\pi_{ZD}$

La probabilité qu'une ZD soit sélectionnée dépend de la région (Abidjan vs autres) et de sa taille relative en nombre de ménages dans la strate.

**Formule :**

$$
\pi_{ZD} = k \times \frac{N_{ménages\_ZD}}{N_{ménages\_strat}} \times \frac{N_{ZD\_strat}}{k} = \frac{N_{ménages\_ZD}}{N_{ménages\_strat}} \times N_{ZD\_strat}
$$

Avec $N_{ménages\_ZD} \approx N_{ménages\_segment} \times 6$.

_Note : Dans le code, la formule est implémentée avec un multiplicateur $k$ qui s'annule mathématiquement mais explicite le tirage._

- **Si Région = ABIDJAN** ($k=104$) :
  $$ \pi*{ZD} = 104 \times \frac{N*{ménages_ZD}}{N*{ménages_strat}} \times \frac{N*{ZD_strat}}{104} $$
- **Si Autre Région** ($k=56$) :
  $$ \pi*{ZD} = 56 \times \frac{N*{ménages_ZD}}{N*{ménages_strat}} \times \frac{N*{ZD_strat}}{56} $$

**Variables :**

- $N_{ménages\_ZD}$ : Nombre estimé de ménages dans la ZD (calculé comme $N_{ménages\_segment} \times 6$).
- $N_{ménages\_strat}$ (`nb_men_reg`) : Nombre total de ménages dans la strate (région).
- $N_{ZD\_strat}$ (`nb_zd_strat`) : Nombre total de ZD dans la strate.

#### B. Probabilité d'inclusion du Ménage - $\pi_{Ménage}$

La probabilité qu'un ménage soit sélectionné dans un segment donné.

> **Note importante sur la structure ZD/Segment :**
> Dans ce plan de sondage, la ZD est découpée en segments (généralement 6). Par hypothèse, le nombre total de ménages dans la ZD est estimé comme étant **6 fois le nombre de ménages du segment** :
> $$ N*{ménages_ZD} \approx N*{ménages_segment} \times 6 $$

**Formule :**

$$
\pi_{Ménage|ZD} = \frac{n_{cible}}{N_{denomb\_segment}} \times \frac{1}{6}
$$

**Variables :**

- $n_{cible}$ (`NB_MENS_ENQ = 12`) : Nombre de ménages **cible** à enquêter par segment — constante de design, indépendante des réalisations effectives.
- $N_{denomb\_segment}$ (`nb_mens_seg`) : Nombre total de ménages dénombrés dans le segment.
- $1/6$ : Probabilité de sélection du segment parmi les 6 segments de la ZD.

> **Note** : La probabilité d'inclusion utilise le nombre de ménages prévu par le plan de sondage (12), et non le nombre réellement enquêté. L'écart entre les deux est traité par l'ajustement pour non-réponse (`03_nonresponse`).

#### C. Poids de Base Ménage ($w_{base}$)

Le poids de base est l'inverse de la probabilité d'inclusion conjointe.

$$
\pi_{Global} = \pi_{ZD} \times \pi_{Ménage|ZD}
$$

$$
w_{base} = \frac{1}{\pi_{Global}}
$$

---

### 3.2. Ajustement pour Non-Réponse

L'objectif est de compenser la perte d'information due aux ménages non-répondants en augmentant le poids des ménages répondants du même segment ou de la même strate (Région x Milieu).

**Formule du Facteur d'Ajustement ($f_{NR}$) :**

Le code calcule d'abord un "potentiel de collecte" théorique, puis compare l'effectif théorique à l'effectif réellement enquêté.

$$
f_{NR} = \frac{\text{Nombre de ménages théoriques (attendus)}}{\text{Nombre de ménages enquêtés (répondants)}}
$$

Ce facteur est calculé par groupe d'ajustement (généralement Région x Milieu).

**Poids Ajusté :**

$$
w_{ajusté} = w_{base} \times f_{NR}
$$

---

### 3.3. Calibration (Calage)

Le calage assure que les estimations pondérées sont cohérentes avec des totaux de population connus issus des projections du RGPH 2021. La méthode retenue est l'estimateur par régression généralisée (**GREG**), implémenté via le package R `ReGenesees` (Zardetto, 2015), avec une fonction de distance **logit** contraignant les facteurs de correction dans des bornes prédéfinies.

**Principe :**

Trouver de nouveaux poids $w_{final}$ proches des poids initiaux $w^{(1)}$ tels que :

$$\sum_{i \in \mathcal{S}} w_{final,i} \cdot \mathbf{x}_i = \mathbf{T}_X$$

où $\mathbf{x}_i$ est le vecteur des variables auxiliaires de l'individu $i$ et $\mathbf{T}_X$ le vecteur des totaux de population correspondants. Le poids final est :

$$w_{final,i} = g_i \times w^{(1)}_i$$

où $g_i$ (`FINAL_CORR_FACTOR`) est le facteur de correction logit, contraint dans un intervalle $[l, u]$.

**Schéma de référence — 180X_1D (180 contraintes, 1 domaine) :**

- **Niveau national ($X_1$–$X_{48}$)** : 48 contraintes = sexe (2) × milieu (2) × 12 groupes d'âge quinquennaux.
- **Niveau régional ($X_{49}$–$X_{180}$)** : 132 contraintes = 33 régions × 4 (sexe × 2 groupes d'âge : 0–14 ans / 15 ans et plus).

**Plan de sondage déclaré dans ReGenesees :**

- `ids = ~ PSUKEY + HHKEY` (deux degrés : ZD puis ménage)
- `strata = ~ STRATAKEY`
- `weights = ~ d_weights`

**Workflow en 7 étapes :**

1. Chargement des données d'enquête et des totaux de population ;
2. Construction des variables indicatrices $X_1$–$X_{180}$ dans l'échantillon ;
3. Construction des totaux de population correspondants ;
4. Création de l'objet de plan de sondage ReGenesees ;
5. Exécution du calage logit avec bornes sur $g_i$ ;
6. Attachement de `FINAL_WEIGHT` au fichier individuel complet (export `.dta`) ;
7. Calcul des indicateurs de précision post-calage (CV par domaine).

### 3.4. Pondération Annuelle

Le poids annuel est obtenu par **l'approche directe** : les fichiers trimestriels calibrés sont empilés (*bind_rows*) et chaque poids est divisé par $K$, le nombre de trimestres disponibles pour l'année.

**Formule :**

$$
w_{annuel,i} = \frac{w_{final,i}}{K}
$$

**Variables :**

- $w_{final,i}$ (`FINAL_WEIGHT`) : poids calibré de l'individu $i$ au trimestre $t$.
- $K$ : nombre de trimestres disponibles pour l'année ($1 \leq K \leq 4$, détecté automatiquement).

Cette approche correspond à $\alpha_t = 1/K$ dans la formule générale de combinaison des estimateurs trimestriels. L'estimateur annuel d'un indicateur $\theta$ est alors :

$$
\hat{\theta}^{annuel} = \frac{1}{K} \sum_{t=1}^{K} \hat{\theta}_t
$$

Le fichier de sortie (`LFS_WEIGHTS_{annee}.dta`) est produit par `scripts/08_yearly_weights/ponderation_annuelle.r`.

### 3.5. Pondération Longitudinale

La pondération longitudinale est utilisée pour l'estimation d'indicateurs de transition (changement de statut dans l'emploi entre deux trimestres). Elle est construite à partir des **poids calibrés transversaux** $w_{final}$, corrigés de l'attrition par un facteur estimé via un modèle logistique :

$$
w_{long,i} = w_{final,i} \times \frac{1}{\hat{p}_{attrition,i}}
$$

où $\hat{p}_{attrition,i}$ est la probabilité estimée qu'un individu soit présent à la ré-interrogation, modélisée par régression logistique sur des variables observables (caractéristiques sociodémographiques au trimestre de première interrogation). Cette construction garantit que le poids longitudinal hérite de la cohérence démographique assurée par la calibration transversale.

---

## 4. Explication des Fonctions Principales

Voici les fonctions clés définies dans les scripts, principalement dans `scripts/02_base_weights/inc_probs_functions.R` et les scripts de calcul.

### `compute_pi_zd(region, nb_mens_seg, nb_men_reg, nb_zd_strat)`

- **Fichier** : `scripts/02_base_weights/2_calc_base_weights.R`
- **But** : Calcule $\pi_{ZD}$.
- **Logique** : Applique la formule conditionnelle selon si la région est "ABIDJAN" ou non. Utilise le nombre de ménages estimé de la ZD ($N_{ménages\_segment} \times 6$) et le nombre total de ménages de la strate.

### `compute_pi_hh(nb_mens_seg)`

- **Fichier** : `scripts/02_base_weights/2_calc_base_weights.R`
- **But** : Calcule $\pi_{Ménage|ZD}$.
- **Logique** : `(NB_MENS_ENQ / nb_mens_seg) * (1/6)` — utilise la **constante de design 12** (`NB_MENS_ENQ`) au numérateur, pas le nombre de ménages réellement enquêtés. L'écart entre 12 et le réel est traité par l'ajustement non-réponse.

### `quarters_since_q2_2024(reference_date)`

- **Fichier** : `inc_probs_functions.R`
- **But** : Détermine le numéro du trimestre séquentiel depuis le T2 2024 (début du panel).
- **Logique** : Calcule la différence en mois entre la date de référence et le 1er avril 2024, divisée par 3.

### `adjust_non_response_HH(data, ...)`

- **Fichier** : `scripts/03_nonresponse/1_adjust_weights_non_response.R`
- **But** : Calcule les facteurs d'ajustement pour la non-réponse.
- **Logique** :
  1.  Définit un `potentiel_de_collecte` (min entre nb ménages segment et cible théorique, ex: 12).
  2.  Agrège ce potentiel et le nombre réel d'enquêtés par `region`.
  3.  Calcule le ratio (Théorique / Réel) pour obtenir le facteur d'ajustement.
  4.  Multiplie le poids de base par ce facteur.

### `check_ene_data_quality(data_path)`

- **Fichier** : `scripts/05_quality_control/quality_control_weights.r`
- **But** : Vérifie l'unicité des clés primaires.
- **Logique** : Vérifie qu'il n'y a pas de doublons pour les combinaisons de clés (Region, Dept, SousPref, ZD, Segment, NumMen).

## 5. Résumé des Scripts par Dossier

| Dossier           | Script Principal                  | Description                                                 |
| :---------------- | :-------------------------------- | :---------------------------------------------------------- |
| `01_utils`        | `1_concat_denomb.R`               | Fusionne les fichiers de dénombrement bruts.                |
| `02_base_weights` | `1_gen_weights_columns.R`         | Prépare les variables (effectifs) pour le calcul des poids. |
| `02_base_weights` | `2_calc_base_weights.R`           | Applique les formules de probabilité d'inclusion.           |
| `03_nonresponse`  | `1_adjust_weights_non_response.R` | Calcule et applique l'ajustement NR.                        |
| `04_calibration`  | `run_calibration.R`               | Orchestre le calage avec ReGenesees (14 schémas, paramétrable via `SCHEMA_ID`). |
| `08_yearly_weights` | `ponderation_annuelle.r`        | Empile les fichiers trimestriels calibrés et divise les poids par $K$ (nombre de trimestres disponibles). |
