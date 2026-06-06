# Architecture du Pipeline ENE-M — Données, Pondérations, Indicateurs

**Version :** 3.0
**Date :** 2026-03-16
**Périmètre :** T4 2025 — extensible à tous les trimestres

---

## 1. Vue d'ensemble

Le dispositif ENE-M produit chaque trimestre des **indicateurs officiels du
marché du travail** pour la Côte d'Ivoire. La production repose sur trois
projets séquentiels :

```
┌──────────────┐     ┌──────────────────┐     ┌──────────────────────┐
│  PROJET 1    │     │  PROJET 2        │     │  PROJET 3            │
│  Apurement   │────▶│  Pondération     │────▶│  Tabulations         │
│  Stata       │     │  R + Stata       │     │  R + Stata           │
└──────────────┘     └──────────────────┘     └──────────────────────┘
```

**MinIO** est le lac de données centralisé. Python (boto3) est l'unique
interface — Stata et R ne communiquent jamais directement avec le stockage.

**Principe d'organisation :** les données sont rangées par **état de
maturité** (le bucket) puis par **trimestre** puis par **entité** (ce que
la donnée représente). Les projets sont des processus de transformation —
leur nom n'apparaît pas dans les chemins.

---

## 2. Entités de données

| Entité | Description | Présente dans |
|---|---|---|
| `brutes/` | Exports Survey Solutions bruts + dénombrement terrain | Staging uniquement |
| `codification/` | Tables de codification métier (.dta + .xlsx) | Staging |
| `references/` | RP 2021, tables d'équivalence (données stables, sans trimestre) | Staging |
| `menage/` | Données ménage à tous les états | Bronze → Gold |
| `individu/` | Données individus à tous les états | Bronze → Gold |
| `denombrement/` | Données de dénombrement nettoyées | Bronze |
| `poids/` | Poids de sondage intermédiaires (base + calibrés) | Silver |
| `indicateurs/` | Tableaux Excel + bulletin trimestriel | Gold |

**Règle de nommage :** `enem/{trim}/{entité}[/{sous-entité}]`
Exception : `references/` sans trimestre (données stables).

---

## 3. Structure complète MinIO

```
bucket: staging
└── enem/
    ├── {trim}/
    │   ├── brutes/
    │   │   ├── membres.dta                    Survey Solutions — individus
    │   │   ├── QX_EEC_VF.dta                  Survey Solutions — ménages
    │   │   ├── disponibilite.dta
    │   │   ├── emigration.dta
    │   │   ├── Revenu.dta
    │   │   ├── r_activite_s.dta
    │   │   ├── ...                            autres modules Survey Solutions
    │   │   └── denombrement/
    │   │       ├── ENEM_{trim}_DenomVF.dta    données terrain ZD
    │   │       └── SEG_Base{trim}_menage_*.xlsx  (un fichier par segment)
    │   └── codification/
    │       ├── codif_emploi_principal.dta
    │       ├── codif_emploi_second.dta
    │       ├── codif_pluriactivite.dta
    │       └── activites_principales_{trim}.xlsx
    └── references/                            sans trimestre
        ├── Bases_Menage_RGPH2021.dta
        ├── POP_LFS_BY_REGION_SEX_*.xlsx
        └── tables_equivalence/

bucket: bronze
└── enem/
    └── {trim}/
        ├── menage/
        │   ├── QM_S0_identification.dta
        │   ├── QM_S1_composition_menage.dta
        │   ├── QM_S2_education_formation.dta
        │   ├── QM_S3_formation_professionnelle.dta
        │   ├── QM_S4_immigration.dta
        │   ├── QM_S5_emmigration.dta
        │   ├── QM_S6_difficultes_fonctionnelles.dta
        │   └── QM_S7_logement.dta
        ├── individu/
        │   ├── INDIV_S1_autres_formes_travail.dta
        │   ├── INDIV_S2_situation_emploi.dta
        │   ├── ...
        │   └── INDIV_S15_disponibilite.dta
        └── denombrement/
            └── denombrement_clean_{trim}.dta

bucket: silver
└── enem/
    └── {trim}/
        ├── menage/
        │   ├── QM_S0_identification.dta       sections ménage apurées
        │   ├── ...
        │   └── QM_S7_logement.dta
        ├── individu/
        │   └── membres.dta                    fusionné + apuré + codifié
        │                                      (sans poids — input Projet 2)
        └── poids/
            ├── base_weights_{trim}.dta        poids de base avant calage
            └── calibrated_{spec}_{trim}.dta   une version par spécification

bucket: gold
└── enem/
    └── {trim}/
        ├── menage/
        │   └── qx_eec_vf.dta                  base ménage finale (Projet 1)
        ├── individu/
        │   └── membres.dta                    apuré + codifié + pmencor_ind
        │                                      (Projet 2 final — input Projet 3)
        └── indicateurs/
            ├── Tableaux_Indicateurs_ENEM_{trim}.xlsx
            └── Bulletin_emploi_{trim}.docx
```

