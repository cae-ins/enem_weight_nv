# =============================================================================
# Corrections du dénombrement T3 2026
# Chargé par scripts/02_base_weights/4_construct_denombrement.r
# =============================================================================

# =============================================================================
# CORRECTIONS BASÉES SUR L'INTERVIEW KEY
# =============================================================================

# Entretiens de dénombrement vides (ni ménage, ni bâtiment) : doublons d'une ZD
# dont le vrai dénombrement est dans un autre entretien. Sans effet sur les
# comptages (ils n'ont aucune ligne dans menage.dta), retirés pour la propreté.
suppression_par_interview_key <- function(data) {
  keys_a_supprimer <- tibble::tibble(interview_key = c(
    # San-Pédro, Eqpe24Agent6, ouverts et clos en moins de 30 s (4 août, 4 oct.)
    "64-41-90-30", # 1030903703 ZD 6048, vrai : 10-94-02-05
    "22-15-39-22", # 1030903705 ZD 0232, vrai : 85-93-20-41
    "86-93-80-53", # 1030903705 ZD 6065, vrai : 27-85-81-31
    "95-28-33-80", # 1030903705 ZD 0042, vrai : 43-18-52-07
    "67-26-29-99", # 1030903705 ZD 0127, vrai : 56-72-36-46
    "55-89-70-72", # 1030903704 ZD 6053, vrai : 64-35-51-96
    "11-92-53-27", # 1030904204 ZD 6025, vrai : 29-93-59-23
    # Gôh, Eqpe13Agent2, ouverts et clos en moins de 30 s (6 août)
    "54-38-37-97", # 1061702407 ZD 6008, vrai : 03-34-78-44
    "07-96-04-36", # 1061702402 ZD 4003, vrai : 81-72-54-50
    "14-56-86-16", # 1061703501 ZD 0001, vrai : 10-64-21-55
    # Cavally, Eqpe18Agent4 : dénombrement commencé (1 îlot) puis abandonné,
    # commentaire « A VÉRIFIER », rejeté par le siège
    "58-52-26-95"  # 1101802602 ZD 0006, vrai : 87-01-82-39
  ))

  data %>%
    anti_join(keys_a_supprimer, by = "interview_key")
}
