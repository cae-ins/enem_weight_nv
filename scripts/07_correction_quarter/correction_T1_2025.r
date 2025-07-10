apply_T1_2025_correction <- function(df, log_dir = "logs") {
  # Créer dossier log si nécessaire
  if (!dir.exists(log_dir)) dir.create(log_dir, recursive = TRUE)
  
  log_path <- file.path(log_dir, paste0("removals_specific_doublons", format(Sys.Date(), "%Y%m%d"), ".log"))
  
  # Lignes ciblées pour suppression
  to_remove <- df %>%
    filter(
      (region == 10524 & depart == 10524081 & souspref == 1052408103 & ZD == "6017" & nb_indivs_seg == 0)
      |
      (region == 11132 & depart == 11132086 & souspref == 1113208603 & ZD == "0018" & nb_indivs_seg == 0)
    )
  
  # Écriture du log
  if (nrow(to_remove) > 0) {
    writeLines(
      c(
        paste0("Suppression de ", nrow(to_remove), " lignes spécifiques le ", Sys.Date()),
        "Détails des lignes supprimées :",
        capture.output(print(to_remove))
      ),
      log_path
    )
  } else {
    writeLines(paste0("Aucune ligne spécifique à supprimer le ", Sys.Date()), log_path)
  }
  
  # Dataframe nettoyé
  df_clean <- df %>%
    filter(!(
      (region == 10524 & depart == 10524081 & souspref == 1052408103 & ZD == "6017" & nb_indivs_seg == 0)
      |
      (region == 11132 & depart == 11132086 & souspref == 1113208603 & ZD == "0018" & nb_indivs_seg == 0)
    ))
  
  message("✅ Suppressions spécifiques appliquées et log créé dans: ", log_path)
  return(df_clean)
}
