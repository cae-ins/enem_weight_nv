# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**RUWTHS** (R Unified Weighting Treatment Harmonized System) — a modular R system for computing survey weights for the Enquête Nationale sur l'Emploi auprès des Ménages (ENE-M) in Côte d'Ivoire. The project language is French; comments, variable names, and documentation are primarily in French.

## Architecture & Pipeline

The weighting pipeline runs sequentially through numbered script directories under `scripts/`:

```
01_utils/        → Data preparation, concatenation, key mapping, deduplication
02_base_weights/ → Base weight calculation: w^(0) = 1/π (inverse inclusion probability)
03_nonresponse/  → Non-response adjustment by Region × Milieu: w^(1) = w^(0) × N_rm/R_rm
04_calibration/  → Calibration via ReGenesees to align with population benchmarks
05_quality_control/ → Post-estimation validation (CV thresholds, outliers, consistency checks)
06_monitoring/   → Monitoring dashboards
07_correction_quarter/ → Quarter-specific household data corrections
08_yearly_weights/ → Combine quarterly weights into annual weights
09_create_indicators/ → Employment/labor market indicator computation
10_data_management/  → Data cleaning (income variables, cloud storage)
11_modif_design/ → Sample reduction simulation framework (experimental)
```

Within each directory, scripts are numbered to indicate execution order (e.g., `1_gen_weights_columns.R` → `2_calc_base_weights.R` → `3_indivs_weights.R`).

## Key Entry Points

### Global configuration
All scripts begin by sourcing `config/1_config.r`, which sets `BASE_DIR`, `TARGET_QUARTER` (format: `"TX_YYYY"`, e.g. `"T4_2025"`), path templates (`PATHS` list with `{quarter}` placeholders), and file templates (`FILES` list). Changing the target quarter is the primary way to switch between periods.

### Calibration pipeline
```r
# In scripts/04_calibration/run_calibration.R — set these parameters:
TARGET_QUARTER <- "T1_2025"
SCHEMA_ID <- "180X_1D"       # See config/schemas_calibration.csv for all schemas
USE_SR <- FALSE               # Use non-response adjusted weights
INTERACTIVE_BOUNDS_MODE <- FALSE
source("scripts/04_calibration/run_calibration.R")
```
This orchestrator replaced 237 duplicated script files. It runs 7 steps automatically (load data → prepare sample → prepare population totals → calibrate → attach weights → summary table → precision). Schema configurations are in `config/schemas_calibration.csv` (14 schemas, from 8 to 816 constraints). Calibration constraint files live in `scripts/04_calibration/QUARTERLY_WEIGHTING/constraints/[schema_id]/`.

### Simulation pipeline (sample reduction)
```r
# In scripts/11_modif_design/0_MASTER_SIMULATION.r — set these parameters:
PARAM_TARGET_QUARTER <- "2025_T3"   # NB: format is "YYYY_TX" here, not "TX_YYYY"
PARAM_RATIO_REDUCTION <- 0.75       # Keep 75% of households
PARAM_N_ITER <- 30
PARAM_SEED <- 123
source("scripts/11_modif_design/0_MASTER_SIMULATION.r")
```
Runs 5 steps: PSU selection → base weights → calibration → attach LFS data → precision estimation. Uses `furrr::future_map()` for parallel iterations. Output goes to `data/04_weights/simulation/{TARGET_QUARTER}/`.

## Key Libraries

- **ReGenesees**: Core calibration engine (generalized regression estimator)
- **survey**: Survey design objects and estimation
- **haven**: Read/write Stata `.dta` files (primary data format)
- **dplyr**: All data manipulation uses tidyverse pipes (`%>%`)
- **arrow**: Parquet I/O for intermediate simulation results
- **furrr/future**: Parallel processing in simulation scripts
- **labelled**: Stata value label handling

No renv/packrat lockfile — packages are installed directly via `install.packages()` in config.

## Data Conventions

- **Primary format**: Stata `.dta` (via haven). All data files are gitignored.
- **Data directory structure**: `data/01_raw/`, `data/02_Cleaned/`, `data/03_Processed/`, `data/04_weights/`
- **Quarter format**: `"TX_YYYY"` in most scripts (e.g., `"T4_2025"`), but `"YYYY_TX"` in simulation master script
- **Weight variables**: `poids_de_base` (base), `weight` (intermediate), `poids_final` (calibrated)
- **Key identifiers**: `interview_key` (household), `cle_individu`/`membre_id` (individual), `ZD` (enumeration district/segment)
- **Inconsistency tracking**: `incoherence_code` field (code 10 = segment dropped from weighting)
- **Column normalization**: Scripts lowercase column names and remove double underscores

## File Naming Conventions

- Weight outputs: `individu_TX_YYYY.dta` (base), `individu_TX_YYYY_CAL.dta` (calibrated), `SR_individu_TX_YYYY.dta` (with non-response)
- Schema notation: `[X]X_[D]D` — X = number of constraints, D = number of domains (e.g., `180X_1D`)
- Script headers follow a standard format with `# ====` dividers, script name, title, description, author, date

## Code Style

- Heavy use of `dplyr` pipes (`%>%`) and `all_of()` for dynamic column selection
- Vectorized operations preferred over loops
- Helper functions use named arguments with explicit documentation in comments
- `cat()` with Unicode box-drawing characters for terminal progress display
- `tryCatch()` around sourced scripts in master orchestrators

## Quality Control Thresholds

CV (Coefficient of Variation) interpretation used in quality checks and simulation analysis:
- < 5% = Excellent
- 5-10% = Good
- 10-15% = Moderate
- \> 15% = Poor