---

## 4. Mapping Projets ↔ Chemins MinIO

### 4.1 Projet 1 — Apurement (`ENE-M-T4_2025/apurement/`)

| Direction | Dossier local | Chemin MinIO | Bucket |
|---|---|---|---|
| ← Download | `datain/brute/` | `enem/{trim}/brutes/` | staging |
| ← Download | `datatemp/` + `document/` | `enem/{trim}/codification/` | staging |
| ← Download | `document/` | `enem/references/` | staging |
| → Upload | `datain/standard/menage/` | `enem/{trim}/menage/` | bronze |
| → Upload | `datain/standard/individu/` | `enem/{trim}/individu/` | bronze |
| → Upload | `dataout/standard/menage/` | `enem/{trim}/menage/` | silver |
| → Upload | `dataout/standard/individu/` | `enem/{trim}/individu/` | silver |
| → Upload | `dataout/menage/qx_eec_vf.dta` | `enem/{trim}/menage/` | **gold** |

> `membres.dta` apuré+codifié est dans `silver/individu/` — il reste à pondérer.
> `qx_eec_vf.dta` va directement en gold — le ménage ne nécessite pas de pondération.

---

### 4.2 Projet 2 — Pondération (`ENE_SURVEY_WEIGHTS/`)

| Direction | Dossier local | Chemin MinIO | Bucket |
|---|---|---|---|
| ← Download | `data/05_DERIVED_VARIABLES/{an}/{trim}/` | `enem/{trim}/individu/membres.dta` | silver |
| ← Download | `data/01_raw/Denombrement/{trim}/` | `enem/{trim}/brutes/denombrement/` | staging |
| ← Download | `data/01_raw/RpProj/` | `enem/references/` | staging |
| → Upload | `data/02_cleaned/Denombrement/{trim}/` | `enem/{trim}/denombrement/` | bronze |
| → Upload | `data/04_weights/{trim}/` | `enem/{trim}/poids/` | silver |
| → Upload | membres.dta + pmencor_ind | `enem/{trim}/individu/membres.dta` | **gold** |

---

### 4.3 Projet 3 — Tabulations (`ENE_INDICATORS_TABULATIONS/`)

| Direction | Dossier local | Chemin MinIO | Bucket |
|---|---|---|---|
| ← Download | `Base/Base_brute/membres.dta` | `enem/{trim}/individu/membres.dta` × N trim | gold |
| ← Download | `Base/Base_brute/qx_eec_vf.dta` | `enem/{trim}/menage/qx_eec_vf.dta` × N trim | gold |
| → Upload | `Resultats_Tab/*.xlsx` | `enem/{trim}/indicateurs/` | gold |
| → Upload | `Publications/*.docx` | `enem/{trim}/indicateurs/` | gold |

> Projet 3 télécharge N trimestres (fenêtre du bulletin) configurée par
> `TRIMESTRES_BULLETIN` dans `.env`.

