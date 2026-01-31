# ==============================================================================
# SIMULATEUR CORRIGÉ - ENQUÊTE MÉNAGE
# Prend en compte : Non-réponse ménage + Taille ménage + Non-réponse individuelle
# ==============================================================================

library(openxlsx)
library(dplyr)
library(ggplot2)
library(scales)
library(haven)

cat("\n")
cat("═══════════════════════════════════════════════════════════════════════════\n")
cat("    SIMULATEUR CORRIGÉ - ENQUÊTE MÉNAGE (3 NIVEAUX DE NON-RÉPONSE)        \n")
cat("═══════════════════════════════════════════════════════════════════════════\n\n")

# ------------------------------------------------------------------------------
# 1. Charger les données pour calculer les paramètres réels
# ------------------------------------------------------------------------------
cat("=== ANALYSE DES DONNÉES RÉELLES ===\n")

df <- read_dta("data/04_weights/Base_Travail_BT_vf.dta")

# Statistiques réelles
stats_reelles <- list()

# Effectif individus T3
stats_reelles$n_individus_t3 <- nrow(df %>% filter(trimestre == "25T3", !is.na(pmencor_ind), pmencor_ind > 0))

# Si vous avez l'info ménage dans vos données, calculer :
# Pour l'instant, on va estimer en fonction des paramètres standards d'enquête ménage

cat("  • Individus 15+ observés T3 :", stats_reelles$n_individus_t3, "\n\n")

cat("⚠️  IMPORTANT : Pour des calculs précis, fournir :\n")
cat("  1. Nombre de MÉNAGES échantillonnés initialement\n")
cat("  2. Taux de réponse au niveau MÉNAGE\n")
cat("  3. Taille moyenne des ménages (nb de 15+)\n")
cat("  4. Taux de réponse au niveau INDIVIDUEL\n\n")

# ------------------------------------------------------------------------------
# 2. Fonction de calcul corrigée
# ------------------------------------------------------------------------------

calculer_precision_menage <- function(
  n_menages,                        # Nombre de ménages échantillonnés
  taux_reponse_menage = 0.61357,    # Ex: 95% des ménages répondent
  taille_moyenne_15plus = 3.2,      # Ex: 3.2 personnes de 15+ par ménage
  taux_reponse_individuel = 0.7083, # Ex: 98% des 15+ répondent
  p = 0.123,                        # Proportion estimée
  z = 1.96,                         # Z-score pour IC 95%
  deff = 2                          # Design effect
) {
  
  # ÉTAPE 1 : Ménages répondants
  n_menages_repondants <- n_menages * taux_reponse_menage
  
  # ÉTAPE 2 : Individus 15+ dans les ménages répondants
  n_individus_15plus <- n_menages_repondants * taille_moyenne_15plus
  
  # ÉTAPE 3 : Individus 15+ répondants (effectif final)
  n_individus_repondants <- n_individus_15plus * taux_reponse_individuel
  
  # ÉTAPE 4 : Calcul de précision sur l'effectif final
  n_effectif <- n_individus_repondants
  
  # Erreur standard
  se <- sqrt(p * (1 - p) / n_effectif) * sqrt(deff)
  
  # Marge d'erreur
  me <- z * se
  
  # Coefficient de variation
  cv <- se / p
  
  # Intervalle de confiance
  ic_inf <- p - me
  ic_sup <- p + me
  
  # Flag de qualité
  flag <- case_when(
    cv < 0.15 ~ "A",
    cv < 0.30 ~ "B",
    TRUE ~ "C"
  )
  
  list(
    # Inputs
    n_menages_initial = n_menages,
    taux_rep_menage = taux_reponse_menage,
    taille_moy_15plus = taille_moyenne_15plus,
    taux_rep_individuel = taux_reponse_individuel,
    
    # Étapes de calcul
    n_menages_repondants = round(n_menages_repondants),
    n_individus_15plus = round(n_individus_15plus),
    n_individus_repondants = round(n_individus_repondants),
    
    # Taux globaux
    taux_reponse_global = taux_reponse_menage * taux_reponse_individuel,
    taux_attrition_menage = 1 - taux_reponse_menage,
    taux_attrition_individuel = 1 - taux_reponse_individuel,
    taux_attrition_global = 1 - (taux_reponse_menage * taux_reponse_individuel),
    
    # Résultats de précision
    p = p,
    se = se,
    me = me,
    me_pct = me * 100,
    cv = cv,
    cv_pct = cv * 100,
    ic_inf = ic_inf,
    ic_sup = ic_sup,
    ic_inf_pct = ic_inf * 100,
    ic_sup_pct = ic_sup * 100,
    largeur_ic_pct = (ic_sup - ic_inf) * 100,
    flag = flag
  )
}

