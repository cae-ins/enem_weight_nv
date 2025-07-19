# ------------------------------------------------------------------
correction_reaffectation_denombrement <- function(data) {
  data %>%
    mutate(
      hh8 = ifelse(interview_key == "52-72-00-97", "0186",hh8)
    )
}

# ------------------------------------------------------------------
# =============================================================================
# CORRECTIONS BASÉES SUR L'INTERVIEW KEY
# =============================================================================

correction_taille_segment_par_interview_key <- function(data) {
  data %>%
    mutate(
      nb_mens_seg = case_when(
        interview_key == "90-07-52-04" ~ 15,
        TRUE ~ nb_mens_seg
      )
    )
}

suppression_par_interview_key <- function(data) {
  keys_a_supprimer <- tibble::tibble(interview_key = c(
    "22-51-62-59", "47-38-68-48", "63-91-92-81", "61-51-78-01"
  ))
  
  data %>%
    anti_join(keys_a_supprimer, by = "interview_key")
}

# =============================================================================
# CORRECTIONS BASÉES SUR LES VARIABLES GÉOGRAPHIQUES (hh2, hh3, hh4, hh8)
# =============================================================================

correction_taille_segment_par_geo <- function(data) {
  data %>%
    mutate(
      nb_mens_seg = case_when(
        (region == 10702 & depart == 10702048 & souspref == 1070204803 & ZD == "6048") ~ 40,
        (region == 10829 & depart == 10829111 & souspref == 1082911103 & ZD == "6019") ~ 26,
        (region == 11132 & depart == 11132086 & souspref == 1113208602 & ZD == "6013") ~ 24,
        (region == 11322 & depart == 11322097 & souspref == 1132209702 & ZD == "6043") ~ 51,
        TRUE ~ nb_mens_seg
      )
    )
}

# =============================================================================
# SUPPRESSIONS BASÉES SUR LES COMBINAISONS GÉOGRAPHIQUES (region, depart, souspref, ZD)
# =============================================================================

suppression_par_combinaisons_geo <- function(data) {
  combinaisons_a_supprimer <- tibble::tribble(
    ~region, ~depart, ~souspref, ~ZD,
    10926, 10926054, 1092605401, "0005",
    10930, 10930004, 1093000401, "6066",
    11018, 11018059, 1101805901, "6019",
    11027, 11027007, 1102700709, "6009",
    11027, 11027062, 1102706201, "0006",
    11228, 11228016, 1122801603, "0024",
    11314, 11314080, 1131408003, "6014",
    11322, 11322097, 1132209702, "6002",
    11408, 11408043, 1140804302, "6004",
    11018, 11018059, 1101805901, "0056",
    11132, 11132032, 1113203201, "6016"
  )
  
  data %>%
    anti_join(combinaisons_a_supprimer, by = c("region", "depart", "souspref", "ZD"))
}

ajouter_missing <- function(dataset_full) {
# Ajouter les lignes manquantes pour T3_2024, vu qu'il ny a pas de missing à ajouter, elle n'aura aucun effet 
  return(dataset_full)
}