# ==============================================================================
# ANALYSE DE SCÉNARIO : RÉDUCTION BUDGÉTAIRE
# Scénario 1 : Réduction de 25% de la taille d'échantillon
# Basé sur les données du T3 2025
# ==============================================================================

library(survey)
library(dplyr)
library(openxlsx)
library(ggplot2)
library(scales)
library(haven)
library(tidyr)

cat("\n")
cat("═══════════════════════════════════════════════════════════════════════════\n")
cat("         ANALYSE DE SCÉNARIO : RÉDUCTION BUDGÉTAIRE DE 25%                 \n")
cat("═══════════════════════════════════════════════════════════════════════════\n\n")

# ------------------------------------------------------------------------------
# 1. Chargement des données
# ------------------------------------------------------------------------------
cat("=== CHARGEMENT DES DONNÉES ===\n")

df_original <- read_dta("data/04_weights/Base_Travail_BT_vf.dta")

# Identifier le trimestre 3
df_t3 <- df_original %>%
  filter(trimestre == "25T3", !is.na(pmencor_ind), pmencor_ind > 0)

cat("  • Observations T3 (100%):", nrow(df_t3), "\n")
cat("  • Régions T3:", length(unique(df_t3$region)), "\n")
cat("  • Districts T3:", length(unique(df_t3$District)), "\n\n")

# ------------------------------------------------------------------------------
# 2. Scénario : Réduction de 25% (échantillon à 75%)
# ------------------------------------------------------------------------------
cat("=== SCÉNARIO DE RÉDUCTION ===\n")

# Fixer la graine pour reproductibilité
set.seed(2025)

# Échantillonnage aléatoire stratifié par région pour maintenir la représentativité
df_t3_reduit <- df_t3 %>%
  group_by(region) %>%
  slice_sample(prop = 0.75) %>%
  ungroup()

cat("  • Scénario : Réduction de 25% de l'échantillon\n")
cat("  • Observations T3 (75%):", nrow(df_t3_reduit), "\n")
cat("  • Réduction effective:", nrow(df_t3) - nrow(df_t3_reduit), "observations\n")
cat("  • Pourcentage réel:", round(nrow(df_t3_reduit) / nrow(df_t3) * 100, 2), "%\n\n")

# Vérifier la distribution par région
cat("=== DISTRIBUTION PAR RÉGION ===\n")
comparison_region <- df_t3 %>%
  group_by(region) %>%
  summarise(n_100 = n(), .groups = "drop") %>%
  left_join(
    df_t3_reduit %>% group_by(region) %>% summarise(n_75 = n(), .groups = "drop"),
    by = "region"
  ) %>%
  mutate(
    reduction = n_100 - n_75,
    pct_conserve = round(n_75 / n_100 * 100, 1)
  ) %>%
  arrange(region)

print(comparison_region)
cat("\n")

# ------------------------------------------------------------------------------
# 3. Configuration
# ------------------------------------------------------------------------------
options(survey.lonely.psu = "adjust")

indicators <- c("SU1", "SU2", "SU3", "SU4")

cv_flag <- function(estimate, cv) {
  case_when(
    is.na(estimate) | estimate == 0 ~ "F",
    cv < 0.15                       ~ "A",
    cv < 0.30                       ~ "B",
    TRUE                            ~ "C"
  )
}

# ------------------------------------------------------------------------------
# 4. Designs d'enquête
# ------------------------------------------------------------------------------
cat("=== CRÉATION DES DESIGNS D'ENQUÊTE ===\n")

# Design avec échantillon complet (100%)
des_100 <- svydesign(ids = ~1, weights = ~pmencor_ind, data = df_t3)
cat("  ✓ Design 100% (n =", nrow(df_t3), ")\n")

# Design avec échantillon réduit (75%)
des_75 <- svydesign(ids = ~1, weights = ~pmencor_ind, data = df_t3_reduit)
cat("  ✓ Design 75% (n =", nrow(df_t3_reduit), ")\n\n")

# ------------------------------------------------------------------------------
# 5. Fonction d'estimation
# ------------------------------------------------------------------------------
estimate_overall <- function(var, design, scenario_name) {
  f <- as.formula(paste0("~", var))
  
  res <- svymean(f, design = design, na.rm = TRUE)
  
  estimate <- as.numeric(coef(res))
  se <- as.numeric(SE(res))
  ci <- confint(res)
  
  data.frame(
    scenario = scenario_name,
    indicator = var,
    n = nrow(design$variables),
    estimate = round(estimate, 4),
    se = round(se, 4),
    ci_l = round(ci[1], 4),
    ci_u = round(ci[2], 4),
    ci_width = round(ci[2] - ci[1], 4),
    cv = round(se / estimate, 4),
    flag = cv_flag(estimate, se / estimate)
  )
}

