# Manuel de référence — pondération de l'ENE-M (dépôt ENE_SURVEY_WEIGHTS)

> **Objet.** Ce manuel décrit tout ce que contient le dépôt `ENE_SURVEY_WEIGHTS` : le plan de sondage de l'Enquête Nationale sur l'Emploi auprès des Ménages (ENE-M, Côte d'Ivoire, ANStat), chaque étape du calcul des poids, les formules, les fichiers, la manière d'exploiter la chaîne, les choix faits au fil du temps et leur origine.
>
> **État décrit.** 26 octobre 2026, branche git `feat/non-reponse-modelisee` (tout le travail décrit est commité). Dernier trimestre publié : T1 2026 ; T2 2026 traité sans publication (§2.4) ; trimestre de travail : T3 2026.
>
> **Convention.** Ce qui est écrit dans le code, un commit ou un document du dépôt est donné comme un fait, avec sa source (fichier, ligne ou hash de commit). Ce qui est déduit sans être écrit nulle part est signalé par **(inférence)**. Les formules ont été recopiées depuis le code puis simplifiées à la main ; elles doivent être relues par le responsable méthodologique avant tout usage officiel.

---

## Sommaire

1. [Contexte](#1-contexte)
2. [Plan de sondage](#2-plan-de-sondage)
3. [Vue d'ensemble de la chaîne](#3-vue-densemble-de-la-chaîne)
4. [Préparation des données (01_utils, 07_correction_quarter)](#4-préparation-des-données)
5. [Poids de base (02_base_weights)](#5-poids-de-base)
6. [Correction de la non-réponse (03_nonresponse)](#6-correction-de-la-non-réponse)
7. [Calage 180X_1D (04_calibration)](#7-calage-180x_1d)
8. [Totaux de population](#8-totaux-de-population)
9. [Produits dérivés : poids ménages, poids annuels](#9-produits-dérivés)
10. [Précision et contrôle qualité](#10-précision-et-contrôle-qualité)
11. [Échanges avec les autres dépôts : MinIO](#11-échanges-avec-les-autres-dépôts--minio)
12. [Modules annexes (09, 10, 11, 12, 99)](#12-modules-annexes)
13. [Exploitation : produire un trimestre](#13-exploitation--produire-un-trimestre)
14. [Chronologie des choix](#14-chronologie-des-choix)
15. [Limites, risques et dette technique](#15-limites-risques-et-dette-technique)
16. [Écarts entre l'ancienne documentation et le code](#16-écarts-entre-lancienne-documentation-et-le-code)
17. [Annexes](#17-annexes)

---

## 1. Contexte

### 1.1 L'enquête

L'ENE-M mesure l'emploi, le chômage et la sous-utilisation de la main-d'œuvre selon les normes de la 19e Conférence internationale des statisticiens du travail (CIST, 2013). Elle succède à l'ENSETE 2013, l'ENSESI 2016, l'ERI-ESI 2017 et l'ENE 2019 (note méthodologique, l.84-94). La CIST recommande des indicateurs infra-annuels ; l'enquête est donc continue, sur les 52 semaines de l'année, avec une publication trimestrielle à 90 jours après la fin du trimestre (l.96, 541).

La collecte a commencé au **T2 2024** (commentaire de `scripts/08_yearly_weights/ponderation_annuelle.r`). L'année 2024 est donc incomplète (T2, T3, T4).

La note méthodologique citée tout au long de ce manuel est `reports/Note_Methodologique_ENEM_2024.tex`, datée d'octobre 2024. Elle est supprimée du répertoire de travail mais reste lisible par `git show HEAD:reports/Note_Methodologique_ENEM_2024.tex`. Elle contient des éléments postérieurs à 2024 (schéma 180X, poids annuel 1/K), donc elle a été réécrite après coup **(inférence)**.

### 1.2 Ce que produit ce dépôt

Le dépôt calcule, pour chaque trimestre, le poids de chaque individu enquêté :

- `FINAL_WEIGHT` : poids calé de production, dans `data/04_weights/<T>/calibrated_weights/individu_<T>_CAL.dta` ;
- à partir de T1 2026, `FINAL_WEIGHT_cellules` : le même calage appliqué à l'ancienne correction de non-réponse, gardé pour comparaison ;
- des produits dérivés : poids ménages, poids annuels `LFS_WEIGHTS_<année>`.

Il ne calcule pas les indicateurs publiés : ceux-ci sont produits en Stata dans le dépôt `ENE_INDICATORS_TABULATIONS` (source de vérité des tabulations, d'après `ENE_MEDALLION_ORCHESTRATION/docs/MULTI_REPO_INTEGRATION.md`).

### 1.3 Place dans l'écosystème

```
 ENE_APUREMENT ──► MinIO silver (menage, individu)
                          │
                          ▼
 ENE_SURVEY_WEIGHTS (ce dépôt) ──► MinIO silver/poids, gold/base_ponderee
                          ▲                         │
   gold/base_indicateurs ─┘                         ▼
                                     ENE_INDICATORS_TABULATIONS ──► gold/base_indicateurs, gold/indicateurs
                                                    │
                                                    ▼
                                         dépôt précision ──► gold/precision
```

Les dépôts n'échangent jamais de fichiers directement : chacun télécharge depuis MinIO et publie vers MinIO, via les scripts Python de `ENE_MEDALLION_ORCHESTRATION/ene_medallion_io/` (§11). Ce principe a été adopté le 30 mai 2026 (commits `b98db03`, `39c0984`) ; avant, `export_weights_to_indicators.R` copiait les poids directement dans le dossier du dépôt de tabulation.

### 1.4 Origine du code

Trois sources se superposent.

1. **Le kit de formation de l'OIT.** Les scripts de calage (`04_calibration/QUARTERLY_WEIGHTING/...`) sont des gabarits du cours « TRAINING ON STRATEGIES TO CALCULATE LFS SAMPLE WEIGHTS USING CALIBRATION » d'Antonio R. Discenza (OIT, département de statistique, unité SSMU). Leurs en-têtes portent encore « CASE STUDY N. 6 - (312X_1D_ALLWR) » et des chemins du jeu d'entraînement (`W:/ILO_LFS_GSBPM/...`). Les scripts de précision (`STANDARD_ERRORS/`) viennent d'une autre session : « TRAINING ON WEIGHTING METHODS AND STRATEGIES - ILO STATISTICS & ITC-ILO - Oct/Dec 2023 », cas d'étude 16 et 17. La fonction `constraints_model()` est d'Alessandro Martini (ISTAT), `X_Summaries()` de Discenza. L'arborescence `DERIVED_VARIABLES / POPULATION_ESTIMATES / QUARTERLY_WEIGHTING / STANDARD_ERRORS` reprend l'organisation GSBPM du kit **(inférence)**.
2. **ReGenesees**, le package R de calage et d'estimation de Diego Zardetto (Istat), installé depuis GitHub.
3. **Le code propre à l'ANStat** : préparation, poids de base et non-réponse (en-têtes d'Ezechiel KOFFIE, mai-juin 2025), puis l'essentiel des évolutions par Franck MIGONE (auteur principal, environ 65 commits), et des contributions d'Anderson KOUASSI (`kouassijacques75`, CAE-ANStat : schémas `_ALLWR_np` de 2024/T4, calage T3 2025, tableau de bord des effectifs par contrainte).

Le commit `3e5a1b8` (29 août 2025) intègre « les modifications d'antonio (poids_zd) et (correction non-réponse régionale) ». L'identification de cet « Antonio » à A. R. Discenza est une **inférence** (même prénom ; le commit modifie aussi le fichier de fonctions qui porte son en-tête).

---

## 2. Plan de sondage

Sources : note méthodologique (l.108-312), `data/01_raw/Organisation/quarter_resurvey.xlsx`, code de `02_base_weights/` et `03_nonresponse/2_attrition_propensity.R`.

### 2.1 Base de sondage et strates

- **Base** : zones de dénombrement (ZD) du Recensement général de la population et de l'habitat (RGPH) 2021. Les comptages de ménages par ZD sont dans `data/03_processed/RP_2021/nb_men_indivs_ZD.dta` (produit par `01_utils/harm_rp_ene.R`) ; les totaux régionaux dans `nb_men_reg_milieu.dta` (66 lignes : 33 régions × 2 milieux, avec `nb_men_reg` = total de la région répété sur les deux milieux). Aucun script du dépôt ne produit `nb_men_reg_milieu.dta`.
- **Strates** : les 33 régions administratives, district autonome d'Abidjan compris (code `hh2 = 10101`).

### 2.2 Tirage des ZD

- 56 ZD par région, 104 pour Abidjan, soit 32 × 56 + 104 = **1 896 ZD**.
- Tirage à probabilité proportionnelle à la taille. La note parle d'une taille en **individus** (l.154) ; le code utilise des **ménages** depuis `3e5a1b8` (§5.3).
- Les ZD de chaque région sont réparties au hasard en **8 sous-échantillons** (A à H) : 7 ZD par sous-échantillon, 13 à Abidjan (d'où 56 = 7 × 8 et 104 = 13 × 8). Un sous-échantillon entre dans l'enquête chaque trimestre : 32 × 7 + 13 = **237 ZD** par trimestre.

### 2.3 Segments et ménages

- Chaque ZD est découpée en **6 segments**, rangés au hasard de 1 à 6.
- À l'entrée d'une ZD, on dénombre le segment actif, puis on y tire **12 ménages** par tirage systématique (6 par semaine de référence). Soit 237 × 12 = **2 844 ménages** en première interrogation par trimestre.
- Le segment suivant de la même ZD n'entre qu'au cycle suivant (A1 en T2 2024, A2 en T2 2026 d'après le tableau de rotation de la note). Chaque lot trimestriel de ZD est construit pour représenter le pays par région et milieu de résidence. Le segment 2 des ZD de T2 2024 est entré en T3 2026 et non en T2 2026 (§2.4) ; le segment se déduit du trimestre de dénombrement par `segment_actif()` (§4.1).

### 2.4 Rotation

Un ménage est interrogé **quatre fois** : aux trimestres t, t+1, t+4 et t+5 après son entrée. Le code parle de « rotation 2-2-2 » (`2_attrition_propensity.R`) ; la note annonce un schéma « 2-2 trimestriel », avec un quart de l'échantillon renouvelé chaque trimestre. Les justifications données par la note (l.108-144), après comparaison avec l'INSEE (6-0), le BLS/Census (4-8-4 mensuel) et le Rwanda (1-1-1) :

- coût : pas de rotation mensuelle ;
- charge sur les ménages plus faible que le 6-0 ;
- mesure des variations trimestrielles possible, contrairement au 1-1-1.

Rangs d'interrogation au T1 2026 :

| Rang | Décalage | Cohorte entrée au |
|---|---|---|
| 1 | 0 | T1 2026 |
| 2 | 1 | T4 2025 |
| 3 | 4 | T1 2025 |
| 4 | 5 | T4 2024 |

La table `quarter_resurvey.xlsx` (colonnes `Trimestre_En_Cours`, `Trimestre_1_Reint`, `_2_`, `_3_`) donne ces correspondances pour chaque trimestre.

**Choix — premières interrogations de T2 2026 reportées (25 octobre 2026).** En T2 2026, les réinterrogations (par téléphone) ont eu lieu comme prévu, mais pas les premières interrogations : les ZD prévues pour T2 2026 (segment 2 des ZD de T2 2024) sont entrées en T3 2026. La cohorte « T2 2026 » n'existe donc pas : elle a été retirée de `quarter_resurvey.xlsx` (lignes T3 2026, T2 2027, T3 2027), le reste de la table est inchangé. En T3 2026, les réinterrogés sont T3 2025 (rang 3) et T2 2025 (rang 4), sans rang 2. Original gardé localement dans `data/01_raw/Organisation/archive/quarter_resurvey_avant_report_T2_2026.xlsx`. `03_nonresponse/2_attrition_propensity.R` lit désormais ses cohortes, rangs (1 + nombre de visites antérieures) et visites intermédiaires dans cette table au lieu des décalages fixes 1, 4, 5 (résultat identique pour tous les trimestres sauf ceux où la cohorte T2 2026 manque). `COHORT_OFFSETS` du contrat MinIO (`ENE_MEDALLION_ORCHESTRATION/ene_medallion_io/weights_contract.py`) reste sur les décalages fixes : il télécharge pour T3 2026 un sur-ensemble des cohortes (T2 2026 en trop), sans blocage. **T2 2026 n'est pas publié** : il est traité et conservé pour la continuité des échantillons (visites intermédiaires et correspondance des entretiens de T3 2026), et doit donc être traité avant T3 2026. Les poids annuels 2026 se calculent avec `--quarters=T1,T3,T4` (K = 3).

### 2.5 Collecte

- Deux semaines de référence par segment, 6 ménages par semaine.
- Première interrogation en face-à-face, les suivantes par téléphone ; retour au face-à-face après 10 appels sans succès (note, l.265-312).
- Variables utiles en pondération : `rgmen` (1 = première interrogation, 2 = réinterrogation), `v1interviewkey` (clé de la première interrogation du ménage), `hh14` (résultat de l'entretien, 1 = rempli), `modintr` (2 = téléphone).

### 2.6 Incohérences de la note méthodologique

1. Elle annonce « 2-2 » mais argumente en partie sur le « 6-0 » (l.287 : « six trimestres à raison de deux par an ») ; le code n'a que 4 rangs.
2. Le tableau de rotation répète les lignes T1 à T3 2026 (l.135-141).
3. Taille de tirage en individus dans le texte, en ménages dans la formule et le code.
4. Non-réponse décrite par région × milieu avec plafonnement ; le code fait autrement (§6.2).
5. Population en âge de travailler à 16 ans et plus ; le calage coupe à 0-14 / 15+.

---

## 3. Vue d'ensemble de la chaîne

### 3.1 Ordre réel d'exécution

Aucun orchestrateur n'enchaîne les étapes de préparation et de poids de base : elles sont lancées à la main. L'ordre ci-dessous est déduit des entrées et sorties de chaque script ; **la numérotation des dossiers ne le reflète pas** (par exemple `02_base_weights/3_indivs_weights.R` s'exécute après `03_nonresponse/1_adjust_weights_non_response.R`).

| # | Script | Rôle | Écrit |
|---|---|---|---|
| 0 | `python scripts/medallion/medallion.py download` | Télécharge les entrées depuis MinIO (§11.3) | `data/` (références, dénombrements, fichiers apurés, entrées des cohortes) |
| 1 | `01_utils/1_concat_denomb.R` | Empile le dénombrement du trimestre | `data/02_cleaned/Denombrement/<T>/` |
| 2 | `01_utils/2_denomb_updates.R` | Intègre les dénombrements mis à jour (Excel, IDSeg), garde le segment enquêté (`segment_actif()`) | `data/02_cleaned/Denombrement_update/denombrement_update_<ts>.dta` |
| 3 | `01_utils/update_interviewkey_map.R` | Table de correspondance des `interview_key` | `data/03_processed/Tracking_ID/<date>/` |
| 4 | `01_utils/3_assign_firstTrim_interview.R` | Trimestre de première interrogation | `data/03_processed/Menage/<T>/` |
| 5 | Fichiers Stata `.do` de suppression (§4.5) | Retire les ménages au-delà de 12 par ZD | `data/03_processed/Menage/<T>/` |
| 6 | `01_utils/5_delete_individu_age_sexe.r` | Retire les individus sans âge ni sexe, les orphelins | `data/03_processed/{Menage,Individu}/<T>/` |
| 7 | `02_base_weights/1_gen_weights_columns.R` (source `4_construct_denombrement.r`) | Comptages par ZD (cohortes lues dans `quarter_resurvey.xlsx`, corrections de `07_correction_quarter/denombrement/`), codes d'incohérence | `base_weights_<T>.dta`, `inconsistent_rows_<T>.dta` |
| 8 | `02_base_weights/2_calc_base_weights.R` | Probabilités d'inclusion, poids de base | `base_weights_<T>.dta`, `probabilities_gt1_<T>.dta` |
| 9 | `03_nonresponse/1_adjust_weights_non_response.R` | Correction de non-réponse par région | `base_weights_<T>.dta` |
| 10 | `02_base_weights/3_indivs_weights.R` | Fichiers ménages et individus avec `d_weights` | `menage_<T>.dta`, `individu_<T>.dta`, `SR_individu_<T>.dta` |
| 11 | `03_nonresponse/2_attrition_propensity.R` (à partir de T1 2026) | Non-réponse modélisée (cohortes et rangs lus dans `quarter_resurvey.xlsx`) | réécrit `individu_<T>.dta` ; `nr_modele_*.csv` |
| 12 | `04_calibration/QUARTERLY_WEIGHTING/<année>/<T>/180X_1D/00_Master_Calibration_180X_1D.R` | Calage | `data/07_QUARTERLY_WEIGHTING/...`, `calibrated_weights/individu_<T>_CAL.dta` |
| 13 | `03_nonresponse/3_compare_nonresponse_methods.R` | Compare les deux méthodes | `nr_comparaison_*.csv` |
| 14 | `04_calibration/household_weights.r` | Poids ménages | `household_weights/` |
| 15 | `python scripts/medallion/medallion.py upload-outputs` | Publie sur MinIO | — |
| — | `08_yearly_weights/ponderation_annuelle.r` (une fois l'année close) | Poids annuels | `data/04_weights/<année>/LFS_WEIGHTS_<année>.*` |

Les étapes 1 à 6 traitent aussi les trimestres antérieurs dont les cohortes sont réinterrogées.

### 3.2 Les poids successifs

| Variable | Niveau | Définition | Créée par |
|---|---|---|---|
| `pi_zd`, `pi_hh`, `pi_HH` | ZD (ligne de `base_weights`) | Probabilités d'inclusion | `2_calc_base_weights.R` |
| `base_weight_HH` | ZD | 1 / `pi_HH` | `2_calc_base_weights.R` |
| `corrected_weight_HH` | ZD | Poids de base × facteur régional de non-réponse | `1_adjust_weights_non_response.R` |
| `d_weights` | individu | Poids d'entrée du calage. Jusqu'à T4 2025 : `corrected_weight_HH`. À partir de T1 2026 : poids modélisé | `3_indivs_weights.R`, puis `2_attrition_propensity.R` |
| `d_weights_cellules` | individu | `corrected_weight_HH` (à partir de T1 2026) | `2_attrition_propensity.R` |
| `FINAL_WEIGHT` | individu | Poids calé | `04c_...` |
| `FINAL_CORR_FACTOR` | individu | `FINAL_WEIGHT / d_weights` | `04c_...` |
| `FINAL_WEIGHT_cellules`, `FINAL_CORR_FACTOR_cellules` | individu | Même calage sur `d_weights_cellules` | `04c_...` (T1 2026) |

Les noms `poids_de_base`, `poids_final` et `pmencor_ind` n'apparaissent pas dans la chaîne de production. `pmencor_ind` est le nom du poids dans les bases du dépôt de tabulation.

---

## 4. Préparation des données

Tous les scripts font `source("config/1_config.r")` : il faut les lancer avec la racine du dépôt comme répertoire de travail. `config/1_config.r` fixe `BASE_DIR` (chemin absolu du poste) et `TARGET_QUARTER` (format `TX_AAAA`) ; c'est le seul endroit où l'on change de trimestre pour les étapes 01 à 03.

### 4.1 Dénombrement

- **`1_concat_denomb.R`** lit tous les `.dta` de `data/01_raw/Denombrement/<T>/`, normalise les noms (`janitor::clean_names`), aligne les colonnes et empile les fichiers de même nom (`menage*`, `ENEM*`, `batiment*`, `ilot*`). `concat_denomb.R` est un doublon figé sur T2 2024.
- **`2_denomb_updates.R`** intègre les dénombrements refaits sur le terrain, livrés en Excel dans `data/01_raw/Denombrement_update/T?_AAAA/`. Il convertit les libellés géographiques en codes par jointure sur le RGPH, compte `nb_mens_seg` (ménages du segment) et `nb_mens_zd`, et écrit un fichier horodaté qui garde le segment enquêté (`segment_actif(quarter)`, voir ci-dessous).

**Choix — segment 2 (25 octobre 2026).** Dans le schéma de rotation, les ZD dénombrées en T3 2026 sont celles de T2 2024 : l'enquête y revient, mais sur le segment 2. `config/1_config.r` fixe `SEGMENT_2_FIRST_QUARTER = "T3_2026"` ; `segment_actif()` renvoie 2 pour un trimestre d'entrée (dénombrement) à partir de ce seuil, 1 avant. `2_denomb_updates.R` l'applique au dossier de la mise à jour, `1_gen_weights_columns.R` à `first_trim` : les ZD réinterrogées issues des dénombrements antérieurs restent au segment 1. Trimestres publiés inchangés (lignes antérieures à T3 2026 identiques au fichier du 25 juin 2026).

**Choix — IDSeg (commit `f66d621`, 6 juin 2026).** Quatre fichiers Excel étaient ignorés en silence parce que la colonne du segment s'appelait autrement qu'`IDSeg` ou manquait. Comme `nb_mens_seg` entre dans la probabilité de tirage du ménage, ces segments gardaient un dénombrement périmé **(inférence sur l'impact)**. Correction : liste d'alias (`IDSEG_ALIASES`), arrêt du script si un fichier n'a aucune colonne compatible, et une exception documentée (`SEG_BaseT12025_menage_Touba_6014_.xlsx`), traitée dans `07_correction_quarter/denombrement/correction_T1_2025.r`.

### 4.2 Correspondance des entretiens et premier trimestre

- **`update_interviewkey_map.R`** ajoute les nouveaux trimestres à la table `interview_key_mapping_<date>.dta` (une ligne par entretien ménage, avec son trimestre). Défaut : il perd `v1interviewkey` et `date1` à cause d'une casse (§15).
- **`3_assign_firstTrim_interview.R`** calcule `firsttriminterview` : le trimestre courant si `rgmen == 1`, sinon le trimestre de l'entretien pointé par `v1interviewkey`. Il réécrit `data/03_processed/Menage/` pour **tous** les trimestres, ce qui oblige à relancer ensuite les suppressions (§4.5) et `5_delete_individu_age_sexe.r`.
- `4_gen_interviewkey_map.R` est une ancienne version « tout reconstruire » dont la sortie n'est plus lue.

**Choix — réinterrogations (commit `2547bac`, 11 juillet 2025, « dynamisme pour gerer les reinterrogations et les premières interrogations »).** La chaîne distingue les premières interrogations (`rgmen == 1`) des réinterrogations, et produit deux fichiers d'entrée du calage : l'échantillon complet et le sous-échantillon des seules premières interrogations (`SR_`, §5.5). La raison probable est de pouvoir caler l'un ou l'autre **(inférence)**.

### 4.3 Individus sans âge ou sans sexe

`5_delete_individu_age_sexe.r` (décembre 2025) retire les individus dont `ageannee` ou `m5` (sexe) manque ou vaut -9998, les individus dont le ménage est absent, puis les ménages sans individu. Origine : le commit `3e5a1b8` notait « reste à corriger les individus sans ménages et les ménages sans individus » ; `3e32644` (novembre 2025) et `9138da6` (décembre 2025) ont fait le travail. Raison : un individu sans âge ni sexe n'entre dans aucune contrainte de calage (§7.6).

### 4.4 Corrections trimestrielles (07_correction_quarter)

Deux mécanismes :

1. **`07_correction_quarter/denombrement/correction_<T>.r`**, chargé dans un environnement isolé par `4_construct_denombrement.r` pour chaque trimestre traité (courant et cohortes). Fonctions reconnues : `suppression_par_interview_key`, `correction_reaffectation_denombrement`, `correction_taille_segment_par_interview_key`, `correction_taille_segment_par_geo`, `suppression_par_combinaisons_geo`, `ajouter_missing`.
2. **`07_correction_quarter/correction_<T>.r`** à la racine, appliqué par `0_apply_quarter_correction.r` depuis `2_calc_base_weights.R`, pour le trimestre courant seulement.

Contenu par trimestre :

| Trimestre | Corrections |
|---|---|
| T2 2024 | Taille de segment de 11 ZD ; ajout des ZD 0023 (Touba, 36 ménages) et 6016 (Doropo, 33) absentes du dénombrement |
| T3 2024 | Réaffectation d'une ZD ; taille de 5 segments ; suppression de 4 entretiens de dénombrement et de 11 ZD |
| T4 2024 | Réaffectation de ZD (sans effet, §15) ; 20 tailles de segment ; ajout d'une ZD ; suppression d'un doublon de ZD |
| T1 2025 | Taille du segment de Touba lue dans l'Excel d'exception ; suppression de deux doublons de ZD |
| T2 2025 | Ajout de 4 ZD manquantes |
| T3 2025 | Ajout de 4 ZD manquantes |
| T4 2025, T1 2026 | Aucune |
| T3 2026 | Suppression de 11 entretiens de dénombrement vides (doublons de ZD, sans effet sur les comptages) |

Les fichiers `07_correction_quarter/menage/*.r`, `01_utils/2_0_denomb_special_updates.r` et `01_utils/0_fonctions_utiles` sont d'anciennes versions jamais appelées.

### 4.5 Ménages au-delà de 12 par ZD

**Choix (commits `9138da6`, 18 décembre 2025, et `0dd8854`, 1er janvier 2026 : « suppression interview_key plus de 12 men par ZD »).** Des ZD comptaient plus de 12 ménages enquêtés au premier passage. Les ménages en surplus sont supprimés par des listes de clés en Stata :

- `01_utils/correction_menage_T4_2024.do` (123 suppressions), `correction_menage_T2_2025.do` (255), `correction_T3_2025_menage.do` (environ 377 lignes, avec des commandes interactives `ed`) ;
- `05_quality_control/suppression_T2_2024.do` à `suppression_T3_2025.do` (25, 39, 56, 29, 56 et 260 ménages).

La règle « plus de 12 » n'est écrite dans aucun script : seules les listes existent, et aucun script ne les appelle. **Le critère de choix des ménages supprimés n'est pas documenté.** Le motif probable est que la probabilité de tirage d'un ménage suppose exactement 12 tirages par segment ; des ménages en surplus fausseraient le poids **(inférence)**.

---

## 5. Poids de base

### 5.1 Colonnes de pondération (`1_gen_weights_columns.R`)

Le script construit `base_weights_<T>.dta`, une ligne par ZD présente au trimestre (toutes cohortes), en joignant :

- le dénombrement de chaque trimestre concerné (via `4_construct_denombrement.r`), qui donne `nb_mens_seg`, `nb_indivs_seg`, le `first_trim` (trimestre de dénombrement de la ZD) et `rgmen` (1 si la ZD entre ce trimestre, 2 sinon) ;
- le RGPH : `nb_mens_zd`, `nb_indivs_zd` (ZD) et `nb_men_reg` (région) ;
- les comptages d'enquête : `nb_mens_enq` (ménages enquêtés dans la ZD ce trimestre), `nb_indivs_enq`, `nb_indivs_enq_pot` (15 ans et plus), `nb_indivs_enq_elig` ;
- les dénombrements mis à jour (le fichier le plus récent par date de modification).

**Choix — une ligne par ZD (commit `b4f61f6`, 25 juin 2025, « regler doublons »).** Quand une ZD apparaît dans plusieurs dénombrements, seul le plus récent est gardé (`quarter_rank` maximal).

**Codes d'incohérence** (`incoherence_code`, évalués dans cet ordre) :

| Code | Condition |
|---|---|
| 10 | Aucun ménage ni individu enquêté dans la ZD ce trimestre |
| 1 à 4 | `nb_mens_seg`, `nb_mens_zd`, `nb_indivs_seg`, `nb_indivs_zd` manquant |
| 5, 6 | Comptages d'enquête manquants |
| 7 | `nb_mens_seg > nb_mens_zd` |
| 8 | Même test sur les individus |
| 9 | `nb_mens_seg > nb_indivs_seg` |
| 11 | ZD en double |

Seul le code 10 entraîne une exclusion (§5.2).

### 5.2 Exclusions

`2_calc_base_weights.R` retire les lignes sans région et les ZD au code 10. Une ZD dénombrée mais sans aucun entretien sort de l'échantillon et n'est pas comptée dans le nombre de ZD de la région : c'est un ajustement implicite de la non-réponse au niveau de la ZD **(inférence sur l'intention)**.

### 5.3 Probabilités d'inclusion

Code (`2_calc_base_weights.R`) :

```r
compute_pi_zd <- function(region, nb_mens_seg, nb_men_reg, nb_zd_strat) {
  multiplier <- ifelse(region == 10101, 104, 56)
  multiplier * ((nb_mens_seg * 6) / nb_men_reg) * (nb_zd_strat / multiplier)
}
compute_pi_hh <- function(nb_mens_seg) (NB_MENS_ENQ / nb_mens_seg) * (1 / 6)   # NB_MENS_ENQ = 12
pi_HH <- pi_zd * pi_hh
base_weight_HH <- 1 / pi_HH
```

avec `nb_zd_strat` = nombre de ZD de la région présentes après exclusions (toutes cohortes).

En notation, pour une ZD *z* de la région *r* :

$$
\pi_{z} = n_r \cdot \frac{6\, M_{z}}{M_r},
\qquad
\pi_{h|z} = \frac{12}{M_{z}} \cdot \frac{1}{6},
\qquad
\pi_{h} = \pi_z \, \pi_{h|z}
$$

où $M_z$ = `nb_mens_seg` (ménages dénombrés dans le segment ; 6 $M_z$ approxime la taille de la ZD), $M_r$ = `nb_men_reg` (ménages de la région au RGPH), $n_r$ = `nb_zd_strat`. Le multiplicateur 104/56 s'annule. Interprétation : tirage proportionnel au nombre de ménages, puis un segment sur 6, puis 12 ménages.

**Conséquence : le poids de base est constant dans la région.** Le produit se simplifie :

$$
\pi_h = \frac{12\, n_r}{M_r}
\qquad\Longrightarrow\qquad
w^{(0)}_h = \frac{M_r}{12\, n_r}
$$

Le nombre de ménages du segment disparaît. Le plan est donc autopondéré par région. Vérifié sur les 937 ZD du T1 2026 : `base_weight_HH` = `nb_men_reg / (12 × nb_zd_strat)` à 4e-16 près.

**Choix — mesure de taille et nombre de ZD (commit `3e5a1b8`, 29 août 2025, « modifications d'antonio (poids_zd) »).** Avant ce commit :

- la taille était en **individus** (`nb_indivs_zd / nb_indivs_reg`, lue dans `help_poids_regionaux.dta`) ;
- `nb_zd_strat` était théorique : 13 (Abidjan) ou 7 ZD × nombre de trimestres écoulés − segments abandonnés (`quarter_phase`) ;
- `pi_hh` était plafonné à 1 quand le segment comptait moins de 12 ménages.

Après : taille en ménages, nombre de ZD réellement présentes, plus de plafonnement. `quarter_phase` est resté dans le fichier mais n'est plus utilisé.

### 5.4 Contrôle des probabilités supérieures à 1

`check_probability_bounds()` écrit les cas où une probabilité dépasse 1 dans `probabilities_gt1_<T>.dta`. Introduit comme **bloquant** par `f66d621` (juin 2026) ; passé en **avertissement** par `bf59339` (24 octobre 2026). Sans plafonnement, `pi_hh` dépasse 1 dès qu'un segment compte moins de 2 ménages. Comme le poids final ne dépend pas de `nb_mens_seg` (§5.3), ces cas n'affectent pas le poids de base, mais ils signalent un dénombrement suspect.

### 5.5 Poids « WR » et fichier `SR_`

`nb_zd_strat_wr` ne compte que les ZD de la cohorte entrante (`rgmen == 1`). `pi_zd_wr`, `base_weight_HH_WR` et `corrected_weight_HH_WR` en découlent ; « WR » signifie *without resurvey* (`calc_base_weights_2.R`), libellé « trimestre en cours uniquement ». `3_indivs_weights.R` écrit `SR_individu_<T>.dta` avec `d_weights = corrected_weight_HH_WR`.

Le master de calage peut lire ce fichier (`use_sr = TRUE`), mais la production utilise l'échantillon complet. Défaut : `nb_zd_strat_wr` est joint à toutes les lignes de la région, y compris les réinterrogations, qui reçoivent un poids WR environ 4 fois plus grand (§15).

### 5.6 Fichiers ménages et individus (`3_indivs_weights.R`)

Le script joint ménages et individus aux poids par la clé géographique (`hh2 = region`, `hh3 = depart`, `hh4 = souspref`, `hh8 = ZD`), dédoublonne sur (`interview_key`, `membres_id`), retire les individus sans `corrected_weight_HH` (commit `3e32644`, « suppression d'individus non trouvés ») et pose `d_weights = corrected_weight_HH`. Pas de correction de non-réponse individuelle (« Nothing to do ») : un ménage répondant fournit tous ses membres.

---

## 6. Correction de la non-réponse

Deux méthodes coexistent. Jusqu'au T4 2025 (trimestres publiés), seule la méthode par cellules régionales existe. À partir du T1 2026, la méthode modélisée est la production et la méthode par cellules est gardée en colonnes de référence.

### 6.1 Pourquoi une correction

Dans chaque ZD, 12 ménages sont prévus mais tous ne répondent pas. Aux réinterrogations s'ajoute l'**attrition** : un ménage interrogé au rang 1 peut ne plus être joignable aux rangs 2, 3 ou 4. Les ménages qui restent ne ressemblent pas forcément à ceux qui partent.

### 6.2 Méthode par cellules régionales (`1_adjust_weights_non_response.R`)

Code :

```r
nb_men_theo <- 12                                         # par ligne (ZD)
correction_factor_region_milieu <- sum(nb_men_theo) / sum(nb_mens_enq)   # group_by(region)
corrected_weight_HH <- base_weight_HH * correction_factor_region_milieu
```

Pour la région *r* :

$$
f_r = \frac{12\, n_r}{m_r},
\qquad
w^{(1)}_h = w^{(0)}_h \, f_r = \frac{M_r}{12\, n_r} \cdot \frac{12\, n_r}{m_r} = \frac{M_r}{m_r}
$$

où $m_r$ = nombre de ménages enquêtés dans la région au trimestre (tous rangs). **Le poids corrigé vaut donc le nombre de ménages de la région au RGPH divisé par le nombre de ménages enquêtés dans la région.** Tous les ménages répondants d'une région ont le même poids, quel que soit leur rang d'interrogation. Vérifié sur les 937 ZD du T1 2026, à 4e-16 près.

Malgré les noms (`*_region_milieu`), le regroupement se fait par **région seule**. `adjusted_weight_HH` (facteur par segment) et `potentiel_de_collecte` sont calculés mais ne servent plus.

**Choix — historique.**

1. `23d2f4a` (27 août 2025, « correction facteur non-réponse regional ») : passage d'un facteur par segment à un facteur par région × milieu, avec un potentiel plafonné au nombre de ménages dénombrés. Motif probable : un facteur par segment est instable avec 12 ménages au plus **(inférence)**.
2. `3e5a1b8` (29 août 2025, « modifications d'antonio ») : regroupement par région seule, théorique fixe de 12 ménages par ZD, sans plafonnement. C'est la méthode actuelle. La note méthodologique décrit encore la version 1.

### 6.3 Le problème de la méthode par cellules

Les quatre groupes de rotation sont des sous-échantillons équivalents : chacun devrait représenter environ un quart de la population. Comme le facteur régional est le même pour tous les rangs, un rang qui répond moins pèse moins. Résultat au T1 2026, après calage :

| Rang | Part des poids, méthode cellules | Part attendue |
|---|---|---|
| 1 | 31,3 % | 25 % |
| 2 | 25,6 % | 25 % |
| 3 | 22,6 % | 25 % |
| 4 | 20,5 % | 25 % |

Les nouveaux ménages, qui répondent mieux, sont sur-représentés ; les ménages réinterrogés, touchés par l'attrition, sont sous-représentés. Si l'attrition est liée à la situation sur le marché du travail, les indicateurs sont biaisés.

### 6.4 Méthode modélisée (`2_attrition_propensity.R`) — production à partir du T1 2026

**Principe.** Rang 1 : correction par cellule région × rang. Rangs 2 à 4 : correction en deux phases. Phase 1, comme si tous les répondants de la première interrogation étaient revenus. Phase 2, correction de l'attrition entre la première interrogation et le trimestre courant, par classes de propension de réponse estimées à partir de ce que l'on savait du ménage à sa première interrogation.

**Population du modèle (le panel).** Pour chaque cohorte réinterrogée (rangs 2, 3, 4 ; cohortes, rangs et visites intermédiaires lus dans `quarter_resurvey.xlsx`, le rang étant 1 + le nombre de visites antérieures ; en T3 2026, pas de rang 2, §2.4), les ménages qui ont répondu à leur première interrogation (`first_trim` = trimestre d'entrée, `hh14 == 1`), lus dans `data/04_weights/<cohorte>/base_weights/menage_<cohorte>.dta`. Au T1 2026 : 7 154 ménages.

**Variable expliquée.** `repond = 1` si le ménage figure parmi les répondants du trimestre courant, reconnus par `v1interviewkey`. Un ménage répond s'il est dans `base_weights/individu_<T>.dta`, c'est-à-dire dans l'échantillon d'entrée du calage. Ce périmètre est identique à celui de l'échantillon calé (7 789 ménages au T1 2026), mais il est connu avant le calage. Au T1 2026 : 5 297 répondants sur 7 154.

**Covariables**, toutes mesurées avant le trimestre courant (composition lue dans la base `Traite_` du trimestre d'entrée, téléchargée depuis MinIO) :

| Bloc | Variables |
|---|---|
| Rotation | `rang_f` (rang 2, 3, 4) ; `inter_c` (réponse aux visites intermédiaires : « k/n ») |
| Géographie | `abidjan` ; `urbain` ; `district` |
| Ménage | `taille_c` (1, 2-3, 4-5, 6-8, 9+) ; `enf6` (enfant de moins de 6 ans) ; `part_emploi` (part des 16 ans et plus en emploi) ; `chom` (au moins un chômeur) ; `compo_nd` (composition inconnue) |
| Chef de ménage | `cm_age_c` (<30, 30-44, 45-59, 60+) ; `cm_femme` ; `cm_instr_c` (aucun, primaire, secondaire, supérieur, nd) |
| Collecte de la 1re interrogation (paradonnées) | `appel` (entretien par téléphone) ; `semaine_c` (semaine du trimestre : 1-3, 4-7, 8-10, 11-13) ; `delai_c` (jours entre la date de référence et l'entretien) ; `visites_mult` |
| Profil du répondant | `rep_non_cm` (questionnaire répondu par une autre personne que le chef) ; `contacts_c` (nombre de moyens de recontacter le ménage : aucun, un, deux et plus) |

Trois logits sont estimés : modèle de base, + paradonnées, + profil du répondant (modèle final). Des tests du rapport de vraisemblance et l'AUC sont écrits dans `nr_modele_diagnostics_<T>.csv` ; les coefficients dans `nr_modele_coefficients_<T>.csv`.

**Classes.** Quintiles de la probabilité prédite $\hat p$ à l'intérieur de chaque rang (`N_CLASSES = 5`). Le recours à des classes plutôt qu'à l'inverse direct de $\hat p$ limite la dispersion des poids et la dépendance à la forme exacte du logit.

**Facteurs.** Pour la région *r*, le rang *k*, la classe *c* :

$$
f^{\text{cell}}_{r,k} = \frac{12\, n_{r,k}}{m_{r,k}},
\qquad
f^{(1)}_{r,k} = \frac{12\, n_{r,k}}{p_{r,k}},
\qquad
f^{(2)}_{k,c} = \frac{\sum_{h \in \text{panel}_{k,c}} w^{(0)}_h}{\sum_{h \in \text{panel}_{k,c}} w^{(0)}_h \, \text{repond}_h}
$$

où $n_{r,k}$ = nombre de ZD de rang *k* dans la région, $m_{r,k}$ = répondants courants de rang *k*, $p_{r,k}$ = ménages du panel (répondants à la première interrogation). Le facteur $f^{(2)}$ est l'inverse du taux de réponse pondéré de la classe.

$$
d^{\text{modèle}}_h =
\begin{cases}
w^{(0)}_h \, f^{\text{cell}}_{r,1} & \text{si rang } 1 \\[4pt]
w^{(0)}_h \, f^{(1)}_{r,k} \, f^{(2)}_{k,c} & \text{si rang } k \in \{2,3,4\}
\end{cases}
$$

Un ménage réinterrogé absent du panel (123 au T1 2026) reçoit le facteur de cellule $f^{\text{cell}}_{r,k}$.

Puisque $w^{(0)}_h = M_r / (12 n_r)$, la phase 1 donne à chaque rang la part $n_{r,k}/n_r$ du total régional : c'est ce qui rééquilibre les rangs.

**Sorties.** Le script réécrit `base_weights/individu_<T>.dta` sur place : `d_weights` = poids modélisé ; `d_weights_cellules` = `corrected_weight_HH` ; plus `rang`, `classe_propension`, `f_cell`, `f_phase1`, `f_classe`. Il est idempotent (il repart de `corrected_weight_HH`). Il refuse les trimestres antérieurs à `NR_MODEL_FIRST_QUARTER` (`config/1_config.r`).

**Résultats au T1 2026** (après calage) :

| | Méthode cellules | Méthode modélisée |
|---|---|---|
| Part des poids, rangs 1 / 2 / 3 / 4 | 31,3 / 25,6 / 22,6 / 20,5 % | 24,3 / 24,7 / 25,0 / 26,0 % |
| Ratio emploi / population, national | 65,06 % | 65,16 % |
| SU1 (taux de chômage BIT), national | 3,59 % | 3,70 % |
| SU1, Abidjan | 7,30 % | 7,67 % |
| SU3, national | 11,12 % | 11,22 % |
| Effet de plan de Kish (1 + CV²) | 2,11 | 2,29 |
| Poids maximal | 11 693 | 15 637 |

Lecture : le rééquilibrage des rangs relève légèrement le chômage, surtout à Abidjan, au prix d'une dispersion des poids un peu plus forte. Une variante intermédiaire (cellules région × rang, sans modèle) a été testée : elle obtient presque tout le rééquilibrage (24,9 / 24,4 / 25,2 / 25,6 %) ; le modèle ajoute une correction à l'intérieur des rangs, visible à Abidjan. Elle n'a pas été retenue comme méthode.

**Choix — décisions d'octobre 2026** (branche `feat/non-reponse-modelisee`) :

1. Les trimestres publiés (jusqu'au T4 2025) ne changent pas ; la méthode modélisée s'applique à partir du T1 2026.
2. Une seule chaîne de production : pas de dossiers parallèles. L'ancienne méthode est gardée dans le même fichier (`d_weights_cellules`, `FINAL_WEIGHT_cellules`).
3. Le script de non-réponse ne refait jamais le calage : il produit `d_weights`, le master standard cale. Une première version faisait son propre calage et ses propres sorties ; elle a été réécrite pour cette raison.
4. Les bases `Traite_` viennent de MinIO, pas du dépôt de tabulation.

**Limites de la spécification** (relevées à la relecture) :

- `abidjan` est colinéaire avec le district d'Abidjan, et `inter_c == "sans_objet"` avec le rang 2 : `glm` met ces coefficients à NA ;
- le test « profil du répondant » compare des modèles non emboîtés (`telephone` retiré, `contacts_c` ajouté) ;
- l'AUC est calculée sur l'échantillon d'estimation ;
- les classes sont nationales par rang : la somme des poids modélisés par région n'est pas exactement 12 × ZD (le calage absorbe l'écart) ;
- les paramètres (5 classes, covariables) sont codés en dur, pas dans `config/longitudinal_propensity.yml`.

### 6.5 Comparaison des méthodes (`3_compare_nonresponse_methods.R`)

Lit `FINAL_WEIGHT` et `FINAL_WEIGHT_cellules` dans le fichier de production et écrit `nr_comparaison_poids_par_rang_<T>.csv` et `nr_comparaison_dispersion_<T>.csv`. Les indicateurs sous les deux poids se calculent côté tabulation, à partir de `gold/enem/<T>/base_ponderee/` (le fichier `_CAL` publié contient les deux colonnes).

---

## 7. Calage 180X_1D

### 7.1 Point d'entrée

Pour chaque trimestre, un dossier complet `scripts/04_calibration/QUARTERLY_WEIGHTING/<année>/<T>/180X_1D/` contient le master `00_Master_Calibration_180X_1D.R` et les étapes 01 à 05. Le master d'un nouveau trimestre est copié du précédent ; c'est la méthode prévue par le gabarit OIT (« make a copy of all scripts in the folder of a new quarter »).

`scripts/04_calibration/_experimental_archived/run_calibration.R` (orchestrateur générique créé le 11 janvier 2026, commit `a317c04`) a été archivé le 6 juin 2026 (`d0a9ff5`) : ce n'est pas le point d'entrée de production.

### 7.2 Étapes

| Étape | Fichier | Contenu |
|---|---|---|
| 00 | `00_Master_...` | Paramètres, chemins, garde de non-réponse (T1 2026), appel des étapes |
| 01 | `01_Upload_...` | Lit `base_weights/individu_<T>.dta` ; crée les clés ; lit les totaux de population |
| — | `01_Set_of_constraints_180X_1D.xlsx` | Ouvert dans Excel par `excel.link` (gabarit des 180 contraintes) |
| 02 | `02_Prepare_input_sample_data_...` | Construit les 180 indicatrices X et `LFS_SAMPLE_DATA` |
| 03 | `03_Prepare_input_pop_figures_...` | Construit les totaux connus `LFS_KNOWN_TOTALS` |
| 04c | `04c_Run_Quarterly_Calibration_...` | Plan de sondage, diagnostics, calage, poids finaux |
| 04f | `04f_XFormats_180X_1D.R` | Libellés des contraintes |
| 05 | `05_Attach_final_weights_...` | Rattache les poids aux données complètes, écrit l'export |
| 06, 07f | — | Appelés par le master mais **absents** : le master s'arrête en erreur après l'étape 05, une fois les sorties écrites |

### 7.3 Clés et plan de sondage

```r
INDKEY    <- paste0(hh2,"-",hh3,"-",hh4,"-",hh8,"-",interview_key,"-",membres_id)
HHKEY     <- paste0(hh2,"-",hh3,"-",hh4,"-",hh8,"-",interview_key)
PSUKEY    <- paste0(hh2,"-",hh3,"-",hh4,"-",hh8)      # unité primaire = ZD
STRATAKEY <- as.factor(hh2)                            # strate = région
design_lfs <- e.svydesign(data = sample_data, ids = ~ PSUKEY + HHKEY,
                          strata = ~ STRATAKEY, weights = ~ d_weights,
                          fpc = NULL, self.rep.str = NULL, check.data = TRUE)
```

Sans correction de population finie (`fpc = NULL`) : approximation « tirage avec remise au premier degré ».

### 7.4 Les 180 contraintes

Un seul domaine (`DOMAIN = "1"`). Variables : `ageannee`, `m5` (1 = homme, 2 = femme), `milieu` (1 = urbain, 2 = rural), `hh2`.

- **X1 à X48, niveau national** : milieu × sexe × 12 groupes d'âge (0-14, 15-19, 20-24, …, 60-64, 65 et plus). X1-X12 hommes urbains, X13-X24 hommes ruraux, X25-X36 femmes urbaines, X37-X48 femmes rurales.
- **X49 à X180, niveau régional** : 33 régions × sexe × {0-14, 15 et plus}, sans milieu. Quatre X par région, dans l'ordre (H 0-14), (H 15+), (F 0-14), (F 15+). Ordre des régions : annexe 17.3.

Les deux blocs se recoupent (la somme des X régionaux par sexe × âge égale celle des X nationaux correspondants) : la matrice est de rang incomplet. ReGenesees l'accepte à condition que les totaux soient exactement cohérents, d'où l'ajustement des totaux régionaux sur les marges nationales (§8).

### 7.5 Formule du calage

Estimateur par calage de Deville et Särndal (1992), avec la fonction logit bornée de ReGenesees. Avec $d_k$ = `d_weights`, $x_k \in \{0,1\}^{180}$ et $T_x$ les totaux connus, on cherche $w_k = d_k g_k$ qui minimise $\sum_k d_k\, G(g_k)$ sous les contraintes

$$
\sum_{k \in s} w_k\, x_k = T_x, \qquad L \le g_k \le U .
$$

La solution s'écrit $g_k = F(x_k' \lambda)$, $\lambda$ étant obtenu par Newton-Raphson, avec

$$
F(u) = \frac{L(U-1) + U(1-L)\, e^{A u}}{(U-1) + (1-L)\, e^{A u}},
\qquad
A = \frac{U - L}{(1-L)(U-1)} .
$$

Correspondance avec l'appel :

```r
calib_lfs <- e.calibrate(design = design_lfs, df.population = popdataframe,
                         calmodel = ~ X1 + ... + X180 - 1, partition = ~ DOMAIN,
                         calfun = "logit", bounds = c(0.01, 5),   # L, U
                         aggregate.stage = NULL, maxit = 30, epsilon = 1e-4,
                         force = TRUE)
FINAL_WEIGHT      <- weights(calib_lfs)          # w_k
FINAL_CORR_FACTOR <- FINAL_WEIGHT / d_weights    # g_k
```

- `aggregate.stage = NULL` : calage au niveau individuel. Les membres d'un même ménage peuvent avoir des poids différents ; c'est pourquoi les poids ménages sont des moyennes (§9.1).
- `force = TRUE` : en cas de non-convergence, ReGenesees renvoie la meilleure approximation au lieu d'une erreur. Le statut est dans `ecal.status`. Pour le calage de production, il n'est qu'imprimé ; depuis T1 2026 il est conservé dans `ecal.status.production` avant le calage de référence.
- Un individu sans âge a toutes ses X à 0 : $g_k = F(0) = 1$, il garde son poids d'entrée et n'est compté dans aucune contrainte. C'est la raison du nettoyage du §4.3.

### 7.6 Calage de référence (à partir du T1 2026)

Si `d_weights_cellules` est présent, 04c refait le même calage (même plan, mêmes contraintes, mêmes paramètres) sur `d_weights_cellules`. Il s'arrête si ce calage ne converge pas, puis ajoute `FINAL_WEIGHT_cellules` et `FINAL_CORR_FACTOR_cellules`, que 02 et 05 transportent jusqu'au fichier d'export. Vérification faite au T1 2026 : `FINAL_WEIGHT_cellules` est identique, à l'unité près, au poids officiel calculé avant le changement de méthode.

### 7.7 Diagnostics

- `find.lon.strata` : strates à une seule unité primaire.
- `X_Summaries()` avant et après calage, par contrainte : effectif, estimation initiale, total connu, facteur moyen (`Known_Total / Initial_Estimate`), alertes si le facteur sort de [0,95 ; 1,65], si l'effectif est ≤ 30, ou si une contrainte a un total nul d'un seul côté (« Error »). Après calage, `Diff_Known_Tot_Final_Est` doit être nul. Les valeurs par défaut de l'OIT sont 0,5 / 1,5 / 30 ; les seuils ENE ont été resserrés.
- `bounds.hint()` (bornes suggérées par ReGenesees) : calculé mais non utilisé. Commentaire du code : « La borne suggérée est négative ». L'historique montre des bornes suggérées comme c(-0.796, 3.771) en 2025.
- `table_check` (commits `9138da6` et `100e269`) : compare les totaux calés aux totaux de population ; alerte si l'écart dépasse 100. La correspondance est positionnelle.
- Résumés des poids et facteurs par strate (CSV).

### 7.8 Sorties

Dans `data/07_QUARTERLY_WEIGHTING/<année>/T<q>/180X_1D/` : `LFS_SAMPLE_DATA_*`, `LFS_KNOWN_TOTALS_*`, `LFS_CALIBRATION_*_FINAL_WEIGHTS.RData`, les résumés, `LFS_CALIBRATION_*_IMAGE.RData` (image de la session, avec l'objet `cal.analytic` utilisé par les poids annuels et la précision), `LFS_ILO_<a>_T<q>_CAL.dta` (fichier réduit).

Export de production : `data/04_weights/<T>/calibrated_weights/individu_<T>_CAL.dta` (fichier complet, publié sur MinIO).

### 7.9 Choix du schéma : historique

Schémas essayés (dossiers sous `QUARTERLY_WEIGHTING/`) :

| Schéma | Contraintes | Remarque |
|---|---|---|
| 180X_1D | 48 nationales + 132 régionales (région × sexe × 2 âges) | **Retenu** |
| 182X_1D | 180X avec coupure 0-15 / 16+, plus âge 0-14 et âge = 15 | 2024/T2 seulement. Créé « 184X » (`a7375ef`, 26 décembre 2025), renommé (`0dd8854`) |
| 312X_1D | 48 + 33 × milieu × sexe × 2 âges | Essayé de 2024/T2 à 2025/T4 |
| 444X_1D | 48 + 33 × milieu × sexe × 3 âges | Essayé de 2024/T2 à 2025/T4 |
| 156X, 222X, 288X, 312X, 444X `_ALLWR_np`, variantes `_milieu`, 8X_33D | Variantes des cas d'étude OIT | 2024/T4 seulement (A. Kouassi). « 816X » est en fait une copie de 156X ; 8X_33D est le seul en calage linéaire |

`_ALLWR` signifie « calibration of final weights using R for all steps » et `_np` « not parameterized » (en-têtes des scripts), et non « non pondérés » comme l'indique `scripts/04_calibration/config/schemas_calibration.csv`.

Chronologie : 312X et 444X dès le premier commit (`bf7c7f7`, 5 juin 2025) ; 180X apparaît le 19 juillet 2025 (`379c8a3`) ; seul 180X existe en 2026/T1.

**Pourquoi 180X : aucun document ne le dit.** Ce que le code suggère **(inférence)** : c'est le schéma le plus parcimonieux, sans croisement région × milieu, donc avec moins de cellules de petite taille ; 312X et 444X ont demandé des bornes très larges (jusqu'à c(0.0001, 50)) ou ont été lancés sans bornes avec une tolérance relâchée ; `scripts/check_calibration.r` compte les effectifs bruts par région × sexe × milieu × âge, ce qui est l'outil d'un tel arbitrage.

### 7.10 Choix des bornes : historique

Les bornes sont choisies à la main pour chaque trimestre, sans critère écrit. Bornes actuelles du 180X :

| Trimestre | Bornes | maxit | epsilon | force |
|---|---|---|---|---|
| 2024/T2 | c(0.01, 4) | 30 | 1e-6 | FALSE |
| 2024/T3 | c(0.02, 6) | 30 | 1e-6 | FALSE |
| 2024/T4 | c(0.01, 5) | 30 | 1e-6 | FALSE |
| 2025/T1 | c(0.01, 6) | 30 | 1e-4 | FALSE |
| 2025/T2 | c(0.01, 6) | 100 | 1e-10 | TRUE |
| 2025/T3 | c(0.01, 6) | 30 | 1e-4 | TRUE |
| 2025/T4 | c(0.01, 4.5) | 30 | 1e-4 | TRUE |
| 2026/T1 | c(0.01, 5) | 30 | 1e-4 | TRUE |

Étapes marquantes : abandon des bornes négatives suggérées par `bounds.hint` (`3e5a1b8`, `dbd2d48`) ; élargissement et harmonisation (`9138da6`, `100e269` « refines calibration bounds… to enhance flexibility », `0dd8854`). Le passage à `force = TRUE` à partir de 2025/T2 n'est pas commenté.

---

## 8. Totaux de population

**Source** : projections de population de l'ANStat dérivées du RGPH 2021, livrées en classeurs `ANStat_Trimestre*.xlsx` (feuilles `TAB1_T<q>_<a>` : totaux ; `TAB2_T<q>_<a>` : région × sexe × milieu × âge).

**Fichier lu par le calage** : `data/06_POPULATION_ESTIMATES/<a>/T<q>/POP_LFS_BY_REGION_SEX_2AGEGR_<a>_T<q>.xlsx`, 180 lignes (132 régionales puis 48 nationales), colonnes `Domain`, `Région (33)`, `Sexe`, `Milieu`, `groupe_age`, `Nombre`. L'étape 03 associe chaque ligne à sa contrainte par le **nom exact** de la région (accents compris).

**Construction.**

- 2024-2025 : `01_utils/Remplissage_tableau_knowns_totals.R` produit `KNOWNS_TOTAL_180X_1D_<T>.xlsx`, puis une étape manuelle non tracée le recopie dans le gabarit.
- À partir de 2026 : `01_utils/build_pop_lfs_by_region_sex_2agegr_from_anstat.py` (README associé, commit `d0a9ff5`). Le format ANStat change en 2026 : colonnes 0-15, 16-19, …, 65+ et une colonne « 15 ans et plus » qui chevauche. Formules : total = somme des groupes ; 0-14 = total − 15+ ; 15-19 = 15+ − (20-24 + … + 65+). Arrondi par plus forts restes, puis ajustement unité par unité des lignes régionales pour retrouver exactement les marges nationales (nécessaire au §7.4). Contrôle contre TAB1 ; échec si un écart est non nul.

**Choix — l'âge de 15 ans.** Le chevauchement 0-15 / 15+ des sources ANStat explique probablement l'essai du schéma 182X (âge = 15 isolé) en 2024/T2 **(inférence)**.

---

## 9. Produits dérivés

### 9.1 Poids ménages (`04_calibration/household_weights.r`)

Comme le calage est individuel, le poids d'un ménage est une moyenne des poids de ses membres :

$$
w_m = \frac{1}{n_m} \sum_{i \in m} \text{FINAL\_WEIGHT}_i
$$

Deux versions : sur les membres de 15 ans et plus (`menage_weights_15plus_<T>.dta` ; les ménages sans adulte en sont absents) et sur tous les membres (`menage_weights_all_<T>.dta`). Écrites dans `data/04_weights/<T>/household_weights/`. `household_weights_yearly_quarter.r` fait de même en mode annuel. `household_calibration.R` calcule un facteur de marge par milieu qui n'est utilisé nulle part et réécrit `base_weights_<T>.dta` en place : à ne pas lancer.

### 9.2 Poids annuels (`08_yearly_weights/ponderation_annuelle.r`)

**Méthode** : empilement des trimestres de l'année et division par leur nombre *K* (manifeste : « direct pooled-quarter weighting: quarterly FINAL_WEIGHT / K »).

$$
w^{\text{annuel}}_{i,q} = \frac{w_{i,q}}{K}
$$

Un individu interrogé plusieurs trimestres apparaît plusieurs fois. Clé : `trimestre` (`AAT<q>`, par exemple `25T1`) + `interview_key` + `membres_id`.

La note méthodologique dérive des coefficients optimaux $\alpha_q$ (minimum de variance) ; la pratique retenue est $\alpha_q = 1/K$.

**Vérification (commit `7a5771b`, 21 août 2026)** : avant d'empiler, le script vérifie que le `FINAL_WEIGHT` publié de chaque trimestre est identique, à 1e-10 près par `INDKEY`, aux poids de l'objet de calage enregistré dans `*_IMAGE.RData`. Il refuse aussi les clés en double et les poids non positifs.

**Sorties** dans `data/04_weights/<année>/` : `LFS_WEIGHTS_<année>.parquet` (produit principal), `.dta` (compatibilité), `_quality.csv`, `_manifest.json` (méthode, trimestres, MD5 des sources).

**Année incomplète.** 2024 ne compte que T2, T3, T4. Avant `2950590` (24 octobre 2026), le script exigeait les quatre trimestres ; il accepte désormais `--quarters=T2,T3,T4` et le champ `annual_coverage` (`ANNEE_COMPLETE` / `ANNEE_INCOMPLETE`). Le fichier 2024 a été produit ainsi le 20 octobre 2026 (48 796 lignes) ; 2025 compte 96 276 lignes. 2026 se calculera avec `--quarters=T1,T3,T4` : T2 2026 n'est pas publié (§2.4).

**Historique.** Août 2025 : moyenne des poids par individu (`poids_annuels.r`), puis division par le nombre de trimestres (`agregate_year.R`) ; janvier 2026 : `ponderation_annuelle.r` avec détection automatique des trimestres (`0dd8854`) et un do-file Stata pour 2024 ; août 2026 : réécriture vérifiée (`7a5771b`).

À partir de 2026, les poids trimestriels intègrent la non-réponse modélisée ; les poids annuels 2026 aussi.

---

## 10. Précision et contrôle qualité

### 10.1 Contrôles intégrés au calage

Voir §7.7. Plus, dans `05_quality_control/` : `Check_Ponderations.do` (somme des poids par région = `nb_men_reg`), `quality_control_weights.r` (doublons de clés).

### 10.2 Erreurs types

**La précision officielle se calcule dans le dépôt [`ENE_PRECISION_ESTIMATION`](https://github.com/cae-ins/ENE_PRECISION_ESTIMATION)** : erreurs types, intervalles de confiance, CV et effets de plan des indicateurs trimestriels et annuels, par linéarisation de Taylor sur l'objet de calage publié dans `silver/enem/<T>/poids/calibration_design/`, avec la covariance entre trimestres due à la rotation 2-2 (Berger-Priam). La méthode est dans sa note `docs/NOTE_METHODOLOGIQUE_PRECISION_ENE.md`. Ce dépôt-ci ne fait que publier l'objet de calage.

Les outils de ce dépôt ci-dessous servent au contrôle ou aux simulations ; trois outils, de qualité inégale :

1. **`04_calibration/STANDARD_ERRORS/<a>/<T>/07*.R`** (cas d'étude OIT 17) : `svystatTM` et `svystatR` de ReGenesees sur l'objet calé, soit la linéarisation de Taylor de l'estimateur par calage, avec effet de plan. C'est la méthode correcte, mais elle ne couvre que 2024/T2 à 2025/T2 et utilise des noms de variables OIT absents des données ENE.
2. **`05_quality_control/postestimation_quality.R`** (`fc68676`, décembre 2025) : `svydesign(ids = ~1, weights = ~pmencor_ind)` sur la base de travail `Base_Travail_BT_vf.dta`, par trimestre, région et district. **Sans grappes ni strates** : les erreurs types sont celles d'un sondage aléatoire simple pondéré, probablement sous-estimées. Drapeaux A (CV < 15 %), B (15-30 %), C (≥ 30 %), F (estimation absente).
3. **`11_modif_design/5_estimate_precision_auto.r`** : `svydesign(ids = ~PSUKEY+HHKEY, strata = ~STRATAKEY, nest = TRUE)`, plan à deux degrés, utilisé pour les simulations.

Les seuils de CV « < 5 % excellent, 5-10 % bon, 10-15 % modéré, > 15 % faible » cités dans l'ancien `CLAUDE.md` n'apparaissent dans aucun script de 04 ou 05 ; le code applique 15 / 30 %.

La note méthodologique donne pour SU3 un intervalle de confiance à 95 % de ±1,67 point la première année, ±0,84 en régime de croisière, ±0,48 en annuel (premières interrogations seules) et environ ±0,42 (tous ménages).

---

## 11. Échanges avec les autres dépôts : MinIO

### 11.1 Principe

R et Stata n'accèdent jamais directement au stockage. Les scripts Python de `ENE_MEDALLION_ORCHESTRATION/ene_medallion_io/` (client `boto3`) font les entrées-sorties ; ce dépôt les appelle par un lanceur Python, `scripts/medallion/medallion.py` (sous-commandes `download`, `upload-inputs`, `upload-outputs`), qui fonctionne sous Windows comme sous Linux. Les anciens wrappers PowerShell ont été retirés le 24 octobre 2026. Chaque dépôt a ses préfixes : la pondération écrit `base_ponderee` et `poids`, la tabulation `base_indicateurs` et `indicateurs`, la précision `precision`.

### 11.2 Buckets et préfixes

| Bucket | Préfixes utilisés par ce dépôt |
|---|---|
| staging | `enem/<T>/brutes/denombrement/`, `enem/references/` (lecture) |
| silver | `enem/<T>/menage/`, `enem/<T>/individu/` (lecture) ; `enem/<T>/poids/` et `poids/calibration_design/<schéma>/` (écriture) |
| gold | `enem/<T>/base_indicateurs/` (lecture) ; `enem/<T>/base_ponderee/` (écriture) ; `enem/annual/<année>/base_ponderee/` (écriture) |

Sans `--overwrite`, un objet existant n'est jamais remplacé. Chaque envoi de dossier dépose un manifeste dans `_manifests/`.

### 11.3 Le contrat de données de la pondération

Principe (adopté le 24 octobre 2026) : **données, code et calcul sont indépendants.** Le code ne contient aucun chemin propre à un poste ; tout ce qu'il lit est sur MinIO et se télécharge dans `data/` ; tout ce qu'il produit est publié sur MinIO. N'importe quel poste qui a le code et un accès à MinIO peut refaire n'importe quel trimestre.

La liste des entrées est écrite à un seul endroit : `ENE_MEDALLION_ORCHESTRATION/ene_medallion_io/weights_contract.py`. Pour chaque fichier, elle donne son emplacement MinIO et sa place sous `data/`.

| Entrée | MinIO | Destination locale | Propriétaire |
|---|---|---|---|
| Comptages RGPH 2021 | `staging/enem/references/rgph2021/` | `data/03_processed/RP_2021/` | pondération |
| Table de rotation | `staging/enem/references/organisation/` | `data/01_raw/Organisation/` | pondération |
| Projections ANStat | `staging/enem/references/population/` | `data/01_raw/RpProj/`, `data/06_POPULATION_ESTIMATES/<a>/` | pondération |
| Dénombrement | `staging/enem/<T>/brutes/denombrement/` | `data/01_raw/Denombrement/<T>/` | pondération |
| Dénombrements mis à jour | `staging/enem/<T>/brutes/denombrement_update/` | `data/01_raw/Denombrement_update/<T>/` | pondération |
| Totaux de calage | `staging/enem/<T>/population/` | `data/06_POPULATION_ESTIMATES/<a>/T<q>/` | pondération |
| Fichiers apurés ménages, individus | `silver/enem/<T>/{menage,individu}/` | `data/02_cleaned/{Menage,Individu}/<T>/` | apurement |
| Poids des cohortes (non-réponse modélisée) | `silver/enem/<cohorte>/poids/base_weights/menage_<cohorte>.dta` | `data/04_weights/<cohorte>/base_weights/` | pondération |
| Bases d'indicateurs des cohortes (idem) | `gold/enem/<cohorte>/base_indicateurs/Traite_<AATq>.dta` | `data/03_processed/base_indicateurs/<cohorte>/` | tabulation |

Le téléchargement d'un trimestre prend les références, puis les fichiers apurés et le dénombrement de **tous** les trimestres depuis T2 2024 (la table de correspondance des entretiens et les cohortes réinterrogées en ont besoin), puis les entrées des cohortes. Il liste à la fin les objets absents de MinIO.

### 11.4 Ce qui est publié

- **Entrées** (`medallion.py upload-inputs`) : dénombrement, mises à jour, totaux de calage du trimestre ; `--references` pour les références ; `--all-quarters` pour tout l'historique. L'option `--with-cleaned-surveys` sert seulement à la migration des anciens trimestres (fichiers apurés, jamais remplacés).
- **Poids trimestriels** (`medallion.py upload-outputs`) : vers `silver/enem/<T>/poids/`, **uniquement les produits de la liste** `QUARTERLY_WEIGHT_PRODUCTS` (fichiers `base_weights_`, `inconsistent_rows_`, `individu_`, `SR_individu_`, `menage_`, `probabilities_gt1_`, diagnostics `nr_modele_*` et `nr_comparaison_*`, `calibrated_weights/individu_<T>_CAL.dta`, poids ménages). Les fichiers d'essai laissés dans le dossier local ne partent jamais. Plus l'image de calage vers `silver/.../poids/calibration_design/180X_1D/`, et `individu_<T>_CAL.dta` et `menage_<T>.dta` vers `gold/enem/<T>/base_ponderee/`.
- **Poids annuels** (`upload-outputs --period annual --year <a>`) : `LFS_WEIGHTS_<a>.parquet` puis `.dta` vers `silver/enem/annual/<a>/poids/` et `gold/enem/annual/<a>/base_ponderee/` ; le rapport qualité et le manifeste vers `silver`.

### 11.5 Configuration

Variables lues dans `.env` (racine du dépôt ou de l'orchestration) : `MINIO_ENDPOINT`, `MINIO_ACCESS_KEY`, `MINIO_SECRET_KEY`, `ENE_QUARTER`, `ENE_PERIOD`, `ENE_YEAR`, `ENE_CALIBRATION_STRATEGY`. Modèle sans valeurs réelles : `.env.example`. Le lanceur `scripts/medallion/medallion.py` charge `.env`, ajoutent l'hôte MinIO à `NO_PROXY` et cherchent le dépôt d'orchestration à côté de celui-ci, ou dans `ENE_ORCHESTRATION_ROOT`. Côté R, `ENE_BASE_DIR` et `ENE_QUARTER` remplacent les valeurs de `config/1_config.r`.

**Sans accès au serveur**, les publications attendent ; le circuit ne change pas. Pour tester une étape qui a besoin d'un fichier normalement téléchargé, on place une copie à l'emplacement cible du téléchargement, jamais un chemin vers l'autre dépôt.

### 11.6 Migration du 24 octobre 2026

Avant cette date, seul T1 2026 suivait le circuit, et les poids y étaient rangés dans `gold/.../base_indicateurs/`, préfixe du dépôt de tabulation, parce qu'ils avaient été publiés avant l'introduction de `base_ponderee` (orchestration `d41158f`, 21 août 2026). Les entrées de la pondération (dénombrement, références) n'étaient pas sur MinIO. La migration (`ENE_MEDALLION_ORCHESTRATION/migrations/20261024_reorganisation_ponderation.py`, plus les publications standard) :

1. publie les entrées de tous les trimestres et les références ;
2. publie les fichiers apurés des trimestres T2 2024 à T4 2025 qui manquaient dans `silver` ;
3. publie les poids de tous les trimestres (T1 2026 avec la non-réponse modélisée) et les poids annuels 2024 et 2025 ;
4. publie les bases `Traite_` des trimestres publiés dans `gold/.../base_indicateurs/` ;
5. retire les trois fichiers de poids de `gold/enem/T1_2026/base_indicateurs/`, avec un manifeste qui documente le retrait.

Les anciens emplacements (bucket `enem`, `staging/ene/`) ne sont pas modifiés : ils relèvent aussi de l'apurement.

---

## 12. Modules annexes

### 12.1 Indicateurs (09_create_indicators)

Traduction partielle en R du code Stata des tabulations : variables socio-démographiques (`01_variables_objectives.R`) et définitions BIT (`02_variables_indivs.R` : population en âge de travailler à 16 ans et plus, emploi présent et absent, chômage, main-d'œuvre potentielle, SU1 à SU4, CISE-18, informalité, NEET). `03_compute_indicator` ne source que le script 01. Les tabulations officielles restent en Stata dans `ENE_INDICATORS_TABULATIONS`.

### 12.2 Graphiques CCM (99_ccm)

Neuf scripts ggplot (avril 2026) dont les valeurs sont saisies à la main pour T2 2024 à T2 2025. Aucun ne lit de base.

### 12.3 Gestion des données (10_data_management)

- `export_weights_to_indicators.R` : extrait `poids_<T>.dta` et lance l'envoi vers MinIO. Les colonnes cherchées (`pmencor_ind`, `membre_id`…) n'existent pas dans le fichier calé : l'extrait peut ne contenir aucun poids (§15). La tabulation lit de toute façon `base_ponderee`.
- `clean_income_variables.R`, `income_vars_config.R` : squelettes de nettoyage des revenus (cinq détecteurs de valeurs aberrantes), avec des noms de variables provisoires ; non branchés.
- `minio_manager.py` : ancien outil (un seul bucket), antérieur au circuit actuel.

### 12.4 Simulation de réduction d'échantillon (11_modif_design)

Objectif : garder toutes les ZD et réduire le nombre de ménages par ZD, puis mesurer l'effet sur les CV (README : « presque toute la variation est générée au premier degré »). Paramètres du master `0_MASTER_SIMULATION.r` : trimestre (format `AAAA_TX`), ratio (0,75), 30 itérations, graine. Étapes : tirage des ménages par ZD (`ceiling(n × ratio)`), poids de base avec 12 × ratio ménages, calage 180X (bornes c(0.01, 6)), rattachement des indicateurs, précision (plan à deux degrés). Parallélisation `furrr`.

Résultats saisis dans `report_variation.r` (T3 2025) : CV de SU1 de 7,93 % (100 %), 12,46 % (75 %), 11,99 % (67 %), 14,00 % (50 %) ; conclusion écrite : 75 % est le scénario optimal, 50 % une limite.

État : la chaîne `_auto` ne tourne pas telle qu'elle est commitée (chemin d'entrée mal construit) ; les sorties existantes viennent des versions non `_auto`. Le README est obsolète.

### 12.5 Poids longitudinaux (12_longitudinal_weights, commit `82c097c`)

Probabilités de retour d'un individu entre deux vagues, pour les transitions R1 → R2, R3 → R4 (un trimestre) et R1 → R3 (quatre trimestres). Un logit par fenêtre, avec des covariables mesurées à l'origine seulement (les agrégats sur toutes les vagues sont exclus parce qu'ils contiennent de l'information postérieure). Poids :

$$
w^{L}_{i,t,h} = \frac{w^{CS}_{i,t}}{\hat p_{i,t,h}}
$$

winsorisé au 99e centile par fenêtre. Le recalage 180X sur les marges de la vague d'origine reste à coder. Configuration : `config/longitudinal_propensity.yml` ; tests : `tests/testthat/test-longitudinal-propensity.R`.

---

## 13. Exploitation : produire un trimestre

### 13.1 Environnement

- R (≥ 4.4). Le calage de 2026/T1 tourne aussi bien dans RStudio qu'avec `Rscript` depuis la racine du dépôt : en mode batch, `View()` est neutralisé et Excel n'est pas ouvert. Les dossiers de calage des trimestres publiés (2024-2025) gardent leur code figé et demandent RStudio et Excel.
- Paquets : `scripts/00_setup/install_required_packages.R` (n'installe pas `plotly`, `ggplot2`, `gridExtra`, `arrow`, `zoo`, `tibble`, utilisés par certains scripts) ; ReGenesees depuis GitHub (`DiegoZardetto/ReGenesees`).
- Python (`boto3`) et le dépôt `ENE_MEDALLION_ORCHESTRATION` pour MinIO ; un fichier `.env`.
- Stata pour les fichiers de suppression `.do`.
- Répertoire de travail : la racine du dépôt.

### 13.2 Pas à pas (trimestre T à partir de T1 2026)

1. Fixer le trimestre : variable d'environnement `ENE_QUARTER=T<q>_<a>`, ou `TARGET_QUARTER` dans `config/1_config.r`.
2. Vérifier que la ligne du trimestre dans `quarter_resurvey.xlsx` décrit les cohortes réellement réinterrogées (écarts de terrain : §2.4), et que `SEGMENT_2_FIRST_QUARTER` correspond au segment dénombré (`hh7` du dénombrement).
3. Télécharger les entrées : `python scripts/medallion/medallion.py download --quarter T<q>_<a>`. La fin du journal liste les objets absents ; il ne doit rester que des absences attendues (par exemple les bases `Traite_` d'un trimestre que la tabulation n'a pas encore publié). Les nouvelles entrées du trimestre (dénombrement, mises à jour, totaux) se publient avec `python scripts/medallion/medallion.py upload-inputs --quarter T<q>_<a>`.
4. Lancer, dans l'ordre du §3.1, les étapes 1 à 10. Après `3_assign_firstTrim_interview.R`, relancer les suppressions `.do` et `5_delete_individu_age_sexe.r`.
5. Ajouter dans `07_correction_quarter/` les corrections propres au trimestre si le dénombrement en demande.
6. Lancer `Rscript scripts/03_nonresponse/2_attrition_propensity.R`. Lire `nr_modele_diagnostics_<T>.csv` (AUC, tests) et `nr_modele_classes_<T>.csv` (taux de réponse par classe).
7. Créer le dossier de calage du trimestre en copiant celui du trimestre précédent (`QUARTERLY_WEIGHTING/<a>/<T>/180X_1D/`), puis ajuster les bornes dans 04c si nécessaire.
8. Préparer les totaux : `python scripts/01_utils/build_pop_lfs_by_region_sex_2agegr_from_anstat.py --year <a> --quarter T<q> --template <gabarit>`.
9. Lancer le master, dans RStudio ou avec `Rscript scripts/04_calibration/QUARTERLY_WEIGHTING/<a>/T<q>/180X_1D/00_Master_Calibration_180X_1D.R`. Vérifier : `ecal.status.production` (codes de retour nuls ; un avertissement est émis sinon), `X_Summary_Table` (pas d'« Error », `Diff_Known_Tot_Final_Est` nul), `table_check` (aucun écart > 100), le calage `_cellules` (il s'arrête en cas de non-convergence). Les étapes 06 et 07f, absentes du dossier, sont signalées et ignorées.
10. Lancer `Rscript scripts/03_nonresponse/3_compare_nonresponse_methods.R` et lire la répartition des poids par rang.
11. Lancer `scripts/04_calibration/household_weights.r`.
12. Publier : `python scripts/medallion/medallion.py upload-outputs --quarter T<q>_<a>` (seuls les produits de la liste partent ; `--overwrite` uniquement pour une republication voulue).
13. Une fois l'année complète : `Rscript scripts/08_yearly_weights/ponderation_annuelle.r --year=<a>`, puis `python scripts/medallion/medallion.py upload-outputs --period annual --year <a>`.

Pour un trimestre antérieur à T1 2026 : sauter l'étape 6 ; le master de ces trimestres n'a ni garde ni calage de référence.

### 13.3 Fichiers à connaître

| Fichier | Contenu |
|---|---|
| `data/04_weights/<T>/base_weights/base_weights_<T>.dta` | Une ligne par ZD : comptages, probabilités, poids de base, facteurs |
| `.../base_weights/inconsistent_rows_<T>.dta` | ZD avec un code d'incohérence |
| `.../base_weights/individu_<T>.dta` | Entrée du calage (`d_weights`, `d_weights_cellules`) |
| `.../base_weights/menage_<T>.dta` | Ménages avec poids de base (publié en gold) |
| `.../base_weights/nr_modele_*.csv`, `nr_comparaison_*.csv` | Diagnostics de la non-réponse |
| `.../calibrated_weights/individu_<T>_CAL.dta` | **Produit de production** |
| `data/07_QUARTERLY_WEIGHTING/<a>/T<q>/180X_1D/` | Fichiers intermédiaires et diagnostics du calage |
| `data/04_weights/<a>/LFS_WEIGHTS_<a>.parquet` | Poids annuels |

---

## 14. Chronologie des choix

| Date | Commit | Décision ou changement |
|---|---|---|
| 5 juin 2025 | `bf7c7f7` | Premier code : préparation, poids de base, calages 312X et 444X (gabarits OIT) |
| 25 juin 2025 | `b4f61f6` | Une ligne par ZD (dénombrement le plus récent), `first_trim`, correspondance des réinterrogations |
| 11 juillet 2025 | `2547bac` | Distinction premières interrogations / réinterrogations ; fichier `SR_` ; calage sur `d_weights` |
| 19 juillet 2025 | `379c8a3` | Introduction du schéma 180X_1D ; corrections de dénombrement T2 2024 |
| 27 août 2025 | `23d2f4a` | Non-réponse : facteur par région × milieu au lieu de par segment |
| 29 août 2025 | `3e5a1b8` | « Modifications d'Antonio » : taille en ménages, nombre de ZD effectif, non-réponse par région, bornes positives |
| 30 sept. 2025 | `dbd2d48` | Abandon des bornes négatives de `bounds.hint` |
| Sept.-nov. 2025 | `8fb0d0d`, `2a8bd39` | Passage par GitLab (`cae-anstat/enem_weight_nv`) |
| 4 nov. 2025 | `3e32644` | Suppression des individus sans poids |
| 21 nov. 2025 | `42bad4d` | Premier usage de MinIO pour les données |
| 18 déc. 2025 | `9138da6` | Suppression des ménages au-delà de 12 par ZD ; contrôle des totaux calés ; éligibilité à 15 ans |
| 21 déc. 2025 | `fc68676` | Erreurs types, IC et CV des SU par trimestre |
| 23 déc. 2025 | `100e269` | Bornes élargies, `maxit` 30, `epsilon` 1e-4 ; `check_calibration.r` |
| 26 déc. 2025 | `a7375ef` | Schéma 184X (devenu 182X) pour 2024/T2 |
| 1er janv. 2026 | `0dd8854` | Suppressions par trimestre ; nouveaux poids annuels |
| 11 janv. 2026 | `a317c04` | Orchestrateur générique `run_calibration.R` (archivé en juin) |
| Janv.-févr. 2026 | `7e46d79`, `5b6614b`, `21e5f84` | Simulation de réduction d'échantillon |
| 7 avril 2026 | `dd074cb` | Finalisation T4 2025 ; graphiques CCM |
| 30 mai 2026 | `b98db03`, `39c0984` | Échanges entre dépôts par MinIO (fin des copies directes) |
| 6 juin 2026 | `d0a9ff5` | Finalisation T1 2026 ; archivage de `run_calibration.R` ; script Python des totaux |
| 6 juin 2026 | `f66d621` | Fichiers de dénombrement ignorés (IDSeg) ; contrôle des probabilités > 1 |
| 21 août 2026 | `7a5771b` | Poids annuels vérifiés contre l'objet de calage ; `.env` retiré du suivi |
| 24 oct. 2026 | `427ed7d` | Non-réponse modélisée en production à partir du T1 2026 ; calage de référence `_cellules` |
| 24 oct. 2026 | `bf59339`, `2950590` | Contrôle π > 1 non bloquant ; poids annuels d'une année incomplète (`--quarters`) |
| 24 oct. 2026 | `6a9fcb3`, `f39b077`, `0befa09` | Plus aucun chemin propre au poste ; toutes les données par MinIO (contrat de données) ; lanceur Python `medallion.py` à la place de PowerShell |
| 24 oct. 2026 | `82c097c`, `140aa99` | Poids longitudinaux (probabilités de retour) ; ce manuel |
| 25 oct. 2026 | `42848d8` | Segment 2 pour les ZD entrées à partir de T3 2026 (`segment_actif()`) ; cohorte T2 2026 retirée de la rotation (premières interrogations reportées en T3 2026) ; cohortes de la non-réponse modélisée lues dans `quarter_resurvey.xlsx` |
| 26 oct. 2026 | `9264ae3` | Corrections de dénombrement T3 2026 (11 entretiens vides retirés) |

---

## 15. Limites, risques et dette technique

Classés du plus urgent au moins urgent.

### 15.1 À traiter avant le prochain trimestre

1. **Segment 2.** Traité depuis le 25 octobre 2026 par `segment_actif()` (§4.1) : segment 2 pour les ZD entrées à partir de T3 2026. Un troisième passage (segment 3) demandera d'étendre la règle.
2. **Bases `Traite_` à republier par la tabulation.** La migration du 24 octobre 2026 a publié celles des trimestres T2 2024 à T4 2025 (copies locales du dépôt de tabulation, dont certaines venaient de son dossier `legacy/`). La tabulation doit désormais publier elle-même la base de chaque trimestre (`07_upload_quarter_bases`), y compris celle de T1 2026 une fois recalculée avec les nouveaux poids : elle servira de cohorte à partir de T2 2026. Les indicateurs de T1 2026 publiés en juin reposent sur l'ancienne méthode et doivent être recalculés.
3. **Secrets dans l'historique git.** Le `.env` (de `42bad4d` à `7a5771b`), `config/credentials.json` (jusqu'à `d0a9ff5`) et `ARCHITECTURE_ENE_PIPELINE.md` (`dd074cb`) ont contenu des identifiants MinIO. Les fichiers actuels sont nettoyés, mais les valeurs restent dans l'historique : il faut changer ces identifiants côté serveur.
4. **Publications MinIO en attente (T3 2026).** Le dénombrement de T3 2026 et `quarter_resurvey.xlsx` corrigé (cohorte T2 2026 retirée) ne sont que locaux : `python scripts/medallion/medallion.py upload-inputs --quarter T3_2026 --references`. T2 2026, non publié, doit être traité avant T3 2026. `COHORT_OFFSETS` du contrat MinIO reste sur les décalages fixes (sur-ensemble sans blocage) : à aligner sur la table de rotation.

### 15.2 Méthode

5. **Statut de convergence non testé** pour le calage de production, avec `force = TRUE` : un calage non convergé produit des poids sans erreur. Seuls `X_Summary_Table` et `table_check` le révèlent.
6. **Strates = régions seules** dans le plan déclaré, alors que la non-réponse et le tirage tiennent compte du milieu dans certains documents : à confirmer avec le plan réel.
7. **Erreurs types de `postestimation_quality.R`** sans grappes ni strates : probablement sous-estimées. La méthode correcte (`STANDARD_ERRORS`) n'est plus à jour depuis 2025/T2.
8. **Remplissage de `nb_men_reg`** dans `1_gen_weights_columns.R` : les valeurs manquantes reçoivent la première valeur non manquante du fichier entier, pas de la région.
9. **Poids WR** attribués à toutes les lignes de la région, y compris les réinterrogations.
10. **Critère de suppression des ménages au-delà de 12 par ZD** non documenté.
11. **Bornes de calage** choisies à la main, sans critère écrit.

### 15.3 Code

12. Les libellés de `04f_XFormats_180X_1D.R` suivent l'ordre « régional d'abord » alors que le code numérote le national d'abord : tous les libellés de `X_Summary_Table` sont décalés (le calage n'est pas affecté).
13. Les étapes 06 (tableau 1) et 07f (précision) n'existent pas dans les dossiers 180X ; le master 2026/T1 les signale et continue. Le calcul de précision relève du dépôt de précision (image publiée dans `calibration_design/`).
14. Les dossiers de calage des trimestres publiés (2024-2025) gardent des chemins absolus et des étapes interactives ; ils ne sont plus relancés. Le master 2026/T1 a été corrigé (chemins relatifs, mode batch, plus de réinstallation de ReGenesees) et sert de modèle aux trimestres suivants.
15. Les schémas 180X et 444X écrivent le même fichier d'export : le dernier lancé écrase la production.
16. `correction_T4_2024.r` (réaffectation) est sans effet ; `update_interviewkey_map.R` perd `v1interviewkey` ; `3_assign_firstTrim_interview.R` réécrit tous les trimestres.
17. Choix de fichiers « le plus récent par date de modification » (dénombrements mis à jour, correspondances) : fragile.
18. Chemins absolus : retirés du code actif le 24 octobre 2026 (`BASE_DIR` détecté, lanceur MinIO en Python, fichiers `.do` en chemins relatifs, fichier RGPH brut via `ENE_RGPH_SAV`). Il en reste dans le code figé des trimestres publiés et dans `reports/Echantillonnage_ENEE_Saturation_Interieur.ipynb` (travail d'échantillonnage d'une autre équipe, sur des fichiers externes).
19. `export_weights_to_indicators.R` cherche des colonnes de poids qui n'existent pas dans le fichier calé.
20. Doublons de scripts et code mort : `concat_denomb.R`, `denomb_update_log.r`, `2_0_denomb_special_updates.r`, `0_fonctions_utiles`, `gen_weights_columns_2.R`, `calc_base_weights_2.R`, `inc_probs_functions.R`, `4_gen_interviewkey_map.R`, `calc_nb_men_indiv_ZD.R`, `comp_followup_matrix.R`, `household_calibration.R`, `07_correction_quarter/menage/`, dossiers « - Copie », `scripts/06_monitoring/` vide.

---

## 16. Écarts entre l'ancienne documentation et le code

Ce manuel remplace, sur les points ci-dessous, les documents antérieurs (`README.md`, `CLAUDE.md`, `ARCHITECTURE_ENE_PIPELINE.md`, `docs/00_index.md` à `docs/05_processus_complet.md`, note méthodologique).

| Document | Ce qu'il dit | Ce que fait le code |
|---|---|---|
| `CLAUDE.md` | `run_calibration.R` est l'orchestrateur | Archivé ; le point d'entrée est le master par trimestre |
| `CLAUDE.md` | `config/schemas_calibration.csv`, 14 schémas | `scripts/04_calibration/config/schemas_calibration.csv`, 13 schémas, utilisé seulement par l'architecture archivée |
| `CLAUDE.md`, `README.md`, `docs/04`, `docs/05`, note | Non-réponse par région × milieu | Par région seule, sans plafonnement ; modélisée à partir de T1 2026 |
| `CLAUDE.md` | `SR_individu` = poids avec non-réponse | `SR_` = premières interrogations seules ; les deux fichiers sont corrigés de la non-réponse |
| `CLAUDE.md` | Variables `poids_de_base`, `poids_final` | `base_weight_HH`, `corrected_weight_HH`, `d_weights`, `FINAL_WEIGHT` |
| `CLAUDE.md` | Seuils de CV 5 / 10 / 15 % | Le code applique 15 / 30 % |
| `README.md` | Scripts `calc_base_weights.R`, `tracking.R`, `non_response.R`, `calibration.R`, `quality_checks.R` | N'existent pas sous ces noms |
| `ARCHITECTURE_ENE_PIPELINE.md` | `calc_base_weights_2.R` et `comp_followup_matrix.R` en production ; schémas 156X/312X/444X | Scripts hérités ; production en 180X_1D |
| `ARCHITECTURE`, `docs/05` | Poids final `pmencor_ind` ; sortie gold `individu/membres.dta` | `FINAL_WEIGHT` ; gold `base_ponderee/individu_<T>_CAL.dta` |
| `docs/04` | Poids annuel avec K détecté automatiquement | K = 4 par défaut, ou `--quarters` explicite |
| Note méthodologique | Tirage proportionnel aux individus | Ménages |
| Note méthodologique | Population en âge de travailler : 16 ans et plus | Calage coupé à 0-14 / 15+ ; indicateurs à 16+ |
| En-têtes des fichiers 180X | « 312 constraints », « region, urban and rural » | 180 contraintes, sans milieu au niveau régional |

---

## 17. Annexes

### 17.1 Glossaire des variables

| Variable | Sens |
|---|---|
| `hh2`, `hh3`, `hh4`, `hh8`, `hh7`, `hh6` | Région, département, sous-préfecture, ZD, segment, milieu |
| `interview_key` | Clé de l'entretien ménage |
| `membres_id` | Numéro du membre dans le ménage |
| `v1interviewkey` | Clé de la première interrogation du ménage |
| `rgmen` | 1 = première interrogation, 2 = réinterrogation |
| `first_trim` | Trimestre de dénombrement (d'entrée) de la ZD |
| `hh14` | Résultat de l'entretien (1 = rempli) |
| `ageannee`, `m4confirm`, `m5` | Âge, âge confirmé, sexe |
| `nb_mens_seg` | Ménages dénombrés dans le segment |
| `nb_mens_enq` | Ménages enquêtés dans la ZD au trimestre |
| `nb_men_reg` | Ménages de la région au RGPH 2021 |
| `nb_zd_strat` | ZD de la région présentes au trimestre |
| `incoherence_code` | Code de contrôle de la ligne (§5.1) |
| `rang` | Rang d'interrogation (1 à 4), à partir de T1 2026 |
| `classe_propension` | Quintile de propension de réponse (rangs 2 à 4) |

### 17.2 Arborescence

```
config/1_config.r                    trimestre, chemins, NR_MODEL_FIRST_QUARTER
config/longitudinal_propensity.yml   module 12
scripts/00_setup/                    installation des paquets
scripts/01_utils/                    dénombrement, correspondances, nettoyage, totaux, RGPH
scripts/02_base_weights/             colonnes de pondération, poids de base, fichiers individus
scripts/03_nonresponse/              non-réponse (cellules, modélisée, comparaison)
scripts/04_calibration/              calage (QUARTERLY_WEIGHTING/<a>/<T>/<schéma>/), précision OIT, poids ménages
scripts/05_quality_control/          contrôles, erreurs types, suppressions .do
scripts/07_correction_quarter/       corrections par trimestre
scripts/08_yearly_weights/           poids annuels
scripts/09_create_indicators/        indicateurs (traduction partielle du Stata)
scripts/10_data_management/          export, revenus, ancien outil MinIO
scripts/11_modif_design/             simulation de réduction d'échantillon
scripts/12_longitudinal_weights/     poids longitudinaux (en cours)
scripts/99_ccm/                      graphiques
scripts/medallion/                   lanceur MinIO (medallion.py)
data/                                données (non versionnées)
```

### 17.3 Ordre des régions dans les contraintes X49 à X180

Quatre contraintes par région, en commençant à X49 : (H, 0-14), (H, 15+), (F, 0-14), (F, 15+).

| Première X | Région | `hh2` | Première X | Région | `hh2` |
|---|---|---|---|---|---|
| X49 | Abidjan | 10101 | X117 | Cavally | 11018 |
| X53 | Haut-Sassandra | 10702 | X121 | Bafing | 11319 |
| X57 | Poro | 11103 | X125 | Bagoué | 11120 |
| X61 | Gbêkê | 11204 | X129 | Bélier | 10821 |
| X65 | Indénié-Djuablin | 10405 | X133 | Béré | 11322 |
| X69 | Tonkpi | 11006 | X137 | Bounkani | 11423 |
| X73 | Yamoussoukro | 10207 | X141 | Folon | 10524 |
| X77 | Gontougo | 11408 | X145 | Gbôklé | 10325 |
| X81 | San-Pédro | 10309 | X149 | Grands-Ponts | 10926 |
| X85 | Kabadougou | 10510 | X153 | Guémon | 11027 |
| X89 | N'Zi | 10811 | X157 | Hambol | 11228 |
| X93 | Marahoué | 10712 | X161 | Iffou | 10829 |
| X97 | Sud-Comoé | 10413 | X165 | La Mé | 10930 |
| X101 | Worodougou | 11314 | X169 | Nawa | 10331 |
| X105 | Lôh-Djiboua | 10615 | X173 | Tchologo | 11132 |
| X109 | Agnéby-Tiassa | 10916 | X177 | Moronou | 10833 |
| X113 | Gôh | 10617 | | | |

Dans le fichier de population, les noms doivent être écrits exactement comme dans `03_Prepare_input_pop_figures_...` (en majuscules, par exemple « LÔH-DJIBOUA », « GÔH », « LA ME », « N'ZI »).

### 17.4 Références

- Deville, J.-C. et Särndal, C.-E. (1992). « Calibration Estimators in Survey Sampling ». *Journal of the American Statistical Association*, 87(418), 376-382.
- Zardetto, D. (2015). « ReGenesees: an Advanced R System for Calibration, Estimation and Sampling Error Assessment in Complex Sample Surveys ». *Journal of Official Statistics*, 31(2).
- Organisation internationale du Travail. Résolution concernant les statistiques du travail, de l'emploi et de la sous-utilisation de la main-d'œuvre, 19e CIST, 2013 ; Classification internationale des situations dans la profession (CISE-18), 20e CIST, 2018.
- Discenza, A. R. Supports de formation de l'OIT sur le calage des poids des enquêtes sur la population active (cas d'étude 6, 10, 16, 17), repris dans les en-têtes des scripts de `04_calibration/`.
- ANStat. Note méthodologique de l'ENE-M, octobre 2024 (`git show HEAD:reports/Note_Methodologique_ENEM_2024.tex`).
- Loonis, V. (2009) et Cheng (2012), cités par la note pour les schémas de rotation de l'INSEE et du BLS/Census.
