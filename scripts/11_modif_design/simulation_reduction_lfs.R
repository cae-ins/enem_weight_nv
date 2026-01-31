# ==============================================================================
# SIMULATION DE RÉDUCTION DE TAILLE D'ÉCHANTILLON - ENQUÊTE LFS
# ==============================================================================
# Objectif: Simuler l'impact de la réduction du nombre de ménages par UPE
#           sur la précision des estimations tout en maintenant le nombre d'UPEs
# ==============================================================================

# Chargement des bibliothèques nécessaires
library(dplyr)
library(tidyr)
library(purrr)
library(survey)
library(ggplot2)

# ==============================================================================
# ÉTAPE 0 : CONFIGURATION ET CHARGEMENT DES DONNÉES
# ==============================================================================

# TODO: Précisez vos noms de variables ici
NOM_UPE <- "upe_id"              # Identifiant de l'Unité Primaire d'Échantillonnage
NOM_MENAGE <- "menage_id"         # Identifiant du ménage
NOM_INDIVIDU <- "individu_id"     # Identifiant de l'individu

# Chargement des données LFS (ex: T3 2025)
# TODO: Remplacez par le chemin vers vos données
# donnees_lfs <- read.csv("chemin/vers/donnees_lfs_t3_2025.csv")

# Structure attendue des données :
# - upe_id : identifiant UPE
# - menage_id : identifiant ménage
# - individu_id : identifiant individu
# - statut_reponse : statut de réponse du ménage
# - prob_menage_originale : probabilité de sélection du ménage (original)
# - prob_upe : probabilité de sélection de l'UPE
# - poids_original : poids d'enquête original
# - variables d'intérêt (emploi, chômage, etc.)

# ==============================================================================
# ÉTAPE 1 : DÉFINITION DES PARAMÈTRES DE SIMULATION
# ==============================================================================

# Ratios de réduction à tester
RATIOS_REDUCTION <- c(0.9, 0.8, 0.7, 0.6)

# Nombre d'itérations pour chaque scénario
NOMBRE_ITERATIONS <- 30

# Nombre total de ménages dans chaque UPE (N dans le document)
# Option 1: Valeur unique pour toutes les UPEs
# TOTAL_MENAGES_UPE <- 1000

# Option 2: Vecteur nommé avec valeurs spécifiques par UPE
# TOTAL_MENAGES_UPE <- c(upe1 = 1000, upe2 = 1200, upe3 = 950, ...)

# ==============================================================================
# ÉTAPE 2 : PRÉPARATION DES DONNÉES DE BASE
# ==============================================================================

preparer_donnees_base <- function(donnees, nom_upe, nom_menage, nom_individu) {
  
  cat("Préparation des données de base...\n")
  
  # Filtrer uniquement les ménages répondants
  # TODO: Ajustez la condition selon votre variable de statut de réponse
  donnees_repondantes <- donnees %>%
    filter(statut_reponse == "complet")  # Ajustez selon vos codes
  
  # Compter les ménages répondants par UPE
  menages_par_upe <- donnees_repondantes %>%
    group_by(!!sym(nom_upe)) %>%
    summarise(
      nb_menages_repondants = n_distinct(!!sym(nom_menage)),
      nb_individus = n(),
      .groups = "drop"
    )
  
  cat("Nombre d'UPEs:", nrow(menages_par_upe), "\n")
  cat("Nombre total de ménages répondants:", sum(menages_par_upe$nb_menages_repondants), "\n")
  cat("Nombre total d'individus:", sum(menages_par_upe$nb_individus), "\n")
  
  return(list(
    donnees = donnees_repondantes,
    comptage_menages = menages_par_upe
  ))
}

# ==============================================================================
# ÉTAPE 3 : FONCTION POUR UNE SEULE ITÉRATION DE SIMULATION
# ==============================================================================

