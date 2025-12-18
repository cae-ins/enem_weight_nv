ajouter_missing <- function(dataset_full) {
  
  missing_records <- tibble::tibble(
    segment     = 1,
    region      = c(10325, 11018, 11103, 11120),
    depart      = c(10325077, 11018059, 11103029, 11120015),
    souspref    = c(1032507701, 1101805901, 1110302906, 1112001504),
    ZD          = c("6003", "6040", "0348", "6023"),
    nb_mens_seg = c(14, 70, 22, 106),
    milieu      = c(2, 2, 1, 2),
    nb_indivs_seg = c(0, 0, 0, 0),
    date_ref    = as.Date(c("2025-07-02", "2025-07-02", "2025-07-02", "2025-07-02")),
    rgmen       = c(1, 1, 1, 1),
    first_trim  = c("T3_2025", "T3_2025", "T3_2025", "T3_2025") 
  )
  
  lignes_a_ajouter <- dplyr::anti_join(
    missing_records,
    dataset_full,
    by = c("region", "depart", "souspref", "ZD","segment")
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
