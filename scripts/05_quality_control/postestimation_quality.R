# ==============================================================================
# Quarterly Survey Indicators – Mean, CI, CV, Quality Flags
# Statistics Canada style – Dual Excel export + Forest plots
# ENHANCED VERSION with sample sizes, missing data tracking, and improved plots
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. Packages
# ------------------------------------------------------------------------------
library(survey)
library(dplyr)
library(openxlsx)
library(ggplot2)
library(scales)
library(haven)

# ------------------------------------------------------------------------------
# 1. Data validation and summary
# ------------------------------------------------------------------------------
# Check for required variables
df = read_dta("data/Base_Travail_BT.dta")  
required_vars <- c("pmencor_ind", "trimestre", "pop_emp_dich", "SU1","SU2","SU3","SU4")
missing_vars <- setdiff(required_vars, names(df))

if (length(missing_vars) > 0) {
  stop("Missing required variables in dataframe 'df': ", 
       paste(missing_vars, collapse = ", "))
}

# Basic data summary
cat("\n=== DATA SUMMARY ===\n")
cat("Total observations:", nrow(df), "\n")
cat("Quarters present:", paste(unique(df$trimestre), collapse = ", "), "\n")
cat("Weight range:", round(min(df$pmencor_ind, na.rm = TRUE), 2), "to", 
    round(max(df$pmencor_ind, na.rm = TRUE), 2), "\n\n")

# Missing data summary
missing_summary <- data.frame(
  variable = c("pmencor_ind", "trimestre", "pop_emp_dich", "SU1","SU2","SU3","SU4"),
  n_missing = c(
    sum(is.na(df$pmencor_ind)),
    sum(is.na(df$trimestre)),
    sum(is.na(df$pop_emp_dich)),
    sum(is.na(df$SU1)),
    sum(is.na(df$SU2)),
    sum(is.na(df$SU3)),
    sum(is.na(df$SU4))
  ),
  pct_missing = round(c(
    sum(is.na(df$pmencor_ind)) / nrow(df) * 100,
    sum(is.na(df$trimestre)) / nrow(df) * 100,
    sum(is.na(df$pop_emp_dich)) / nrow(df) * 100,
    sum(is.na(df$SU1)) / nrow(df) * 100,
    sum(is.na(df$SU2)) / nrow(df) * 100,
    sum(is.na(df$SU3)) / nrow(df) * 100,
    sum(is.na(df$SU4)) / nrow(df) * 100
  ), 2)
)

print(missing_summary)
cat("\n")

# ------------------------------------------------------------------------------
# 2. Survey design (Stata pweight equivalent)
# ------------------------------------------------------------------------------
options(survey.lonely.psu = "adjust")

des <- svydesign(
  ids = ~1,
  weights = ~pmencor_ind,
  data = df
)

# ------------------------------------------------------------------------------
# 3. Indicators to estimate
# ------------------------------------------------------------------------------
indicators <- c(
  "SU1",
  "SU2",
  "SU3",
  "SU4"
)

# ------------------------------------------------------------------------------
# 4. Statistics Canada CV quality flag function
# ------------------------------------------------------------------------------
cv_flag <- function(estimate, cv) {
  case_when(
    is.na(estimate) | estimate == 0 ~ "F",
    cv < 0.15                       ~ "A",
    cv < 0.30                       ~ "B",
    TRUE                            ~ "C"
  )
}

# ------------------------------------------------------------------------------
# 5. Quality footnotes
# ------------------------------------------------------------------------------
quality_footnotes <- data.frame(
  Flag = c("A", "B", "C", "F"),
  Meaning = c(
    "Reliable estimate (CV < 15%)",
    "Use with caution (15% ≤ CV < 30%)",
    "Unreliable estimate (CV ≥ 30%)",
    "Estimate suppressed or not reliable"
  )
)