simuler_echantillon_reduit <- function(donnees, 
                                       nom_upe, 
                                       nom_menage, 
                                       nom_individu,
                                       ratio_reduction, 
                                       total_menages_upe,
                                       nom_prob_upe = "prob_upe",
                                       iteration = 1) {
  
  # ---------------------------------------------------------------------------
  # Étape 3.1 : Calculer le nombre de ménages à garder par UPE
  # ---------------------------------------------------------------------------
  # Formule : nombre_repondants * ratio_reduction
  
  menages_a_garder <- donnees %>%
    group_by(!!sym(nom_upe)) %>%
    summarise(
      nb_repondants = n_distinct(!!sym(nom_menage)),
      .groups = "drop"
    ) %>%
    mutate(
      nb_a_garder_exact = nb_repondants * ratio_reduction,
      nb_a_garder = floor(nb_a_garder_exact),  # Arrondi à l'entier inférieur
      nb_a_garder = pmax(nb_a_garder, 1)  # Minimum 1 ménage par UPE
    )
  
  # ---------------------------------------------------------------------------
  # Étape 3.2 : Sélectionner aléatoirement les ménages à garder
  # ---------------------------------------------------------------------------
  
  set.seed(1000 + iteration)  # Pour la reproductibilité
  
  menages_selectionnes <- donnees %>%
    select(!!sym(nom_upe), !!sym(nom_menage)) %>%
    distinct() %>%
    left_join(menages_a_garder, by = nom_upe) %>%
    group_by(!!sym(nom_upe)) %>%
    slice_sample(n = first(nb_a_garder)) %>%
    select(!!sym(nom_upe), !!sym(nom_menage))
  
  # ---------------------------------------------------------------------------
  # Étape 3.3 : Filtrer les données (garder seulement les ménages sélectionnés
  #             et TOUS leurs membres)
  # ---------------------------------------------------------------------------
  
  donnees_reduites <- donnees %>%
    semi_join(menages_selectionnes, by = c(nom_upe, nom_menage))
  
  # ---------------------------------------------------------------------------
  # Étape 3.4 : Mettre à jour les probabilités de sélection des ménages
  # ---------------------------------------------------------------------------
  # Nouvelle probabilité = nb_gardes / N (N = total ménages dans l'UPE)
  
  if (length(total_menages_upe) == 1) {
    # Cas 1: Valeur unique pour toutes les UPEs
    donnees_reduites <- donnees_reduites %>%
      group_by(!!sym(nom_upe)) %>%
      mutate(
        nb_gardes_upe = n_distinct(!!sym(nom_menage)),
        nouvelle_prob_menage = nb_gardes_upe / total_menages_upe
      ) %>%
      ungroup()
    
  } else {
    # Cas 2: Valeurs spécifiques par UPE
    totaux_upe <- data.frame(
      upe = names(total_menages_upe),
      total_menages = as.numeric(total_menages_upe)
    )
    names(totaux_upe)[1] <- nom_upe
    
    donnees_reduites <- donnees_reduites %>%
      group_by(!!sym(nom_upe)) %>%
      mutate(nb_gardes_upe = n_distinct(!!sym(nom_menage))) %>%
      ungroup() %>%
      left_join(totaux_upe, by = nom_upe) %>%
      mutate(nouvelle_prob_menage = nb_gardes_upe / total_menages)
  }
  
  # ---------------------------------------------------------------------------
  # Étape 3.5 : Calculer la probabilité totale et le poids de base
  # ---------------------------------------------------------------------------
  # Probabilité totale = prob_upe * nouvelle_prob_menage
  # Poids de base = 1 / probabilité totale
  
  donnees_reduites <- donnees_reduites %>%
    mutate(
      prob_totale = !!sym(nom_prob_upe) * nouvelle_prob_menage,
      poids_base = 1 / prob_totale
    )
  
  return(donnees_reduites)
}

# ==============================================================================
# ÉTAPE 4 : FONCTION DE CALIBRATION DES POIDS
# ==============================================================================

calibrer_poids <- function(donnees, 
                          nom_upe,
                          nom_menage,
                          nom_individu,
                          variables_calibration = NULL,
                          totaux_population = NULL) {
  
  cat("Calibration des poids...\n")
  
  # TODO: Implémentez votre procédure habituelle de calibration
  # Ceci est un exemple simplifié
  
  if (is.null(variables_calibration)) {
    # Si pas de calibration spécifiée, retourner les poids de base
    donnees <- donnees %>%
      mutate(poids_final = poids_base)
    return(donnees)
  }
  
  # Exemple de calibration avec le package survey
  # Créer un design d'enquête
  design <- svydesign(
    ids = as.formula(paste0("~", nom_upe)),
    weights = ~poids_base,
    data = donnees
  )
  
  # Appliquer la calibration (exemple)
  # TODO: Ajustez selon vos totaux de population connus
  # design_calibre <- calibrate(design, formula = ..., population = ...)
  
  # Pour l'instant, on garde les poids de base
  donnees <- donnees %>%
    mutate(poids_final = poids_base)
  
  return(donnees)
}

