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
\pi_{Ménage|ZD} = \frac{N_{enq\_ti}}{N_{total\_segment}} \times \frac{1}{6}
$$

**Variables :**

- $N_{enq\_ti}$ (`nb_enq_ti`) : Nombre de ménages enquêtés dans le segment au trimestre $T_i$.
- $N_{total\_segment}$ (`nb_total_segment`) : Nombre total de ménages dans le segment (issu du dénombrement).
- $1/6$ : Probabilité de sélection du segment (correspondant au tirage d'un segment parmi 6).

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

Le calage assure que la somme des poids finaux correspond aux totaux de population connus (par exemple, total population par Région, Sexe, Tranche d'âge).

Le projet utilise la méthode **Logit** via le package R `ReGenesees`.

**Principe :**
Trouver de nouveaux poids $w_{final}$ proches des poids initiaux $w_{ajusté}$ tels que :
$$ \sum*{i \in \text{Echantillon}} w*{final, i} \times X*{i} = \text{Total}*{Population}(X) $$
où $X$ est un vecteur de variables auxiliaires (Sexe, Age, Région, Milieu).

Les contraintes (bornes) sont appliquées pour éviter des poids extrêmes (ex: bornes `[0.3, 4.5]`).

---

## 4. Explication des Fonctions Principales

Voici les fonctions clés définies dans les scripts, principalement dans `scripts/02_base_weights/inc_probs_functions.R` et les scripts de calcul.

### `compute_pi_zd(region, nb_mens_seg, nb_men_reg, nb_zd_strat)`

- **Fichier** : `scripts/02_base_weights/2_calc_base_weights.R`
- **But** : Calcule $\pi_{ZD}$.
- **Logique** : Applique la formule conditionnelle selon si la région est "ABIDJAN" ou non. Utilise le nombre de ménages estimé de la ZD ($N_{ménages\_segment} \times 6$) et le nombre total de ménages de la strate.

### `calc_proba_inclusion_menage(nb_enq_ti, nb_total_segment)`

- **Fichier** : `inc_probs_functions.R`
- **But** : Calcule $\pi_{Ménage|ZD}$.
- **Logique** : Ratio entre ménages enquêtés et total ménages du segment, multiplié par $1/6$.

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
| `04_calibration`  | `00_Master_Calibration_*.R`       | Orchestre le calage avec ReGenesees (par trimestre/design). |
