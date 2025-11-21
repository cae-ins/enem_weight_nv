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
graphe_su3_tidy <- donnees_su3 %>%
  # 1. Base du graphique
  tidyplot(
    x = Periode,
    y = Taux_SU3
  ) %>%
  # 2. Ajout des barres (geom_col)
  add_bar(
    fill = "grey50",
    width = 0.7 # Ajustement de la largeur
  ) %>%
  # 3. Ajout de la ligne et des points (geom_line + geom_point)
  # tidyplots combine ces deux géométries en une seule fonction
  add_line_points(
    size = 1.5,
    point_size = 3, # Taille du point
    colour = "black"
  ) %>%
  # 4. Ajout des étiquettes de données (geom_text)
  # Utilisation d'une fonction plus concise pour étiqueter
  add_riser_data_labels(
    y_labels_suffix = "%",
    nudge_y = 0.5, # Vjust = -0.5
    size = 4
  ) %>%
  # 5. Personnalisation des titres
  add_labs(
    title = "Évolution de la sous-utilisation de la main-d'œuvre (SU3)",
    y = "Taux SU3 (%)",
    x = "Période"
  ) %>%
  # 6. Ajout des lignes de quadrillage horizontales (simplifié)
  add_gridlines(
    direction = "horizontal",
    colour = "gray80",
    linetype = "dashed",
    linewidth = 0.5
  ) %>%
  # 7. Mise à l'échelle Y (utilise toujours ggplot2)
  scale_y_continuous(
    limits = c(0, 20),
    breaks = seq(0, 20, by = 2.5),
    expand = expansion(mult = c(0, 0.05))
  ) +
  # 8. Thème et ajustements finaux (utilise toujours ggplot2)
  theme_classic() +
  theme(
    axis.line.x = element_blank(),
    plot.title = element_text(hjust = 0.5, face = "bold")
  )

# Afficher le graphique
print(graphe_su3_tidy)
