# ======================================================================
# ÉTAPE 5: ESTIMATION DE LA PRÉCISION (VERSION AUTOMATISÉE)
# ======================================================================
# Ce script est appelé par 0_MASTER_SIMULATION.r
# Il utilise les paramètres globaux PARAM_* définis dans le master
# ======================================================================

library(dplyr)
library(haven)
library(future)
library(furrr)
library(writexl)
library(ggplot2)
library(survey)

# ----------------------------------------------------------------------
# RÉCUPÉRATION DES PARAMÈTRES DU MASTER
# ----------------------------------------------------------------------

if (!exists("PARAM_TARGET_QUARTER")) {
  stop("Ce script doit être appelé depuis 0_MASTER_SIMULATION.r")
}

TARGET_QUARTER <- PARAM_TARGET_QUARTER
RATIO_REDUCTION <- PARAM_RATIO_REDUCTION
N_ITER <- PARAM_N_ITER
SUFFIXE_SIMU <- PARAM_SUFFIXE_SIMU

# ----------------------------------------------------------------------
# FONCTION : CALCULER INDICATEURS SU AVEC SURVEY
# ----------------------------------------------------------------------

calculate_su_indicators_survey <- function(iter) {

  iter_dir <- file.path(SIMULATION_QUARTER_DIR, paste0("iteration_", iter))

  # Charger la base fusionnée (avec SUFFIXE_SIMU = trimestre + taux)
  base_fused <- read_dta(
    file.path(iter_dir, paste0("LFS_ILO_CAL_IND_FUSED_", SUFFIXE_SIMU, "_iter_", iter, ".dta"))
  )

  # Identifier les variables SU
  su_vars <- names(base_fused)[grepl("^SU", names(base_fused))]

  if (length(su_vars) == 0) {
    warning("Itération ", iter, ": Aucune variable SU trouvée")
    return(NULL)
  }

  # Vérifier les variables du design
  required_vars <- c("PSUKEY", "HHKEY", "STRATAKEY", "FINAL_WEIGHT")
  missing_vars <- setdiff(required_vars, names(base_fused))

  if (length(missing_vars) > 0) {
    stop("Itération ", iter, ": Variables manquantes: ", paste(missing_vars, collapse = ", "))
  }

  # Créer le design
  design_iter <- svydesign(
    ids = ~ PSUKEY + HHKEY,
    strata = ~ STRATAKEY,
    weights = ~ FINAL_WEIGHT,
    data = base_fused,
    nest = TRUE
  )

  # Calculer les indicateurs
  results <- tibble::tibble(iteration = iter)

  for (su_var in su_vars) {

    if (all(is.na(base_fused[[su_var]]))) {
      results[[paste0("mean_", su_var)]] <- NA
      results[[paste0("SE_", su_var)]] <- NA
      results[[paste0("variance_", su_var)]] <- NA
      results[[paste0("CI_lower_", su_var)]] <- NA
      results[[paste0("CI_upper_", su_var)]] <- NA
      results[[paste0("CV_", su_var)]] <- NA
      next
    }

    formula_mean <- as.formula(paste0("~", su_var))

    tryCatch({
      mean_result <- svymean(formula_mean, design_iter, na.rm = TRUE)

      mean_val <- as.numeric(mean_result)
      se_val <- as.numeric(SE(mean_result))
      var_val <- se_val^2

      ci <- confint(mean_result, level = 0.95)
      ci_lower <- ci[1, 1]
      ci_upper <- ci[1, 2]

      cv_val <- if (mean_val != 0) (se_val / abs(mean_val)) * 100 else NA

      results[[paste0("mean_", su_var)]] <- round(mean_val, 6)
      results[[paste0("SE_", su_var)]] <- round(se_val, 6)
      results[[paste0("variance_", su_var)]] <- round(var_val, 8)
      results[[paste0("CI_lower_", su_var)]] <- round(ci_lower, 6)
      results[[paste0("CI_upper_", su_var)]] <- round(ci_upper, 6)
      results[[paste0("CV_", su_var)]] <- round(cv_val, 2)

    }, error = function(e) {
      results[[paste0("mean_", su_var)]] <- NA
      results[[paste0("SE_", su_var)]] <- NA
      results[[paste0("variance_", su_var)]] <- NA
      results[[paste0("CI_lower_", su_var)]] <- NA
      results[[paste0("CI_upper_", su_var)]] <- NA
      results[[paste0("CV_", su_var)]] <- NA
    })
  }

  return(results)
}

# ----------------------------------------------------------------------
# EXÉCUTION PARALLÈLE
# ----------------------------------------------------------------------

N_CORES <- max(1, parallel::detectCores() - 1)
plan(multisession, workers = N_CORES)

cat("Calcul des indicateurs SU sur", N_ITER, "itérations...\n")

indicateurs_su <- future_map_dfr(
  1:N_ITER,
  calculate_su_indicators_survey,
  .progress = TRUE,
  .options = furrr_options(seed = TRUE)
)

