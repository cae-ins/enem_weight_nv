# =======================================================================
# 📊 GRAPHIQUE FINAL — Répartition de l'emploi (Barres empilées 100% transparentes)
# =======================================================================

library(ggplot2)
library(tidyr)
library(dplyr)
library(scales) 

# --- 1. Données ---
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

# --- 2. Format long ---
emploi_long <- emploi_secteur %>%
  pivot_longer(cols = -Periode, names_to = "Secteur", values_to = "Pourcentage") %>%
  mutate(
    Secteur = factor(
      Secteur,
      levels = c("Agriculture", "Industrie", "Commerce", "Services")
    )
  )

# --- 3. Palette transparente ---
couleurs_secteurs <- c(
  "Agriculture" = "#2C3E50",
  "Industrie"   = "#3498DB",
  "Commerce"    = "#95A5A6",
  "Services"    = "#16A085"
)

couleurs_transparentes <- scales::alpha(couleurs_secteurs, 0.7)

# --- 4. Graphique ---
p <- ggplot(emploi_long, aes(x = Periode, y = Pourcentage, fill = Secteur)) +
  
  geom_bar(stat = "identity", width = 0.7) +
  
  geom_hline(yintercept = 100, color = "gray20", linewidth = 0.3) +
  
  # ---- LABELS SANS % ----
geom_text(
  aes(label = sprintf("%.1f", Pourcentage)),
  position = position_stack(vjust = 0.5),
  size = 4,
  fontface = "bold",
  color = "white"
) +
  
  scale_fill_manual(values = couleurs_transparentes) +
  
  scale_y_continuous(
    limits = c(0, 105),
    breaks = seq(0, 100, 20),
    expand = c(0, 0)
  ) +
  
  labs(
    title = "Répartition de l'emploi par secteur d'activité",
    subtitle = "Structure en pourcentage de l'emploi total par trimestre (barres transparentes)",
    x = NULL,
    y = "Pourcentage (%)",
    fill = "Branche"
  ) +
  
  theme_minimal() +
  theme(
    plot.title = element_text(size = 15, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 11, color = "gray40", hjust = 0.5),
    legend.position = "bottom",
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10, face = "bold"),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "gray85", linetype = "dashed"),
    axis.text = element_text(size = 10),
    axis.title.y = element_text(size = 10)
  )

print(p)