estimate_by_strata <- function(var, design, scenario_name, strata_var) {
  f <- as.formula(paste0("~", var))
  
  res <- svyby(
    formula = f,
    by = as.formula(paste0("~", strata_var)),
    design = design,
    FUN = svymean,
    vartype = c("se", "ci"),
    na.rm = TRUE
  )
  
  res <- as.data.frame(res)
  col_names <- names(res)
  
  res_renamed <- res
  names(res_renamed)[1] <- strata_var
  names(res_renamed)[grepl(paste0("^", var, "$"), col_names)] <- "estimate"
  names(res_renamed)[grepl("^se", col_names)] <- "se"
  names(res_renamed)[grepl("^ci_l", col_names)] <- "ci_l"
  names(res_renamed)[grepl("^ci_u", col_names)] <- "ci_u"
  
  res_renamed %>%
    mutate(
      scenario = scenario_name,
      indicator = var,
      ci_width = ci_u - ci_l,
      cv = se / estimate,
      flag = cv_flag(estimate, cv)
    ) %>%
    select(scenario, indicator, !!sym(strata_var), estimate, se, ci_l, ci_u, ci_width, cv, flag) %>%
    mutate(across(c(estimate, se, ci_l, ci_u, ci_width, cv), ~round(., 4)))
}

# ------------------------------------------------------------------------------
# 6. ESTIMATIONS - SCÉNARIO 100% (RÉFÉRENCE)
# ------------------------------------------------------------------------------
cat("=== ESTIMATIONS SCÉNARIO 100% (RÉFÉRENCE) ===\n")

cat("  National...\n")
results_100_overall <- bind_rows(
  lapply(indicators, estimate_overall, design = des_100, scenario_name = "100% (Référence)")
)

cat("  Régional...\n")
results_100_region <- bind_rows(
  lapply(indicators, estimate_by_strata, design = des_100, scenario_name = "100% (Référence)", strata_var = "region")
)

cat("  District...\n")
results_100_district <- bind_rows(
  lapply(indicators, estimate_by_strata, design = des_100, scenario_name = "100% (Référence)", strata_var = "District")
)

cat("  ✓ Terminé\n\n")

# ------------------------------------------------------------------------------
# 7. ESTIMATIONS - SCÉNARIO 75% (RÉDUCTION)
# ------------------------------------------------------------------------------
cat("=== ESTIMATIONS SCÉNARIO 75% (RÉDUCTION) ===\n")

cat("  National...\n")
results_75_overall <- bind_rows(
  lapply(indicators, estimate_overall, design = des_75, scenario_name = "75% (Réduction)")
)

cat("  Régional...\n")
results_75_region <- bind_rows(
  lapply(indicators, estimate_by_strata, design = des_75, scenario_name = "75% (Réduction)", strata_var = "region")
)

cat("  District...\n")
results_75_district <- bind_rows(
  lapply(indicators, estimate_by_strata, design = des_75, scenario_name = "75% (Réduction)", strata_var = "District")
)

cat("  ✓ Terminé\n\n")

# ------------------------------------------------------------------------------
# 8. COMPARAISON NATIONALE
# ------------------------------------------------------------------------------
cat("=== COMPARAISON NATIONALE ===\n\n")

comparison_overall <- results_100_overall %>%
  select(indicator, estimate_100 = estimate, se_100 = se, cv_100 = cv, flag_100 = flag) %>%
  left_join(
    results_75_overall %>% select(indicator, estimate_75 = estimate, se_75 = se, cv_75 = cv, flag_75 = flag),
    by = "indicator"
  ) %>%
  mutate(
    diff_estimate = estimate_75 - estimate_100,
    diff_estimate_pct = round((estimate_75 - estimate_100) / estimate_100 * 100, 2),
    augmentation_se = round((se_75 - se_100) / se_100 * 100, 2),
    augmentation_cv = round((cv_75 - cv_100) / cv_100 * 100, 2),
    degradation_flag = ifelse(flag_75 != flag_100, paste0(flag_100, " → ", flag_75), "Stable")
  )

print(comparison_overall)
cat("\n")

# ------------------------------------------------------------------------------
# 9. COMPARAISON RÉGIONALE
# ------------------------------------------------------------------------------
cat("=== COMPARAISON RÉGIONALE - RÉSUMÉ ===\n\n")

