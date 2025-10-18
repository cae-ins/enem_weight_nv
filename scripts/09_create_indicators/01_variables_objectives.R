# Load necessary libraries (best practice to have this at the top)
# install.packages("dplyr") # Run this line if you don't have dplyr installed
library(dplyr)

# Assume 'df' is your starting data frame that contains all the source variables
# (e.g., AgeAnnee, M4Confirm, M5, EF1, HH6, etc.)

# ============================================================================ #
#                                    Age                                       #
# ============================================================================ #

# --- Age ---
# Description: Create and clean the main age variable.

# The original Stata code generates 'age' based on a condition.
# Here, 'M4Confirm' is used for ages 13+, and 'AgeAnnee' is used for ages under 13.
df <- df %>%
  mutate(
    # Create the 'age' variable using a condition
    age = if_else(AgeAnnee < 13, AgeAnnee, M4Confirm)
  )

# Display a frequency table for age, including missing values (NA)
# This is equivalent to Stata's `ta age, mis`
print(table(df$age, useNA = "ifany"))

# Remove rows where age is missing
# In R, is.na() handles all types of missing values.
df <- df %>%
  filter(!is.na(age))
# revoir: on voit que certains individus ont des ages vide ou -9998, on attent le retour de l'appurement.


# ============================================================================ #
#                                 Age Groups                                   #
# ============================================================================ #

# --- Age Group 1 ---
df <- df %>%
  mutate(
    grp_age = cut(age,
      breaks = c(-Inf, 14, 24, 35, 64, Inf),
      labels = c("moins de 15 ans", "15 à 24 ans", "25 à 35 ans", "36 à 64 ans", "65 ans et plus"),
      right = TRUE, # intervals are (lower, upper]
      include.lowest = TRUE
    )
  )
print(table(df$grp_age, useNA = "ifany"))

# --- Quinquennial Age Group (grpe_age5) ---
df <- df %>%
  mutate(
    grpe_age5 = cut(age,
      breaks = c(-Inf, 4, 9, 14, 19, 24, 29, 34, 39, 44, 49, 54, 59, 64, Inf),
      labels = c("Moins de 5 ans", "5 à 9 ans", "10 à 14 ans", "15 à 19 ans",
                 "20 à 24 ans", "25 a 29 ans", "30 à 34 ans", "35 à 39 ans",
                 "40 à 44 ans", "45 à 49 ans", "50 à 54 ans", "55 à 59 ans",
                 "60 à 64 ans", "65 ans et plus"),
      right = TRUE,
      include.lowest = TRUE
    )
  )
print(table(df$grpe_age5, useNA = "ifany"))


# --- Age Group 3 ---
df <- df %>%
  mutate(
    grp_age3 = cut(age,
      breaks = c(-Inf, 14, 24, 64, Inf),
      labels = c("Moins de 15 ans", "15 à 24 ans", "25 à 64 ans", "65 ans et plus"),
      right = TRUE,
      include.lowest = TRUE
    )
  )
print(table(df$grp_age3, useNA = "ifany"))

# --- Age Group 4 ---
df <- df %>%
  mutate(
    groupe_age4 = cut(age,
      breaks = c(15, 24, 35, 64, Inf), # Note: this group starts from age 16 in Stata, so we use 15 as the lower bound
      labels = c("16-24 ans", "25-35 ans", "36-64 ans", "65 ans et plus"),
      right = TRUE,
      include.lowest = TRUE
    )
  )
print(table(df$groupe_age4, useNA = "ifany"))


# --- Age Group 5 ---
df <- df %>%
  mutate(
    groupe_age5 = cut(age,
      breaks = c(15, 35, 64, Inf), # Starts from age 16
      labels = c("16-35 ans", "36-64 ans", "65 ans et plus"),
      right = TRUE,
      include.lowest = TRUE
    )
  )
print(table(df$groupe_age5, useNA = "ifany"))


# --- Age Group 6 ---
df <- df %>%
  mutate(
    groupe_age6 = cut(age,
      breaks = c(14, 19, 24, 29, 35, 40), # Note Stata code has a gap between 29 and 30, and 35 and 36. This is an interpretation.
      labels = c("15-19 ans", "20-24 ans", "25-29 ans", "30-35 ans", "36-40 ans"),
      right = TRUE,
      include.lowest = TRUE
    )
  )
print(table(df$groupe_age6, useNA = "ifany"))