# Sauvegarde détaillée
write_dta(
  indicateurs_su,
  file.path(SIMULATION_QUARTER_DIR, paste0("indicateurs_SU_survey_", SUFFIXE_SIMU, ".dta"))
)

# ----------------------------------------------------------------------
# TABLEAU RÉCAPITULATIF
# ----------------------------------------------------------------------

cat("\nCréation du tableau récapitulatif...\n")

mean_cols <- names(indicateurs_su)[grepl("^mean_", names(indicateurs_su))]
su_vars_list <- sub("^mean_", "", mean_cols)

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

  moyenne_des_moyennes <- mean(indicateurs_su[[mean_col]], na.rm = TRUE)
  sd_des_moyennes <- sd(indicateurs_su[[mean_col]], na.rm = TRUE)

  moyenne_se <- mean(indicateurs_su[[se_col]], na.rm = TRUE)
  sd_se <- sd(indicateurs_su[[se_col]], na.rm = TRUE)

  moyenne_var <- mean(indicateurs_su[[var_col]], na.rm = TRUE)
  sd_var <- sd(indicateurs_su[[var_col]], na.rm = TRUE)

  moyenne_cv <- mean(indicateurs_su[[cv_col]], na.rm = TRUE)
  sd_cv <- sd(indicateurs_su[[cv_col]], na.rm = TRUE)

  ci_widths <- indicateurs_su[[ci_upper_col]] - indicateurs_su[[ci_lower_col]]
  moyenne_ci_width <- mean(ci_widths, na.rm = TRUE)

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

# Sauvegarde Excel avec 2 onglets
write_xlsx(
  list(
    "Tableau_30_iterations" = indicateurs_su,
    "Recapitulatif_SU" = tableau_recapitulatif
  ),
  file.path(SIMULATION_QUARTER_DIR, paste0("indicateurs_SU_survey_complet_", SUFFIXE_SIMU, ".xlsx"))
)

write_dta(
  tableau_recapitulatif,
  file.path(SIMULATION_QUARTER_DIR, paste0("recapitulatif_SU_survey_", SUFFIXE_SIMU, ".dta"))
)

# ----------------------------------------------------------------------
# GRAPHIQUES
# ----------------------------------------------------------------------

cat("Création des graphiques...\n")

if (nrow(tableau_recapitulatif) > 0) {

  plot_data <- tableau_recapitulatif %>%
    mutate(Variable = factor(Variable, levels = Variable))

  # Graphique 1: Moyenne ± SE
  p1 <- ggplot(plot_data, aes(x = Variable)) +
    geom_point(aes(y = Moyenne_des_moyennes), color = "blue", size = 3) +
    geom_errorbar(aes(ymin = Moyenne_des_moyennes - Moyenne_SE,
                      ymax = Moyenne_des_moyennes + Moyenne_SE),
                  width = 0.2, color = "blue", alpha = 0.5) +
    labs(
      title = paste0("Indicateurs SU - Simulation ", RATIO_REDUCTION * 100, "%"),
      subtitle = paste0(TARGET_QUARTER, " - ", N_ITER, " itérations"),
      x = "Variable",
      y = "Moyenne ± SE"
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

  # Graphique 2: CV
  p2 <- ggplot(plot_data, aes(x = Variable, y = Moyenne_CV)) +
    geom_col(fill = "steelblue", alpha = 0.7) +
    geom_hline(yintercept = 15, linetype = "dashed", color = "red", size = 1) +
    annotate("text", x = 1, y = 16, label = "Seuil CV = 15%", color = "red", hjust = 0) +
    labs(
      title = paste0("Coefficients de variation - Simulation ", RATIO_REDUCTION * 100, "%"),
      subtitle = paste0(TARGET_QUARTER, " - ", N_ITER, " itérations"),
      x = "Variable",
      y = "CV moyen (%)"
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

  cat("✓ Graphiques sauvegardés\n")
}

# ----------------------------------------------------------------------
# RÉSUMÉ FINAL
# ----------------------------------------------------------------------

cat("\n=== RÉSUMÉ ÉTAPE 5 ===\n")
cat("Variables SU analysées:", nrow(tableau_recapitulatif), "\n")

if (nrow(tableau_recapitulatif) > 0) {
  cat("\nRésumé par variable:\n")
  for (i in 1:nrow(tableau_recapitulatif)) {
    row <- tableau_recapitulatif[i, ]
    cat(sprintf("  %s: Moyenne=%.4f, SE=%.4f, CV=%.1f%%\n",
                row$Variable, row$Moyenne_des_moyennes, row$Moyenne_SE, row$Moyenne_CV))
  }

  # Évaluation qualité
  cv_above_15 <- sum(tableau_recapitulatif$Moyenne_CV > 15, na.rm = TRUE)
  cat("\nIndicateurs avec CV > 15%:", cv_above_15, "/", nrow(tableau_recapitulatif), "\n")
}
