# Line Chart - Taux de chômage par milieu de résidence
# Load required libraries
library(ggplot2)
library(tidyr)

# Dataset
chomage_milieu <- data.frame(
  Periode = factor(
    c("T2-2024", "T3-2024", "T4-2024", "T1-2025", "T2-2025"),
    levels = c("T2-2024", "T3-2024", "T4-2024", "T1-2025", "T2-2025")
  ),
  Abidjan = c(9.7, 4.1, 5.8, 6.0, 9.0),
  Autre_urbain = c(5.8, 8.5, 5.6, 4.7, 5.0),
  Rural = c(2.6, 2.8, 2.9, 2.6, 1.9)
)

# Transform data to long format for ggplot2
chomage_long <- chomage_milieu %>%
  pivot_longer(cols = c(Abidjan, Autre_urbain, Rural), 
               names_to = "Milieu", 
               values_to = "Taux")

# Rename for display
chomage_long$Milieu <- factor(chomage_long$Milieu,
                              levels = c("Abidjan", "Autre_urbain", "Rural"),
                              labels = c("Abidjan", "Autre urbain", "Rural"))

# Create line chart with previous style
p <- ggplot(chomage_long, aes(x = Periode, y = Taux, color = Milieu, group = Milieu)) +
  geom_line(size = 1.5) +
  geom_point(size = 4, shape = 15) +
  scale_color_manual(values = c("Abidjan" = "#C62828", 
                                "Autre urbain" = "#1565C0", 
                                "Rural" = "#2E7D32")) +
  scale_y_continuous(limits = c(0, 12), breaks = seq(0, 12, 2)) +
  labs(title = "Taux de chômage par milieu de résidence",
       subtitle = "% de la population",
       x = NULL,
       y = NULL) +
  theme_minimal() +
  theme(
    legend.position = "none",
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 14, color = "gray40"),
    panel.grid.minor = element_blank(),
    axis.text.y = element_blank(),
    axis.text.x = element_text(size = 24),
    panel.grid.major.y = element_blank(),
    plot.margin = margin(10, 80, 10, 80)
  ) +
  geom_text(data = chomage_long[chomage_long$Periode == "T2-2024", ],
            aes(label = Milieu, x = Periode, y = Taux),
            hjust = 1.5, size = 5, fontface = "bold") +
  geom_text(aes(label = Taux), vjust = -1, size = 7)

print(p)