# ==============================================================================
# ÉTAPE 5 : FONCTION POUR CALCULER LES ESTIMATIONS ET LA PRÉCISION
# ==============================================================================

calculer_precision <- function(donnees,
                               nom_upe,
                               groupes_population = NULL,
                               variables_interet = NULL) {
  
  # Créer le design d'enquête
  design <- svydesign(
    ids = as.formula(paste0("~", nom_upe)),
    weights = ~poids_final,
    data = donnees
  )
  
  # TODO: Calculez vos indicateurs clés du marché du travail
  # Exemples d'indicateurs:
  
  resultats <- list()
  
  # Exemple 1: Taux de chômage global
  if ("est_chomeur" %in% names(donnees)) {
    taux_chomage <- svymean(~est_chomeur, design, na.rm = TRUE)
    resultats$taux_chomage <- list(
      estimation = coef(taux_chomage)[1],
      erreur_type = SE(taux_chomage)[1],
      cv = SE(taux_chomage)[1] / coef(taux_chomage)[1] * 100
    )
  }
  
  # Exemple 2: Taux d'emploi global
  if ("est_employe" %in% names(donnees)) {
    taux_emploi <- svymean(~est_employe, design, na.rm = TRUE)
    resultats$taux_emploi <- list(
      estimation = coef(taux_emploi)[1],
      erreur_type = SE(taux_emploi)[1],
      cv = SE(taux_emploi)[1] / coef(taux_emploi)[1] * 100
    )
  }
  
  # Exemple 3: Estimations par groupes de population
  if (!is.null(groupes_population) && "sexe" %in% names(donnees)) {
    par_sexe <- svyby(~est_chomeur, ~sexe, design, svymean, na.rm = TRUE)
    resultats$chomage_par_sexe <- par_sexe
  }
  
  return(resultats)
}

# ==============================================================================
# ÉTAPE 6 : FONCTION PRINCIPALE - EXÉCUTER TOUTES LES SIMULATIONS
# ==============================================================================

executer_simulations <- function(donnees,
                                nom_upe,
                                nom_menage,
                                nom_individu,
                                ratios_reduction,
                                nb_iterations,
                                total_menages_upe,
                                nom_prob_upe = "prob_upe") {
  
  cat("\n")
  cat("================================================================================\n")
  cat("DÉBUT DES SIMULATIONS\n")
  cat("================================================================================\n")
  cat("Nombre de scénarios:", length(ratios_reduction), "\n")
  cat("Itérations par scénario:", nb_iterations, "\n")
  cat("Total de simulations:", length(ratios_reduction) * nb_iterations, "\n\n")
  
  # Stocker tous les résultats
  tous_resultats <- list()
  
  # Boucle sur chaque ratio de réduction
  for (ratio in ratios_reduction) {
    
    cat("------------------------------------------------------------------------\n")
    cat("Scénario: Ratio de réduction =", ratio, "\n")
    cat("------------------------------------------------------------------------\n")
    
    resultats_scenario <- list()
    
    # Boucle sur chaque itération
    for (iter in 1:nb_iterations) {
      
      if (iter %% 5 == 0) {
        cat("  Itération", iter, "/", nb_iterations, "\n")
      }
      
      # Étape 1: Simuler l'échantillon réduit
      donnees_sim <- simuler_echantillon_reduit(
        donnees = donnees,
        nom_upe = nom_upe,
        nom_menage = nom_menage,
        nom_individu = nom_individu,
        ratio_reduction = ratio,
        total_menages_upe = total_menages_upe,
        nom_prob_upe = nom_prob_upe,
        iteration = iter
      )
      
      # Étape 2: Calibrer les poids
      donnees_sim <- calibrer_poids(
        donnees = donnees_sim,
        nom_upe = nom_upe,
        nom_menage = nom_menage,
        nom_individu = nom_individu
      )
      
      # Étape 3: Calculer les estimations et la précision
      precision <- calculer_precision(
        donnees = donnees_sim,
        nom_upe = nom_upe
      )
      
      # Stocker les résultats de cette itération
      resultats_scenario[[iter]] <- precision
    }
    
    # Stocker les résultats de ce scénario
    tous_resultats[[as.character(ratio)]] <- resultats_scenario
    
    cat("Scénario", ratio, "terminé!\n\n")
  }
  
  cat("================================================================================\n")
  cat("SIMULATIONS TERMINÉES\n")
  cat("================================================================================\n\n")
  
  return(tous_resultats)
}

