# ======================================================================
# CALCUL DES INDICATEURS SU AVEC SURVEY DESIGN (RIGOUREUX)
# ======================================================================

library(dplyr)
library(haven)
library(future)
library(furrr)
library(writexl)
library(ggplot2)
library(survey)

# ----------------------------------------------------------------------
# CONFIGURATION
# ----------------------------------------------------------------------

source("config/1_config.r")

DATA_DIR <- file.path(BASE_DIR, "data")
WEIGHTS_DIR <- file.path(DATA_DIR, "04_weights")
SIMULATION_DIR <- file.path(WEIGHTS_DIR, "simulation")
SIMULATION_QUARTER_DIR <- file.path(SIMULATION_DIR, TARGET_QUARTER)

RATIO_REDUCTION <- 0.50
N_ITER <- 30
SUFFIXE_SIMU <- paste0(TARGET_QUARTER, "_", RATIO_REDUCTION * 100, "pct")

# ----------------------------------------------------------------------
# FONCTION : CALCULER INDICATEURS SU AVEC SURVEY POUR UNE ITÉRATION
# ----------------------------------------------------------------------

calculate_su_indicators_survey <- function(iter) {
  
  iter_dir <- file.path(SIMULATION_QUARTER_DIR, paste0("iteration_", iter))
  
  cat("Calcul indicateurs SU (survey) - itération", iter, "...\n")
  
  # Charger la base fusionnée
  base_fused <- read_dta(
    file.path(iter_dir, paste0("LFS_ILO_CAL_IND_FUSED_", TARGET_QUARTER, "_iter_", iter, ".dta"))
  )
  
  # Identifier toutes les variables qui commencent par "SU"
  su_vars <- names(base_fused)[grepl("^SU", names(base_fused))]
  
  if (length(su_vars) == 0) {
    warning("Itération ", iter, ": Aucune variable SU trouvée")
    return(NULL)
  }
  
  cat("  Variables SU trouvées:", paste(su_vars, collapse = ", "), "\n")
  
  # Vérifier les variables nécessaires pour le design
  required_vars <- c("PSUKEY", "HHKEY", "STRATAKEY", "FINAL_WEIGHT")
  missing_vars <- setdiff(required_vars, names(base_fused))
  
  if (length(missing_vars) > 0) {
    stop("Itération ", iter, ": Variables manquantes pour le design: ", 
         paste(missing_vars, collapse = ", "))
  }
  
  # Créer le design d'enquête
  # Note importante: 
  # - ids = ~ PSUKEY + HHKEY : structure d'échantillonnage hiérarchique (PSU -> Ménage)
  # - weights = ~ FINAL_WEIGHT : poids calibrés AU NIVEAU INDIVIDU (chaque individu a son propre poids)
  # - Les individus sont dans les ménages, les ménages sont dans les PSU
  design_iter <- svydesign(
    ids = ~ PSUKEY,          # Structure hiérarchique de l'échantillonnage
    strata = ~ STRATAKEY,             # Stratification
    weights = ~ FINAL_WEIGHT,         # Poids INDIVIDUELS calibrés
    data = base_fused,                # Chaque ligne = 1 individu
    nest = TRUE                       # Les ménages sont imbriqués dans les PSU
  )
  
  cat("  Design créé avec succès (", nrow(base_fused), " individus)\n")
  
  # Calculer les indicateurs pour chaque variable SU
  results <- tibble::tibble(iteration = iter)
  
  for (su_var in su_vars) {
    
    # Vérifier que la variable existe et n'est pas entièrement NA
    if (all(is.na(base_fused[[su_var]]))) {
      warning("  Variable ", su_var, " : Entièrement NA")
      results[[paste0("mean_", su_var)]] <- NA
      results[[paste0("SE_", su_var)]] <- NA
      results[[paste0("variance_", su_var)]] <- NA
      results[[paste0("CI_lower_", su_var)]] <- NA
      results[[paste0("CI_upper_", su_var)]] <- NA
      results[[paste0("CV_", su_var)]] <- NA
      next
    }
    
    # Créer la formule pour svymean
    formula_mean <- as.formula(paste0("~", su_var))
    
    # Calculer la moyenne avec survey (utilise les poids individuels FINAL_WEIGHT)
    tryCatch({
      mean_result <- svymean(formula_mean, design_iter, na.rm = TRUE)
      
      # Extraire les statistiques
      mean_val <- as.numeric(mean_result)
      se_val <- as.numeric(SE(mean_result))  # Erreur standard tenant compte du design complexe
      var_val <- se_val^2
      
      # Calculer l'intervalle de confiance à 95%
      ci <- confint(mean_result, level = 0.95)
      ci_lower <- ci[1, 1]
      ci_upper <- ci[1, 2]
      
      # Calculer le coefficient de variation (en %)
      cv_val <- if (mean_val != 0) (se_val / abs(mean_val)) * 100 else NA
      
      # Stocker les résultats
      results[[paste0("mean_", su_var)]] <- round(mean_val, 6)
      results[[paste0("SE_", su_var)]] <- round(se_val, 6)
      results[[paste0("variance_", su_var)]] <- round(var_val, 8)
      results[[paste0("CI_lower_", su_var)]] <- round(ci_lower, 6)
      results[[paste0("CI_upper_", su_var)]] <- round(ci_upper, 6)
      results[[paste0("CV_", su_var)]] <- round(cv_val, 2)
      
    }, error = function(e) {
      warning("  Erreur pour ", su_var, ": ", e$message)
      results[[paste0("mean_", su_var)]] <- NA
      results[[paste0("SE_", su_var)]] <- NA
      results[[paste0("variance_", su_var)]] <- NA
      results[[paste0("CI_lower_", su_var)]] <- NA
      results[[paste0("CI_upper_", su_var)]] <- NA
      results[[paste0("CV_", su_var)]] <- NA
    })
  }
  
  cat("✓ Itération", iter, "terminée\n")
  
  return(results)
}

