# ============================================================
# Title: Harmonize Rp Dataset with ENE Coding and Labels
# Description:
#   - Converts Cod* variables in mapping to integer
#   - Uses REGION, DEPART, SOUSPREFID, ZD as composite key
#   - Merges Num* (ENE codes) and Nom* (ENE labels) into Rp
#   - Keeps both original and harmonized identifiers
# Author: [Your Name]
# ============================================================

# -----------------------
# 1. Load Required Libraries
# -----------------------
library(haven)    # For .dta files
library(readxl)   # For Excel files
library(dplyr)    # For data manipulation
library(labelled) # For labelling the columns
library(tibble)
library(tidyr)
library(stringr)

# -----------------------
# 2. Define File Paths
# -----------------------
source("config/1_config.r")
# Define the base directory for the project
rp_path <- file.path(BASE_DIR, "data", "03_processed", "RP_2021", "nb_men_indiv_RP.dta")
map_path <- file.path(BASE_DIR, "data", "01_raw", "Equivalence", "VF_BASE_ILOT_12012024_VF_work_Geovf.xlsx")


# -----------------------
# 3. Load Datasets
# -----------------------
rp <- read_dta(rp_path)
mapping <- read_excel(map_path)

mapping <- mapping %>%
  mutate(
    CodDep = as.character(CodDep),
    CodSp  = as.character(CodSp),
    CodSp  = paste0(CodDep, CodSp)  # concatenate with no separator
  ) %>%
  distinct()

# -----------------------
# 4. Convert Cod* Columns to Integer
# -----------------------
mapping <- mapping %>%
  mutate(across(starts_with("Cod"), ~ as.integer(.)))

# -----------------------
# 5. Swap region codes 29 and 30
# -----------------------
## There is a mismatch between the labels and the mapping data.
## In the RP dataset, region codes 29 and 30 correspond to LA ME and IFFOU, respectively.
## However, in the mapping dataset, these codes are reversed.

# rp <- rp %>%
#   mutate(REGION = case_when(
#     REGION == 29 ~ -1,   # Temporarily assign -1 to avoid conflict
#     REGION == 30 ~ 29,   # Change 30 to 29
#     TRUE         ~ REGION
#   )) %>%
#   mutate(REGION = if_else(REGION == -1, 30, REGION))

# -----------------------
# 6. Perform the Join on Composite Key
# -----------------------
# The key is (REGION, DEPART, SOUSPREFID, ZD) in Rp
# Match with (CodReg, CodDep, CodSp, ZD) in mapping

rp <- rp %>%
  mutate(
    ZD = str_pad(as.character(NUM_ZD_Vf), width = 4, pad = "0"),
    SOUSPREFID = as.double(paste0(
      as.character(CodDep_num),
      str_pad(as.character(CodSp_num), width = 2, pad = "0")
    ))
  ) %>%
  select(
    REGION = OFFICIEL_CodReg,
    DEPART = CodDep_num,
    SOUSPREFID,
    ZD,
    Nb_individus = POP_ZdVf,
    Nb_menages = MENAGES
  ) %>%
  left_join(
    mapping %>%
      select(
        CodReg, CodDep, CodSp,
        NumReg, NomReg,
        NumDep, NomDep,
        NumSp, NomSp
      ) %>%
      distinct(CodReg, CodDep, CodSp, .keep_all = TRUE),
    by = c(
      "REGION" = "CodReg",
      "DEPART" = "CodDep",
      "SOUSPREFID"     = "CodSp"
    )
  ) %>%
  drop_na()


# -----------------------
# 7. Rename Variables for Clarity
# -----------------------
rp <- rp %>%
  rename(region_code  = REGION,
         depart_code  = DEPART,
         souspref_code = SOUSPREFID,
         region        = NumReg,
         region_label  = NomReg,
         depart        = NumDep,
         depart_label  = NomDep,
         souspref      = NumSp,
         souspref_label = NomSp)

# -----------------------
# 8. Add value labels
# -----------------------

# Step 1 — build unique label vectors
region_labels <- rp %>%
  distinct(region, region_label) %>%
  deframe()

depart_labels <- rp %>%
  distinct(depart, depart_label) %>%
  deframe()

souspref_labels <- rp %>%
  distinct(souspref, souspref_label) %>%
  deframe()

# Step 2 — assign the labels (as dbl+lbl)
rp <- rp %>%
  mutate(
    region   = labelled(region, region_labels),
    depart   = labelled(depart, depart_labels),
    souspref = labelled(souspref, souspref_labels)
  )

# -----------------------
# 9. Review and Save Output
# -----------------------
# Inspect the updated dataset
glimpse(rp)

# Save the harmonized dataset
output_path <- file.path(BASE_DIR, "data", "03_processed", "RP_2021", "nb_men_indivs_ZD.dta")
write_dta(rp, output_path)
# -----------------------
# End of Script
# -----------------------