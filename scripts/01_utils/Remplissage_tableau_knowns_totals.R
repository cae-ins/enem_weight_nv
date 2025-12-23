
library(readxl)
library(tidyr)
library(dplyr)
library(zoo)
library(writexl)

############### Importation des tables ###############


root <- "C:/Users/f.migone/Desktop/ENE_SURVEY_WEIGHTS/data/01_raw/RpProj/"
dir_table_RP_Proj <- "C:/Users/f.migone/Desktop/ENE_SURVEY_WEIGHTS/data/01_raw/RpProj/ANStat_Trimestre.xlsx"

dir_table_RP_Proj



Creation_table_knowns_totals <- function(root, dir_table_RP_Proj, trimestre, nb_contraintes) {
  
  ### Table de projection (récensement)
  
  table_RP_Proj = read_xlsx(dir_table_RP_Proj, sheet = paste0("TAB2_",trimestre))
  

  ### Reformater la table de projection
  
  ## Concatener region et sexe et ensuite milieu et groupe d'age
  
  # Répéter les regions dans les cellules vides (en colonne)
  table_RP_Proj <- table_RP_Proj |> 
    fill(2, .direction = "down")
  
  
  # Répéter le milieu  dans les cellules vide (en ligne)
  i <- 1  # numéro de la ligne
  cols <- 5:dim(table_RP_Proj)[2]
  
  table_RP_Proj[i, cols] <- t(na.locf(t(table_RP_Proj[i, cols, drop = FALSE])))
  
  # Concatenations region et sexe
  
  table_RP_Proj[, 4] <- paste0(
    table_RP_Proj[[2]],
    "__",
    table_RP_Proj[[4]]
  )
  
  # Concatenation milieu et groupe d'age
  
  table_RP_Proj[4, ] <- table_RP_Proj %>%
    slice(c(1, 3)) %>%                         
    summarise(across(everything(), ~paste(.x, collapse = "__")))
  
  
  ## Utiliser pivot_longer et après détacher les concatenations
  
  table_RP_Proj <- table_RP_Proj %>% # Récupérer les éléments de la table qui nous intéressent
    slice(4:n()) %>%          
    select(4:ncol(.))
    
  table_RP_Proj[1, 1] = "Region_Sexe"
  
  table_RP_Proj <- table_RP_Proj %>% # Prendre la première ligne comme nom de colonne
    slice(-1) %>%                     
    setNames(as.character(table_RP_Proj[1, ]))
  
  # Reformatatage
  
  table_RP_Proj <- table_RP_Proj |>
    pivot_longer(
      cols = -Region_Sexe,            # colonnes à transformer
      names_to = "Mileu_AgeGroup",    # nouvelle colonne
      values_to = "Nombre"   # valeurs
    )
  
  # Détacher les concatenations
  
  table_RP_Proj <- table_RP_Proj %>%
    separate(Region_Sexe, into = c("Region", "Sexe"), sep = "__")%>%
    separate(Mileu_AgeGroup, into = c("Mileu", "AgeGroup"), sep = "__")%>%
    mutate(across(everything(), ~gsub("Ensemble", "National", .)))%>%
    filter(!if_any(everything(), ~ grepl("Total", .))) %>%  
    mutate(Nombre = as.numeric(Nombre)) # convertir en numérique
    
  
  # Aggrégation 
  
  if(nb_contraintes == 180){
  
    table_final <- table_RP_Proj %>%
      filter(Region != "National") %>%  
      mutate(AgeGroup = if_else(AgeGroup == "0-14", AgeGroup, "15_plus")) %>%
      group_by(Region, Sexe, AgeGroup) %>%
      summarise(Nombre = sum(Nombre, na.rm = TRUE), .groups = "drop")%>%
      bind_rows(table_RP_Proj %>%
                  filter(Region == "National"))%>%
      select(names(table_RP_Proj)) %>%   # remet l’ordre des colonnes d’origine 
      left_join(table_RP_Proj %>%
                  select(Region, Sexe)%>%
                  distinct(Region, Sexe) %>%
                  mutate(.row_id = row_number()) # numéroter les lignes originales
                  , by = c("Region", "Sexe")) %>%
      arrange(.row_id) %>%                # remettre l’ordre initial
      select(-.row_id)    # supprimer la colonne temporaire
    
    write_xlsx(table_final, paste0(root, "KNOWNS_TOTAL_180X_1D_", trimestre, ".xlsx"))
    
  }
  
  else if(nb_contraintes == 312){
    
    table_final <- table_RP_Proj %>%
      filter(Region != "National") %>%  
      mutate(AgeGroup = if_else(AgeGroup == "0-14", AgeGroup, "15_plus")) %>%
      group_by(Region, Sexe, Mileu, AgeGroup) %>%
      summarise(Nombre = sum(Nombre, na.rm = TRUE), .groups = "drop")%>%
      bind_rows(table_RP_Proj %>%
                  filter(Region == "National"))%>%
      select(names(table_RP_Proj)) %>%   # remet l’ordre des colonnes d’origine 
      left_join(table_RP_Proj %>%
                  select(Region, Sexe, Mileu)%>%
                  distinct(Region, Sexe, Mileu) %>%
                  mutate(.row_id = row_number()) # numéroter les lignes originales
                , by = c("Region", "Sexe", "Mileu")) %>%
      arrange(.row_id) %>%                # remettre l’ordre initial
      select(-.row_id)    # supprimer la colonne temporaire
    
    
    write_xlsx(table_final, paste0(root, "KNOWNS_TOTAL_312X_1D_", trimestre, ".xlsx"))
    
    
  }
  
  else if(nb_contraintes == 444){
    
    table_final <- table_RP_Proj %>%
      filter(Region != "National") %>%  
      mutate(AgeGroup = if_else(AgeGroup == "0-14", AgeGroup, if_else(AgeGroup %in% c("15-19", "20-24", "25-29", "30-34"), "15-34", "35_plus"))) %>%
      group_by(Region, Sexe, Mileu, AgeGroup) %>%
      summarise(Nombre = sum(Nombre, na.rm = TRUE), .groups = "drop")%>%
      bind_rows(table_RP_Proj %>%
                  filter(Region == "National"))%>%
      select(names(table_RP_Proj)) %>%   # remet l’ordre des colonnes d’origine 
      left_join(table_RP_Proj %>%
                  select(Region, Sexe, Mileu)%>%
                  distinct(Region, Sexe, Mileu) %>%
                  mutate(.row_id = row_number()) # numéroter les lignes originales
                , by = c("Region", "Sexe", "Mileu")) %>%
      arrange(.row_id) %>%                # remettre l’ordre initial
      select(-.row_id)    # supprimer la colonne temporaire
    
    
    write_xlsx(table_final, paste0(root, "KNOWNS_TOTAL_444X_1D_", trimestre, ".xlsx"))
    
  }
  
}

# Création des tables knowns totals

for (nb_X in c(180)) {
  for (trimestre in c("T1_2025", "T2_2025","T3_2025")) {
    Creation_table_knowns_totals(root, dir_table_RP_Proj, trimestre, nb_X)
  }
}