# ------------------------------------------------------------------------------
# 6. Enhanced estimation function with sample sizes - CORRECTED
# ------------------------------------------------------------------------------
estimate_by_quarter <- function(var, design, quarter_var = "trimestre") {
  
  f <- as.formula(paste0("~", var))
  
  # Get sample sizes (unweighted)
  n_data <- design$variables %>%
    group_by(!!sym(quarter_var)) %>%
    summarise(
      n_total = n(),
      n_valid = sum(!is.na(!!sym(var))),
      n_missing = sum(is.na(!!sym(var))),
      pct_missing = round(n_missing / n_total * 100, 2),
      .groups = "drop"
    )
  
  # Weighted estimates
  res <- svyby(
    formula = f,
    by = as.formula(paste0("~", quarter_var)),
    design = design,
    FUN = svymean,
    vartype = c("se", "ci"),
    na.rm = TRUE
  )
  
  # CORRECTION: Convert to data.frame and inspect column names
  res <- as.data.frame(res)
  
  # Dynamically find column names
  col_names <- names(res)
  quarter_col <- col_names[1]
  estimate_col <- col_names[grepl(paste0("^", var, "$"), col_names)]
  se_col <- col_names[grepl("^se", col_names)]
  ci_l_col <- col_names[grepl("^ci_l", col_names)]
  ci_u_col <- col_names[grepl("^ci_u", col_names)]
  
  # Rename columns to standardized names
  res_renamed <- res
  names(res_renamed)[names(res_renamed) == quarter_col] <- quarter_var
  names(res_renamed)[names(res_renamed) == estimate_col] <- "estimate"
  names(res_renamed)[names(res_renamed) == se_col] <- "se"
  names(res_renamed)[names(res_renamed) == ci_l_col] <- "ci_l"
  names(res_renamed)[names(res_renamed) == ci_u_col] <- "ci_u"
  
  # Combine with sample sizes
  res_renamed %>%
    left_join(n_data, by = quarter_var) %>%
    mutate(
      indicator = var,
      cv = se / estimate,
      flag = cv_flag(estimate, cv)
    ) %>%
    select(
      indicator,
      !!sym(quarter_var),
      n_total,
      n_valid,
      n_missing,
      pct_missing,
      estimate,
      se,
      ci_l,
      ci_u,
      cv,
      flag
    )
}

# ------------------------------------------------------------------------------
# 7. Run estimation - CORRECTED
# ------------------------------------------------------------------------------
cat("Running estimations...\n")

results_all <- bind_rows(
  lapply(indicators, estimate_by_quarter, design = des)
) %>%
  mutate(
    estimate = round(estimate, 4),
    se       = round(se, 4),
    ci_l     = round(ci_l, 4),
    ci_u     = round(ci_u, 4),
    cv       = round(cv, 4)
  ) %>%
  arrange(indicator, .data$trimestre)  # CORRECTED: use .data$ pronoun

cat("Estimations complete.\n\n")

# Print summary of quality flags
flag_summary <- results_all %>%
  group_by(flag) %>%
  summarise(count = n(), .groups = "drop") %>%
  arrange(flag)

cat("=== QUALITY FLAG SUMMARY ===\n")
print(flag_summary)
cat("\n")

# ------------------------------------------------------------------------------
# 8. EXCEL FILE 1 — One sheet per QUARTER - CORRECTED
# ------------------------------------------------------------------------------
cat("Creating Excel file 1 (by quarter)...\n")

# Create output directory if it doesn't exist
output_dir <- "data/08_STANDARD_ERRORS"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

wb_quarter <- createWorkbook()

for (q in unique(results_all$trimestre)) {  # CORRECTED: use trimestre
  
  addWorksheet(wb_quarter, as.character(q))  # Convert to character for sheet name
  
  sheet_data <- results_all %>% filter(trimestre == q)  # CORRECTED
  
  writeDataTable(wb_quarter, as.character(q), sheet_data, withFilter = TRUE)
  
  start_row <- nrow(sheet_data) + 4
  
  writeData(wb_quarter, as.character(q), "Quality flags:", startRow = start_row, startCol = 1)
  
  writeDataTable(
    wb_quarter, as.character(q), quality_footnotes,
    startRow = start_row + 1, startCol = 1
  )
}

saveWorkbook(
  wb_quarter,
  file.path(output_dir, "survey_indicators_by_quarter.xlsx"),
  overwrite = TRUE
)