---

## 5. Pipelines détaillés

### 5.1 Projet 1 — Apurement

```
[01] DOWNLOAD  staging/enem/{trim}/brutes/         → datain/brute/
               staging/enem/{trim}/codification/   → datatemp/ + document/
               staging/enem/references/            → document/

[02] STATA     standard_db.do   → sections dans datain/standard/
               apurement.do     → sections apurées dans dataout/standard/
               Fusion.do        → membres.dta + qx_eec_vf.dta dans dataout/
               Codification.do  → membres.dta enrichi (CIAP, CITP, branches)

[03] UPLOAD    datain/standard/menage/      → bronze/enem/{trim}/menage/
               datain/standard/individu/   → bronze/enem/{trim}/individu/

[04] UPLOAD    dataout/standard/menage/    → silver/enem/{trim}/menage/
               dataout/individu/membres.dta → silver/enem/{trim}/individu/

[05] UPLOAD    dataout/menage/qx_eec_vf.dta → gold/enem/{trim}/menage/
```

**Condition de succès :**
`silver/enem/{trim}/individu/membres.dta` et `gold/enem/{trim}/menage/qx_eec_vf.dta`

---

### 5.2 Projet 2 — Pondération

```
[01] DOWNLOAD  silver/enem/{trim}/individu/membres.dta
                                           → data/05_DERIVED_VARIABLES/
               staging/enem/{trim}/brutes/denombrement/
                                           → data/01_raw/Denombrement/
               staging/enem/references/   → data/01_raw/RpProj/

[02] R         Nettoyage dénombrement

[03] UPLOAD    data/02_cleaned/Denombrement/ → bronze/enem/{trim}/denombrement/

[04] R         calc_base_weights_2.R  (π_ZD, π_ménage, poids de base)

[05] R         comp_followup_matrix.R (correction non-réponse)

[06] R         Calibration ReGenesees (région × sexe × âge, specs 156X/312X/444X…)

[07] UPLOAD    data/04_weights/{trim}/ → silver/enem/{trim}/poids/

[08] STATA     scripts/05_quality_control/  (contrôles qualité)

[09] R         Attachement pmencor_ind → membres.dta

[10] UPLOAD    membres.dta + pmencor_ind → gold/enem/{trim}/individu/
```

**Condition de succès :**
`gold/enem/{trim}/individu/membres.dta` avec variable `pmencor_ind`

---

### 5.3 Projet 3 — Tabulations

```
[01] DOWNLOAD  Pour chaque trim dans TRIMESTRES_BULLETIN :
               gold/enem/{trim}/individu/membres.dta → Base/Base_brute/
               gold/enem/{trim}/menage/qx_eec_vf.dta → Base/Base_brute/

[02] STATA     1_1_Var_objectives_to_run.do  (variables analytiques)
               1_2_Indicateur_Bulletin.do    (indicateurs : sum(pmencor_ind))
               Tabulation_Bulletin_automatise.do  (export Excel putexcel)

[03] R         tests_validation.R   (7 tests de cohérence)
               generer_bulletin.R   (rendu Rmarkdown → Word/PDF)

[04] UPLOAD    Tableaux_Indicateurs_ENEM_{trim}.xlsx → gold/enem/{trim}/indicateurs/
               Bulletin_emploi_{trim}.docx           → gold/enem/{trim}/indicateurs/
```

**Condition de succès :**
`gold/enem/{trim}/indicateurs/Bulletin_emploi_{trim}.docx`

---

## 6. Infrastructure Python partagée

### 6.1 Module `minio_client.py`

