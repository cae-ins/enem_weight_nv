# ===================================================================
# denomb_special_updates.R
# Fonctions pour les traitements spécifiques des mises à jour denomb
# ===================================================================



library(dplyr)
library(tibble)

update_T2_2024 <- function(dataset_segment1) {
  lookup_data <- tribble(
    ~region, ~depart, ~souspref, ~ZD, ~segment, ~nb_mens_seg,
    10916, 10916107, 1091610702, "6025", 1, 13,
    11423, 11423014, 1142301402, "6021", 1, 28,
    11228, 11228085, 1122808502, "6006", 1, 51,
    11103, 11103075, 1110307501, "6012", 1, 27,
    11018, 11018059, 1101805901, "0035", 1, 17,
    11018, 11018059, 1101805901, "6019", 1, 27,
    11027, 11027022, 1102702202, "6049", 1, 30,
    10510, 10510034, 1051003403, "6006", 1, 56,
    11314, 11314080, 1131408003, "6014", 1, 21,
    10309, 10309037, 1030903705, "6065", 1, 21,
    10617, 10617024, 1061702402, "4003", 1, 16
  )

  missing_records <- tribble(
    ~region, ~depart, ~souspref, ~ZD, ~segment, ~nb_mens_seg,
    11319, 11319046, 1131904604, "0023", 1, 36, 
    11423, 11423076, 1142307602, "6016", 1, 33
  )

  update_data <- bind_rows(lookup_data, missing_records)
  jointure_cle <- c("region", "depart", "souspref", "ZD", "segment")

  lignes_non_trouvees <- anti_join(update_data, dataset_segment1, by = jointure_cle)

  if (nrow(lignes_non_trouvees) > 0) {
    message("⛔️ Clés non trouvées dans le dataset cible :")
    print(lignes_non_trouvees)
  }

  dataset_segment1 <- dataset_segment1 %>%
    rows_update(update_data, by = jointure_cle)

  return(dataset_segment1)
}


update_T4_2024 <- function(dataset_full) {
  lookup_data <- tribble(
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
    11319, 11319087, 1131908704, "0007", 38,
    11132, 11132086, 1113208603, "0018", 12
  ) %>%
    mutate(
      quarter = "T4_2024",
      segment = 1
    )
  
  missing_records <- tibble(
    region = 11132,
    depart = 11132086,
    souspref = 1113208603,
    ZD = "0018",
    nb_mens_seg = 12,
    segment = 1
  )
  
  dataset_full <- dataset_full %>%
    rows_update(lookup_data, by = c("region", "depart", "souspref", "ZD", , "segment")) %>%
    bind_rows(
      anti_join(lookup_data, dataset_full, by = c("region", "depart", "souspref", "ZD", "segment"))
    ) %>%
    rows_update(missing_records, by = c("region", "depart", "souspref", "ZD", "quarter", "segment")) %>%
    bind_rows(
      anti_join(missing_records, dataset_full, by = c("region", "depart", "souspref", "ZD", "segment"))
    )
  
  return(dataset_full)
}

