library(survey)
library(dplyr)
library(haven)     # pour lire Stata
library(openxlsx)  # pour exporter en Excel


# ------------------------------------------------------------------
# 1) CHARGER LA BASE GLOBALE (STATA)
# ------------------------------------------------------------------
BASE_COMPLETE_PATH <- file.path("data", "04_weights", "Base_Travail_BT_vf.dta")
data_all <- read_dta(BASE_COMPLETE_PATH)

# ------------------------------------------------------------------
# 2) FONCTION POUR CALCULER LE DEFF PAR TRIMESTRE
# ------------------------------------------------------------------

calc_deff_trimestre <- function(df){

  plan <- svydesign(
    ids = ~PSUKEY,
    strata = ~hh2,
    weights = ~pmencor_ind,   # <-- TON POIDS CORRIGÉ ICI
    data = df,
    nest = TRUE
  )

  res <- svymean(~SU1, design = plan, deff = TRUE)

  data.frame(
    trimestre = unique(df$trimestre),
    mean_SU1 = coef(res)[1],
    SE = SE(res)[1],
    Deff = attr(res, "deff")[1]
  )
}

# ------------------------------------------------------------------
# 3) APPLIQUER PAR TRIMESTRE
# ------------------------------------------------------------------

resultats_deff <- data_all %>%
  group_by(trimestre) %>%
  group_modify(~ calc_deff_trimestre(.x)) %>%
  ungroup()

print(resultats_deff)

# ------------------------------------------------------------------
# 4) EXPORTER EN EXCEL
# ------------------------------------------------------------------

write.xlsx(
  resultats_deff,
  file = "deff_su1_par_trimestre.xlsx",
  sheetName = "Deff_SU1",
  rowNames = FALSE
)
