# ==============================================================================
# Structure de la population en âge de travailler
# ==============================================================================
library(dplyr)
library(labelled)

data <- data %>%
  # Création de la variable PAT
  mutate(PAT = as.integer(age >= 16)) %>%
  set_variable_labels(
    PAT = "population en âge de travailler selon le BIT"
  ) %>%
  set_value_labels(
    PAT = c("Non" = 0, "Oui" = 1)
  ) %>%

  # --- Population en emploi: pop_emploi ---

  ## Emploi présent (emp_present)
  mutate(
    emp_present = as.integer(
      PAT == 1 & (
        SE1 == 1 |
          (SE1 == 2 & SE2 %in% 1:9) |
          (SE2 == 10 & SE3 %in% 1:2) |
          (SE3 %in% 3:5 & SE4 == 1) |
          (SE4 == 2 & SE5 == 1 & SE7 %in% 1:2)
      )
    )
  ) %>%
  set_variable_labels(
    emp_present = "Population en emploi présent"
  ) %>%
  set_value_labels(
    emp_present = c("Non" = 0, "Oui" = 1)
  ) %>%

  ## Emploi absent (emp_absent)
  mutate(
    emp_absent = as.integer(
      PAT == 1 & (
        ((SE5 == 2 | SE7 %in% 3:4) & SE8 == 1 & SE9 %in% 1:4) |
          ((SE5 == 2 | SE7 %in% 3:4) & SE8 == 1 & SE9 == 10 & SE9A == 1) |
          ((SE5 == 2 | SE7 %in% 3:4) & SE8 == 1 & SE9 == 14 & SE9B == 1) |
          ((SE5 == 2 | SE7 %in% 3:4) & SE8 == 1 & (SE9 %in% 5:9 | SE9 %in% c(11, 12, 15, 16, 17)) & SE10 == 1) |
          ((SE5 == 2 | SE7 %in% 3:4) & SE8 == 1 & (SE9 %in% 5:9 | SE9 %in% c(11, 12, 15, 16, 17)) & SE10 == 2 & SE11 == 1)
      )
    )
  ) %>%
  set_variable_labels(
    emp_absent = "Population absent à leur poste de travail"
  ) %>%
  set_value_labels(
    emp_absent = c("Non" = 0, "Oui" = 1)
  ) %>%

  ## Population en emploi (pop_emp)
  mutate(
    pop_emp = case_when(
      PAT == 1 & emp_present == 1 ~ 1,
      PAT == 1 & emp_absent == 1 ~ 2,
      PAT == 1 ~ 0,
      TRUE ~ NA_real_
    )
  ) %>%
  set_variable_labels(
    pop_emp = "Population en emploi"
  ) %>%
  set_value_labels(
    pop_emp = c("Non en emploi" = 0, "Emploi présent" = 1, "Emploi absent" = 2)
  ) %>%

  ## Variable dichotomique sur l'emploi (pop_emp_dich)
  mutate(
    pop_emp_dich = as.integer(pop_emp %in% c(1, 2))
  ) %>%
  set_variable_labels(
    pop_emp_dich = "Population en emploi (dichotomique)"
  ) %>%
  set_value_labels(
    pop_emp_dich = c("Non" = 0, "Oui" = 1)
  ) %>%

  # --- Secteur institutionnel ---

  ## Secteur institutionnel (secteur_institutionnel)
  mutate(
    secteur_institutionnel = case_when(
      pop_emp_dich == 1 & !is.na(EP11) & EP11 %in% 1:2 ~ 1,
      pop_emp_dich == 1 & !is.na(EP11) & EP11 %in% 3:4 ~ 2,
      pop_emp_dich == 1 & !is.na(EP11) & EP11 %in% 7:8 ~ 3,
      pop_emp_dich == 1 & !is.na(EP11) & EP11 == 9 ~ 4,
      pop_emp_dich == 1 & !is.na(EP11) & EP11 == 6 ~ 5,
      TRUE ~ NA_real_
    )
  ) %>%
  set_variable_labels(
    secteur_institutionnel = "Secteur institutionnel"
  ) %>%
  set_value_labels(
    secteur_institutionnel = c("Administration publique" = 1, "Société non financière" = 2, "Institution sans but lucratif" = 3, "Ménage" = 4, "Reste du monde" = 5)
  ) %>%

  ## Secteur institutionnel 2 (secteur_institionnel2)
  mutate(
    secteur_institionnel2 = case_when(
      PAT == 1 & pop_emp_dich == 1 & EP11 %in% 1:2 ~ 1,
      PAT == 1 & pop_emp_dich == 1 & EP11 %in% c(3, 4, 6) ~ 2,
      PAT == 1 & pop_emp_dich == 1 & EP11 == 8 ~ 3,
      TRUE ~ NA_real_
    )
  ) %>%
  set_variable_labels(
    secteur_institionnel2 = "Secteur institutionnel"
  ) %>%
  set_value_labels(
    secteur_institionnel2 = c("Public" = 1, "Privé" = 2, "Ménage" = 3)
  ) %>%

  ## Secteur institutionnel 3 (secteur_institutionnel3)
  mutate(
    secteur_institutionnel3 = case_when(
      EP11 %in% 1:2 ~ 1,
      EP11 == 3 ~ 2,
      EP11 == 4 ~ 3,
      EP11 == 5 ~ 4,
      EP11 %in% 6:7 ~ 5,
      EP11 == 8 ~ 6,
      TRUE ~ NA_real_
    )
  ) %>%
  set_variable_labels(
    secteur_institutionnel3 = "Secteur institutionnel"
  ) %>%
  set_value_labels(
    secteur_institutionnel3 = c("Public/parapublic" = 1, "Entreprise privée non agricole" = 2, "Entreprise agricole" = 3, "Organisation internationale" = 4, "ONG/eglise" = 5, "Ménage" = 6)
  ) %>%

  # --- Population au chômage ---

  ## Chômeur sans promesse d'emploi (aucun_emp)
  mutate(
    aucun_emp = as.integer(
      pop_emp_dich == 0 & (SRH1 == 1 | SRH2 == 1) & SRH11 == 1 & PAT == 1
    )
  ) %>%
  set_variable_labels(
    aucun_emp = "Chômeur qui n'ont pas de promesse"
  ) %>%
  set_value_labels(
    aucun_emp = c("Non" = 0, "Oui" = 1)
  ) %>%

  ## Futur entrant (futures_staters)
  mutate(
    futures_staters = as.integer(
      SRH1 == 2 & SRH2 == 2 & SRH2A == 2 & SRH7 == 18 & SRH9 == 1 & pop_emp_dich == 0 & PAT == 1
    )
  ) %>%
  set_variable_labels(
    futures_staters = "Recherchent pas un emploi car ils en ont déjà trouvé un et sont disponibles pour commencer un emploi"
  ) %>%
  set_value_labels(
    futures_staters = c("Non" = 0, "Oui" = 1)
  ) %>%

  ## Population au chômage (pop_chomage)
  mutate(
    pop_chomage = case_when(
      PAT == 1 & pop_emp_dich == 0 & aucun_emp == 1 ~ 1,
      PAT == 1 & pop_emp_dich == 0 & futures_staters == 1 ~ 2,
      TRUE ~ NA_real_
    )
  ) %>%
  set_variable_labels(
    pop_chomage = "Population au chômage"
  ) %>%
  set_value_labels(
    pop_chomage = c("Auncune d'emploi sans promesse" = 1, "Futures staters" = 2)
  ) %>%

  ## Variable dichotomique sur le chômage (pop_chomage_dich)
  mutate(
    pop_chomage_dich = as.integer(!is.na(pop_chomage))
  ) %>%
  set_variable_labels(
    pop_chomage_dich = "Population au chômage (dichotomique)"
  ) %>%
  set_value_labels(
    pop_chomage_dich = c("Non" = 0, "Oui" = 1)
  ) %>%

  # --- Statut de la population en âge de travailler ---

  ## Statut de la main d'oeuvre (statut_MO)
  mutate(
    statut_MO = case_when(
      PAT == 1 & pop_emp_dich == 1 ~ 1,
      PAT == 1 & pop_chomage_dich == 1 ~ 2,
      PAT == 1 ~ 3,
      TRUE ~ NA_real_
    )
  ) %>%
  set_variable_labels(
    statut_MO = "Statut de la population en age de travailler"
  ) %>%
  set_value_labels(
    statut_MO = c("Population en emploi" = 1, "Population au chomage" = 2, "Population hors main d'oeuvre" = 3)
  ) %>%

  ## Main d'oeuvre (MO)
  mutate(
    MO = case_when(
      PAT == 1 & statut_MO == 1 ~ 1,
      PAT == 1 & statut_MO == 2 ~ 2,
      TRUE ~ NA_real_
    )
  ) %>%
  set_variable_labels(
    MO = "Main d'oeuvre"
  ) %>%
  set_value_labels(
    MO = c("Population en emploi" = 1, "Population au chômage" = 2)
  ) %>%

  ## Variable dichotomique sur la main d'oeuvre (MO_dich)
  mutate(
    MO_dich = as.integer(!is.na(MO))
  ) %>%
  set_variable_labels(
    MO_dich = "Main d'oeuvre (dichotomique)"
  ) %>%
  set_value_labels(
    MO_dich = c("Non" = 0, "Oui" = 1)
  ) %>%

  # --- Main d'oeuvre potentielle ---

  ## Non disponible (Non_dispo)
  mutate(
    Non_dispo = as.integer(
      statut_MO == 3 & (SRH1 == 1 | SRH2 == 1) & SRH11 == 2
    )
  ) %>%
  set_variable_labels(
    Non_dispo = "Personne non disponibles"
  ) %>%
  set_value_labels(
    Non_dispo = c("Non" = 0, "Oui" = 1)
  ) %>%

  ## Aucune recherche (aucune_rech)
  mutate(
    aucune_rech = as.integer(
      statut_MO == 3 & SRH1 == 2 & SRH2 == 2 & SRH11 == 1
    )
  ) %>%
  set_variable_labels(
    aucune_rech = "Aucune recherche"
  ) %>%
  set_value_labels(
    aucune_rech = c("Non" = 0, "Oui" = 1)
  ) %>%

  ## Main d'oeuvre potentielle (MOPOT)
  mutate(
    MOPOT = case_when(
      PAT == 1 & Non_dispo == 1 ~ 1,
      PAT == 1 & aucune_rech == 1 ~ 2,
      TRUE ~ NA_real_
    )
  ) %>%
  set_variable_labels(
    MOPOT = "Main d'oeuvre potentielle"
  ) %>%
  set_value_labels(
    MOPOT = c("Non disponible" = 1, "Aucune recherche" = 2)
  ) %>%

  ## Variable dichotomique sur la MOPOT (MOPOT_dich)
  mutate(
    MOPOT_dich = as.integer(!is.na(MOPOT))
  ) %>%
  set_variable_labels(
    MOPOT_dich = "Main d'oeuvre potentielle (dichotomique)"
  ) %>%
  set_value_labels(
    MOPOT_dich = c("Non" = 0, "Oui" = 1)
  ) %>%

  # --- Main d'oeuvre élargie: MOE ---

  ## Main d'oeuvre élargie (MOE)
  mutate(
    MOE = case_when(
      PAT == 1 & MO_dich == 1 ~ 1,
      PAT == 1 & MOPOT_dich == 1 ~ 2,
      TRUE ~ NA_real_
    )
  ) %>%
  set_variable_labels(
    MOE = "Main d'oeuvre élargie"
  ) %>%
  set_value_labels(
    MOE = c("Main d'oeuvre" = 1, "Main d'oeuvre potentielle" = 2)
  ) %>%

  ## Variable dichotomique sur la main d'oeuvre élargie (MOE_dich)
  mutate(
    MOE_dich = as.integer(!is.na(MOE))
  ) %>%
  set_variable_labels(
    MOE_dich = "Main d'oeuvre élargie (dichotomique)"
  ) %>%
  set_value_labels(
    MOE_dich = c("Non" = 0, "Oui" = 1)
  ) %>%

  # ==============================================================================
  # Sous utilisation de la main d'oeuvre (Revoir)
  # ==============================================================================

  ## Heures effectives de travail (hor_eff)
  mutate(
    hor_eff = case_when(
      PAT == 1 & pop_emp_dich == 1 & WKT17A == 1 ~ NB_HEURE_TRAVAIL_TOTAL,
      PAT == 1 & pop_emp_dich == 1 & WKT17A == 2 ~ WKT18,
      TRUE ~ NA_real_
    )
  ) %>%
  set_variable_labels(
    hor_eff = "Nombre effective de travail"
  ) %>%

  ## Sous emploi lié au temps de travail (sous_emp)
  mutate(
    sous_emp = as.integer(
      PAT == 1 & pop_emp_dich == 1 & hor_eff < 40 & WKI4 == 1 & WKI5 == 1
    )
  ) %>%
  set_variable_labels(
    sous_emp = "Sous emploi lié au temps de travail"
  ) %>%
  set_value_labels(
    sous_emp = c("Non" = 0, "Oui" = 1)
  ) %>%

  ## Taux de chômage SU1 (SU1)
  mutate(
    SU1 = as.integer(
      MO %in% c(1, 2) & PAT == 1 & pop_chomage_dich == 1
    )
  ) %>%
  set_variable_labels(
    SU1 = "Taux de chômage SU1"
  ) %>%
  set_value_labels(
    SU1 = c("Non" = 0, "Oui" = 1)
  ) %>%

  ## Taux de chômage SU2 (SU2)
  mutate(
    SU2 = as.integer(
      MO %in% c(1, 2) & PAT == 1 & (pop_chomage_dich == 1 | sous_emp == 1)
    )
  ) %>%
  set_variable_labels(
    SU2 = "Taux de chômage lié à la durée du travail"
  ) %>%
  set_value_labels(
    SU2 = c("Non" = 0, "Oui" = 1)
  ) %>%

  ## Taux de chômage SU3 (SU3)
  mutate(
    SU3 = as.integer(
      MOE %in% c(1, 2) & PAT == 1 & (pop_chomage_dich == 1 | MOPOT_dich == 1)
    )
  ) %>%
  set_variable_labels(
    SU3 = "Taux de chômage combiné à la main d'oeuvre potentielle"
  ) %>%
  set_value_labels(
    SU3 = c("Non" = 0, "Oui" = 1)
  ) %>%

  ## Mesure composite de la sous-utilisation de la main-d'œuvre: SU4 (SU4)
  mutate(
    SU4 = as.integer(
      MOE %in% c(1, 2) & PAT == 1 & (pop_chomage_dich == 1 | MOPOT_dich == 1 | sous_emp == 1)
    )
  ) %>%
  set_variable_labels(
    SU4 = "Taux de chômage SU4"
  ) %>%
  set_value_labels(
    SU4 = c("Non" = 0, "Oui" = 1)
  ) %>%

  # ==============================================================================
  # Classification Internationale selon la situation dans l'emploi
  # ==============================================================================

  ## Emploi principal (sit_empEP)
  mutate(
    duree_contrat = case_when(
      EP30b == 3 ~ EP30,
      EP30b == 2 ~ EP30 * 365,
      EP30b == 1 ~ EP30 * 30,
      TRUE ~ NA_real_
    ),
    sit_empEP = case_when(
      pop_emp_dich == 1 & PAT == 1 & EP3 == 2 & (EP11 %in% c(1, 2, 5) | (EP11 %in% c(3, 4, 6, 7) & EP14B == 1)) ~ 11,
      pop_emp_dich == 1 & PAT == 1 & EP3 == 2 & (EP11 %in% c(3, 4, 6, 7, 8) & EP14B %in% c(2, 9998)) ~ 12,
      pop_emp_dich == 1 & PAT == 1 & EP3 == 3 & (EP11 %in% c(3, 4, 6, 7) & EP14B == 1) ~ 21,
      pop_emp_dich == 1 & PAT == 1 & EP3 == 3 & (EP11 == 8 | (EP11 %in% c(3, 4, 6, 7) & EP14B %in% c(2, 9998))) ~ 22,
      pop_emp_dich == 1 & PAT == 1 & EP3 == 1 & EP6a != 1 & EP37 == 2 & EP10c != 1 ~ 3,
      pop_emp_dich == 1 & PAT == 1 & EP3 == 1 & (EP29 %in% c(3, 4) | EP37 == 1) ~ 41,
      pop_emp_dich == 1 & PAT == 1 & EP3 == 1 & ((EP29 %in% c(1, 2) & duree_contrat >= 365) | (EP28 == 9998 & EP37 == 1)) ~ 42,
      pop_emp_dich == 1 & PAT == 1 & EP3 == 1 & ((EP29 %in% c(1, 2) & duree_contrat < 365) | (EP28 == 9998)) ~ 43,
      EP3 %in% c(8, 9) ~ 44,
      EP3 %in% c(5, 6) ~ 5,
      EP3 == 4 ~ 6,
      EP3 == 10 ~ 7,
      TRUE ~ NA_real_
    )
  ) %>%
  set_variable_labels(
    duree_contrat = "Duree du contrat de travail en jour",
    sit_empEP = "Situation dans l'emploi (ICSEa 18)"
  ) %>%
  set_value_labels(
    sit_empEP = c("Employeurs en entreprise légalement constituée" = 11, "Employeurs en entreprise non légalement constituée" = 12, "Travailleurs pour compte propre en entreprise légalement constituée" = 21, "Travailleurs pour compte propre en entreprise non légalement constituée" = 22, "Contractuel dépendant" = 3, "Employés permanents" = 41, "Employés en contrat à durée déterminée" = 42, "Employés temporaires" = 43, "Apprenti ou stagiare payé" = 44, "Travailleurs familiaux" = 5, "Membre coopérative" = 6, "Non classé" = 7)
  ) %>%

  ## Emploi principal agrégé en 7 modalités (sit_empEP2)
  mutate(
    sit_empEP2 = case_when(
      sit_empEP %in% c(11, 12) ~ 1,
      sit_empEP %in% c(21, 22) ~ 2,
      sit_empEP == 3 ~ 3,
      sit_empEP %in% c(41, 42, 43, 44) ~ 4,
      sit_empEP == 5 ~ 5,
      sit_empEP == 6 ~ 6,
      sit_empEP == 7 ~ 7,
      TRUE ~ NA_real_
    )
  ) %>%
  set_variable_labels(
    sit_empEP2 = "Situation dans l'emploi agrégé en 7 modalités"
  ) %>%
  set_value_labels(
    sit_empEP2 = c("Employeurs" = 1, "Travailleurs pour compte propre" = 2, "Contractuel dépendant" = 3, "Employés" = 4, "Travailleurs familiaux" = 5, "Membre coopérative" = 6, "Non classé" = 7)
  ) %>%

  ## Emploi principal agrégé en 5 modalités (sit_empEP3)
  mutate(
    sit_empEP3 = case_when(
      sit_empEP %in% c(11, 12) ~ 1,
      sit_empEP %in% c(21, 22) ~ 2,
      sit_empEP == 3 ~ 3,
      sit_empEP %in% c(41, 42, 43, 44) ~ 4,
      sit_empEP == 5 ~ 5,
      sit_empEP == 7 ~ 7,
      TRUE ~ NA_real_
    )
  ) %>%
  set_variable_labels(
    sit_empEP3 = "Situation dans l'emploi selon agrégé en 5 modalités (ICSEa 18_5 ou ICSE 13)"
  ) %>%
  set_value_labels(
    sit_empEP3 = c("Employeurs" = 1, "Travailleurs pour compte propre ou Travailleurs indépendants sans employés" = 2, "Contractuel dépendant" = 3, "Employés" = 4, "Travailleurs familiaux" = 5, "Non classé" = 7)
  ) %>%

  ## Regroupement selon le degré d'autorité (sit_empEP_Autorite)
  mutate(
    sit_empEP_Autorite = case_when(
      sit_empEP %in% c(11, 12, 21, 22) ~ 1,
      sit_empEP %in% c(3, 41, 42, 43, 44, 5) ~ 2,
      sit_empEP == 7 ~ 4,
      TRUE ~ NA_real_
    )
  ) %>%
  set_variable_labels(
    sit_empEP_Autorite = "regroupement de la situation dans l'emploi selon le dégré d'autorité"
  ) %>%
  set_value_labels(
    sit_empEP_Autorite = c("Travailleurs indépendants" = 1, "Travailleurs dépendants" = 2, "Non classé" = 4)
  ) %>%

  ## Regroupement selon le type de risque économique (sit_empEP_risk)
  mutate(
    sit_empEP_risk = case_when(
      sit_empEP %in% c(12, 22, 3, 5) ~ 1,
      sit_empEP %in% c(11, 21, 41, 42, 43, 44) ~ 2,
      sit_empEP == 7 ~ 4,
      TRUE ~ NA_real_
    )
  ) %>%
  set_variable_labels(
    sit_empEP_risk = "regroupement  de la situation dans l'emploi selon le type de risque économique"
  ) %>%
  set_value_labels(
    sit_empEP_risk = c("Travailleurs employés pour le profit" = 1, "Travailleurs employés contre rémunération" = 2, "Non classé" = 4)
  ) %>%

  # ==============================================================================
  # Qualité de l'emploi
  # ==============================================================================

  ## Formalité du secteur (form_sect)
  mutate(
    form_sect = case_when(
      PAT == 1 & EP11 == 8 ~ 3,
      PAT == 1 & ((EP3 %in% c(1, 8, 9) & EP11 %in% c(1, 2, 5)) | (EP3 %in% c(2, 3) & EP14B == 1) | (EP3 %in% c(2, 3) & (EP20 == 1 | EP22 == 1)) | (EP3 %in% c(2, 3) & (EP24__1 == 1 | EP24__2 == 1))) ~ 1,
      PAT == 1 & EP11 != 8 & (EP3 %in% c(2, 3) | (EP3 %in% c(1, 8, 9) & EP11 %in% c(1, 2, 5))) ~ 2,
      TRUE ~ NA_real_
    )
  ) %>%
  set_variable_labels(
    form_sect = "Formalité du secteur"
  ) %>%
  set_value_labels(
    form_sect = c("Secteur formel" = 1, "Secteur informel" = 2, "Ménage" = 3)
  ) %>%

  ## Formalité de l'emploi principal (form_empEP)
  mutate(
    form_empEP = case_when(
      pop_emp_dich == 1 & PAT == 1 & sit_empEP_Autorite == 1 & form_sect == 1 ~ 1,
      pop_emp_dich == 1 & PAT == 1 & sit_empEP3 == 3 & form_sect == 1 & (EP37 == 1 | EP38 == 1 | EP39 == 1 | EP44 == 1) ~ 1,
      pop_emp_dich == 1 & PAT == 1 & sit_empEP3 == 4 & (EP37 == 1 | EP38 == 1 | EP39 == 1 | EP44 == 1) ~ 1,
      pop_emp_dich == 1 & PAT == 1 & sit_empEP %in% c(5, 6, 7) & form_sect == 1 & (EP37 == 1 | EP38 == 1 | EP39 == 1 | EP44 == 1) ~ 1,
      pop_emp_dich == 1 & PAT == 1 & form_sect == 3 & (EP37 == 1 | EP38 == 1 | EP39 == 1 | EP44 == 1) ~ 1,
      TRUE ~ 0
    )
  ) %>%
  set_variable_labels(
    form_empEP = "Statut de l'emploi principal"
  ) %>%
  set_value_labels(
    form_empEP = c("Emploi informel" = 0, "Emploi formel" = 1)
  ) %>%

  ## Emploi vulnérable (emp_vul)
  mutate(
    emp_vul = as.integer(
      pop_emp_dich == 1 & PAT == 1 & EP3 %in% c(3, 5)
    )
  ) %>%
  set_variable_labels(
    emp_vul = "Taux d'emploi vulnerable"
  ) %>%
  set_value_labels(
    emp_vul = c("Non" = 0, "Oui" = 1)
  ) %>%

  ## Emploi précaire (emp_prec)
  mutate(
    emp_prec = as.integer(
      pop_emp_dich == 1 & PAT == 1 & EP29 %in% c(1, 2, 4)
    )
  ) %>%
  set_variable_labels(
    emp_prec = "Emploi précaire"
  ) %>%
  set_value_labels(
    emp_prec = c("Non" = 0, "Oui" = 1)
  ) %>%

  # ==============================================================================
  # NEETS
  # ==============================================================================

  ## Pas en éducation (no_education)
  mutate(
    no_education = case_when(
      AgeAnnee >= 3 & (EF6 != 1 | EF1 == 2) ~ 1,
      AgeAnnee >= 3 ~ 0,
      TRUE ~ NA_real_
    )
  ) %>%
  set_variable_labels(
    no_education = "Personne pas en education au moment de l'enquête"
  ) %>%
  set_value_labels(
    no_education = c("En education actuellement" = 0, "Pas en education actuellement" = 1)
  ) %>%

  ## Pas en formation (no_formation)
  mutate(
    no_formation = case_when(
      AgeAnnee >= 6 & (FP1 == 2 | (FP1 == 1 & FP6 != 2)) ~ 1,
      AgeAnnee >= 6 ~ 0,
      TRUE ~ NA_real_
    )
  ) %>%
  set_variable_labels(
    no_formation = "Personne pas en formation au moment de l'enquête"
  ) %>%
  set_value_labels(
    no_formation = c("En formation actuellement" = 0, "Pas en formation actuellement" = 1)
  ) %>%

  ## NEETs
  mutate(
    NEETs = as.integer(
      pop_emp_dich == 0 & no_education == 1 & no_formation == 1
    ),
    NEET15_24 = as.integer(jeune15_24 == 1 & NEETs == 1),
    NEET15_35 = as.integer(jeune15_35 == 1 & NEETs == 1),
    NEET15_40 = as.integer(jeune15_40 == 1 & NEETs == 1)
  ) %>%
  set_variable_labels(
    NEETs = "Neet",
    NEET15_24 = "NEETs (15-24 ans)",
    NEET15_35 = "NEETs (15-35 ans)",
    NEET15_40 = "NEETs (15-40 ans)"
  ) %>%
  set_value_labels(
    NEETs = c("Non Neet" = 0, "Neet" = 1)
  ) %>%

  # ==============================================================================
  # Pluriactivité
  # ==============================================================================

  ## Pluriactivité (pluriactivite)
  mutate(
    pluriactivite = as.integer(
      pop_emp_dich == 1 & PAT == 1 & (PL1 == 1 | (PL1 == 2 & PL2 == 1))
    )
  ) %>%
  set_variable_labels(
    pluriactivite = "Personne en emploi avec plus d'un activte"
  ) %>%
  set_value_labels(
    pluriactivite = c("Non" = 0, "Oui" = 1)
  )