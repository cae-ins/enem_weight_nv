# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Reference documentation: `docs/MANUEL.md`** (method, formulas, files, history of choices, risks). It supersedes the older `docs/00_index.md` … `05_processus_complet.md`, the README and `ARCHITECTURE_ENE_PIPELINE.md` where they disagree.

## Project Overview

**RUWTHS** (R Unified Weighting Treatment Harmonized System) — R code computing the survey weights of the Enquête Nationale sur l'Emploi auprès des Ménages (ENE-M, Côte d'Ivoire, ANStat). The project language is French; comments, variable names and documentation are mostly in French.

**Data, code and compute are independent.** The code holds no path of a given computer: `config/1_config.r` takes the repository root (working directory, or `ENE_BASE_DIR`). All inputs are downloaded from MinIO into `data/` and all products are published back to MinIO, through the wrappers in `scripts/medallion/` and the Python module of the sibling repository `ENE_MEDALLION_ORCHESTRATION` (data contract: `ene_medallion_io/weights_contract.py`). Repositories never exchange files directly. Credentials only live in `.env` (see `.env.example`) or the secrets file of the orchestration module.

## Pipeline

Real execution order (folder numbers do not reflect it):

```
scripts/medallion/03_download_weights_inputs.ps1   inputs from MinIO
01_utils/  1_concat_denomb → 2_denomb_updates → update_interviewkey_map → 3_assign_firstTrim_interview
           (+ Stata suppression .do files) → 5_delete_individu_age_sexe
02_base_weights/1_gen_weights_columns → 2_calc_base_weights         π and base weights (constant within a region)
03_nonresponse/1_adjust_weights_non_response                         regional cell adjustment (corrected_weight_HH)
02_base_weights/3_indivs_weights                                     individu_<T>.dta, d_weights
03_nonresponse/2_attrition_propensity   (from T1 2026)               modelled non-response: d_weights; old one in d_weights_cellules
04_calibration/QUARTERLY_WEIGHTING/<year>/<T>/180X_1D/00_Master_Calibration_180X_1D.R
                                                                     calibration (FINAL_WEIGHT, and FINAL_WEIGHT_cellules from T1 2026)
03_nonresponse/3_compare_nonresponse_methods, 04_calibration/household_weights
scripts/medallion/04_upload_weights_outputs.ps1                      publication
08_yearly_weights/ponderation_annuelle.r                             annual weights (FINAL_WEIGHT / K)
```

- `scripts/medallion/10_upload_weights_inputs.ps1` publishes the inputs owned by the weighting stage (enumeration, enumeration updates, population totals, references).
- The calibration master of each quarter is a copy of the previous one; it runs in RStudio or with `Rscript` from the repository root (batch mode: `View()` is neutralised, Excel is not opened). `scripts/04_calibration/_experimental_archived/run_calibration.R` is archived and is not the entry point.
- Published quarters (up to T4 2025) are frozen, including their calibration folders. The modelled non-response applies from `NR_MODEL_FIRST_QUARTER` (`config/1_config.r`).
- `11_modif_design/`: sample-reduction simulation (`0_MASTER_SIMULATION.r`, quarter format `YYYY_TX`). `12_longitudinal_weights/`: longitudinal weights, in progress.

## Key Libraries

ReGenesees (calibration, linearisation), survey, haven (`.dta`), dplyr (`%>%`), labelled, arrow (Parquet), furrr/future (simulation). No renv lockfile; `scripts/00_setup/install_required_packages.R` installs CRAN packages, ReGenesees comes from GitHub (`DiegoZardetto/ReGenesees`).

## Data Conventions

- Stata `.dta` is the primary format; Parquet for annual weights and simulations. `data/` is gitignored and rebuilt from MinIO.
- Quarter format `TX_YYYY` (`ENE_QUARTER` or `TARGET_QUARTER`), except `YYYY_TX` in the simulation master.
- Weight variables: `base_weight_HH` (1/π), `corrected_weight_HH` (cell non-response), `d_weights` (calibration input), `FINAL_WEIGHT`, `FINAL_CORR_FACTOR`; from T1 2026 also `d_weights_cellules`, `FINAL_WEIGHT_cellules`.
- Keys: `interview_key` (household), `membres_id` (member), `v1interviewkey` (first interview), `hh2/hh3/hh4/hh8/hh7` (region, department, sub-prefecture, ZD, segment), `rgmen` (1 = first interview).
- `incoherence_code` 10 = ZD without any interview this quarter, dropped. `SR_individu_<T>.dta` = first interviews only (`_WR` = without resurvey), not "with non-response".
- Outputs: `base_weights/individu_<T>.dta` (calibration input), `calibrated_weights/individu_<T>_CAL.dta` (production), `data/04_weights/<year>/LFS_WEIGHTS_<year>.parquet` (annual).

## Code Style

- `dplyr` pipes (`%>%`), `all_of()` for dynamic columns, vectorised operations.
- Script headers with `# ====` dividers (name, title, description, usage).
- Paths relative to the repository root or built from `BASE_DIR`; never a path of a given computer.

## Quality Control

- Calibration: `X_Summary_Table` (no "Error", `Diff_Known_Tot_Final_Est` = 0, correction factor within [0.95, 1.65], cells ≥ 30), `table_check` (gap ≤ 100), convergence status `ecal.status.production`.
- `05_quality_control/postestimation_quality.R` flags estimates A (CV < 15 %), B (15–30 %), C (≥ 30 %); its standard errors ignore the sample design (see `docs/MANUEL.md` §10).
