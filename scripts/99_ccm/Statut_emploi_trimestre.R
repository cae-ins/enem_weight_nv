library(ggplot2)
library(tidyr)
library(dplyr)

# --- Données ---
emploi_statut <- data.frame(
  Periode = factor(
    c("T2-2024", "T3-2024", "T4-2024", "T1-2025", "T2-2025"),
    levels = c("T2-2024", "T3-2024", "T4-2024", "T1-2025", "T2-2025")
  ),
  Employeur = c(1.49, 0.63, 2.76, 1.61, 2.77),
  Travailleurs_independants = c(67.14, 65.34, 64.50, 64.60, 65.08),
  Non_salaries_dependants = c(2.82, 4.48, 3.20, 3.08, 3.65),
  Employes = c(20.75, 21.21, 22.46, 23.48, 21.66),
  Travailleurs_familiaux = c(7.80, 8.34, 7.08, 7.23, 6.84)
)

# --- Passage au format long ---
emploi_long <- emploi_statut %>%
  pivot_longer(
    cols = -Periode,
    names_to = "Statut",
    values_to = "Pourcentage"
  ) %>%
  mutate(
    Statut = factor(
      Statut,
      levels = c(
        "Travailleurs_familiaux",
        "Employes",
        "Non_salaries_dependants",
        "Travailleurs_independants",
        "Employeur"
      ),
      labels = c(
        "Travailleurs familiaux",
        "Employés",
        "Non-salariés dépendants",
        "Travailleurs indépendants sans employés",
        "Employeur"
      )
    )
  )

# --- Palette ---
palette_statut <- c(
  "Employeur" = "#2C3E50",
  "Travailleurs indépendants sans employés" = "#3498DB",
  "Non-salariés dépendants" = "#95A5A6",
  "Employés" = "#16A085",
  "Travailleurs familiaux" = "#5D6D7E"
)

# --- Graphique ---
p <- ggplot(emploi_long, aes(x = Periode, y = Pourcentage, fill = Statut)) +
  geom_bar(stat = "identity", width = 0.72) +
  
  # ------- ÉTIQUETTES SANS % --------
geom_text(
  aes(label = sprintf("%.1f", Pourcentage)),
  position = position_stack(vjust = 0.5),
  size = 4,
  color = "white",
  fontface = "bold"
) +
  # -----------------------------------

scale_fill_manual(values = palette_statut) +
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(0, 100, 20),
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "",
    subtitle = "",
    y = "Pourcentage (%)",
    x = NULL,
    fill = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(size = 15, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 14, hjust = 0.5, color = "gray40"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "right",
    plot.margin = margin(12, 15, 12, 15)
  )

print(p)
