# ==============================================================================
# export_weights_to_indicators.R
# Prepare les poids calibres pour publication vers MinIO.
# A lancer apres la calibration.
#
# Les echanges entre depots sont assures par les scripts Python medallion.
# ENE_INDICATORS_TABULATIONS recupere ensuite les fichiers avec:
#   scripts/medallion/05_download_tabulation_inputs.ps1
# ==============================================================================

source("config/1_config.r")

library(haven)
library(dplyr)

src_cal <- get_export_path(TARGET_QUARTER, quarter, year, use_sr = FALSE)
if (!file.exists(src_cal)) {
  stop(
    "Fichier calibre introuvable:\n  ", src_cal,
    "\nLancez d'abord la calibration."
  )
}

# Conserver un export des poids seuls dans le depot de ponderation. Le wrapper
# medallion publie ensuite ce fichier et la base calibree depuis le meme dossier.
export_dir <- dirname(src_cal)
dest_poids <- file.path(export_dir, paste0("poids_", TARGET_QUARTER, ".dta"))

data_cal <- read_dta(src_cal)
weight_vars <- c(
  "interview_key", "cle_individu", "membre_id",
  "pmencor_ind", "pmencor_ind_annuel",
  "ZD", "region", "milieu", "trimestre"
)
weight_vars_present <- intersect(weight_vars, names(data_cal))
missing_vars <- setdiff(weight_vars, names(data_cal))

if (length(missing_vars) > 0) {
  cat("Variables absentes et ignorees:", paste(missing_vars, collapse = ", "), "\n")
}

poids_df <- data_cal %>% select(all_of(weight_vars_present))
write_dta(poids_df, dest_poids)
cat("Poids seuls exportes:", dest_poids, "\n")

wrapper <- file.path(BASE_DIR, "scripts", "medallion", "04_upload_weights_outputs.ps1")
if (!file.exists(wrapper)) {
  stop("Wrapper MinIO introuvable:\n  ", wrapper)
}

status <- system2(
  "powershell",
  c(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-File", shQuote(wrapper),
    "-Quarter", shQuote(TARGET_QUARTER)
  )
)
if (status != 0) {
  stop("Echec de la publication MinIO. Code de sortie: ", status)
}

cat("\nPublication MinIO terminee.\n")
cat("Dans ENE_INDICATORS_TABULATIONS, lancer:\n")
cat("  scripts\\medallion\\05_download_tabulation_inputs.ps1 -Quarter ", TARGET_QUARTER, "\n", sep = "")