cat("✓ survey_indicators_by_quarter.xlsx created\n")

# ------------------------------------------------------------------------------
# 9. EXCEL FILE 2 — One sheet per INDICATOR
# ------------------------------------------------------------------------------
cat("Creating Excel file 2 (by indicator)...\n")

wb_indicator <- createWorkbook()

for (ind in indicators) {
  
  addWorksheet(wb_indicator, ind)
  
  sheet_data <- results_all %>% filter(indicator == ind)
  
  writeDataTable(wb_indicator, ind, sheet_data, withFilter = TRUE)
  
  start_row <- nrow(sheet_data) + 4
  
  writeData(wb_indicator, ind, "Quality flags:", startRow = start_row, startCol = 1)
  
  writeDataTable(
    wb_indicator, ind, quality_footnotes,
    startRow = start_row + 1, startCol = 1
  )
}

saveWorkbook(
  wb_indicator,
  file.path(output_dir, "survey_indicators_by_indicator.xlsx"),
  overwrite = TRUE
)

cat("✓ survey_indicators_by_indicator.xlsx created\n")

# ==============================================================================
# SECTION 10 GRAPHIQUES POST-ESTIMATIONS
# ==============================================================================
cat("Création des graphiques forestiers...\n")

plot_dir <- file.path(output_dir, "forest_plots")
dir.create(plot_dir, showWarnings = FALSE, recursive = TRUE)

quarters <- unique(results_all$trimestre)

