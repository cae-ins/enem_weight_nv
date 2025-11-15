# Stacked Bar Chart 100% - Répartition de l'emploi par statut
# Load required libraries
library(ggplot2)
library(tidyr)

# Dataset
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

# Transform data to long format
emploi_long <- emploi_statut %>%
  pivot_longer(cols = c(Employeur, Travailleurs_independants, Non_salaries_dependants, 
                        Employes, Travailleurs_familiaux), 
               names_to = "Statut", 
               values_to = "Pourcentage")

# Rename for display
emploi_long$Statut <- factor(emploi_long$Statut,
                             levels = c("Travailleurs_familiaux", "Employes", 
                                        "Non_salaries_dependants", "Travailleurs_independants", 
                                        "Employeur"),
                             labels = c("Travailleurs familiaux", "Employés", 
                                        "Non-salariés (Entrepreneurs) dépendants",
                                        "Travailleurs indépendants sans employés", 
                                        "Employeur"))

# Create stacked bar chart at 100%
p <- ggplot(emploi_long, aes(x = Periode, y = Pourcentage, fill = Statut)) +
  geom_bar(stat = "identity", width = 0.7, position = "stack") +
  geom_text(aes(label = paste0(sprintf("%.1f", Pourcentage), "%")), 
            position = position_stack(vjust = 0.5), 
            size = 7,
            color = "white",
            fontface = "bold") +
  scale_fill_manual(values = c("Employeur" = "#2C3E50", 
                               "Travailleurs indépendants sans employés" = "#3498DB", 
                               "Non-salariés (Entrepreneurs) dépendants" = "#95A5A6",
                               "Employés" = "#16A085",
                               "Travailleurs familiaux" = "#34495E")) +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 20)) +
  labs(title = "Répartition de l'emploi par statut dans l'emploi",
       subtitle = "Distribution en pourcentage",
       x = NULL,
       y = "Pourcentage (%)",
       fill = NULL) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 15, face = "bold", hjust = 0.5, margin = margin(b = 5)),
    plot.subtitle = element_text(size = 11, color = "gray40", hjust = 0.5, margin = margin(b = 15)),
    legend.position = "right",
    legend.text = element_text(size = 10),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    axis.title.y = element_text(size = 15, margin = margin(r = 10)),
    axis.text = element_text(size = 10),
    plot.margin = margin(15, 15, 15, 15)
  )

print(p)