# ----------------------------------------------------------------------
# TEST SUR UNE ITÉRATION
# ----------------------------------------------------------------------

test_su <- calculate_su_indicators_survey(1)
# print(test_su)

# ----------------------------------------------------------------------
# CALCUL PARALLÈLE POUR TOUTES LES ITÉRATIONS
# ----------------------------------------------------------------------

N_CORES <- max(1, parallel::detectCores() - 1)
plan(multisession, workers = N_CORES)

cat("\n=== Lancement calcul indicateurs SU (survey) sur", N_ITER, "itérations ===\n")
cat("Nombre de cœurs utilisés:", N_CORES, "\n\n")

indicateurs_su <- future_map_dfr(
  1:N_ITER,
  calculate_su_indicators_survey,
  .progress = TRUE,
  .options = furrr_options(seed = TRUE)
)

# Sauvegarder les résultats détaillés
write_dta(
  indicateurs_su,
  file.path(SIMULATION_QUARTER_DIR, paste0("indicateurs_SU_survey_", SUFFIXE_SIMU, ".dta"))
)

print(indicateurs_su)

# ----------------------------------------------------------------------
# CRÉER TABLEAU RÉCAPITULATIF FORMATÉ POUR EXCEL
# ----------------------------------------------------------------------

cat("\n=== Création du tableau récapitulatif ===\n")

# Identifier les variables SU
mean_cols <- names(indicateurs_su)[grepl("^mean_", names(indicateurs_su))]
su_vars_list <- sub("^mean_", "", mean_cols)