for (q in quarters) {
  
  # Ordre fixe des indicateurs (du bas vers le haut dans le graphique)
  indicator_order <- c("SU4", "SU3", "SU2", "SU1")
  
  df_plot <- results_all %>%
    filter(
      trimestre == q,
      flag %in% c("A", "B")
    ) %>%
    mutate(
      indicator = factor(indicator, levels = indicator_order),
      estimate_text = sprintf("%.1f%%", estimate * 100),
      ci_text = sprintf("[%.1f%%, %.1f%%]", ci_l * 100, ci_u * 100),
      cv_text = sprintf("%.2f%%", cv * 100)
    ) %>%
    arrange(indicator)
  
  if (nrow(df_plot) == 0) {
    cat("  ⚠ Aucune estimation fiable pour", q, "- graphique ignoré\n")
    next
  }
  
  # Calculer les limites pour l'échelle
  x_min <- 0  # Commencer à 0 pour plus de clarté
  x_max <- max(df_plot$ci_u) * 1.1
  
  # Positions pour les colonnes de texte
  col1_x <- x_max * 1.15  # Estimation
  col2_x <- x_max * 1.40  # IC 95%
  col3_x <- x_max * 1.70  # CV
  
  # GRAPHIQUE FORESTIER HORIZONTAL AMÉLIORÉ
  p <- ggplot(df_plot, aes(x = estimate, y = indicator)) +
    # Fond avec grille subtile
    theme_minimal(base_size = 13) +
    # Ligne de référence verticale
    geom_vline(xintercept = 0, color = "gray40", linetype = "solid", linewidth = 0.4) +
    # Intervalles de confiance avec épaisseur variable selon qualité
    geom_errorbarh(
      aes(xmin = ci_l, xmax = ci_u, color = flag, linewidth = flag),
      height = 0.3
    ) +
    # Points des estimations (cercles)
    geom_point(aes(color = flag, size = flag), shape = 16) +
    # Colonne 1 : Estimation
    geom_text(
      aes(x = col1_x, label = estimate_text),
      hjust = 0.5,
      size = 4,
      fontface = "bold",
      family = "sans"
    ) +
    # Colonne 2 : Intervalle de confiance
    geom_text(
      aes(x = col2_x, label = ci_text),
      hjust = 0.5,
      size = 3.8,
      family = "sans"
    ) +
    # Colonne 3 : Coefficient de variation
    geom_text(
      aes(x = col3_x, label = cv_text),
      hjust = 0.5,
      size = 3.8,
      family = "sans"
    ) +
    # Échelles de couleurs et tailles
    scale_color_manual(
      values = c("A" = "#27AE60", "B" = "#E67E22"),
      labels = c("A" = "Fiable (CV < 15%)", "B" = "À utiliser avec prudence (15% ≤ CV < 30%)"),
      name = "Qualité"
    ) +
    scale_linewidth_manual(
      values = c("A" = 1.0, "B" = 0.8),
      guide = "none"
    ) +
    scale_size_manual(
      values = c("A" = 4, "B" = 3.5),
      guide = "none"
    ) +
    # Échelle X optimisée
    scale_x_continuous(
      limits = c(x_min, col3_x * 1.15),
      breaks = pretty(c(x_min, x_max), n = 6),
      labels = label_percent(accuracy = 0.1, scale = 100),
      expand = c(0, 0)
    ) +
    # En-têtes et titres
    labs(
      x = "Estimation (intervalle de confiance à 95%)",
      y = NULL,
      title = paste("Estimations de l'enquête –", q),
      subtitle = "Cercles = estimation ponctuelle | Barres horizontales = intervalle de confiance à 95%"
    ) +
    # Personnalisation du thème
    theme(
      # Grille
      panel.grid.major.y = element_blank(),
      panel.grid.major.x = element_line(color = "gray90", linewidth = 0.3),
      panel.grid.minor = element_blank(),
      panel.background = element_rect(fill = "white", color = NA),
      plot.background = element_rect(fill = "white", color = NA),
      # Axes
      axis.text.y = element_text(size = 12, face = "bold", hjust = 1, color = "gray20"),
      axis.text.x = element_text(size = 11, color = "gray30"),
      axis.title.x = element_text(size = 12, face = "bold", margin = margin(t = 10)),
      axis.line.x = element_line(color = "gray40", linewidth = 0.5),
      # Titres
      plot.title = element_text(face = "bold", size = 16, hjust = 0, margin = margin(b = 5)),
      plot.subtitle = element_text(size = 11, color = "gray50", hjust = 0, margin = margin(b = 15)),
      # Légende
      legend.position = "bottom",
      legend.title = element_text(face = "bold", size = 11),
      legend.text = element_text(size = 10),
      legend.background = element_rect(fill = "gray95", color = "gray70", linewidth = 0.3),
      legend.key = element_rect(fill = "gray95"),
      legend.margin = margin(5, 5, 5, 5),
      # Marges
      plot.margin = margin(15, 150, 15, 15)
    ) +
    # En-têtes de colonnes avec fond
    annotate(
      "rect",
      xmin = col1_x - (col2_x - col1_x) * 0.45,
      xmax = col3_x + (col3_x - col2_x) * 0.45,
      ymin = nrow(df_plot) + 0.5,
      ymax = nrow(df_plot) + 1.0,
      fill = "gray90",
      alpha = 0.5
    ) +
    annotate(
      "text",
      x = col1_x,
      y = nrow(df_plot) + 0.75,
      label = "Estimation",
      fontface = "bold",
      size = 4.2
    ) +
    annotate(
      "text",
      x = col2_x,
      y = nrow(df_plot) + 0.75,
      label = "IC 95%",
      fontface = "bold",
      size = 4.2
    ) +
    annotate(
      "text",
      x = col3_x,
      y = nrow(df_plot) + 0.75,
      label = "CV",
      fontface = "bold",
      size = 4.2
    )
  
  # Sauvegarder le graphique avec haute résolution
  ggsave(
    filename = file.path(plot_dir, paste0("forest_", q, ".png")),
    plot = p,
    width = 13,
    height = max(6, nrow(df_plot) * 0.65 + 2.5),
    dpi = 400,
    bg = "white"
  )
  
  cat("  ✓ Graphique forestier créé pour", q, "\n")
}

cat("\n=== ANALYSE TERMINÉE ===\n")
cat("Fichiers créés :\n")
cat("  • ", file.path(output_dir, "survey_indicators_by_quarter.xlsx"), "\n")
cat("  • ", file.path(output_dir, "survey_indicators_by_indicator.xlsx"), "\n")
cat("  • ", plot_dir, "/ répertoire avec fichiers PNG\n\n")

message("Tableaux Excel et graphiques forestiers créés avec succès.")
