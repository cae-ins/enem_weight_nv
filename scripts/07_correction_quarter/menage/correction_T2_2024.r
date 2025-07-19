library(dplyr)

apply_T2_2024_correction <- function(df) {

  # --------------------------------------------------------------------
  # Sous-fonction : réaffectation d’un ménage unique
  reaffecter_menage <- function(df, ikey, region, depart, souspref, ZD) {
    df %>%
      mutate(
        HH2 = ifelse(interview__key == ikey, region, HH2),
        HH3 = ifelse(interview__key == ikey, depart, HH3),
        HH4 = ifelse(interview__key == ikey, souspref, HH4),
        HH8 = ifelse(interview__key == ikey, ZD, HH8)
      )
  }

  # --------------------------------------------------------------------
  # Sous-fonction : réaffectation d’un groupe de ménages identiques
  reaffecter_menages_groupe <- function(df, keys, region, depart, souspref, ZD) {
    for (ikey in keys) {
      df <- reaffecter_menage(df, ikey, region, depart, souspref, ZD)
    }
    return(df)
  }

  # --------------------------------------------------------------------
  # Sous-fonction : suppression des interviews à supprimer
  supprimer_menages_vides <- function(df, keys_a_supprimer) {
    df %>% filter(!interview__key %in% keys_a_supprimer)
  }

  # --------------------------------------------------------------------
  # Clés des interviews à supprimer (nouveau + ancien)
  cles_suppr <- c(
    "07-22-93-19", "11-68-53-03", "13-47-97-94", "18-60-49-50",
    "18-74-30-69", "21-40-72-82", "28-39-71-69", "31-35-48-19",
    "49-09-93-51", "63-03-27-27", "79-93-49-22", "83-79-83-99",
    "89-89-22-16", "86-05-71-44", "72-80-67-78", "06-22-03-87"
  )

  # --------------------------------------------------------------------
  # Application en pipeline
  df %>%
    reaffecter_menage("87-03-24-57", 10617, 10617024, 1061702402, "4003") %>%

    reaffecter_menages_groupe(
      keys = c("03-61-35-11", "98-35-46-81", "67-05-62-43",
               "62-34-78-74", "37-03-14-94", "16-14-09-83", "51-74-69-13"),
      region = 10101, depart = 10101002, souspref = 1010100211, ZD = "0893"
    ) %>%

    reaffecter_menage("80-40-38-81", 10615, 10615021, 1061502103, "0069") %>%
    reaffecter_menage("63-03-27-27", 11103, 11103029, 1110302906, "0255") %>%
    reaffecter_menage("86-05-71-44", 10524, 10524081, 1052408102, "6006") %>%
    reaffecter_menage("04-62-90-06", 11006, 11006031, 1100603105, "0127") %>%
    reaffecter_menage("34-00-83-22", 11423, 11423076, 1142307602, "6016") %>%
    reaffecter_menage("81-41-54-56", 10510, 10510034, 1051003404, "0012") %>%
    reaffecter_menage("16-64-40-46", 10325, 10325077, 1032507701, "6009") %>%

    supprimer_menages_vides(keys_a_supprimer = cles_suppr)
}