calculer_precision_menage(n_menages = 5688) # Test rapide
11376

# ------------------------------------------------------------------------------
# 3. Estimer les paramètres à partir des données observées
# ------------------------------------------------------------------------------

cat("=== ESTIMATION DES PARAMÈTRES RÉELS ===\n\n")

cat("Avec l'effectif observé de", stats_reelles$n_individus_t3, "individus 15+ répondants,\n")
cat("et en supposant des paramètres standards d'enquête ménage :\n\n")

# Hypothèses raisonnables
param_hypotheses <- data.frame(
  Paramètre = c(
    "Taux de réponse ménage",
    "Taille moyenne ménage (15+)",
    "Taux de réponse individuel",
    "Taux de réponse global",
    "DEFF"
  ),
  Hypothèse = c(
    "61.357%",
    "3.2 personnes",
    "70.83%",
    "43.3% (61.357% × 70.83%)",
    "2.0"
  ),
  Ajustable = c("OUI", "OUI", "OUI", "Calculé", "OUI")
)

print(param_hypotheses)
cat("\n")

# Retrouver le nombre de ménages initial
# n_individus_final = n_menages × 0.95 × 3.2 × 0.98
# n_menages = n_individus_final / (0.95 × 3.2 × 0.98)

taux_rep_men_defaut <- 0.61357
taille_moy_defaut <- 3.2
taux_rep_ind_defaut <- 0.7083

n_menages_estime <- ceiling(15828 / (taux_rep_men_defaut * taille_moy_defaut * taux_rep_ind_defaut))

cat("→ Nombre de ménages échantillonnés (estimé) :", n_menages_estime, "\n")
cat("→ Ménages répondants (61.357%) :", round(n_menages_estime * 0.61357), "\n")
cat("→ Individus 15+ dans ménages répondants :", round(n_menages_estime * 0.61357 * 3.2), "\n")
cat("→ Individus 15+ répondants (70.83%) :", round(n_menages_estime * 0.61357 * 3.2 * 0.7083), "\n\n")

# ------------------------------------------------------------------------------
# 4. Créer le simulateur Excel
# ------------------------------------------------------------------------------
cat("=== CRÉATION DU SIMULATEUR EXCEL CORRIGÉ ===\n")

wb <- createWorkbook()

# Styles
style_header <- createStyle(
  fontSize = 12, fontColour = "white", fgFill = "#4472C4",
  halign = "center", valign = "center", textDecoration = "bold",
  border = "TopBottomLeftRight"
)

style_param <- createStyle(
  fontSize = 11, fgFill = "#D9E1F2", halign = "left",
  valign = "center", textDecoration = "bold",
  border = "TopBottomLeftRight"
)

style_calcul <- createStyle(
  fontSize = 11, fgFill = "#E2EFDA", halign = "center",
  valign = "center", border = "TopBottomLeftRight"
)

style_value <- createStyle(
  fontSize = 11, halign = "center", valign = "center",
  border = "TopBottomLeftRight"
)

style_result_good <- createStyle(
  fontSize = 11, fontColour = "#375623", fgFill = "#C6E0B4",
  halign = "center", valign = "center", textDecoration = "bold",
  border = "TopBottomLeftRight"
)

style_result_warning <- createStyle(
  fontSize = 11, fontColour = "#9C5700", fgFill = "#FFE699",
  halign = "center", valign = "center", textDecoration = "bold",
  border = "TopBottomLeftRight"
)

style_result_bad <- createStyle(
  fontSize = 11, fontColour = "#9C0006", fgFill = "#FFC7CE",
  halign = "center", valign = "center", textDecoration = "bold",
  border = "TopBottomLeftRight"
)

style_title <- createStyle(
  fontSize = 16, fontColour = "#1F4E78", halign = "left",
  valign = "center", textDecoration = "bold"
)

# ------------------------------------------------------------------------------
# 5. ONGLET 1 : PARAMÈTRES AVEC 3 NIVEAUX
# ------------------------------------------------------------------------------
cat("  Onglet 1 : Paramètres (corrigés)...\n")

addWorksheet(wb, "1_Parametres_Enquete_Menage")

writeData(wb, "1_Parametres_Enquete_Menage", 
          "SIMULATEUR ENQUÊTE MÉNAGE - PRISE EN COMPTE COMPLÈTE DES NON-RÉPONSES", 
          startRow = 1, startCol = 1)
addStyle(wb, "1_Parametres_Enquete_Menage", style_title, rows = 1, cols = 1)
mergeCells(wb, "1_Parametres_Enquete_Menage", cols = 1:3, rows = 1)

