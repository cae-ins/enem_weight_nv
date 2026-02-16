# ======================================================================
# ANALYSE COMPARATIVE - IMPACT RÉDUCTION ÉCHANTILLON SUR PRÉCISION
# Génération graphiques + infographies + document Word
# ======================================================================

library(dplyr)
library(ggplot2)
library(tidyr)
library(officer)
library(flextable)
library(ggpubr)

# ----------------------------------------------------------------------
# PRÉPARATION DES DONNÉES
# ----------------------------------------------------------------------

# Données échantillon complet (100%)
data_100 <- tibble::tribble(
  ~Variable, ~CV, ~SE, ~IC_width, ~Moyenne,
  "SU1", 7.93, 0.0037, 0.0144, 0.0466,
  "SU2", 3.53, 0.0051, 0.0200, 0.1448,
  "SU3", 3.90, 0.0048, 0.0188, 0.1229,
  "SU4", 2.64, 0.0056, 0.0220, 0.2132
) %>% mutate(Scenario = "100% (Référence)")

# Données 75% gardés
data_75 <- tibble::tribble(
  ~Variable, ~CV, ~SE, ~IC_width, ~Moyenne,
  "SU1", 12.46, 0.00578, 0.022657, 0.046409,
  "SU2", 4.61, 0.006693, 0.026235, 0.145274,
  "SU3", 5.73, 0.007031, 0.027562, 0.122797,
  "SU4", 3.49, 0.007465, 0.029262, 0.213742
) %>% mutate(Scenario = "75% gardés (-25%)")

# Données 67% gardés
data_67 <- tibble::tribble(
  ~Variable, ~CV, ~SE, ~IC_width, ~Moyenne,
  "SU1", 11.99, 0.005483, 0.021492, 0.045639,
  "SU2", 4.66, 0.006765, 0.026517, 0.145264,
  "SU3", 5.72, 0.006978, 0.027355, 0.121938,
  "SU4", 3.56, 0.007601, 0.029797, 0.213599
) %>% mutate(Scenario = "67% gardés (-33%)")

# Données 50% gardés
data_50 <- tibble::tribble(
  ~Variable, ~CV, ~SE, ~IC_width, ~Moyenne,
  "SU1", 14.00, 0.006477, 0.025389, 0.04633,
  "SU2", 5.56, 0.008055, 0.031577, 0.144995,
  "SU3", 6.53, 0.008084, 0.031689, 0.123854,
  "SU4", 4.12, 0.008824, 0.03459, 0.2145
) %>% mutate(Scenario = "50% gardés (-50%)")

# Combiner toutes les données
data_combined <- bind_rows(data_100, data_75, data_67, data_50) %>%
  mutate(
    Scenario = factor(Scenario, levels = c("100% (Référence)", "75% gardés (-25%)", 
                                            "67% gardés (-33%)", "50% gardés (-50%)")),
    Perte_pct = case_when(
      Scenario == "100% (Référence)" ~ 0,
      Scenario == "75% gardés (-25%)" ~ 25,
      Scenario == "67% gardés (-33%)" ~ 33,
      Scenario == "50% gardés (-50%)" ~ 50
    )
  )

# ----------------------------------------------------------------------
# GRAPHIQUE 1 : ÉVOLUTION DU CV
# ----------------------------------------------------------------------