comparison_region <- results_100_region %>%
  select(indicator, region, cv_100 = cv, flag_100 = flag) %>%
  left_join(
    results_75_region %>% select(indicator, region, cv_75 = cv, flag_75 = flag),
    by = c("indicator", "region")
  ) %>%
  mutate(
    augmentation_cv = round((cv_75 - cv_100) / cv_100 * 100, 2),
    degradation_flag = flag_100 != flag_75
  )

cat("Dégradation des flags de qualité par région:\n")
degradation_summary_region <- comparison_region %>%
  group_by(region) %>%
  summarise(
    n_total = n(),
    n_degradations = sum(degradation_flag, na.rm = TRUE),
    pct_degradations = round(n_degradations / n_total * 100, 1),
    cv_moyen_100 = round(mean(cv_100, na.rm = TRUE) * 100, 2),
    cv_moyen_75 = round(mean(cv_75, na.rm = TRUE) * 100, 2),
    augmentation_cv_moyenne = round(mean(augmentation_cv, na.rm = TRUE), 1),
    .groups = "drop"
  ) %>%
  arrange(desc(pct_degradations))

print(degradation_summary_region)
cat("\n")

# ------------------------------------------------------------------------------
# 10. COMPARAISON PAR DISTRICT
# ------------------------------------------------------------------------------
cat("=== COMPARAISON PAR DISTRICT - RÉSUMÉ ===\n\n")

comparison_district <- results_100_district %>%
  select(indicator, District, cv_100 = cv, flag_100 = flag) %>%
  left_join(
    results_75_district %>% select(indicator, District, cv_75 = cv, flag_75 = flag),
    by = c("indicator", "District")
  ) %>%
  mutate(
    augmentation_cv = round((cv_75 - cv_100) / cv_100 * 100, 2),
    degradation_flag = flag_100 != flag_75
  )

cat("Dégradation des flags de qualité par district (Top 15):\n")
degradation_summary_district <- comparison_district %>%
  group_by(District) %>%
  summarise(
    n_total = n(),
    n_degradations = sum(degradation_flag, na.rm = TRUE),
    pct_degradations = round(n_degradations / n_total * 100, 1),
    cv_moyen_100 = round(mean(cv_100, na.rm = TRUE) * 100, 2),
    cv_moyen_75 = round(mean(cv_75, na.rm = TRUE) * 100, 2),
    augmentation_cv_moyenne = round(mean(augmentation_cv, na.rm = TRUE), 1),
    .groups = "drop"
  ) %>%
  arrange(desc(pct_degradations)) %>%
  head(15)

print(degradation_summary_district)
cat("\n")

# ------------------------------------------------------------------------------
# 11. ANALYSE DES FLAGS
# ------------------------------------------------------------------------------
cat("=== ANALYSE DES FLAGS DE QUALITÉ ===\n\n")

# National
cat("NATIONAL:\n")
cat("Scénario 100%:\n")
print(table(results_100_overall$flag))
cat("\nScénario 75%:\n")
print(table(results_75_overall$flag))
cat("\n")

# Régional
cat("RÉGIONAL:\n")
cat("Scénario 100%:\n")
print(table(results_100_region$flag))
cat("\nScénario 75%:\n")
print(table(results_75_region$flag))
cat("\n")

# District
cat("DISTRICT:\n")
cat("Scénario 100%:\n")
print(table(results_100_district$flag))
cat("\nScénario 75%:\n")
print(table(results_75_district$flag))
cat("\n")

# ------------------------------------------------------------------------------
# 12. CRÉATION DU RAPPORT EXCEL
# ------------------------------------------------------------------------------
cat("=== CRÉATION DU RAPPORT EXCEL ===\n")

output_dir <- "data/08_STANDARD_ERRORS"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

wb <- createWorkbook()

# Styles
headerStyle <- createStyle(
  fontSize = 12, fontColour = "white", fgFill = "#4F81BD",
  halign = "center", valign = "center", textDecoration = "bold",
  border = "TopBottomLeftRight"
)

warningStyle <- createStyle(
  fontSize = 11, fontColour = "#C0504D", fgFill = "#FDE9D9",
  halign = "center", valign = "center", border = "TopBottomLeftRight"
)

goodStyle <- createStyle(
  fontSize = 11, fontColour = "#006100", fgFill = "#C6EFCE",
  halign = "center", valign = "center", border = "TopBottomLeftRight"
)

# Feuille 1: Résumé exécutif
addWorksheet(wb, "Résumé")