# ==============================================================================
# ÉTAPE 7 : FONCTION POUR SYNTHÉTISER LES RÉSULTATS
# ==============================================================================

synthetiser_resultats <- function(resultats_simulations, nom_indicateur = "taux_chomage") {
  
  cat("\n")
  cat("================================================================================\n")
  cat("SYNTHÈSE DES RÉSULTATS POUR:", toupper(nom_indicateur), "\n")
  cat("================================================================================\n\n")
  
  synthese <- data.frame()
  
  for (ratio in names(resultats_simulations)) {
    
    iterations <- resultats_simulations[[ratio]]
    
    # Extraire les estimations et erreurs-types de toutes les itérations
    estimations <- sapply(iterations, function(x) {
      if (nom_indicateur %in% names(x)) {
        x[[nom_indicateur]]$estimation
      } else {
        NA
      }
    })
    
    erreurs_types <- sapply(iterations, function(x) {
      if (nom_indicateur %in% names(x)) {
        x[[nom_indicateur]]$erreur_type
      } else {
        NA
      }
    })
    
    cvs <- sapply(iterations, function(x) {
      if (nom_indicateur %in% names(x)) {
        x[[nom_indicateur]]$cv
      } else {
        NA
      }
    })
    
    # Calculer les statistiques
    synthese <- rbind(synthese, data.frame(
      ratio_reduction = as.numeric(ratio),
      estimation_moyenne = mean(estimations, na.rm = TRUE),
      estimation_et = sd(estimations, na.rm = TRUE),
      erreur_type_moyenne = mean(erreurs_types, na.rm = TRUE),
      erreur_type_et = sd(erreurs_types, na.rm = TRUE),
      cv_moyen = mean(cvs, na.rm = TRUE),
      cv_et = sd(cvs, na.rm = TRUE),
      nb_iterations = sum(!is.na(estimations))
    ))
  }
  
  # Afficher le tableau
  print(synthese, row.names = FALSE)
  
  return(synthese)
}

# ==============================================================================
# ÉTAPE 8 : FONCTION POUR CALCULER LES COÛTS
# ==============================================================================

calculer_couts <- function(donnees,
                          nom_upe,
                          nom_menage,
                          cout_visite_upe,
                          cout_menage,
                          couts_upe_specifiques = NULL) {
  
  cat("\n")
  cat("================================================================================\n")
  cat("CALCUL DES COÛTS\n")
  cat("================================================================================\n\n")
  
  # Compter les ménages par UPE
  menages_par_upe <- donnees %>%
    group_by(!!sym(nom_upe)) %>%
    summarise(nb_menages = n_distinct(!!sym(nom_menage)), .groups = "drop")
  
  # Calculer le coût par UPE
  if (is.null(couts_upe_specifiques)) {
    # Coût uniforme pour toutes les UPEs
    menages_par_upe <- menages_par_upe %>%
      mutate(
        cout_visite = cout_visite_upe,
        cout_collecte_menages = nb_menages * cout_menage,
        cout_total_upe = cout_visite + cout_collecte_menages
      )
  } else {
    # Coûts spécifiques par UPE
    couts_df <- data.frame(
      upe = names(couts_upe_specifiques),
      cout_visite = as.numeric(couts_upe_specifiques)
    )
    names(couts_df)[1] <- nom_upe
    
    menages_par_upe <- menages_par_upe %>%
      left_join(couts_df, by = nom_upe) %>%
      mutate(
        cout_collecte_menages = nb_menages * cout_menage,
        cout_total_upe = cout_visite + cout_collecte_menages
      )
  }
  
  # Calculer le coût total
  cout_total <- sum(menages_par_upe$cout_total_upe)
  cout_total_visites <- sum(menages_par_upe$cout_visite)
  cout_total_menages <- sum(menages_par_upe$cout_collecte_menages)
  
  cat("Coût total:", format(cout_total, big.mark = " "), "\n")
  cat("  - Coût des visites UPE:", format(cout_total_visites, big.mark = " "), "\n")
  cat("  - Coût collecte ménages:", format(cout_total_menages, big.mark = " "), "\n")
  cat("Nombre d'UPEs:", nrow(menages_par_upe), "\n")
  cat("Nombre total de ménages:", sum(menages_par_upe$nb_menages), "\n")
  cat("Coût moyen par UPE:", format(mean(menages_par_upe$cout_total_upe), big.mark = " "), "\n")
  cat("Coût moyen par ménage:", format(cout_menage, big.mark = " "), "\n\n")
  
  return(list(
    cout_total = cout_total,
    details_upe = menages_par_upe,
    cout_visite_total = cout_total_visites,
    cout_menages_total = cout_total_menages
  ))
}

