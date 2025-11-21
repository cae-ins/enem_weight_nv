# Stacked Bar Chart - Évolution de la formalité de l'emploi
# Load required libraries
library(ggplot2)
library(tidyr)

# Dataset
emploi_data <- data.frame(
  Periode = factor(
    c("T2-2024", "T3-2024", "T4-2024", "T1-2025", "T2-2025"),
    levels = c("T2-2024", "T3-2024", "T4-2024", "T1-2025", "T2-2025")
  ),
  Emploi_informel = c(84.8, 83.6, 82.8, 82.0, 80.8),
  Emploi_formel = c(15.2, 16.4, 17.2, 18.0, 19.2)
)

# Transform data to long format
emploi_long <- emploi_data %>%
  pivot_longer(cols = c(Emploi_informel, Emploi_formel), 
               names_to = "Type", 
               values_to = "Pourcentage")

# Rename for display
emploi_long$Type <- factor(emploi_long$Type,
                           levels = c("Emploi_formel", "Emploi_informel"),
                           labels = c("Emploi formel", "Emploi informel"))

# Create stacked bar chart
p <- ggplot(emploi_long, aes(x = Periode, y = Pourcentage, fill = Type)) +
  geom_bar(stat = "identity", width = 0.7) +
  geom_text(aes(label = paste0(Pourcentage, "%")), 
            position = position_stack(vjust = 0.5), 
            size = 11, 
            color = "black",
            fontface = "bold") +
  scale_fill_manual(values = c("Emploi formel" = "#BBDEFB", 
                               "Emploi informel" = "#1976D2")) +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 20)) +
  labs(title = "Évolution de la formalité de l'emploi",
       x = NULL,
       y = NULL,
       fill = NULL) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 24, face = "bold", hjust = 0.5),
    legend.position = "right",
    legend.text = element_text(size = 24),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text = element_text(size = 24)
  )

print(p)