resume_data <- data.frame(
  Métrique = c(
    "Scénario",
    "Taille échantillon T3 (100%)",
    "Taille échantillon T3 (75%)",
    "Réduction",
    "",
    "Estimations nationales A (100%)",
    "Estimations nationales A (75%)",
    "Estimations nationales B (100%)",
    "Estimations nationales B (75%)",
    "Estimations nationales C/F (100%)",
    "Estimations nationales C/F (75%)",
    "",
    "Augmentation moyenne SE (%)",
    "Augmentation moyenne CV (%)",
    "",
    "Dégradations flag - National",
    "Dégradations flag - Régional",
    "Dégradations flag - District"
  ),
  Valeur = c(
    "Réduction de 25% de l'échantillon",
    nrow(df_t3),
    nrow(df_t3_reduit),
    paste0(nrow(df_t3) - nrow(df_t3_reduit), " observations (-25%)"),
    "",
    sum(results_100_overall$flag == "A"),
    sum(results_75_overall$flag == "A"),
    sum(results_100_overall$flag == "B"),
    sum(results_75_overall$flag == "B"),
    sum(results_100_overall$flag %in% c("C", "F")),
    sum(results_75_overall$flag %in% c("C", "F")),
    "",
    paste0(round(mean(comparison_overall$augmentation_se), 1), "%"),
    paste0(round(mean(comparison_overall$augmentation_cv), 1), "%"),
    "",
    sum(comparison_overall$flag_100 != comparison_overall$flag_75),
    sum(comparison_region$degradation_flag, na.rm = TRUE),
    sum(comparison_district$degradation_flag, na.rm = TRUE)
  )
)

writeDataTable(wb, "Résumé", resume_data, withFilter = FALSE)

# Feuille 2: Comparaison nationale détaillée
addWorksheet(wb, "National_Comparaison")
writeDataTable(wb, "National_Comparaison", comparison_overall, withFilter = TRUE)

# Feuille 3: Estimations 100%
addWorksheet(wb, "National_100pct")
writeDataTable(wb, "National_100pct", results_100_overall, withFilter = TRUE)

# Feuille 4: Estimations 75%
addWorksheet(wb, "National_75pct")
writeDataTable(wb, "National_75pct", results_75_overall, withFilter = TRUE)

# Feuille 5: Comparaison régionale
addWorksheet(wb, "Regional_Comparaison")
writeDataTable(wb, "Regional_Comparaison", comparison_region, withFilter = TRUE)

# Feuille 6: Résumé régional
addWorksheet(wb, "Regional_Resume")
writeDataTable(wb, "Regional_Resume", degradation_summary_region, withFilter = TRUE)

# Feuille 7: Comparaison district
addWorksheet(wb, "District_Comparaison")
writeDataTable(wb, "District_Comparaison", comparison_district, withFilter = TRUE)

# Feuille 8: Résumé district
addWorksheet(wb, "District_Resume")
writeDataTable(wb, "District_Resume", degradation_summary_district, withFilter = TRUE)

# Feuille 9: Distribution par région
addWorksheet(wb, "Distribution_Region")
writeDataTable(wb, "Distribution_Region", comparison_region, withFilter = TRUE)

saveWorkbook(wb, file.path(output_dir, "scenario_reduction_25pct.xlsx"), overwrite = TRUE)
cat("  ✓ scenario_reduction_25pct.xlsx créé\n\n")

# ------------------------------------------------------------------------------
# 13. VISUALISATIONS
# ------------------------------------------------------------------------------
cat("=== CRÉATION DES VISUALISATIONS ===\n")

plot_dir <- file.path(output_dir, "scenario_plots")
dir.create(plot_dir, showWarnings = FALSE, recursive = TRUE)

# Graphique 1: Comparaison des CV
p1_data <- comparison_overall %>%
  select(indicator, CV_100 = cv_100, CV_75 = cv_75) %>%
  pivot_longer(cols = c(CV_100, CV_75), names_to = "Scenario", values_to = "CV") %>%
  mutate(
    Scenario = recode(Scenario, "CV_100" = "100% (Référence)", "CV_75" = "75% (Réduction)"),
    CV_pct = CV * 100
  )

p1 <- ggplot(p1_data, aes(x = indicator, y = CV_pct, fill = Scenario)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_hline(yintercept = 15, linetype = "dashed", color = "#E67E22", linewidth = 0.8) +
  geom_hline(yintercept = 30, linetype = "dashed", color = "#C0392B", linewidth = 0.8) +
  scale_fill_manual(values = c("100% (Référence)" = "#3498DB", "75% (Réduction)" = "#E74C3C")) +
  labs(
    title = "Impact de la Réduction d'Échantillon sur le Coefficient de Variation",
    subtitle = "Comparaison 100% vs 75% - Estimations Nationales T3",
    x = "Indicateur",
    y = "Coefficient de Variation (%)",
    fill = "Scénario"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 15),
    plot.subtitle = element_text(size = 11, color = "gray50"),
    legend.position = "bottom"
  ) +
  annotate("text", x = 0.7, y = 15, label = "Seuil A/B (15%)", hjust = 0, vjust = -0.5, size = 3, color = "#E67E22") +
  annotate("text", x = 0.7, y = 30, label = "Seuil B/C (30%)", hjust = 0, vjust = -0.5, size = 3, color = "#C0392B")