# ==============================================================================
# ÉTAPE 9 : FONCTION POUR COMPARER LES SCÉNARIOS (COÛT VS PRÉCISION)
# ==============================================================================

comparer_scenarios <- function(donnees_originales,
                              resultats_simulations,
                              synthese_precision,
                              nom_upe,
                              nom_menage,
                              cout_visite_upe,
                              cout_menage,
                              couts_upe_specifiques = NULL) {
  
  cat("\n")
  cat("================================================================================\n")
  cat("COMPARAISON DES SCÉNARIOS: COÛT VS PRÉCISION\n")
  cat("================================================================================\n\n")
  
  # Calculer le coût de l'échantillon actuel
  cout_actuel <- calculer_couts(
    donnees = donnees_originales,
    nom_upe = nom_upe,
    nom_menage = nom_menage,
    cout_visite_upe = cout_visite_upe,
    cout_menage = cout_menage,
    couts_upe_specifiques = couts_upe_specifiques
  )
  
  # Pour chaque scénario, calculer les coûts réduits
  comparaison <- data.frame()
  
  for (ratio in synthese_precision$ratio_reduction) {
    
    # Nombre de ménages dans le scénario réduit
    nb_menages_reduit <- nrow(donnees_originales %>% 
                               group_by(!!sym(nom_upe)) %>% 
                               summarise(n = n_distinct(!!sym(nom_menage)), .groups = "drop")) *
                         ratio
    
    nb_upes <- n_distinct(donnees_originales[[nom_upe]])
    
    # Coût estimé
    cout_reduit <- (nb_upes * cout_visite_upe) + 
                   (nb_menages_reduit * cout_menage)
    
    # Réduction de coût
    reduction_cout_pct <- (1 - cout_reduit / cout_actuel$cout_total) * 100
    
    # Récupérer les métriques de précision
    precision <- synthese_precision %>% filter(ratio_reduction == ratio)
    
    comparaison <- rbind(comparaison, data.frame(
      scenario = paste0("Ratio ", ratio),
      ratio_reduction = ratio,
      cout_total = cout_reduit,
      reduction_cout_pct = reduction_cout_pct,
      cv_moyen = precision$cv_moyen,
      erreur_type_moyenne = precision$erreur_type_moyenne,
      estimation_moyenne = precision$estimation_moyenne
    ))
  }
  
  # Ajouter le scénario actuel
  precision_actuelle <- synthese_precision[1,]  # Approximation
  
  comparaison <- rbind(
    data.frame(
      scenario = "Actuel (100%)",
      ratio_reduction = 1.0,
      cout_total = cout_actuel$cout_total,
      reduction_cout_pct = 0,
      cv_moyen = precision_actuelle$cv_moyen,
      erreur_type_moyenne = precision_actuelle$erreur_type_moyenne,
      estimation_moyenne = precision_actuelle$estimation_moyenne
    ),
    comparaison
  )
  
  # Trier par ratio de réduction
  comparaison <- comparaison %>% arrange(desc(ratio_reduction))
  
  cat("\nTABLEAU COMPARATIF:\n\n")
  print(comparaison, row.names = FALSE)
  
  return(comparaison)
}