# Instructions
instructions <- data.frame(
  Info = c(
    "Ce simulateur prend en compte la structure réelle d'une enquête ménage :",
    "  1. Non-réponse au niveau MÉNAGE",
    "  2. Taille des ménages (nombre de personnes de 15 ans et plus)",
    "  3. Non-réponse au niveau INDIVIDUEL (parmi les 15+)",
    "",
    "Modifiez les PARAMÈTRES EN BLEU pour tester différents scénarios.",
    "L'effectif final d'individus répondants est calculé automatiquement."
  )
)

writeDataTable(wb, "1_Parametres_Enquete_Menage", instructions, 
               startRow = 3, startCol = 1, tableStyle = "TableStyleLight1", 
               withFilter = FALSE, tableName = "Instructions")

# SECTION A : Paramètres d'échantillonnage
writeData(wb, "1_Parametres_Enquete_Menage", "A. ÉCHANTILLONNAGE DES MÉNAGES", 
          startRow = 12, startCol = 1)
addStyle(wb, "1_Parametres_Enquete_Menage", style_header, rows = 12, cols = 1:3)
mergeCells(wb, "1_Parametres_Enquete_Menage", cols = 1:3, rows = 12)

params_echantillon <- data.frame(
  Paramètre = c(
    "Nombre de ménages échantillonnés (référence T3)",
    "Taux de réponse MÉNAGE (%)",
    "→ Ménages répondants",
    "",
    "Taille moyenne du ménage (nb de 15+)",
    "→ Individus 15+ dans ménages répondants"
  ),
  Valeur = c(
    n_menages_estime,
    95,
    round(n_menages_estime * 0.95),
    "",
    3.2,
    round(n_menages_estime * 0.95 * 3.2)
  ),
  Note = c(
    "MODIFIABLE",
    "MODIFIABLE (défaut 95%)",
    "Calculé automatiquement",
    "",
    "MODIFIABLE (défaut 3.2)",
    "Calculé automatiquement"
  )
)

writeDataTable(wb, "1_Parametres_Enquete_Menage", params_echantillon,
               startRow = 13, startCol = 1, tableStyle = "TableStyleMedium2",
               withFilter = FALSE, tableName = "ParamsEchantillon")

# SECTION B : Non-réponse individuelle
writeData(wb, "1_Parametres_Enquete_Menage", "B. NON-RÉPONSE INDIVIDUELLE", 
          startRow = 21, startCol = 1)
addStyle(wb, "1_Parametres_Enquete_Menage", style_header, rows = 21, cols = 1:3)
mergeCells(wb, "1_Parametres_Enquete_Menage", cols = 1:3, rows = 21)

params_individuel <- data.frame(
  Paramètre = c(
    "Taux de réponse INDIVIDUEL (%)",
    "→ Individus 15+ répondants (EFFECTIF FINAL)"
  ),
  Valeur = c(
    98,
    stats_reelles$n_individus_t3
  ),
  Note = c(
    "MODIFIABLE (défaut 98%)",
    "Calculé - C'est l'effectif utilisé pour les calculs"
  )
)

writeDataTable(wb, "1_Parametres_Enquete_Menage", params_individuel,
               startRow = 22, startCol = 1, tableStyle = "TableStyleMedium9",
               withFilter = FALSE, tableName = "ParamsIndividuel")

# SECTION C : Taux globaux
writeData(wb, "1_Parametres_Enquete_Menage", "C. TAUX DE RÉPONSE ET ATTRITION GLOBAUX", 
          startRow = 26, startCol = 1)
addStyle(wb, "1_Parametres_Enquete_Menage", style_header, rows = 26, cols = 1:3)
mergeCells(wb, "1_Parametres_Enquete_Menage", cols = 1:3, rows = 26)

taux_globaux <- data.frame(
  Indicateur = c(
    "Taux de réponse GLOBAL",
    "Attrition au niveau ménage",
    "Attrition au niveau individuel",
    "Attrition GLOBALE"
  ),
  Calcul = c(
    "Taux rép. ménage × Taux rép. individuel",
    "1 - Taux rép. ménage",
    "1 - Taux rép. individuel",
    "1 - Taux rép. global"
  ),
  Valeur = c(
    paste0(round(0.95 * 0.98 * 100, 1), "%"),
    paste0(round((1 - 0.95) * 100, 1), "%"),
    paste0(round((1 - 0.98) * 100, 1), "%"),
    paste0(round((1 - 0.95 * 0.98) * 100, 1), "%")
  )
)