# --- Age Group 7 ---
df <- df %>%
  mutate(
    groupe_age7 = cut(age,
      breaks = c(14, 19, 24, 29, 34, 40),
      labels = c("15-19 ans", "20-24 ans", "25-29 ans", "30-34 ans", "35-40 ans"),
      right = TRUE,
      include.lowest = TRUE
    )
  )
print(table(df$groupe_age7, useNA = "ifany"))


# ============================================================================ #
#                         Specific Demographic Groups                          #
# ============================================================================ #

# --- Youth 15-24 (jeune15_24) ---
# Description: Indicator for youth aged 15-24.
df <- df %>%
  mutate(
    jeune15_24 = factor(if_else(age >= 15 & age <= 24, "Oui", "Pas concerné", missing = "Pas concerné"))
  )
print(table(df$jeune15_24, useNA = "ifany"))


# --- Youth 15-35 (jeune15_35) ---
# Description: Indicator for youth aged 15-35.
df <- df %>%
  mutate(
    jeune15_35 = factor(if_else(age >= 15 & age <= 35, "Oui", "Pas concerné", missing = "Pas concerné"))
  )
print(table(df$jeune15_35, useNA = "ifany"))


# --- Youth 15-40 (jeune15_40) ---
# Description: Indicator for youth aged 15-40.
df <- df %>%
  mutate(
    jeune15_40 = factor(if_else(age >= 15 & age <= 40, "Oui", "Pas concerné", missing = "Pas concerné"))
  )
print(table(df$jeune15_40, useNA = "ifany"))


# --- Sex (sexe) ---
# Description: Create the sex variable from the source variable M5.
df <- df %>%
  mutate(sexe = M5) # Assumes M5 is already a factor with labels "Homme", "Femme"
print(table(df$sexe, useNA = "ifany"))


# ============================================================================ #
#                                  Education                                   #
# ============================================================================ #

# --- Ever Been to School (scolarise) ---
df <- df %>%
  mutate(
    scolarise = case_when(
      age >= 3 & EF1 == 2 ~ "Jamais scolarisé",
      age >= 3 & EF1 == 1 ~ "Déjà scolarisé",
      TRUE ~ NA_character_
    ),
    scolarise = factor(scolarise)
  )
print(table(df$scolarise, useNA = "ifany"))


# --- Level of Education (niveau_instruction) ---
df <- df %>%
  mutate(
    niveau_instruction_code = case_when(
      EF1 == 2 & age >= 3 ~ -99,
      EF6 == 1 & EF1 == 1 & age >= 3 ~ EF7,
      EF10 == 1 & EF6 != 1 & EF1 == 1 & age >= 3 ~ EF11,
      EF6 != 1 & EF10 != 1 & EF1 == 1 & age >= 3 ~ EF3,
      TRUE ~ NA_real_
    ),
    niveau_instruction = factor(niveau_instruction_code,
      levels = c(-99, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12),
      labels = c("Aucun niveau", "Préscolaire", "Primaire", "Secondaire général cycle I",
                 "Sécondaire technique/profesionnelle cycle I", "Sécondaire général cycle II",
                 "secondaire technique/professionnelle II", "Supérieur cycle court",
                 "Licence", "Maitrise/ Master 1", "Master 2 /DEA/DESS",
                 "Doctorat", "Post Doctorat")
    )
  )
print(table(df$niveau_instruction, useNA = "ifany"))
# revoir: il arrive que certains individu de plus de 3 ans n'ont pas de niveau instruction, ce qui n'est pas normal. on doit verfier dans la base.
# In R to check: filter(df, (is.na(niveau_instruction) | is.na(niveau_instruction_code)) & age >= 3)


# --- Aggregated Education Level 1 (7 categories) ---
df <- df %>%
  mutate(
    Niv_inst_AG1 = case_when(
      niveau_instruction_code %in% c(-99, 1) ~ "Aucun niveau",
      niveau_instruction_code == 2 ~ "Primaire",
      niveau_instruction_code %in% c(3, 4) ~ "Secondaire premier cycle",
      niveau_instruction_code %in% c(5, 6) ~ "Secondaire deuxième cycle",
      niveau_instruction_code %in% c(7, 8) ~ "Superieur premier cycle",
      niveau_instruction_code %in% c(9, 10) ~ "Superieur deuxième cycle",
      niveau_instruction_code %in% c(11, 12) ~ "Superieur troisième cycle",
      TRUE ~ NA_character_
    ),
    # Ensure the factor levels are in the correct order
    Niv_inst_AG1 = factor(Niv_inst_AG1, levels = c("Aucun niveau", "Primaire",
      "Secondaire premier cycle", "Secondaire deuxième cycle",
      "Superieur premier cycle", "Superieur deuxième cycle", "Superieur troisième cycle"))
  )