ggsave(file.path(plot_dir, "comparaison_cv_national.png"), p1, width = 12, height = 7, dpi = 300, bg = "white")

# Graphique 2: Augmentation du CV par indicateur
p2_data <- comparison_overall %>%
  mutate(indicator = factor(indicator, levels = c("SU1", "SU2", "SU3", "SU4")))

p2 <- ggplot(p2_data, aes(x = indicator, y = augmentation_cv)) +
  geom_col(fill = "#E74C3C", width = 0.6) +
  geom_text(aes(label = paste0("+", augmentation_cv, "%")), vjust = -0.5, size = 4.5, fontface = "bold") +
  labs(
    title = "Augmentation du Coefficient de Variation",
    subtitle = "Impact de la réduction de 25% de l'échantillon",
    x = "Indicateur",
    y = "Augmentation du CV (%)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 15),
    plot.subtitle = element_text(size = 11, color = "gray50")
  )

ggsave(file.path(plot_dir, "augmentation_cv.png"), p2, width = 10, height = 6, dpi = 300, bg = "white")

# Graphique 3: Dégradations par région
p3_data <- degradation_summary_region %>%
  arrange(desc(pct_degradations)) %>%
  mutate(region = factor(region, levels = region))

p3 <- ggplot(p3_data, aes(x = region, y = pct_degradations)) +
  geom_col(aes(fill = pct_degradations > 25), width = 0.7) +
  geom_text(aes(label = paste0(pct_degradations, "%")), vjust = -0.5, size = 3.5) +
  scale_fill_manual(values = c("FALSE" = "#3498DB", "TRUE" = "#E74C3C"), guide = "none") +
  labs(
    title = "Dégradation de la Qualité par Région",
    subtitle = "Pourcentage d'estimations avec dégradation du flag de qualité",
    x = "Région",
    y = "% Dégradations"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "gray50"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave(file.path(plot_dir, "degradation_par_region.png"), p3, width = 12, height = 7, dpi = 300, bg = "white")

cat("  ✓ Graphiques créés\n\n")

# ------------------------------------------------------------------------------
# 14. SYNTHÈSE FINALE
# ------------------------------------------------------------------------------
cat("═══════════════════════════════════════════════════════════════════════════\n")
cat("                        SYNTHÈSE DU SCÉNARIO                                \n")
cat("═══════════════════════════════════════════════════════════════════════════\n\n")

cat("📊 RÉDUCTION D'ÉCHANTILLON:\n")
cat("  • Échantillon T3 (100%):", nrow(df_t3), "observations\n")
cat("  • Échantillon T3 (75%):", nrow(df_t3_reduit), "observations\n")
cat("  • Réduction:", nrow(df_t3) - nrow(df_t3_reduit), "observations (-25%)\n\n")

cat("📈 IMPACT SUR LA PRÉCISION:\n")
cat("  • Augmentation moyenne SE:", round(mean(comparison_overall$augmentation_se), 1), "%\n")
cat("  • Augmentation moyenne CV:", round(mean(comparison_overall$augmentation_cv), 1), "%\n\n")

cat("⚠️  DÉGRADATIONS DE QUALITÉ:\n")
cat("  • National:", sum(comparison_overall$flag_100 != comparison_overall$flag_75), "sur", nrow(comparison_overall), "estimations\n")
cat("  • Régional:", sum(comparison_region$degradation_flag, na.rm = TRUE), "sur", nrow(comparison_region), "estimations\n")
cat("  • District:", sum(comparison_district$degradation_flag, na.rm = TRUE), "sur", nrow(comparison_district), "estimations\n\n")

cat("📁 FICHIERS CRÉÉS:\n")
cat("  ✓", file.path(output_dir, "scenario_reduction_25pct.xlsx"), "\n")
cat("  ✓", file.path(plot_dir, "comparaison_cv_national.png"), "\n")
cat("  ✓", file.path(plot_dir, "augmentation_cv.png"), "\n")
cat("  ✓", file.path(plot_dir, "degradation_par_region.png"), "\n\n")

cat("═══════════════════════════════════════════════════════════════════════════\n\n")

message("✓ Analyse de scénario terminée !")




