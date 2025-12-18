ajouter_missing <- function(dataset_full) {
  
  missing_records <- tibble::tibble(
    segment     = 1,
    region      = c(11319, 10405, 10510, 10101),
    depart      = c(11319046, 10405001, 10510034, 10101002),
    souspref    = c(1131904604, 1040500101, 1051003404, 1010100211),
    ZD          = c("0020", "17", "0004", "0379"),
    nb_mens_seg = c(49, 115, 15, 6),
    milieu      = c(1, 1, 1, 1),
    nb_indivs_seg = c(0, 0, 0, 0),
    date_ref    = as.Date(c("2025-04-02", "2025-04-02", "2025-04-02", "2025-04-02")),
    rgmen       = c(1, 1, 1, 1),
    first_trim  = c("T1_2025", "T1_2025", "T1_2025", "T2_2024") 
  )
  
  lignes_a_ajouter <- dplyr::anti_join(
    missing_records,
    dataset_full,
    by = c("region", "depart", "souspref", "ZD", "segment")
  )
  
  if (nrow(lignes_a_ajouter) > 0) {
    message(glue::glue(
      "Ajout de {nrow(lignes_a_ajouter)} ligne(s) manquante(s)."
    ))
    dataset_full <- dplyr::bind_rows(dataset_full, lignes_a_ajouter)
  } else {
    message("Aucune ligne manquante à ajouter.")
  }
  
  return(dataset_full)
}