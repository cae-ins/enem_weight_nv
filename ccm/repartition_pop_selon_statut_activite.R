# =======================================================================
# Répartition emploi / chômage / hors main d'œuvre - Barres empilées 100 %
# (Version professionnelle avec transparence + labels sans %)
# =======================================================================

library(ggplot2)
library(tidyr)
library(dplyr)

# -----------------------------------------------------------------------
# Données
# -----------------------------------------------------------------------
proportion_data <- data.frame(
  Periode = factor(
    c("T2-2024", "T3-2024", "T4-2024", "T1-2025", "T2-2025"),
    levels = c("T2-2024", "T3-2024", "T4-2024", "T1-2025", "T2-2025")
  ),
  Emploi = c(68.11, 67.73, 68.27, 66.97, 68.23),
  Chomage = c(3.61, 3.57, 3.15, 2.75, 3.11),
  Hors_main = c(28.28, 28.70, 28.58, 30.28, 28.67)
)

# Transformation au format long
data_long <- proportion_data %>%
  pivot_longer(cols = c(Emploi, Chomage, Hors_main),
               names_to = "Categorie",
               values_to = "Pourcentage")

# Ordre et étiquettes des catégories
data_long$Categorie <- factor(
  data_long$Categorie,
  levels = c("Hors_main", "Chomage", "Emploi"),
  labels = c("Hors main d'œuvre", "Chômage", "Emploi")
)

# -----------------------------------------------------------------------
# Graphique
# -----------------------------------------------------------------------
ggplot(data_long, aes(x = Periode, y = Pourcentage, fill = Categorie)) +
  geom_bar(stat = "identity", width = 0.7, alpha = 0.70) +  # transparence légère
  
  # ❗ Labels SANS le signe %
  geom_text(
    aes(label = sprintf("%.1f", Pourcentage)),
    position = position_stack(vjust = 0.5),
    color = "black", size = 7, fontface = "bold"
  ) +
  
  scale_fill_manual(values = c(
    "Emploi" = "#1B4F72",        # Bleu foncé institutionnel
    "Chômage" = "#A93226",       # Rouge bordeaux
    "Hors main d'œuvre" = "#BDC3C7"  # Gris clair neutre
  )) +
  
  scale_y_continuous(labels = NULL, breaks = NULL, expand = c(0, 0)) +
  
  labs(
    title = "Répartition de la population selon le statut d'activité",
    subtitle = "En proportion du total (100)",
    x = NULL, y = NULL, fill = NULL
  ) +
  
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
    plot.subtitle = element_text(color = "gray40", hjust = 0.5, margin = margin(b = 10)),
    legend.position = "bottom",
    legend.text = element_text(size = 10),
    panel.grid = element_blank(),
    axis.text.x = element_text(size = 11, face = "bold"),
    plot.margin = margin(15, 15, 10, 15)
  )