# Créer le tableau récapitulatif
tableau_recapitulatif <- tibble::tibble(
  Variable = character(),
  Moyenne_des_moyennes = numeric(),
  SD_des_moyennes = numeric(),
  Moyenne_SE = numeric(),
  SD_SE = numeric(),
  Moyenne_variance = numeric(),
  SD_variance = numeric(),
  Moyenne_CV = numeric(),
  SD_CV = numeric(),
  Moyenne_CI_width = numeric()
)

for (su_var in su_vars_list) {
  
  mean_col <- paste0("mean_", su_var)
  se_col <- paste0("SE_", su_var)
  var_col <- paste0("variance_", su_var)
  cv_col <- paste0("CV_", su_var)
  ci_lower_col <- paste0("CI_lower_", su_var)
  ci_upper_col <- paste0("CI_upper_", su_var)
  
  # Calculer les statistiques récapitulatives
  moyenne_des_moyennes <- mean(indicateurs_su[[mean_col]], na.rm = TRUE)
  sd_des_moyennes <- sd(indicateurs_su[[mean_col]], na.rm = TRUE)
  
  moyenne_se <- mean(indicateurs_su[[se_col]], na.rm = TRUE)
  sd_se <- sd(indicateurs_su[[se_col]], na.rm = TRUE)
  
  moyenne_var <- mean(indicateurs_su[[var_col]], na.rm = TRUE)
  sd_var <- sd(indicateurs_su[[var_col]], na.rm = TRUE)
  
  moyenne_cv <- mean(indicateurs_su[[cv_col]], na.rm = TRUE)
  sd_cv <- sd(indicateurs_su[[cv_col]], na.rm = TRUE)
  
  # Largeur moyenne de l'IC
  ci_widths <- indicateurs_su[[ci_upper_col]] - indicateurs_su[[ci_lower_col]]
  moyenne_ci_width <- mean(ci_widths, na.rm = TRUE)
  
  # Ajouter au tableau
  tableau_recapitulatif <- tableau_recapitulatif %>%
    bind_rows(tibble::tibble(
      Variable = su_var,
      Moyenne_des_moyennes = round(moyenne_des_moyennes, 6),
      SD_des_moyennes = round(sd_des_moyennes, 6),
      Moyenne_SE = round(moyenne_se, 6),
      SD_SE = round(sd_se, 6),
      Moyenne_variance = round(moyenne_var, 8),
      SD_variance = round(sd_var, 8),
      Moyenne_CV = round(moyenne_cv, 2),
      SD_CV = round(sd_cv, 2),
      Moyenne_CI_width = round(moyenne_ci_width, 6)
    ))
}

# Afficher le tableau
print(tableau_recapitulatif)

# Sauvegarder les tableaux avec les 2 onglets
write_xlsx(
  list(
    "Tableau_30_iterations" = indicateurs_su,
    "Recapitulatif_SU" = tableau_recapitulatif
  ),
  file.path(SIMULATION_QUARTER_DIR, paste0("indicateurs_SU_survey_complet_", SUFFIXE_SIMU, ".xlsx"))
)

# Sauvegarder aussi le récapitulatif en .dta
write_dta(
  tableau_recapitulatif,
  file.path(SIMULATION_QUARTER_DIR, paste0("recapitulatif_SU_survey_", SUFFIXE_SIMU, ".dta"))
)

cat("\n✓ Tableaux sauvegardés:\n")
cat("  - Excel (2 onglets):", file.path(SIMULATION_QUARTER_DIR, paste0("indicateurs_SU_survey_complet_", SUFFIXE_SIMU, ".xlsx")), "\n")
cat("    → Onglet 1: Tableau_30_iterations (détail par itération)\n")
cat("    → Onglet 2: Recapitulatif_SU (statistiques récapitulatives)\n")
cat("  - Stata (détail):", file.path(SIMULATION_QUARTER_DIR, paste0("indicateurs_SU_survey_", SUFFIXE_SIMU, ".dta")), "\n")
cat("  - Stata (récap):", file.path(SIMULATION_QUARTER_DIR, paste0("recapitulatif_SU_survey_", SUFFIXE_SIMU, ".dta")), "\n")