# ==============================================================================
# ÉTAPE 10 : FONCTION POUR CRÉER DES GRAPHIQUES
# ==============================================================================

creer_graphiques <- function(synthese_precision, comparaison_scenarios) {
  
  # Graphique 1: CV moyen par scénario
  p1 <- ggplot(synthese_precision, aes(x = ratio_reduction, y = cv_moyen)) +
    geom_line(color = "blue", size = 1) +
    geom_point(color = "blue", size = 3) +
    geom_errorbar(aes(ymin = cv_moyen - cv_et, ymax = cv_moyen + cv_et), 
                  width = 0.02, alpha = 0.5) +
    scale_x_continuous(breaks = synthese_precision$ratio_reduction) +
    labs(
      title = "Précision selon le ratio de réduction",
      subtitle = "Coefficient de Variation (CV) moyen avec intervalle de confiance",
      x = "Ratio de réduction de l'échantillon",
      y = "CV moyen (%)"
    ) +
    theme_minimal() +
    theme(plot.title = element_text(face = "bold", size = 14))
  
  # Graphique 2: Coût vs Précision
  p2 <- ggplot(comparaison_scenarios, aes(x = reduction_cout_pct, y = cv_moyen)) +
    geom_point(aes(size = ratio_reduction), color = "darkgreen", alpha = 0.7) +
    geom_text(aes(label = scenario), vjust = -1, size = 3) +
    labs(
      title = "Arbitrage Coût-Précision",
      subtitle = "Réduction de coût vs Impact sur la précision",
      x = "Réduction du coût (%)",
      y = "CV moyen (%)",
      size = "Ratio de\nréduction"
    ) +
    theme_minimal() +
    theme(plot.title = element_text(face = "bold", size = 14))
  
  # Graphique 3: Évolution de l'erreur-type
  p3 <- ggplot(synthese_precision, aes(x = ratio_reduction, y = erreur_type_moyenne)) +
    geom_line(color = "red", size = 1) +
    geom_point(color = "red", size = 3) +
    geom_errorbar(aes(ymin = erreur_type_moyenne - erreur_type_et, 
                      ymax = erreur_type_moyenne + erreur_type_et), 
                  width = 0.02, alpha = 0.5) +
    scale_x_continuous(breaks = synthese_precision$ratio_reduction) +
    labs(
      title = "Erreur-type selon le ratio de réduction",
      subtitle = "Erreur-type moyenne avec intervalle de confiance",
      x = "Ratio de réduction de l'échantillon",
      y = "Erreur-type moyenne"
    ) +
    theme_minimal() +
    theme(plot.title = element_text(face = "bold", size = 14))
  
  return(list(
    cv_plot = p1,
    cout_precision_plot = p2,
    erreur_type_plot = p3
  ))
}

# ==============================================================================
# ÉTAPE 11 : FONCTION POUR GÉNÉRER UN RAPPORT
# ==============================================================================

generer_rapport <- function(synthese_precision,
                           comparaison_scenarios,
                           fichier_sortie = "rapport_simulation_lfs.txt") {
  
  sink(fichier_sortie)
  
  cat("================================================================================\n")
  cat("RAPPORT DE SIMULATION - RÉDUCTION DE TAILLE D'ÉCHANTILLON LFS\n")
  cat("================================================================================\n")
  cat("Date de génération:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n")
  
  cat("1. RÉSUMÉ EXÉCUTIF\n")
  cat("------------------\n")
  cat("Cette simulation évalue l'impact de la réduction du nombre de ménages\n")
  cat("interviewés par UPE sur la précision des estimations et le coût total.\n\n")
  
  cat("2. SCÉNARIOS TESTÉS\n")
  cat("-------------------\n")
  print(synthese_precision, row.names = FALSE)
  cat("\n")
  
  cat("3. ANALYSE COÛT-PRÉCISION\n")
  cat("-------------------------\n")
  print(comparaison_scenarios, row.names = FALSE)
  cat("\n")
  
  cat("4. RECOMMANDATIONS\n")
  cat("------------------\n")
  cat("Basé sur les résultats, choisissez le scénario qui offre le meilleur\n")
  cat("équilibre entre réduction de coût et maintien de la précision pour\n")
  cat("vos groupes de population clés.\n\n")
  
  cat("Points à considérer:\n")
  cat("- Un CV < 5% est généralement considéré comme très bon\n")
  cat("- Un CV entre 5-10% est acceptable pour la plupart des indicateurs\n")
  cat("- Un CV > 15% peut être problématique pour la publication\n\n")
  
  cat("================================================================================\n")
  cat("FIN DU RAPPORT\n")
  cat("================================================================================\n")
  
  sink()
  
  cat("\nRapport enregistré dans:", fichier_sortie, "\n")
}