writeDataTable(wb, "1_Parametres_Enquete_Menage", taux_globaux,
               startRow = 27, startCol = 1, tableStyle = "TableStyleLight11",
               withFilter = FALSE, tableName = "TauxGlobaux")

# SECTION D : Paramètres statistiques
writeData(wb, "1_Parametres_Enquete_Menage", "D. PARAMÈTRES STATISTIQUES", 
          startRow = 33, startCol = 1)
addStyle(wb, "1_Parametres_Enquete_Menage", style_header, rows = 33, cols = 1:3)

params_stats <- data.frame(
  Paramètre = c(
    "Niveau de confiance (%)",
    "Z-score",
    "DEFF (Design Effect)",
    "Proportion estimée (p)"
  ),
  Valeur = c(95, 1.96, 2, 0.104),
  Note = c(
    "Standard",
    "Pour IC 95%",
    "MODIFIABLE",
    "MODIFIABLE (10.4% = chômage)"
  )
)

writeDataTable(wb, "1_Parametres_Enquete_Menage", params_stats,
               startRow = 34, startCol = 1, tableStyle = "TableStyleMedium2",
               withFilter = FALSE, tableName = "ParamsStats")

# SECTION E : Scénarios
writeData(wb, "1_Parametres_Enquete_Menage", "E. SCÉNARIOS DE RÉDUCTION", 
          startRow = 40, startCol = 1)
addStyle(wb, "1_Parametres_Enquete_Menage", style_header, rows = 40, cols = 1:4)

scenarios_data <- data.frame(
  Scénario = c("Référence (100%)", "Scénario 1 (90%)", "Scénario 2 (85%)", 
               "Scénario 3 (75%)", "Scénario 4 (65%)", "Scénario 5 (50%)"),
  `Réduction Budget` = c("0%", "10%", "15%", "25%", "35%", "50%"),
  `% Ménages` = c(100, 90, 85, 75, 65, 50),
  `Ménages échantillonnés` = round(n_menages_estime * c(1, 0.9, 0.85, 0.75, 0.65, 0.5)),
  check.names = FALSE
)

writeDataTable(wb, "1_Parametres_Enquete_Menage", scenarios_data,
               startRow = 41, startCol = 1, tableStyle = "TableStyleMedium9",
               withFilter = FALSE, tableName = "Scenarios")

setColWidths(wb, "1_Parametres_Enquete_Menage", cols = 1, widths = 45)
setColWidths(wb, "1_Parametres_Enquete_Menage", cols = 2:3, widths = 25)

# ------------------------------------------------------------------------------
# 6. ONGLET 2 : FLUX DE CALCUL DÉTAILLÉ
# ------------------------------------------------------------------------------
cat("  Onglet 2 : Flux de calcul...\n")

addWorksheet(wb, "2_Flux_Calcul_Detaille")

writeData(wb, "2_Flux_Calcul_Detaille", 
          "FLUX DE CALCUL : DE L'ÉCHANTILLON DE MÉNAGES À L'EFFECTIF FINAL", 
          startRow = 1, startCol = 1)
addStyle(wb, "2_Flux_Calcul_Detaille", style_title, rows = 1, cols = 1)

# Pour chaque scénario, montrer le flux
scenarios_pct <- c(100, 90, 85, 75, 65, 50)
flux_results <- data.frame()

for (pct in scenarios_pct) {
  n_men <- round(n_menages_estime * pct / 100)
  res <- calculer_precision_menage(
    n_menages = n_men,
    taux_reponse_menage = 0.95,
    taille_moyenne_15plus = 3.2,
    taux_reponse_individuel = 0.98
  )
  
  flux_results <- rbind(flux_results, data.frame(
    Scénario = paste0(pct, "%"),
    `Étape 1: Ménages échantillonnés` = n_men,
    `Étape 2: Ménages répondants (95%)` = res$n_menages_repondants,
    `Étape 3: Individus 15+ (×3.2)` = res$n_individus_15plus,
    `Étape 4: Individus répondants (98%)` = res$n_individus_repondants,
    `Perte totale (%)` = round((1 - res$n_individus_repondants / (n_men * 3.2)) * 100, 1),
    check.names = FALSE
  ))
}

writeDataTable(wb, "2_Flux_Calcul_Detaille", flux_results,
               startRow = 3, startCol = 1, tableStyle = "TableStyleMedium2",
               withFilter = TRUE, tableName = "FluxCalcul")

# Graphique visuel du flux
writeData(wb, "2_Flux_Calcul_Detaille", "VISUALISATION DU FLUX (Scénario 75%)", 
          startRow = 12, startCol = 1)
addStyle(wb, "2_Flux_Calcul_Detaille", style_header, rows = 12, cols = 1:5)

