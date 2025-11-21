# =======================================================================
# 📊 GRAPHIQUE FINAL : Répartition de l'emploi (Barres empilées 100% transparentes)
# =======================================================================

# --- 1. Librairies ---
library(ggplot2)
library(tidyr)
library(dplyr)
library(scales) # Nécessaire pour ajuster la transparence (scales::alpha)

# --- 2. Données ---
emploi_secteur <- data.frame(
  Periode = factor(
    c("T2-2024", "T3-2024", "T4-2024", "T1-2025", "T2-2025"),
    levels = c("T2-2024", "T3-2024", "T4-2024", "T1-2025", "T2-2025")
  ),
  Agriculture = c(41.34, 41.38, 42.9, 41.06, 41.49),
  Industrie   = c(13.59, 11.99, 10.3, 13.59, 13.43),
  Commerce    = c(17.73, 19.38, 18.8, 16.95, 18.00),
  Services    = c(27.34, 27.25, 28.0, 28.39, 27.09)
)

# --- 3. Transformation des données pour ggplot2 ---

# Transformation en format long (uniquement nécessaire pour ggplot)
emploi_long <- emploi_secteur %>%
  pivot_longer(cols = -Periode, names_to = "Secteur", values_to = "Pourcentage")

# Définition de l'ordre d'empilement (du bas vers le haut)
emploi_long$Secteur <- factor(
  emploi_long$Secteur,
  levels = c("Agriculture", "Industrie", "Commerce", "Services")
)


# --- 4. Palette de Couleurs AVEC Transparence ---

# Palette de couleurs originales (codes hexadécimaux)
couleurs_secteurs_orig <- c(
  "Agriculture" = "#2C3E50", 
  "Industrie"   = "#3498DB", 
  "Commerce"    = "#95A5A6", 
  "Services"    = "#16A085"  
)

# Application de la transparence (alpha = 0.7 pour 70% d'opacité)
couleurs_transparentes <- scales::alpha(couleurs_secteurs_orig, alpha = 0.7)


# --- 5. Graphique ggplot2 ---
p <- ggplot(emploi_long, aes(x = Periode, y = Pourcentage, fill = Secteur)) +
  
  # Barres empilées (avec couleurs transparentes)
  geom_bar(stat = "identity", width = 0.7) +
  
  # Ligne de référence à 100%
  geom_hline(yintercept = 100, color = "gray20", linetype = "solid", linewidth = 0.3) +
  
  # Étiquettes de pourcentage (couleur blanche opaque pour la lisibilité)
  geom_text(
    aes(label = paste0(sprintf("%.1f", Pourcentage), "%")),
    position = position_stack(vjust = 0.5),
    size = 3.6,
    fontface = "bold",
    color = "white"
  ) +
  
  # Échelles et Labels
  scale_fill_manual(values = couleurs_transparentes) + # <-- Utilisation de la palette transparente
  scale_y_continuous(
    limits = c(0, 105),
    breaks = seq(0, 100, 20),
    expand = c(0, 0)
  ) +
  labs(
    title = "Répartition de l'emploi par secteur d'activité",
    subtitle = "Structure en pourcentage de l'emploi total par trimestre (Couleurs transparentes)",
    x = NULL,
    y = "Pourcentage (%)",
    fill = "Branche"
  ) +
  
  # Thème
  theme_minimal(base_family = "sans") +
  theme(
    plot.title = element_text(size = 15, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 11, color = "gray40", hjust = 0.5, margin = margin(b = 10)),
    legend.position = "bottom",
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10, face = "bold"),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "gray85", linetype = "dashed"),
    axis.title.y = element_text(size = 10, margin = margin(r = 10)),
    axis.text = element_text(size = 10),
    plot.margin = margin(15, 15, 15, 15)
  )

# Affichage du graphique
print(p)