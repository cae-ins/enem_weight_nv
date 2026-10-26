# ==============================================================================
# export_weights_to_indicators.R
# Publie les poids calibres du trimestre sur MinIO (silver/enem/<T>/poids/ et
# gold/enem/<T>/base_ponderee/). A lancer apres la calibration.
#
# Les echanges entre depots passent par MinIO : ENE_INDICATORS_TABULATIONS lit
# ensuite gold/enem/<T>/base_ponderee/ avec son propre lanceur de telechargement.
# Python : ENE_PYTHON si defini, sinon "python".
# ==============================================================================

source("config/1_config.r")

src_cal <- get_export_path(TARGET_QUARTER, quarter, year, use_sr = FALSE)
if (!file.exists(src_cal)) {
  stop(
    "Fichier calibre introuvable:\n  ", src_cal,
    "\nLancez d'abord la calibration."
  )
}

launcher <- file.path(BASE_DIR, "scripts", "medallion", "medallion.py")
status <- system2(
  Sys.getenv("ENE_PYTHON", unset = "python"),
  c(shQuote(launcher), "upload-outputs", "--quarter", TARGET_QUARTER)
)
if (status != 0) {
  stop("Echec de la publication MinIO. Code de sortie: ", status)
}

cat("\nPublication MinIO terminee : gold/enem/", TARGET_QUARTER, "/base_ponderee/\n", sep = "")