n_men_75 <- round(n_menages_estime * 0.75)
res_75 <- calculer_precision_menage(n_men_75, 0.95, 3.2, 0.98)

flux_visuel <- data.frame(
  Étape = c(
    "➊ Ménages échantillonnés",
    "   ↓ Taux de réponse ménage : 95%",
    "➋ Ménages répondants",
    "   ↓ Taille moyenne ménage : 3.2 personnes de 15+",
    "➌ Individus 15+ dans ménages répondants",
    "   ↓ Taux de réponse individuel : 98%",
    "➍ INDIVIDUS 15+ RÉPONDANTS (effectif final)"
  ),
  Valeur = c(
    n_men_75,
    "",
    res_75$n_menages_repondants,
    "",
    res_75$n_individus_15plus,
    "",
    res_75$n_individus_repondants
  ),
  `Perte cumulative` = c(
    "0%",
    paste0("-", round((1 - 0.95) * 100, 1), "%"),
    paste0("-", round((1 - 0.95) * 100, 1), "%"),
    "(multiplication, pas de perte)",
    paste0("-", round((1 - 0.95) * 100, 1), "%"),
    paste0("-", round((1 - 0.95 * 0.98 + 0.95) * 100, 1), "%"),
    paste0("-", round((1 - 0.95 * 0.98) * 100, 1), "% au total")
  ),
  check.names = FALSE
)

writeDataTable(wb, "2_Flux_Calcul_Detaille", flux_visuel,
               startRow = 13, startCol = 1, tableStyle = "TableStyleLight1",
               withFilter = FALSE, tableName = "FluxVisuel")

# Formule complète
writeData(wb, "2_Flux_Calcul_Detaille", "FORMULE COMPLÈTE", 
          startRow = 22, startCol = 1)
addStyle(wb, "2_Flux_Calcul_Detaille", style_header, rows = 22, cols = 1:2)

formule_complete <- data.frame(
  Élément = c(
    "Effectif final d'individus 15+ répondants",
    "",
    "Application numérique (75%)"
  ),
  Formule = c(
    "n_final = n_ménages × Taux_rép_ménage × Taille_moy_15+ × Taux_rép_individuel",
    "",
    sprintf("n_final = %d × 0.95 × 3.2 × 0.98 = %d individus", 
            n_men_75, res_75$n_individus_repondants)
  )
)

writeDataTable(wb, "2_Flux_Calcul_Detaille", formule_complete,
               startRow = 23, startCol = 1, tableStyle = "TableStyleMedium9",
               withFilter = FALSE, tableName = "FormuleComplete")

setColWidths(wb, "2_Flux_Calcul_Detaille", cols = 1, widths = 50)
setColWidths(wb, "2_Flux_Calcul_Detaille", cols = 2:3, widths = 25)

# ------------------------------------------------------------------------------
# 7. ONGLET 3 : RÉSULTATS DE PRÉCISION
# ------------------------------------------------------------------------------
cat("  Onglet 3 : Résultats de précision...\n")

addWorksheet(wb, "3_Resultats_Precision")

writeData(wb, "3_Resultats_Precision", 
          "PRÉCISION PAR SCÉNARIO (avec prise en compte complète des non-réponses)", 
          startRow = 1, startCol = 1)
addStyle(wb, "3_Resultats_Precision", style_title, rows = 1, cols = 1)

precision_results <- data.frame()

for (pct in scenarios_pct) {
  n_men <- round(n_menages_estime * pct / 100)
  res <- calculer_precision_menage(n_men, 0.95, 3.2, 0.98)
  
  precision_results <- rbind(precision_results, data.frame(
    Scénario = paste0(pct, "%"),
    `Réduction` = paste0(100 - pct, "%"),
    `Ménages échantillonnés` = n_men,
    `Individus répondants` = res$n_individus_repondants,
    `Marge Erreur` = sprintf("±%.2f%%", res$me_pct),
    CV = sprintf("%.2f%%", res$cv_pct),
    `IC Inf` = sprintf("%.2f%%", res$ic_inf_pct),
    `IC Sup` = sprintf("%.2f%%", res$ic_sup_pct),
    `Largeur IC` = sprintf("%.2f%%", res$largeur_ic_pct),
    Flag = res$flag,
    check.names = FALSE
  ))
}

writeDataTable(wb, "3_Resultats_Precision", precision_results,
               startRow = 3, startCol = 1, tableStyle = "TableStyleMedium2",
               withFilter = TRUE, tableName = "PrecisionResults")

