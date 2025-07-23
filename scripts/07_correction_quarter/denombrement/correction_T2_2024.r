

correction_taille_segment_par_geo <- function(dataset_segment1) {
  lookup_data <- tibble::tribble(
    ~region, ~depart, ~souspref, ~ZD, ~nb_mens_seg,
    10916, 10916107, 1091610702, "6025", 13,
    11423, 11423014, 1142301402, "6021", 28,
    11228, 11228085, 1122808502, "6006", 51,
    11103, 11103075, 1110307501, "6012", 27,
    11018, 11018059, 1101805901, "0035", 17,
    11018, 11018059, 1101805901, "6019", 27,
    11027, 11027022, 1102702202, "6049", 30,
    10510, 10510034, 1051003403, "6006", 56,
    11314, 11314080, 1131408003, "6014", 21,
    10309, 10309037, 1030903705, "6065", 21,
    10617, 10617024, 1061702402, "4003", 16
  )

  dataset_segment1 <- dataset_segment1 %>%
    rows_update(lookup_data, by = c("region", "depart", "souspref", "ZD"))

  return(dataset_segment1)
}

ajouter_missing_BDG <- function(dataset_segment1) {
  missing_records <- tibble::tribble(
    ~region, ~depart, ~souspref, ~ZD,    ~segment, ~nb_mens_seg,first_trim,
    11319,   11319046, 1131904604, "0023", 1,        36,"T2_2024",
    11423,   11423076, 1142307602, "6016", 1,        33,"T2_2024"
  )

  # Vérifie les lignes absentes
  lignes_a_ajouter <- dplyr::anti_join(
    missing_records, dataset_segment1,
    by = c("region", "depart", "souspref", "ZD", "segment")
  )

  if (nrow(lignes_a_ajouter) > 0) {
    message(glue::glue("Ajout de {nrow(lignes_a_ajouter)} ligne(s) manquante(s)"))

    # DIAGNOSTIC : colonne par colonne
    for (i in seq_len(nrow(lignes_a_ajouter))) {
      ligne <- lignes_a_ajouter[i, ]

      message(glue::glue("Diagnostic ligne {i} :"))
      for (col in c("region", "depart", "souspref", "ZD", "segment")) {
        valeur <- ligne[[col]]
        existe <- valeur %in% dataset_segment1[[col]]

        message(glue::glue(
          "  - {col} = {valeur} → {if (existe) 'existe' else 'ABSENT'} dans dataset_segment1"
        ))
      }
    }
    glimpse(dataset_segment1)


    dataset_segment1 <- dplyr::bind_rows(dataset_segment1, lignes_a_ajouter)
  } else {
    message("Aucune ligne manquante à ajouter.")
  }

  return(dataset_segment1)
}

ajouter_missing_ancien <- function(dataset_segment1) {
  missing_records <- tibble::tribble(
    ~region, ~depart, ~souspref, ~ZD,    ~segment, ~nb_mens_seg, ~first_trim,
    11319,   11319046, 1131904604, "0023", 1,        36,          "T2_2024",
    11423,   11423076, 1142307602, "6016", 1,        33,          "T2_2024"
  )

  # 🔍 Inclure first_trim dans la jointure
  lignes_a_ajouter <- dplyr::anti_join(
    missing_records, dataset_segment1,
    by = c("region", "depart", "souspref", "ZD", "segment", "first_trim")
  )

  if (nrow(lignes_a_ajouter) > 0) {
    message(glue::glue("Ajout de {nrow(lignes_a_ajouter)} ligne(s) manquante(s)"))

    for (i in seq_len(nrow(lignes_a_ajouter))) {
      ligne <- lignes_a_ajouter[i, ]

      message(glue::glue("Diagnostic ligne {i} :"))
      for (col in c("region", "depart", "souspref", "ZD", "segment", "first_trim")) {
        valeur <- ligne[[col]]
        existe <- valeur %in% dataset_segment1[[col]]

        message(glue::glue(
          "  - {col} = {valeur} → {if (existe) 'existe' else 'ABSENT'} dans dataset_segment1"
        ))
      }
    }

    dataset_segment1 <- dplyr::bind_rows(dataset_segment1, lignes_a_ajouter)
  } else {
    message("Aucune ligne manquante à ajouter.")
  }

  return(dataset_segment1)
}

ajouter_missing <- function(dataset_segment1) {
  missing_records <- tibble::tribble(
    ~region, ~depart, ~souspref, ~ZD,    ~segment, ~nb_mens_seg, ~first_trim, ~date_ref,          ~milieu,
    11319,   11319046, 1131904604, "0023", 1,        36,          "T2_2024",   as.Date("2024-07-02"), 1,
    11423,   11423076, 1142307602, "6016", 1,        33,          "T2_2024",   as.Date("2024-07-02"), 2
  )

  # Comparaison incluant 'milieu'
  lignes_a_ajouter <- dplyr::anti_join(
    missing_records, dataset_segment1,
    by = c("region", "depart", "souspref", "ZD", "segment", 
           "first_trim", "date_ref", "milieu")
  )

  if (nrow(lignes_a_ajouter) > 0) {
    message(glue::glue("Ajout de {nrow(lignes_a_ajouter)} ligne(s) manquante(s)"))

    for (i in seq_len(nrow(lignes_a_ajouter))) {
      ligne <- lignes_a_ajouter[i, ]

      message(glue::glue("Diagnostic ligne {i} :"))
      for (col in c("region", "depart", "souspref", "ZD", "segment", 
                    "first_trim", "date_ref", "milieu")) {
        valeur <- ligne[[col]]
        existe <- valeur %in% dataset_segment1[[col]]
        message(glue::glue(
          "  - {col} = {valeur} → {if (existe) 'existe' else 'ABSENT'} dans dataset_segment1"
        ))
      }
    }

    dataset_segment1 <- dplyr::bind_rows(dataset_segment1, lignes_a_ajouter)
  } else {
    message("Aucune ligne manquante à ajouter.")
  }

  return(dataset_segment1)
}

