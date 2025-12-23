library(haven)
library(dplyr)
library(openxlsx)

# ------------------------------------------------------------------
# 1. Lecture du fichier Stata
# ------------------------------------------------------------------
df <- read_dta("C:/Users/f.migone/Desktop/ENE_SURVEY_WEIGHTS/data/01_raw/test_brute_T4_2024.dta")

# ------------------------------------------------------------------
# 2. Groupes d'âge
# ------------------------------------------------------------------
df <- df %>%
  mutate(
    GroupeAge = case_when(
      AgeAnnee >= 0 & AgeAnnee <= 14 ~ "00-14",
      AgeAnnee >= 15 ~ paste0(
        sprintf("%02d", (AgeAnnee %/% 5) * 5),
        "-",
        sprintf("%02d", (AgeAnnee %/% 5) * 5 + 4)
      ),
      TRUE ~ NA_character_
    )
  )

# ------------------------------------------------------------------
# 3. Agrégation : effectifs + HH13 distinct (libellés)
# ------------------------------------------------------------------
table_effectifs <- df %>%
  group_by(HH2, M5, HH6, GroupeAge) %>%
  summarise(
    n = n(),
    HH13_list = paste(
      unique(na.omit(as.character(as_factor(HH13)))),
      collapse = ", "
    ),
    .groups = "drop"
  )

# ------------------------------------------------------------------
# 4. Ajout des libellés (SANS perdre les codes)
# ------------------------------------------------------------------
table_effectifs <- table_effectifs %>%
  mutate(
    HH2_label = as.character(as_factor(HH2)),
    M5_label  = as.character(as_factor(M5)),
    HH6_label = as.character(as_factor(HH6))
  )

# ------------------------------------------------------------------
# 5. Ordre des colonnes EXACT demandé
# ------------------------------------------------------------------
table_effectifs <- table_effectifs %>%
  select(
    HH2, HH2_label,          # Région
    M5,  M5_label,           # Sexe
    HH6, HH6_label,          # Milieu
    GroupeAge,               # Groupe d'âge
    n,                       # Effectifs
    HH13_list                # HH13 (libellés distincts)
  ) %>%
  arrange(HH2, M5, HH6, GroupeAge)


# ------------------------------------------------------------------
# 5. Export Excel
# ------------------------------------------------------------------
write.xlsx(
  table_effectifs,
  file = "C:/Users/f.migone/Desktop/ENE_SURVEY_WEIGHTS/data/01_raw/effectifs_codes_et_libelles.xlsx"
)