# Appliquer couleurs
for (i in 1:nrow(precision_results)) {
  flag <- precision_results$Flag[i]
  row_idx <- i + 3
  
  if (flag == "A") {
    addStyle(wb, "3_Resultats_Precision", style_result_good, rows = row_idx, cols = 10)
  } else if (flag == "B") {
    addStyle(wb, "3_Resultats_Precision", style_result_warning, rows = row_idx, cols = 10)
  } else {
    addStyle(wb, "3_Resultats_Precision", style_result_bad, rows = row_idx, cols = 10)
  }
}

# Comparaison avec calcul simplifié (ERREUR)
writeData(wb, "3_Resultats_Precision", 
          "COMPARAISON : Calcul simplifié vs Calcul correct", 
          startRow = 12, startCol = 1)
addStyle(wb, "3_Resultats_Precision", style_header, rows = 12, cols = 1:6)

# Calcul ERRONÉ (comme dans mon ancien simulateur)
n_individus_simplifie_75 <- round(stats_reelles$n_individus_t3 * 0.75 * 0.997)
se_simplifie <- sqrt(0.104 * 0.896 / n_individus_simplifie_75) * sqrt(2)
cv_simplifie <- se_simplifie / 0.104

# Calcul CORRECT
n_men_75 <- round(n_menages_estime * 0.75)
res_correct_75 <- calculer_precision_menage(n_men_75, 0.95, 3.2, 0.98)

comparaison <- data.frame(
  Méthode = c("❌ SIMPLIFIÉE (ERREUR)", "✅ CORRECTE (3 niveaux)"),
  `Effectif calculé` = c(n_individus_simplifie_75, res_correct_75$n_individus_repondants),
  `Marge d'erreur` = c(
    sprintf("±%.2f%%", se_simplifie * 1.96 * 100),
    sprintf("±%.2f%%", res_correct_75$me_pct)
  ),
  CV = c(
    sprintf("%.2f%%", cv_simplifie * 100),
    sprintf("%.2f%%", res_correct_75$cv_pct)
  ),
  Flag = c(
    ifelse(cv_simplifie < 0.15, "A", ifelse(cv_simplifie < 0.30, "B", "C")),
    res_correct_75$flag
  ),
  Différence = c(
    "Sous-estime la non-réponse",
    "Prend en compte toutes les pertes"
  ),
  check.names = FALSE
)

writeDataTable(wb, "3_Resultats_Precision", comparaison,
               startRow = 13, startCol = 1, tableStyle = "TableStyleLight9",
               withFilter = FALSE, tableName = "Comparaison")

setColWidths(wb, "3_Resultats_Precision", cols = 1:6, widths = 20)

# ------------------------------------------------------------------------------
# 8. ONGLET 4 : ANALYSE DE SENSIBILITÉ
# ------------------------------------------------------------------------------
cat("  Onglet 4 : Sensibilité aux paramètres...\n")

addWorksheet(wb, "4_Sensibilite")

writeData(wb, "4_Sensibilite", 
          "ANALYSE DE SENSIBILITÉ AUX PARAMÈTRES", 
          startRow = 1, startCol = 1)
addStyle(wb, "4_Sensibilite", style_title, rows = 1, cols = 1)

# Sensibilité au taux de réponse ménage
writeData(wb, "4_Sensibilite", 
          "Impact du taux de réponse MÉNAGE (scénario 75%)", 
          startRow = 3, startCol = 1)
addStyle(wb, "4_Sensibilite", style_header, rows = 3, cols = 1:6)

taux_men_values <- c(100, 95, 90, 85, 80)
sens_taux_men <- data.frame()

for (taux in taux_men_values) {
  res <- calculer_precision_menage(n_men_75, taux / 100, 3.2, 0.98)
  sens_taux_men <- rbind(sens_taux_men, data.frame(
    `Taux rép. ménage` = paste0(taux, "%"),
    `Ménages répondants` = res$n_menages_repondants,
    `Individus répondants` = res$n_individus_repondants,
    `Marge d'erreur` = sprintf("±%.2f%%", res$me_pct),
    CV = sprintf("%.2f%%", res$cv_pct),
    Flag = res$flag,
    check.names = FALSE
  ))
}

writeDataTable(wb, "4_Sensibilite", sens_taux_men,
               startRow = 4, startCol = 1, tableStyle = "TableStyleMedium2",
               withFilter = FALSE, tableName = "SensTauxMenage")

# Sensibilité à la taille du ménage
writeData(wb, "4_Sensibilite", 
          "Impact de la taille moyenne du ménage (15+)", 
          startRow = 12, startCol = 1)
addStyle(wb, "4_Sensibilite", style_header, rows = 12, cols = 1:6)

taille_values <- c(2.5, 3.0, 3.2, 3.5, 4.0)
sens_taille <- data.frame()