g1 <- ggplot(data_combined, aes(x = Perte_pct, y = CV, color = Variable, group = Variable)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  geom_hline(yintercept = 15, linetype = "dashed", color = "red", size = 1) +
  annotate("text", x = 40, y = 16, label = "Seuil acceptable CV = 15%", color = "red", size = 4) +
  scale_color_brewer(palette = "Set1") +
  labs(
    title = "Évolution du Coefficient de Variation selon la réduction d'échantillon",
    subtitle = "Impact de la perte d'échantillon sur la précision des estimations",
    x = "Perte d'échantillon (%)",
    y = "Coefficient de Variation (%)",
    color = "Variable",
    caption = "Source : Simulation LFS T3 2025"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom"
  )

ggsave("graphique_evolution_CV.png", g1, width = 10, height = 6, dpi = 300)

# ----------------------------------------------------------------------
# GRAPHIQUE 2 : ÉLARGISSEMENT DES IC
# ----------------------------------------------------------------------

g2 <- ggplot(data_combined, aes(x = Perte_pct, y = IC_width, color = Variable, group = Variable)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  scale_color_brewer(palette = "Set1") +
  labs(
    title = "Élargissement des Intervalles de Confiance (95%)",
    subtitle = "Plus l'échantillon diminue, plus l'incertitude augmente",
    x = "Perte d'échantillon (%)",
    y = "Largeur de l'Intervalle de Confiance",
    color = "Variable",
    caption = "Source : Simulation LFS T3 2025"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom"
  )

ggsave("graphique_evolution_IC.png", g2, width = 10, height = 6, dpi = 300)

# ----------------------------------------------------------------------
# GRAPHIQUE 3 : AUGMENTATION DE L'ERREUR STANDARD
# ----------------------------------------------------------------------

g3 <- ggplot(data_combined, aes(x = Perte_pct, y = SE, color = Variable, group = Variable)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  scale_color_brewer(palette = "Set1") +
  labs(
    title = "Augmentation de l'Erreur Standard",
    subtitle = "Dégradation de la précision avec la réduction d'échantillon",
    x = "Perte d'échantillon (%)",
    y = "Erreur Standard (SE)",
    color = "Variable",
    caption = "Source : Simulation LFS T3 2025"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom"
  )

ggsave("graphique_evolution_SE.png", g3, width = 10, height = 6, dpi = 300)

# ----------------------------------------------------------------------
# GRAPHIQUE 4 : BARPLOT COMPARATIF CV PAR VARIABLE
# ----------------------------------------------------------------------

g4 <- ggplot(data_combined, aes(x = Variable, y = CV, fill = Scenario)) +
  geom_col(position = "dodge", alpha = 0.8) +
  geom_hline(yintercept = 15, linetype = "dashed", color = "red", size = 1) +
  scale_fill_brewer(palette = "Blues") +
  labs(
    title = "Comparaison des CV par variable et scénario",
    subtitle = "Tous les scénarios restent sous le seuil de 15%",
    x = "Variable",
    y = "Coefficient de Variation (%)",
    fill = "Scénario",
    caption = "Source : Simulation LFS T3 2025"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom"
  )

ggsave("graphique_barplot_CV.png", g4, width = 10, height = 6, dpi = 300)

# ----------------------------------------------------------------------
# GRAPHIQUE 5 : HEATMAP DE LA DÉGRADATION
# ----------------------------------------------------------------------

# Calculer la dégradation relative par rapport à 100%
data_degradation <- data_combined %>%
  select(Variable, Scenario, CV, SE, IC_width) %>%
  pivot_longer(cols = c(CV, SE, IC_width), names_to = "Metric", values_to = "Value") %>%
  group_by(Variable, Metric) %>%
  mutate(
    Reference = Value[Scenario == "100% (Référence)"],
    Degradation_pct = ((Value - Reference) / Reference) * 100
  ) %>%
  filter(Scenario != "100% (Référence)")

g5 <- ggplot(data_degradation, aes(x = Scenario, y = Variable, fill = Degradation_pct)) +
  geom_tile(color = "white", size = 1) +
  geom_text(aes(label = paste0("+", round(Degradation_pct, 0), "%")), color = "white", size = 4, fontface = "bold") +
  scale_fill_gradient2(low = "green", mid = "yellow", high = "red", midpoint = 40) +
  facet_wrap(~Metric, labeller = as_labeller(c(CV = "Coefficient de Variation", 
                                                 SE = "Erreur Standard", 
                                                 IC_width = "Largeur IC"))) +
  labs(
    title = "Dégradation relative par rapport à l'échantillon complet (100%)",
    subtitle = "Augmentation en % de chaque métrique de précision",
    x = "Scénario de réduction",
    y = "Variable",
    fill = "Dégradation (%)",
    caption = "Source : Simulation LFS T3 2025"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom",
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave("graphique_heatmap_degradation.png", g5, width = 12, height = 6, dpi = 300)

# ----------------------------------------------------------------------
# GRAPHIQUE 6 : PANEL COMBINÉ (INFOGRAPHIE)
# ----------------------------------------------------------------------

g_panel <- ggarrange(g1, g2, g3, g4, 
                     ncol = 2, nrow = 2,
                     common.legend = TRUE, legend = "bottom")

g_panel_annotated <- annotate_figure(g_panel,
                top = text_grob("Impact de la réduction d'échantillon sur la précision des indicateurs SU", 
                               face = "bold", size = 16),
                bottom = text_grob("Source : Simulation LFS T3 2025 | 30 itérations par scénario", 
                                  hjust = 1, x = 1, size = 10))

ggsave("infographie_panel_complet.png", g_panel_annotated, width = 16, height = 12, dpi = 300)

# ----------------------------------------------------------------------
# CRÉATION DU DOCUMENT WORD
# ----------------------------------------------------------------------

# Créer le document
doc <- read_docx()

# Page de titre
doc <- doc %>%
  body_add_par("ANALYSE DE L'IMPACT DE LA RÉDUCTION D'ÉCHANTILLON", style = "heading 1") %>%
  body_add_par("Sur la précision des indicateurs du marché du travail", style = "heading 2") %>%
  body_add_par(" ") %>%
  body_add_par(paste("Enquête LFS - Trimestre T3 2025"), style = "Normal") %>%
  body_add_par(paste("Date :", Sys.Date()), style = "Normal") %>%
  body_add_break()

# Section 1 : Introduction
doc <- doc %>%
  body_add_par("1. CONTEXTE ET OBJECTIFS", style = "heading 1") %>%
  body_add_par("Cette analyse compare la précision des estimations pour quatre indicateurs de sous-emploi (SU1 à SU4) selon différents scénarios de réduction d'échantillon :", style = "Normal") %>%
  body_add_par(" ") %>%
  body_add_par("  • Scénario de référence : Échantillon complet (100%)", style = "Normal") %>%
  body_add_par("  • Scénario 1 : 75% de l'échantillon gardé (perte de 25%)", style = "Normal") %>%
  body_add_par("  • Scénario 2 : 67% de l'échantillon gardé (perte de 33%)", style = "Normal") %>%
  body_add_par("  • Scénario 3 : 50% de l'échantillon gardé (perte de 50%)", style = "Normal") %>%
  body_add_par(" ") %>%
  body_add_par("Chaque scénario de réduction a été simulé sur 30 itérations indépendantes avec calibration des poids.", style = "Normal") %>%
  body_add_break()

# Section 2 : Tableau 1 - Évolution du CV
doc <- doc %>%
  body_add_par("2. ÉVOLUTION DU COEFFICIENT DE VARIATION (CV)", style = "heading 1") %>%
  body_add_par("Le CV mesure la précision relative de l'estimation. Un CV < 15% est considéré comme acceptable.", style = "Normal") %>%
  body_add_par(" ")

# Créer le tableau 1
tab1_data <- data_combined %>%
  select(Variable, Scenario, CV) %>%
  pivot_wider(names_from = Scenario, values_from = CV) %>%
  mutate(
    `Dégradation totale` = `50% gardés (-50%)` - `100% (Référence)`,
    `Dégradation (%)` = round((`50% gardés (-50%)` - `100% (Référence)`) / `100% (Référence)` * 100, 0)
  )

ft1 <- flextable(tab1_data) %>%
  set_header_labels(
    Variable = "Variable",
    `100% (Référence)` = "100%\n(Référence)",
    `75% gardés (-25%)` = "75% gardés\n(-25%)",
    `67% gardés (-33%)` = "67% gardés\n(-33%)",
    `50% gardés (-50%)` = "50% gardés\n(-50%)",
    `Dégradation totale` = "Dégradation\n(points)",
    `Dégradation (%)` = "Dégradation\n(%)"
  ) %>%
  theme_booktabs() %>%
  align(align = "center", part = "all") %>%
  bold(part = "header") %>%
  bg(bg = "#4472C4", part = "header") %>%
  color(color = "white", part = "header") %>%
  fontsize(size = 10, part = "all") %>%
  autofit()

doc <- doc %>%
  body_add_flextable(ft1) %>%
  body_add_par(" ") %>%
  body_add_par("Points clés :", style = "heading 3") %>%
  body_add_par("  • Tous les CV restent sous le seuil de 15% même avec 50% de perte d'échantillon", style = "Normal") %>%
  body_add_par("  • La dégradation varie de +56% à +77% selon la variable", style = "Normal") %>%
  body_add_par("  • SU1 est la variable la plus affectée, SU4 la plus robuste", style = "Normal") %>%
  body_add_break()

# Ajouter le graphique 1
doc <- doc %>%
  body_add_par("Graphique 1 : Évolution du CV selon la réduction d'échantillon", style = "heading 3") %>%
  body_add_img("graphique_evolution_CV.png", width = 6, height = 4) %>%
  body_add_break()

# Section 3 : Tableau 2 - Élargissement des IC
doc <- doc %>%
  body_add_par("3. ÉLARGISSEMENT DES INTERVALLES DE CONFIANCE", style = "heading 1") %>%
  body_add_par("La largeur de l'intervalle de confiance (IC à 95%) mesure l'incertitude de l'estimation.", style = "Normal") %>%
  body_add_par(" ")

tab2_data <- data_combined %>%
  select(Variable, Scenario, IC_width) %>%
  pivot_wider(names_from = Scenario, values_from = IC_width) %>%
  mutate(
    `Élargissement absolu` = round(`50% gardés (-50%)` - `100% (Référence)`, 4),
    `Élargissement (%)` = round((`50% gardés (-50%)` - `100% (Référence)`) / `100% (Référence)` * 100, 0)
  )

ft2 <- flextable(tab2_data) %>%
  set_header_labels(
    Variable = "Variable",
    `100% (Référence)` = "100%\n(Référence)",
    `75% gardés (-25%)` = "75% gardés\n(-25%)",
    `67% gardés (-33%)` = "67% gardés\n(-33%)",
    `50% gardés (-50%)` = "50% gardés\n(-50%)",
    `Élargissement absolu` = "Élargissement\n(absolu)",
    `Élargissement (%)` = "Élargissement\n(%)"
  ) %>%
  theme_booktabs() %>%
  align(align = "center", part = "all") %>%
  bold(part = "header") %>%
  bg(bg = "#4472C4", part = "header") %>%
  color(color = "white", part = "header") %>%
  fontsize(size = 10, part = "all") %>%
  autofit()

doc <- doc %>%
  body_add_flextable(ft2) %>%
  body_add_par(" ") %>%
  body_add_par("Points clés :", style = "heading 3") %>%
  body_add_par("  • Les intervalles de confiance s'élargissent de 57% à 76% avec une perte de 50%", style = "Normal") %>%
  body_add_par("  • L'incertitude augmente mais reste maîtrisée", style = "Normal") %>%
  body_add_par("  • Impact le plus fort sur SU1 (+76%), le plus faible sur SU4 (+57%)", style = "Normal") %>%
  body_add_break()

# Ajouter le graphique 2
doc <- doc %>%
  body_add_par("Graphique 2 : Élargissement des IC selon la réduction", style = "heading 3") %>%
  body_add_img("graphique_evolution_IC.png", width = 6, height = 4) %>%
  body_add_break()

# Section 4 : Tableau 3 - Augmentation SE
doc <- doc %>%
  body_add_par("4. AUGMENTATION DE L'ERREUR STANDARD", style = "heading 1") %>%
  body_add_par("L'erreur standard (SE) quantifie la variabilité de l'estimation.", style = "Normal") %>%
  body_add_par(" ")

tab3_data <- data_combined %>%
  select(Variable, Scenario, SE) %>%
  pivot_wider(names_from = Scenario, values_from = SE) %>%
  mutate(
    `Augmentation absolue` = round(`50% gardés (-50%)` - `100% (Référence)`, 5),
    `Facteur multiplicateur` = round(`50% gardés (-50%)` / `100% (Référence)`, 2)
  )

ft3 <- flextable(tab3_data) %>%
  set_header_labels(
    Variable = "Variable",
    `100% (Référence)` = "100%\n(Référence)",
    `75% gardés (-25%)` = "75% gardés\n(-25%)",
    `67% gardés (-33%)` = "67% gardés\n(-33%)",
    `50% gardés (-50%)` = "50% gardés\n(-50%)",
    `Augmentation absolue` = "Augmentation\n(absolu)",
    `Facteur multiplicateur` = "Facteur\nmultiplicateur"
  ) %>%
  theme_booktabs() %>%
  align(align = "center", part = "all") %>%
  bold(part = "header") %>%
  bg(bg = "#4472C4", part = "header") %>%
  color(color = "white", part = "header") %>%
  fontsize(size = 10, part = "all") %>%
  autofit()

doc <- doc %>%
  body_add_flextable(ft3) %>%
  body_add_par(" ") %>%
  body_add_par("Points clés :", style = "heading 3") %>%
  body_add_par("  • L'erreur standard est multipliée par 1,6 à 1,8 avec une perte de 50%", style = "Normal") %>%
  body_add_par("  • SU1 subit la plus forte augmentation (×1,76)", style = "Normal") %>%
  body_add_par("  • SU4 est le plus stable (×1,57)", style = "Normal") %>%
  body_add_break()

# Ajouter le graphique 3
doc <- doc %>%
  body_add_par("Graphique 3 : Augmentation de l'erreur standard", style = "heading 3") %>%
  body_add_img("graphique_evolution_SE.png", width = 6, height = 4) %>%
  body_add_break()

# Section 5 : Heatmap
doc <- doc %>%
  body_add_par("5. VUE D'ENSEMBLE : HEATMAP DE LA DÉGRADATION", style = "heading 1") %>%
  body_add_par("Visualisation synthétique de l'augmentation de chaque métrique par rapport à la référence (100%).", style = "Normal") %>%
  body_add_par(" ") %>%
  body_add_img("graphique_heatmap_degradation.png", width = 7, height = 4) %>%
  body_add_break()

# Section 6 : Conclusions
doc <- doc %>%
  body_add_par("6. CONCLUSIONS ET RECOMMANDATIONS", style = "heading 1") %>%
  body_add_par(" ") %>%
  body_add_par("Synthèse des résultats", style = "heading 2") %>%
  body_add_par("L'analyse de l'impact de la réduction d'échantillon sur la précision des estimations révèle les constats suivants :", style = "Normal") %>%
  body_add_par(" ") %>%
  body_add_par("  1. Dégradation contrôlée : Même avec une perte de 50% de l'échantillon, tous les coefficients de variation restent sous le seuil acceptable de 15%.", style = "Normal") %>%
  body_add_par("  2. Impact modéré : Les CV augmentent de 56% à 77%, les IC s'élargissent de 57% à 76%, et les SE sont multipliés par 1,6 à 1,8.", style = "Normal") %>%
  body_add_par("  3. Variabilité entre indicateurs : SU1 est le plus affecté par la réduction, tandis que SU4 reste le plus robuste.", style = "Normal") %>%
  body_add_par("  4. Progression non-linéaire : La plus grande dégradation se produit lors du passage de 100% à 75%, puis la perte de précision ralentit.", style = "Normal") %>%
  body_add_par(" ") %>%
  body_add_par("Recommandations", style = "heading 2") %>%
  body_add_par("  ✅ Scénario optimal : Conserver 75% de l'échantillon (perte de 25%) offre le meilleur compromis entre réduction des coûts et maintien de la précision.", style = "Normal") %>%
  body_add_par(" ") %>%
  body_add_par("  ⚠️ Scénario limite : Une réduction à 50% reste techniquement acceptable (CV < 15%) mais approche les limites de précision souhaitables.", style = "Normal") %>%
  body_add_par(" ") %>%
  body_add_par("  ❌ Déconseillé : Toute réduction au-delà de 50% risquerait de dépasser le seuil de CV de 15% pour certains indicateurs.", style = "Normal") %>%
  body_add_par(" ") %>%
  body_add_par("Implications opérationnelles", style = "heading 2") %>%
  body_add_par("  • Une réduction de 25% de l'échantillon permettrait des économies substantielles sur la collecte tout en maintenant une précision excellente.", style = "Normal") %>%
  body_add_par("  • La calibration des poids fonctionne efficacement même avec des échantillons réduits.", style = "Normal") %>%
  body_add_par("  • Le plan de sondage actuel est robuste face à une réduction modérée de la taille d'échantillon.", style = "Normal")

# Sauvegarder le document
print(doc, target = "Analyse_Impact_Reduction_Echantillon_LFS_T3_2025.docx")

cat("\n=== GÉNÉRATION TERMINÉE ===\n")
cat("Fichiers créés :\n")
cat("  - graphique_evolution_CV.png\n")
cat("  - graphique_evolution_IC.png\n")
cat("  - graphique_evolution_SE.png\n")
cat("  - graphique_barplot_CV.png\n")
cat("  - graphique_heatmap_degradation.png\n")
cat("  - infographie_panel_complet.png\n")
cat("  - Analyse_Impact_Reduction_Echantillon_LFS_T3_2025.docx\n")