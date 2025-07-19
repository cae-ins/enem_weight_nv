library(dplyr)
library(stringr)
library(haven)

filtrer_menages_et_drops <- function(df) {
  keys_to_drop <- c(
    "94-48-85-25", "14-25-10-79", "78-30-78-37", "69-48-06-98", "69-30-53-46",
    "12-83-32-35", "34-60-64-68", "46-55-23-68", "22-54-88-20", "96-37-49-58",
    "11-76-22-39", "54-85-64-75", "57-34-38-20", "89-80-42-60", "72-37-75-88",
    "61-26-20-96", "62-95-23-94", "47-40-93-91"
  )
  
  df %>%
    filter(hh == 1) %>%
    filter(!interview__key %in% keys_to_drop)
}


reclasse_massala_silakoro <- function(df) {
  keys <- c(
    "62-18-43-17", "70-80-81-58", "63-24-96-44", "86-79-76-75",
    "78-69-68-00", "36-08-90-10", "04-62-07-82", "96-33-35-02",
    "64-06-28-76", "32-38-08-73", "47-33-20-39", "32-18-08-35"
  )
  
  df %>%
    mutate(
      HH1 = if_else(interview__key %in% keys, 113, HH1),
      HH2 = if_else(interview__key %in% keys, 11314, HH2),
      HH3 = if_else(interview__key %in% keys, 11314080, HH3),
      HH4 = if_else(interview__key %in% keys, 1131408003, HH4),
      HH6 = if_else(interview__key %in% keys, 2, HH6),
      HH8 = if_else(interview__key %in% keys, "6009", HH8)
    )
}

reclasse_silakoro_massala <- function(df) {
  keys <- c(
    "40-84-95-82", "01-14-65-83", "71-81-01-92", "65-27-61-70",
    "14-85-34-42", "36-41-81-85", "66-12-70-48", "81-42-70-95",
    "50-57-52-80", "48-07-54-39", "58-49-07-49", "56-50-88-83"
  )
  
  df %>%
    mutate(
      HH1 = if_else(interview__key %in% keys, 113, HH1),
      HH2 = if_else(interview__key %in% keys, 11314, HH2),
      HH3 = if_else(interview__key %in% keys, 11314039, HH3),
      HH4 = if_else(interview__key %in% keys, 1131403908, HH4),
      HH6 = if_else(interview__key %in% keys, 2, HH6),
      HH8 = if_else(interview__key %in% keys, "6009", HH8)
    )
}

# Fonction principale qui exécute tout le pipeline
apply_T4_2024_correction <- function(df) {
  df %>%
    filtrer_menages_et_drops() %>%
    reclasse_massala_silakoro() %>%
    reclasse_silakoro_massala()
}