for (taille in taille_values) {
  res <- calculer_precision_menage(n_men_75, 0.95, taille, 0.98)
  sens_taille <- rbind(sens_taille, data.frame(
    `Taille moyenne 15+` = taille,
    `Individus 15+` = res$n_individus_15plus,
    `Individus répondants` = res$n_individus_repondants,
    `Marge d'erreur` = sprintf("±%.2f%%", res$me_pct),
    CV = sprintf("%.2f%%", res$cv_pct),
    Flag = res$flag,
    check.names = FALSE
  ))
}

writeDataTable(wb, "4_Sensibilite", sens_taille,
               startRow = 13, startCol = 1, tableStyle = "TableStyleMedium2",
               withFilter = FALSE, tableName = "SensTaille")

# Sensibilité au taux de réponse individuel
writeData(wb, "4_Sensibilite", 
          "Impact du taux de réponse INDIVIDUEL", 
          startRow = 21, startCol = 1)
addStyle(wb, "4_Sensibilite", style_header, rows = 21, cols = 1:6)

taux_ind_values <- c(100, 98, 95, 90, 85)
sens_taux_ind <- data.frame()

for (taux in taux_ind_values) {
  res <- calculer_precision_menage(n_men_75, 0.95, 3.2, taux / 100)
  sens_taux_ind <- rbind(sens_taux_ind, data.frame(
    `Taux rép. individuel` = paste0(taux, "%"),
    `Individus 15+ disponibles` = res$n_individus_15plus,
    `Individus répondants` = res$n_individus_repondants,
    `Marge d'erreur` = sprintf("±%.2f%%", res$me_pct),
    CV = sprintf("%.2f%%", res$cv_pct),
    Flag = res$flag,
    check.names = FALSE
  ))
}

writeDataTable(wb, "4_Sensibilite", sens_taux_ind,
               startRow = 22, startCol = 1, tableStyle = "TableStyleMedium2",
               withFilter = FALSE, tableName = "SensTauxIndiv")

setColWidths(wb, "4_Sensibilite", cols = 1:6, widths = 20)

# ------------------------------------------------------------------------------
# 9. Sauvegarder
# ------------------------------------------------------------------------------
output_dir <- "data/08_STANDARD_ERRORS"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

filename <- file.path(output_dir, "SIMULATEUR_MENAGE_CORRIGE.xlsx")
saveWorkbook(wb, filename, overwrite = TRUE)

cat("  ✓ Simulateur corrigé créé\n\n")

# ------------------------------------------------------------------------------
# 10. Créer graphique comparatif
# ------------------------------------------------------------------------------
cat("=== CRÉATION DU GRAPHIQUE COMPARATIF ===\n")

plot_dir <- file.path(output_dir, "simulateur_plots")
dir.create(plot_dir, showWarnings = FALSE, recursive = TRUE)

# Données pour le graphique
comparison_data <- data.frame()

for (pct in scenarios_pct) {
  # Calcul simplifié (ERREUR)
  n_simple <- round(stats_reelles$n_individus_t3 * pct / 100 * 0.997)
  se_simple <- sqrt(0.104 * 0.896 / n_simple) * sqrt(2)
  cv_simple <- (se_simple / 0.104) * 100
  
  # Calcul correct
  n_men <- round(n_menages_estime * pct / 100)
  res_correct <- calculer_precision_menage(n_men, 0.95, 3.2, 0.98)
  
  comparison_data <- rbind(comparison_data, data.frame(
    Scenario = paste0(pct, "%"),
    Methode = "Simplifiée (ERREUR)",
    CV = cv_simple,
    Effectif = n_simple
  ), data.frame(
    Scenario = paste0(pct, "%"),
    Methode = "Correcte (3 niveaux)",
    CV = res_correct$cv_pct,
    Effectif = res_correct$n_individus_repondants
  ))
}

comparison_data$Scenario <- factor(comparison_data$Scenario, 
                                   levels = paste0(scenarios_pct, "%"))

