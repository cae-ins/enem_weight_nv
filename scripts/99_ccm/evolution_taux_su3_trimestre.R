library(ggplot2)
library(dplyr)
library(tidyplots) # Assurez-vous d'avoir installé et chargé tidyplots

# --- Préparation des données (Identique) ---
donnees_su3 <- data.frame(
  Periode = factor(
    c("T2-2024", "T3-2024", "T4-2024", "T1-2025", "T2-2025"),
    levels = c("T2-2024", "T3-2024", "T4-2024", "T1-2025", "T2-2025")
  ),
  # Utilisation des valeurs de votre code (T2-2025 = 13.4)
  Taux_SU3 = c(13.8, 15.3, 13.9, 13.0, 13.4)
)

# --- Génération du graphique avec tidyplots ---
# --- Génération du graphique avec ggplot2 standard ---
graphe_su3_tidy <- ggplot(donnees_su3, aes(x = Periode, y = Taux_SU3)) +
  # 1. Barres (geom_col)
  geom_col(fill = "grey50", width = 0.7) +
  # 2. Ligne et points (geom_line + geom_point)
  geom_line(aes(group = 1), size = 1.5, colour = "black") +
  geom_point(size = 3, colour = "black") +
  # 3. Étiquettes de données (geom_text)
  geom_text(aes(label = Taux_SU3), vjust = -1, size = 4) +
  # 4. Titres
  labs(
    title = "Évolution de la sous-utilisation de la main-d'œuvre (SU3)",
    y = "Taux SU3 (%)",
    x = "Période"
  ) +
  # 5. Mise à l'échelle Y
  scale_y_continuous(
    limits = c(0, 20),
    breaks = seq(0, 20, by = 2.5),
    expand = expansion(mult = c(0, 0.05))
  ) +
  # 6. Thème et ajustements finaux
  theme_classic() +
  theme(
    axis.line.x = element_blank(),
    plot.title = element_text(hjust = 0.5, face = "bold"),
    panel.grid.major.y = element_line(colour = "gray80", linetype = "dashed", linewidth = 0.5)
  )

# Afficher le graphique
print(graphe_su3_tidy)
