# ============================================================
# Évolution de l'emploi vulnérable par sexe (sans axe Y)
# ============================================================

library(ggplot2)
library(tidyr)
library(dplyr)

# Données
emploi_vulnerable <- data.frame(
  Periode = factor(
    c("T2-2024", "T3-2024", "T4-2024", "T1-2025", "T2-2025"),
    levels = c("T2-2024", "T3-2024", "T4-2024", "T1-2025", "T2-2025")
  ),
  Masculin = c(69.2, 65.5, 65.8, 66.7, 66.3),
  Féminin = c(83.9, 84.1, 86.5, 83.2, 83.1)
)

# Format long
emploi_long <- emploi_vulnerable %>%
  pivot_longer(cols = c(Masculin, Féminin),
               names_to = "Sexe",
               values_to = "Taux")

# Couleurs
colors <- c("Masculin" = "#9E8B8E", "Féminin" = "#5DBCD2")

# Graphique
ggplot(emploi_long, aes(x = Periode, y = Taux, color = Sexe, group = Sexe)) +
  geom_line(size = 1.2) +
  geom_point(size = 2.8) +
  geom_text(
    aes(label = round(Taux, 1), color = Sexe),
    vjust = -1.1, size = 12, fontface = "bold"
  ) +
  scale_color_manual(values = colors) +
  scale_y_continuous(limits = c(60, 95), breaks = seq(60, 95, 5)) +
  theme_minimal(base_size = 30) +
  theme(
    axis.title = element_blank(),
    axis.text.y = element_blank(),       # <-- suppression des valeurs Y
    axis.ticks.y = element_blank(),      # <-- suppression des ticks Y
    axis.line.y = element_blank(),       # <-- suppression de la barre Y
    axis.text.x = element_text(color = "gray30"),
    panel.grid.major.x = element_line(color = "gray90"),  # repères verticaux conservés
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  ) +
  labs(title = "Évolution de l'emploi vulnérable par sexe") +
  geom_text(
    data = emploi_long %>% filter(Periode == "T2-2024"),
    aes(label = Sexe, color = Sexe),
    hjust = 1.2, fontface = "bold", size = 10
  )
