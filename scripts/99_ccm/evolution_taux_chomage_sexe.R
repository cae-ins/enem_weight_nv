# Line Chart - Taux de Chômage
# Load required libraries
library(ggplot2)
library(tidyr)

# Dataset
chomage_data <- data.frame(
  Periode = factor(
    c("T2-2024", "T3-2024", "T4-2024", "T1-2025", "T2-2025"),
    levels = c("T2-2024", "T3-2024", "T4-2024", "T1-2025", "T2-2025")
  ),
  Ensemble = c(5.1, 5.1, 4.4, 4.0, 4.4),
  Masculin = c(2.9, 3.5, 2.9, 3.2, 3.7),
  Féminin = c(7.9, 6.8, 6.4, 4.8, 5.2) 
)

# Transform data to long format for ggplot2
chomage_long <- chomage_data %>%
  pivot_longer(cols = c(Ensemble, Masculin, Féminin), 
               names_to = "Categorie", 
               values_to = "Taux")

# Create line chart with labels on the right
p2 <- ggplot(chomage_long, aes(x = Periode, y = Taux, color = Categorie, group = Categorie)) +
  geom_line(size = 1.5) +
  geom_point(size = 4) +
  scale_color_manual(values = c("Global" = "#0077BE", 
                                "Masculin" = "#9E8B8E", 
                                "Féminin" = "#5DBCD2")) +
  scale_y_continuous(limits = c(0, 10), breaks = seq(0, 10, 2.5)) +
  labs(title = "Évolution du Taux de Chômage",
       subtitle = "% de la population",
       x = NULL,
       y = NULL) +
  theme_minimal() +
  theme(
    legend.position = "none",
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 11, color = "gray40"),
    panel.grid.minor = element_blank(),
    axis.text.y = element_blank(),
    axis.text.x = element_text(size = 16),
    panel.grid.major.y = element_blank(),
    plot.margin = margin(10, 80, 10, 10)
  ) +
  geom_text(data = chomage_long[chomage_long$Periode == "T2-2024", ],
            aes(label = Categorie, x = Periode, y = Taux),
            hjust = 1.5, size = 7, fontface = "bold") +
  geom_text(aes(label = Taux), vjust = -1, size = 4.5)

print(p2)