# ==============================================================================
# EXEMPLE D'UTILISATION COMPLÈTE
# ==============================================================================

# Cette section montre comment utiliser toutes les fonctions ensemble

exemple_execution_complete <- function() {
  
  # 1. Charger vos données
  # donnees_lfs <- read.csv("vos_donnees.csv")
  
  # 2. Préparer les données de base
  # donnees_prep <- preparer_donnees_base(
  #   donnees = donnees_lfs,
  #   nom_upe = "upe_id",
  #   nom_menage = "menage_id",
  #   nom_individu = "individu_id"
  # )
  
  # 3. Exécuter les simulations
  # resultats <- executer_simulations(
  #   donnees = donnees_prep$donnees,
  #   nom_upe = "upe_id",
  #   nom_menage = "menage_id",
  #   nom_individu = "individu_id",
  #   ratios_reduction = c(0.9, 0.8, 0.7, 0.6),
  #   nb_iterations = 30,
  #   total_menages_upe = 1000,  # ou votre vecteur nommé
  #   nom_prob_upe = "prob_upe"
  # )
  
  # 4. Synthétiser les résultats
  # synthese <- synthetiser_resultats(
  #   resultats_simulations = resultats,
  #   nom_indicateur = "taux_chomage"
  # )
  
  # 5. Comparer les scénarios
  # comparaison <- comparer_scenarios(
  #   donnees_originales = donnees_prep$donnees,
  #   resultats_simulations = resultats,
  #   synthese_precision = synthese,
  #   nom_upe = "upe_id",
  #   nom_menage = "menage_id",
  #   cout_visite_upe = 500,    # Ajustez selon vos coûts
  #   cout_menage = 50          # Ajustez selon vos coûts
  # )
  
  # 6. Créer les graphiques
  # graphiques <- creer_graphiques(
  #   synthese_precision = synthese,
  #   comparaison_scenarios = comparaison
  # )
  
  # 7. Afficher les graphiques
  # print(graphiques$cv_plot)
  # print(graphiques$cout_precision_plot)
  # print(graphiques$erreur_type_plot)
  
  # 8. Sauvegarder les graphiques
  # ggsave("cv_par_scenario.png", graphiques$cv_plot, width = 10, height = 6)
  # ggsave("cout_vs_precision.png", graphiques$cout_precision_plot, width = 10, height = 6)
  
  # 9. Générer le rapport
  # generer_rapport(
  #   synthese_precision = synthese,
  #   comparaison_scenarios = comparaison,
  #   fichier_sortie = "rapport_simulation_lfs.txt"
  # )
  
  # 10. Sauvegarder les résultats
  # saveRDS(resultats, "resultats_simulations.rds")
  # write.csv(synthese, "synthese_precision.csv", row.names = FALSE)
  # write.csv(comparaison, "comparaison_scenarios.csv", row.names = FALSE)
}

cat("\n")
cat("================================================================================\n")
cat("SCRIPT DE SIMULATION CHARGÉ AVEC SUCCÈS!\n")
cat("================================================================================\n")
cat("\nFonctions disponibles:\n")
cat("  1. preparer_donnees_base()\n")
cat("  2. simuler_echantillon_reduit()\n")
cat("  3. calibrer_poids()\n")
cat("  4. calculer_precision()\n")
cat("  5. executer_simulations()\n")
cat("  6. synthetiser_resultats()\n")
cat("  7. calculer_couts()\n")
cat("  8. comparer_scenarios()\n")
cat("  9. creer_graphiques()\n")
cat(" 10. generer_rapport()\n\n")
cat("Consultez exemple_execution_complete() pour voir comment utiliser ces fonctions.\n")
cat("================================================================================\n")
