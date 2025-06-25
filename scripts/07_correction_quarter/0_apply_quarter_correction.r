# ==============================================================================
# Module : apply_quarter_correction.R
# Fonction : apply_quarter_correction()
# Objet : Appliquer dynamiquement les corrections spécifiques à un trimestre
# Auteur : Franck MIGONE
# ==============================================================================

apply_quarter_correction <- function(df, quarter, log_dir = "logs") {
  correction_function_name <- paste0("apply_", quarter, "_correction")
  correction_script_path   <- file.path("scripts", "07_correction_quarter", paste0("correction_", quarter, ".R"))

  if (file.exists(correction_script_path)) {
    message("🔧 Chargement des corrections pour ", quarter, "...")
    source(correction_script_path)

    if (exists(correction_function_name)) {
      correction_fun <- get(correction_function_name)
      df <- correction_fun(df, log_dir = log_dir)
    } else {
      warning("⚠️ La fonction ", correction_function_name, " n'existe pas dans ", correction_script_path)
    }
  } else {
    message("ℹ️ Aucun module de correction trouvé pour ", quarter, ". Aucune correction appliquée.")
  }

  return(df)
}
