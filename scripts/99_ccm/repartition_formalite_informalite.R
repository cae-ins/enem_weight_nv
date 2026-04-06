library(ggplot2)
library(tidyr)
library(dplyr)

# --- Données ---
emploi_data <- data.frame(
  Periode = factor(
    c("T2-2024", "T3-2024", "T4-2024", "T1-2025", "T2-2025"),
    levels = c("T2-2024", "T3-2024", "T4-2024", "T1-2025", "T2-2025")
  ),
  Emploi_informel = c(84.8, 83.6, 82.8, 82.0, 80.8),
  Emploi_formel = c(15.2, 16.4, 17.2, 18.0, 19.2)
)

# --- Format long ---
emploi_long <- emploi_data %>%
  pivot_longer(
    cols = c(Emploi_informel, Emploi_formel),
    names_to = "Type",
    values_to = "Pourcentage"
  ) %>%
  mutate(
    Type = factor(
      Type,
      levels = c("Emploi_formel", "Emploi_informel"),
      labels = c("Emploi formel", "Emploi informel")
    )
  )

# --- Graphique ---
p <- ggplot(emploi_long, aes(x = Periode, y = Pourcentage, fill = Type)) +
  geom_bar(
    stat = "identity",
    width = 0.7,
    alpha = 0.65    # -------- TRANSPARENCE DES BARRES --------
  ) +
  
  geom_text(
    aes(label = sprintf("%.1f", Pourcentage)),
    position = position_stack(vjust = 0.5),
    size = 8,
    color = "black",
    fontface = "bold"
  ) +
  
  scale_fill_manual(values = c(
    "Emploi formel" = "#BBDEFB",
    "Emploi informel" = "#1976D2"
  )) +
  
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(0, 100, 20),
    expand = expansion(mult = c(0, 0))
  ) +
  
  labs(
    title = "Évolution de la formalité de l'emploi",
    x = NULL,
    y = "Pourcentage (%)",
    fill = NULL
  ) +
  
  theme_minimal() +
  theme(
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    legend.position = "right",
    legend.text = element_text(size = 20),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text = element_text(size = 18)
  )

print(p)
