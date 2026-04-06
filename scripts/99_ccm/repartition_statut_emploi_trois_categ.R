# Stacked Bar Chart 100% - Répartition par statut
# Load required libraries
library(ggplot2)
library(tidyr)

# Dataset
repartition_data <- data.frame(
  Periode = factor(
    c("T2-2024", "T3-2024", "T4-2024", "T1-2025", "T2-2025"),
    levels = c("T2-2024", "T3-2024", "T4-2024", "T1-2025", "T2-2025")
  ),
  Travailleurs_independants = c(68.17, 65.89, 66.03, 65.38, 67.34),
  Travailleurs_dependants = c(30.93, 33.71, 33.76, 34.40, 32.43),
  Non_classe = c(0.90, 0.41, 0.20, 0.22, 0.23)
)

# Transform data to long format
data_long <- repartition_data %>%
  pivot_longer(cols = c(Travailleurs_independants, Travailleurs_dependants, Non_classe), 
               names_to = "Categorie", 
               values_to = "Pourcentage")

# Set factor levels for proper stacking order (bottom to top)
data_long$Categorie <- factor(data_long$Categorie,
                              levels = c("Non_classe", "Travailleurs_dependants", "Travailleurs_independants"),
                              labels = c("Non classé", "Travailleurs dépendants", "Travailleurs indépendants"))

# Create stacked bar chart at 100%
p <- ggplot(data_long, aes(x = Periode, y = Pourcentage, fill = Categorie)) +
  geom_bar(stat = "identity", width = 0.7, position = "stack", alpha = 0.85) +
  geom_text(aes(label = paste0(sprintf("%.2f", Pourcentage), "%")), 
            position = position_stack(vjust = 0.5), 
            size = 3.5,
            color = "white",
            fontface = "bold") +
  scale_fill_manual(values = c("Travailleurs indépendants" = "#2C3E50", 
                               "Travailleurs dépendants" = "#3498DB", 
                               "Non classé" = "#95A5A6")) +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 20)) +
  labs(title = "Répartition par statut dans l'emploi",
       subtitle = "Distribution en pourcentage",
       x = NULL,
       y = "Pourcentage (%)",
       fill = NULL) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 15, face = "bold", hjust = 0.5, margin = margin(b = 5)),
    plot.subtitle = element_text(size = 11, color = "gray40", hjust = 0.5, margin = margin(b = 15)),
    legend.position = "right",
    legend.text = element_text(size = 11),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    axis.title.y = element_text(size = 11, margin = margin(r = 10)),
    axis.text = element_text(size = 10),
    plot.margin = margin(15, 15, 15, 15)
  )

print(p)
