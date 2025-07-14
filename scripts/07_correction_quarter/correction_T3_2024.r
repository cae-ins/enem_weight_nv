library(dplyr)

correction_reaffectation_denombrement <- function(data) {


  # Cette fonction s'applique sur les données de dénombrement pour corriger certaines valeurs spécifiques
  # 1. Remplacer les valeurs pour l'entretien "52-72-00-97"
  # Stata: replace ZD = 186 if interview__key=="52-72-00-97"
  # Stata: replace HH8 = "0186" if interview__key=="52-72-00-97"
  data <- data %>%
    mutate(
      ZD = ifelse(interview__key == "52-72-00-97", 186, ZD),
      HH8 = ifelse(interview__key == "52-72-00-97", "0186", HH8)
    )

  return(data)
}

correction_taille_segment <- function(data) {

  # Cette fonction corrige la taille du segment en fonction de l'entretien. Peut ne pas être nécessaire si les données sont déjà nettoyées dans dénombrement_update.
  # Cette fonction s'applique sur les données de dénombrement pour corriger les tailles de segments spécifiques
  # Série de remplacements pour `p4d`
  # L'utilisation de `case_when` est plus propre que des `ifelse` imbriqués en R.
  data <- data %>%
    mutate(
      p4d = case_when(
        interview__key == "90-07-52-04" ~ 15,
        (HH2 == 10702 & HH3 == 10702048 & HH4 == 1070204803 & HH8 == "6048") ~ 40,
        (HH2 == 10829 & HH3 == 10829111 & HH4 == 1082911103 & HH8 == "6019") ~ 26,
        (HH2 == 11132 & HH3 == 11132086 & HH4 == 1113208602 & HH8 == "6013") ~ 24,
        (HH2 == 11322 & HH3 == 11322097 & HH4 == 1132209702 & HH8 == "6043") ~ 51,
        TRUE ~ p4d  # Garde la valeur originale pour toutes les autres lignes
      )
    )

  return(data)
}

correction_suppression_de_zd_denombrement <- function(data) {
  
  # 1. Créez une table des "keys" à supprimer
  keys_a_supprimer <- tibble::tibble(interview__key = c("22-51-62-59", "47-38-68-48", "63-91-92-81", "61-51-78-01"))

  # 2. Créez une table des combinaisons de variables à supprimer
  combinaisons_a_supprimer <- tibble::tribble(
    ~HH2, ~HH3, ~HH4, ~HH8,
    10926, 10926054, 1092605401, "0005",
    10930, 10930004, 1093000401, "6066",
    11018, 11018059, 1101805901, "6019",
    11027, 11027007, 1102700709, "6009",
    11027, 11027062, 1102706201, "0006",
    11228, 11228016, 1122801603, "0024",
    11314, 11314080, 1131408003, "6014",
    11322, 11322097, 1132209702, "6002",
    11408, 11408043, 1140804302, "6004",
    11018, 11018059, 1101805901, "0056",
    11132, 11132032, 1113203201, "6016"
  )

  # Utilisation d'anti_join pour supprimer les lignes correspondantes
  data_filtree <- data %>%
    anti_join(keys_a_supprimer, by = "interview__key") %>%
    anti_join(combinaisons_a_supprimer, by = c("HH2", "HH3", "HH4", "HH8"))
  
  return(data_filtree)
}

correction_reaffectation_menage <- function(data) {

  # La commande `use` de Stata sert à charger les données. En R, vous
  # Cette fonction s'applique sur les données de ménages en l'état de données raw.
  # devez charger votre jeu de données avant d'appeler cette fonction.
  
  # Stata: `replace` pour plusieurs variables basées sur `interview__key`
  data <- data %>%
    mutate(
      # Remplacements pour HH2
      HH2 = case_when(
        interview__key == "63-19-39-34" ~ 11319,
        interview__key == "34-44-74-98" ~ 11103,
        interview__key == "50-55-84-79" ~ 11132,
        TRUE ~ HH2 # Garde la valeur actuelle si aucune condition n'est remplie
      ),
      # Remplacements pour HH3
      HH3 = case_when(
        interview__key == "63-19-39-34" ~ 11319046,
        interview__key == "34-44-74-98" ~ 11103029,
        interview__key == "50-55-84-79" ~ 11132086,
        TRUE ~ HH3
      ),
      # Remplacements pour HH4
      HH4 = case_when(
        interview__key == "63-19-39-34" ~ 1131904604,
        interview__key == "34-44-74-98" ~ 1110302906,
        interview__key == "50-55-84-79" ~ 1113208603,
        TRUE ~ HH4
      ),
      # Remplacements pour HH8
      HH8 = case_when(
        interview__key == "63-19-39-34" ~ "6012",
        interview__key == "34-44-74-98" ~ "0097",
        interview__key == "50-55-84-79" ~ "0009",
        TRUE ~ HH8
      )
    )

  return(data)
}