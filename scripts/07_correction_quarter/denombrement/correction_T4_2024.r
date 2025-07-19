correction_reaffectation_denombrement <- function(df, chemin_zd_correct = "data/02_Cleaned/Menage/T4_2024/zd_correct.dta") {
  # Étape 0 : Initialisation de la colonne ZD depuis hh8 (si non déjà présente)
  df <- df %>%
    dplyr::mutate(ZD = stringr::str_pad(as.character(hh8), width = 4, side = "left", pad = "0"))

  # Étape 1 : Jointure avec zd_correct.dta
  zd_correct <- haven::read_dta(chemin_zd_correct) %>%
    dplyr::rename(interview_key = interview__key) %>%
    dplyr::select(interview_key, PW, VERIF)

  df <- df %>%
    dplyr::left_join(zd_correct, by = "interview_key") %>%
    dplyr::mutate(
      HH8_real = stringr::str_pad(as.character(round(PW)), width = 4, side = "left", pad = "0"),
      ZD = dplyr::if_else(!is.na(VERIF) & VERIF == 0, HH8_real, ZD)
    ) %>%
    dplyr::select(-PW, -VERIF, -HH8_real)

  # Étape 2 : Correction manuelle sur certains interview_key
  corrections_ZD <- tibble::tibble(
    interview_key = c("17-26-57-50", "07-24-65-44"),
    ZD_corrige = c("0018", "0018")
  )

  df <- df %>%
    dplyr::left_join(corrections_ZD, by = "interview_key") %>%
    dplyr::mutate(ZD = dplyr::coalesce(ZD_corrige, ZD)) %>%
    dplyr::select(-ZD_corrige)

  return(df)
}

correction_taille_segment_par_geo <- function(dataset_full) {
  lookup_data <- tibble::tribble(
    ~region, ~depart, ~souspref, ~ZD, ~nb_mens_seg,
    11120, 11120044, 1112004404, "0043", 29,
    11027, 11027022, 1102702202, "6092", 62,
    10930, 10930060, 1093006002, "6042", 11,
    10101, 10101002, 1010100205, "6047", 22,
    11319, 11319082, 1131908201, "6008", 29,
    10524, 10524081, 1052408101, "6014", 10,
    10309, 10309037, 1030903704, "6077", 70,
    11319, 11319046, 1131904603, "6028", 10,
    10615, 10615021, 1061502103, "6005", 44,
    10524, 10524081, 1052408103, "6028", 13,
    10712, 10712040, 1071204004, "6018", 13,
    10615, 10615030, 1061503005, "6079", 40,
    10829, 10829064, 1082906405, "6032", 15,
    11314, 11314039, 1131403908, "6031", 24,
    11018, 11018026, 1101802602, "6020", 64,
    11103, 11103029, 1110302906, "0141", 20,
    11120, 11120083, 1112008304, "0020", 36,
    10524, 10524081, 1052408103, "6017", 12,
    11228, 11228085, 1122808504, "6003", 19,
    11319, 11319087, 1131908704, "0007", 38
  ) %>%
    mutate(
      segment = 1
    )

  dataset_full <- dataset_full %>%
    rows_update(lookup_data, by = c("region", "depart", "souspref", "ZD", "segment"))

  return(dataset_full)
}

ajouter_missing <- function(dataset_full) {
  missing_records <- tibble(
    region = 11132,
    depart = 11132086,
    souspref = 1113208603,
    ZD = "0018",
    nb_mens_seg = 12,
    segment = 1
  )
  
  lignes_a_ajouter <- anti_join(
    missing_records, dataset_full,
    by = c("region", "depart", "souspref", "ZD")
  )
  
  if (nrow(lignes_a_ajouter) > 0) {
    message(glue::glue("Ajout de {nrow(lignes_a_ajouter)} ligne(s) manquante(s) pour T4_2024."))
    dataset_full <- bind_rows(dataset_full, lignes_a_ajouter)
  } else {
    message("Aucune ligne manquante à ajouter pour T4_2024.")
  }
  
  return(dataset_full)
}