```python
# Entités — noms stables, agnostiques des projets
ENTITY_BRUTES       = "brutes"
ENTITY_CODIFICATION = "codification"
ENTITY_REFERENCES   = "references"
ENTITY_MENAGE       = "menage"
ENTITY_INDIVIDU     = "individu"
ENTITY_DENOMBREMENT = "denombrement"
ENTITY_POIDS        = "poids"
ENTITY_INDICATEURS  = "indicateurs"

def path(trim: str, entity: str, sub: str = None) -> str:
    """Construit enem/{trim}/{entity}[/{sub}]"""
    base = f"enem/{trim}/{entity}"
    return f"{base}/{sub}" if sub else base

def path_stable(entity: str) -> str:
    """Pour les entités sans trimestre (references)."""
    return f"enem/{entity}"
```

### 6.2 Arborescence des orchestrateurs

```
ENE-M-T4_2025/apurement/python/
├── .env
├── minio_client.py
├── 00_upload_staging.py    ← upload brutes + codification
└── orchestrateur.py

ENE_SURVEY_WEIGHTS/python/
├── .env
├── minio_client.py
├── 00_upload_staging.py    ← upload dénombrement + références
└── orchestrateur.py

ENE_INDICATORS_TABULATIONS/python/
├── .env
├── minio_client.py
└── orchestrateur.py
```

### 6.3 Format `.env`

```ini
MINIO_ENDPOINT=http://192.168.1.230:30137
MINIO_ACCESS_KEY=datalab-team
MINIO_SECRET_KEY=minio-datalabteam123

BUCKET_STAGING=staging
BUCKET_BRONZE=bronze
BUCKET_SILVER=silver
BUCKET_GOLD=gold

TRIMESTRE=T4_2025
TRIMESTRES_BULLETIN=T2_2024,T3_2024,T4_2024,T1_2025,T2_2025,T3_2025,T4_2025

STATA_EXE=C:\Users\f.migone\OneDrive - GOUVCI\Stata17\Stata17\StataMP-64.exe
RSCRIPT_EXE=C:\Program Files\R\R-4.4.0\bin\Rscript.exe
```

---

## 7. Flux de données global

```
Survey Solutions
      │ .dta bruts
      ▼
staging · enem/{trim}/brutes/
      │
      │  Projet 1 — Stata
      ├─▶ bronze · enem/{trim}/menage/      sections découpées
      │   bronze · enem/{trim}/individu/    sections découpées
      ├─▶ silver · enem/{trim}/menage/      sections apurées
      │   silver · enem/{trim}/individu/    membres.dta (sans poids)
      └─▶ gold   · enem/{trim}/menage/      qx_eec_vf.dta ✓

staging · enem/{trim}/brutes/denombrement/
staging · enem/references/
      │
      │  + silver · enem/{trim}/individu/membres.dta
      │
      │  Projet 2 — R/ReGenesees
      ├─▶ bronze · enem/{trim}/denombrement/   nettoyé
      ├─▶ silver · enem/{trim}/poids/           poids base + calibrés
      └─▶ gold   · enem/{trim}/individu/        membres.dta + pmencor_ind ✓

gold · enem/{trim}/individu/  ×N trim
gold · enem/{trim}/menage/    ×N trim
      │
      │  Projet 3 — Stata + R
      └─▶ gold · enem/{trim}/indicateurs/
                 Tableaux_Indicateurs_ENEM_{trim}.xlsx ✓
                 Bulletin_emploi_{trim}.docx            ✓
```

---

## 8. Points d'attention

| Risque | Mitigation |
|---|---|
| `membres.dta` sans `pmencor_ind` passe en gold | Vérifier la présence de la variable avant upload gold |
| Mauvaise spec de calage retenue | Upload silver conditionnel au succès du QC Stata |
| Écrasement d'un trimestre précédent | Vérifier l'existence de l'objet avant upload |
| Fenêtre `TRIMESTRES_BULLETIN` mal configurée | Valider la liste dans `.env` avant run Projet 3 |
| Port MinIO change | Centraliser dans `.env`, documenter la procédure |
| Versions Stata/R non documentées | `renv` pour R, noter la version Stata dans `CLAUDE.md` |

---

*Document de travail — ANStat / CAE — GOUVCI*