print(table(df$Niv_inst_AG1, useNA = "ifany"))


# --- Aggregated Education Level 2 (4 categories) ---
df <- df %>%
  mutate(
    Niv_inst_AG2 = case_when(
      niveau_instruction_code %in% c(-99, 1) ~ "Aucun niveau",
      niveau_instruction_code == 2 ~ "Primaire",
      between(niveau_instruction_code, 3, 6) ~ "Secondaire",
      between(niveau_instruction_code, 7, 12) ~ "Superieur",
      TRUE ~ NA_character_
    ),
    Niv_inst_AG2 = factor(Niv_inst_AG2, levels = c("Aucun niveau", "Primaire", "Secondaire", "Superieur"))
  )
print(table(df$Niv_inst_AG2, useNA = "ifany"))


# --- Aggregated Education Level 3 (5 categories) ---
df <- df %>%
  mutate(
    Niv_inst_AG3 = case_when(
      niveau_instruction_code %in% c(-99, 1) ~ "Aucun niveau",
      niveau_instruction_code == 2 ~ "Primaire",
      niveau_instruction_code %in% c(3, 4) ~ "Secondaire premier cycle",
      niveau_instruction_code %in% c(5, 6) ~ "Secondaire deuxième cycle",
      between(niveau_instruction_code, 7, 12) ~ "Superieur",
      TRUE ~ NA_character_
    ),
    Niv_inst_AG3 = factor(Niv_inst_AG3, levels = c("Aucun niveau", "Primaire",
      "Secondaire premier cycle", "Secondaire deuxième cycle", "Superieur"))
  )
print(table(df$Niv_inst_AG3, useNA = "ifany"))


# --- Grade Attained (classe_atteint) ---
df <- df %>%
  mutate(
    classe_atteint_code = case_when(
      EF1 == 2 & age >= 3 ~ -99,
      EF6 == 1 & EF1 == 1 & age >= 3 ~ EF8,
      EF10 == 1 & EF6 != 1 & EF1 == 1 & age >= 3 ~ EF12,
      EF10 != 1 & EF6 != 1 & EF1 == 1 & age >= 3 ~ EF4,
      TRUE ~ NA_real_
    )
    # The list of labels is very long; creating a factor is recommended
    # but omitted here for brevity. It would follow the pattern for `niveau_instruction`.
  )
print(table(df$classe_atteint_code, useNA = "ifany"))


# --- Number of Successful Years of Study (nbr_annee_etude) ---
df <- df %>%
  mutate(
    nbr_annee_etude = case_when(
      classe_atteint_code == -99 ~ 0,
      between(classe_atteint_code, 1, 4) ~ 0,
      classe_atteint_code == 5 ~ 1,
      classe_atteint_code == 6 ~ 2,
      classe_atteint_code == 7 ~ 3,
      classe_atteint_code == 8 ~ 4,
      classe_atteint_code == 9 ~ 5,
      classe_atteint_code == 10 ~ 6,
      classe_atteint_code == 11 ~ 7,
      classe_atteint_code == 12 ~ 8,
      classe_atteint_code == 13 ~ 9,
      classe_atteint_code == 14 ~ 10,
      classe_atteint_code == 15 ~ 11,
      classe_atteint_code == 16 ~ 12,
      classe_atteint_code == 17 ~ 13,
      classe_atteint_code == 18 ~ 14,
      classe_atteint_code == 19 ~ 15,
      classe_atteint_code == 20 ~ 16,
      classe_atteint_code == 21 ~ 17,
      classe_atteint_code == 22 ~ 18,
      TRUE ~ NA_real_
    )
  )
print(table(df$nbr_annee_etude, useNA = "ifany"))


# --- Mean Number of Years of Study ---
# Equivalent to Stata's `mean nbr_annee_etude`
mean_years <- mean(df$nbr_annee_etude, na.rm = TRUE)
print(paste("Mean number of years of study:", mean_years))


# --- Highest Diploma (haut_diplome) ---
df <- df %>%
  mutate(
    haut_diplome = if_else(age >= 3, EF4_1, NA_real_) # Using NA_real_ for numeric missing
  )
print(table(df$haut_diplome, useNA = "ifany"))