# ----------------------------------------------------------------------
# CRÉER GRAPHIQUES DE VISUALISATION
# ----------------------------------------------------------------------

cat("\n=== Création des graphiques ===\n")

# Graphique 1: Moyenne ± SE
plot_data <- tableau_recapitulatif %>%
  mutate(Variable = factor(Variable, levels = Variable))

p1 <- ggplot(plot_data, aes(x = Variable)) +
  geom_point(aes(y = Moyenne_des_moyennes), color = "blue", size = 3) +
  geom_errorbar(aes(ymin = Moyenne_des_moyennes - Moyenne_SE,
                    ymax = Moyenne_des_moyennes + Moyenne_SE),
                width = 0.2, color = "blue", alpha = 0.5) +
  labs(
    title = "Indicateurs SU avec erreurs standard (30 itérations)",
    subtitle = paste0("Réduction d'échantillon: ", RATIO_REDUCTION * 100, "%"),
    x = "Variable",
    y = "Moyenne ± SE",
    caption = paste0("Source: Simulation ", TARGET_QUARTER)
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.text.x = element_text(angle = 0, hjust = 0.5)
  )

ggsave(
  file.path(SIMULATION_QUARTER_DIR, paste0("graphique_SU_SE_", SUFFIXE_SIMU, ".png")),
  plot = p1,
  width = 10,
  height = 6,
  dpi = 300
)

# Graphique 2: Coefficients de variation
p2 <- ggplot(plot_data, aes(x = Variable, y = Moyenne_CV)) +
  geom_col(fill = "steelblue", alpha = 0.7) +
  geom_hline(yintercept = 15, linetype = "dashed", color = "red", size = 1) +
  annotate("text", x = 1, y = 16, label = "Seuil CV = 15%", color = "red", hjust = 0) +
  labs(
    title = "Coefficients de variation des indicateurs SU",
    subtitle = paste0("Moyenne sur 30 itérations - Réduction: ", RATIO_REDUCTION * 100, "%"),
    x = "Variable",
    y = "CV moyen (%)",
    caption = paste0("Source: Simulation ", TARGET_QUARTER)
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.text.x = element_text(angle = 0, hjust = 0.5)
  )

ggsave(
  file.path(SIMULATION_QUARTER_DIR, paste0("graphique_SU_CV_", SUFFIXE_SIMU, ".png")),
  plot = p2,
  width = 10,
  height = 6,
  dpi = 300
)

cat("✓ Graphiques sauvegardés:\n")
cat("  -", file.path(SIMULATION_QUARTER_DIR, paste0("graphique_SU_SE_", SUFFIXE_SIMU, ".png")), "\n")
cat("  -", file.path(SIMULATION_QUARTER_DIR, paste0("graphique_SU_CV_", SUFFIXE_SIMU, ".png")), "\n")

# ----------------------------------------------------------------------
# STATISTIQUES RÉCAPITULATIVES DÉTAILLÉES
# ----------------------------------------------------------------------

cat("\n=== STATISTIQUES RÉCAPITULATIVES ===\n")
cat("Variables SU analysées:", nrow(tableau_recapitulatif), "\n\n")

for (i in 1:nrow(tableau_recapitulatif)) {
  row <- tableau_recapitulatif[i, ]
  cat(row$Variable, ":\n", sep = "")
  cat("  Moyenne des moyennes:", row$Moyenne_des_moyennes, "\n")
  cat("  SD des moyennes (variabilité inter-itérations):", row$SD_des_moyennes, "\n")
  cat("  SE moyen:", row$Moyenne_SE, "\n")
  cat("  CV moyen:", row$Moyenne_CV, "%\n")
  cat("  Largeur IC moyenne:", row$Moyenne_CI_width, "\n\n")
}

cat("=== ANALYSE TERMINÉE ===\n")