# Graphique CV
p_cv <- ggplot(comparison_data, aes(x = Scenario, y = CV, fill = Methode, group = Methode)) +
  geom_col(position = "dodge", width = 0.7) +
  geom_hline(yintercept = 15, linetype = "dashed", color = "#E67E22", size = 1) +
  geom_text(aes(label = sprintf("%.1f%%", CV)), 
            position = position_dodge(width = 0.7), vjust = -0.5, size = 3) +
  scale_fill_manual(
    values = c("Simplifiée (ERREUR)" = "#FFC7CE", "Correcte (3 niveaux)" = "#C6E0B4"),
    name = "Méthode de calcul"
  ) +
  labs(
    title = "Impact de la Méthode de Calcul sur le CV",
    subtitle = "Comparaison : Calcul simplifié vs Calcul avec 3 niveaux de non-réponse",
    x = "Scénario (% ménages échantillonnés)",
    y = "Coefficient de Variation (%)",
    caption = "La méthode simplifiée SOUS-ESTIME le CV car elle ne prend pas en compte\ntous les niveaux de non-réponse (ménage + individuel)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11, color = "gray40"),
    plot.caption = element_text(size = 9, color = "red", hjust = 0),
    legend.position = "bottom"
  ) +
  annotate("text", x = 1, y = 15, label = "Seuil A/B (15%)", 
           hjust = 0, vjust = -0.5, size = 3.5, color = "#E67E22")

ggsave(file.path(plot_dir, "comparaison_methodes_calcul.png"), 
       p_cv, width = 12, height = 7, dpi = 300, bg = "white")

# Graphique Effectif
p_effectif <- ggplot(comparison_data, aes(x = Scenario, y = Effectif, fill = Methode)) +
  geom_col(position = "dodge", width = 0.7) +
  geom_text(aes(label = format(Effectif, big.mark = ",")), 
            position = position_dodge(width = 0.7), vjust = -0.5, size = 3) +
  scale_fill_manual(
    values = c("Simplifiée (ERREUR)" = "#FFC7CE", "Correcte (3 niveaux)" = "#C6E0B4"),
    name = "Méthode de calcul"
  ) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Différence d'Effectif Final selon la Méthode",
    subtitle = "L'effectif calculé est différent selon qu'on prend en compte ou non tous les niveaux de non-réponse",
    x = "Scénario (% ménages échantillonnés)",
    y = "Effectif final d'individus 15+ répondants"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11, color = "gray40"),
    legend.position = "bottom"
  )

ggsave(file.path(plot_dir, "comparaison_effectifs.png"), 
       p_effectif, width = 12, height = 7, dpi = 300, bg = "white")

cat("  ✓ Graphiques créés\n\n")

# ------------------------------------------------------------------------------
# 11. SYNTHÈSE
# ------------------------------------------------------------------------------
cat("═══════════════════════════════════════════════════════════════════════════\n")
cat("                    SIMULATEUR CORRIGÉ CRÉÉ                                \n")
cat("═══════════════════════════════════════════════════════════════════════════\n\n")

cat("📊 FICHIER PRINCIPAL:\n")
cat("  ✓", filename, "\n\n")

cat("🔧 CORRECTIONS APPORTÉES:\n")
cat("  1. ✅ Prise en compte de la non-réponse MÉNAGE\n")
cat("  2. ✅ Prise en compte de la taille des ménages (15+)\n")
cat("  3. ✅ Prise en compte de la non-réponse INDIVIDUELLE\n")
cat("  4. ✅ Calcul correct de l'effectif final\n\n")

cat("📁 CONTENU DU SIMULATEUR:\n")
cat("  • Onglet 1 : Paramètres (avec 3 niveaux de non-réponse)\n")
cat("  • Onglet 2 : Flux de calcul détaillé (étape par étape)\n")
cat("  • Onglet 3 : Résultats de précision + Comparaison avec ancien calcul\n")
cat("  • Onglet 4 : Sensibilité aux paramètres\n\n")

cat("📈 GRAPHIQUES:\n")
cat("  ✓ comparaison_methodes_calcul.png\n")
cat("  ✓ comparaison_effectifs.png\n\n")

cat("⚠️  DIFFÉRENCE CLÉS:\n")

# Calculer l'écart
res_ref_simple <- stats_reelles$n_individus_t3 * 0.997
res_ref_correct <- calculer_precision_menage(n_menages_estime, 0.95, 3.2, 0.98)$n_individus_repondants

cat("  Effectif (méthode simplifiée) :", round(res_ref_simple), "\n")
cat("  Effectif (méthode correcte)   :", res_ref_correct, "\n")
cat("  Différence                     :", round(res_ref_simple - res_ref_correct), 
    sprintf("(%.1f%%)\n", (res_ref_simple - res_ref_correct) / res_ref_simple * 100))
cat("\n")

cat("💡 PARAMÈTRES À AJUSTER SELON VOS DONNÉES RÉELLES:\n")
cat("  1. Taux de réponse ménage (défaut : 95%)\n")
cat("  2. Taille moyenne ménage 15+ (défaut : 3.2)\n")
cat("  3. Taux de réponse individuel (défaut : 98%)\n\n")

cat("═══════════════════════════════════════════════════════════════════════════\n\n")

message("✓ Simulateur corrigé prêt ! Prend en compte tous les niveaux de non-réponse.")