# ============================================================================ #
#                               Area of Residence                              #
# ============================================================================ #

# --- Residence Area (milieu_residence) ---
df <- df %>%
  mutate(milieu_residence = HH6)
print(table(df$milieu_residence, useNA = "ifany"))


# --- Disaggregated Residence Area (milieu_resid2) ---
# revoir: utilisation de HH4 pour les communes d'Abidjan
abidjan_codes <- c(1010100211, 1010100212, 1010100213, 1010100214, 1010100215,
                   1010100216, 1010100217, 1010100218, 1010100219, 1010100220)

df <- df %>%
  mutate(
    milieu_resid2 = case_when(
      HH6 == 1 & HH4 %in% abidjan_codes ~ "Abidjan",
      HH6 == 1 ~ "Autre urbain",
      HH6 == 2 ~ "Rural",
      TRUE ~ NA_character_
    ),
    milieu_resid2 = factor(milieu_resid2, levels = c("Abidjan", "Autre urbain", "Rural"))
  )
print(table(df$milieu_resid2, useNA = "ifany"))


# --- Region ---
df <- df %>%
  mutate(region = HH2)
print(table(df$region, useNA = "ifany"))

# --- District ---
df <- df %>%
  mutate(district = HH1)
print(table(df$district, useNA = "ifany"))


# ============================================================================ #
#                             Institutional Sector                             #
# ============================================================================ #

# The following section is commented out as it was in the original Stata script.
# It depends on variables (e.g., pop_emp, EP11, PAT) that might be created in another script.
#
# # --- Institutional Sector (National Accounts definition) ---
# df <- df %>%
#   mutate(
#     secteur_institutionnel = case_when(
#       pop_emp == 1 & EP11 %in% c(1, 2) ~ "Administration publique",
#       pop_emp == 1 & EP11 %in% c(3, 4) ~ "Societé non financière",
#       pop_emp == 1 & EP11 %in% c(7, 8) ~ "Institution sans but lucratif",
#       pop_emp == 1 & EP11 == 9 ~ "Menage",
#       pop_emp == 1 & EP11 == 6 ~ "Reste du monde",
#       TRUE ~ NA_character_
#     )
#   )
#
# # --- Institutional Sector 2 ---
# df <- df %>%
#   mutate(
#     secteur_institionnel2 = case_when(
#       pop_emp == 1 & EP11 == 8 ~ "Menage",
#       pop_emp == 1 & EP11 %in% c(3, 4, 6) ~ "Privé",
#       pop_emp == 1 ~ "Public", # This is a catch-all for remaining pop_emp == 1
#       TRUE ~ NA_character_
#     )
#   )
#
# # --- Institutional Sector 3 ---
# df <- df %>%
#   mutate(
#     secteur_institutionnel3 = case_when(
#       EP11 %in% c(1, 2) ~ "Public/parapublic",
#       EP11 == 3 ~ "Entreprise privée non agricole",
#       EP11 == 4 ~ "Entreprise agricole",
#       EP11 == 5 ~ "Organisation internationale",
#       EP11 %in% c(6, 7) ~ "ONG/eglise",
#       EP11 == 8 ~ "Ménage",
#       TRUE ~ NA_character_
#     )
#   )


# ============================================================================ #
#                            Housing Characteristics                           #
# ============================================================================ #

# --- Building Type (type_logement) ---
df <- df %>%
  mutate(type_logement = L1)
print(table(df$type_logement, useNA = "ifany"))

# --- Wall Material (nature_murs) ---
df <- df %>%
  mutate(nature_murs = L3)
print(table(df$nature_murs, useNA = "ifany"))

# --- Occupancy Status (statut_occupation) ---
df <- df %>%
  mutate(statut_occupation = L5)
print(table(df$statut_occupation, useNA = "ifany"))

# --- Lighting Source (mode_eclairage) ---
df <- df %>%
  mutate(mode_eclairage = L4)
print(table(df$mode_eclairage, useNA = "ifany"))

# ============================================================================ #
#                         Socio-Professional Category                          #
# ============================================================================ #

# --- Professional Category - Main Employment (cat_profEP) ---
df <- df %>%
  mutate(cat_profEP = EP13)
print(table(df$cat_profEP, useNA = "ifany"))

# --- Professional Category - Secondary Employment (cat_profES) ---
df <- df %>%
  mutate(cat_profES = ES13)
print(table(df$cat_profES, useNA = "ifany"))