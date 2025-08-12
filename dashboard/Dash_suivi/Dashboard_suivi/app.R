library(shiny)
library(dplyr)
library(haven)
library(ggplot2)
library(RColorBrewer)
library(plotly)

# Chargement des données
fichier_suivi <- read_dta("C:/Users/User/Documents/Travaux de stage/data/02_cleaned/Denombrement_update/denombrement_update_2025-06-24_01-16-41.dta") %>%
  mutate(
    region = as_factor(region),
    depart = as_factor(depart),
    souspref = as_factor(souspref),
    ZD = as_factor(ZD),
    segment = as_factor(segment),
    quarter = as_factor(quarter)
  )

fichier_followup <- read_dta("C:/Users/User/Documents/Travaux de stage/data/03_processed/Tracking_ID/2025-06-11/followup_matrix_2025-06-13_01-25-21.dta") %>%
  mutate(
    region = as_factor(region),
    depart = as_factor(depart),
    souspref = as_factor(souspref),
    zd = as_factor(zd),
    segment = as_factor(segment)
  )

ui <- navbarPage("Application de suivi",
                 
                 tabPanel("Suivi collecte",
                          sidebarLayout(
                            sidebarPanel(
                              selectInput("region_suivi", "Region :", choices = NULL),
                              selectInput("depart_suivi", "Departement :", choices = NULL),
                              selectInput("souspref_suivi", "Sous-prefecture :", choices = NULL),
                              selectInput("ZD_suivi", "ZD :", choices = NULL),
                              selectInput("segment_suivi", "Segment :", choices = NULL),
                              selectInput("quarter_suivi", "Trimestre :", choices = NULL)
                            ),
                            mainPanel(
                              h4("Statistiques :"),
                              verbatimTextOutput("nb_zd"),
                              verbatimTextOutput("nb_individus"),
                              verbatimTextOutput("nb_menages"),
                              br(),
                              h4("Répartition des menages par region"),
                              plotlyOutput("barplot_menages_region", height = "600px")
                            )
                          )
                 ),
                 
                 tabPanel("Matrice de suivi",
                          sidebarLayout(
                            sidebarPanel(
                              selectInput("region_followup", "Region :", choices = NULL),
                              selectInput("depart_followup", "Departement :", choices = NULL),
                              selectInput("souspref_followup", "Sous-prefecture :", choices = NULL),
                              selectInput("zd_followup", "Zone de denombrement (ZD) :", choices = NULL),
                              selectInput("segment_followup", "Segment :", choices = NULL)
                            ),
                            mainPanel(
                              h4("Statistiques"),
                              verbatimTextOutput("nb_interro"),
                              verbatimTextOutput("nb_reinterro"),
                              verbatimTextOutput("Taux_reinterro"),
                              h4("Evolution des interrogations et reinterrogations"),
                              plotOutput("evolution_interro"),
                              plotOutput("evolution_reinterro")
                            )
                          )
                 )
                 
)

server <- function(input, output, session) {
  
  # ===== Onglet Suivi collecte =====
  
  filtered_data_suivi <- reactive({
    filt <- fichier_suivi
    if (!is.null(input$region_suivi) && input$region_suivi != "Tout") filt <- filt %>% filter(region == input$region_suivi)
    if (!is.null(input$depart_suivi) && input$depart_suivi != "Tout") filt <- filt %>% filter(depart == input$depart_suivi)
    if (!is.null(input$souspref_suivi) && input$souspref_suivi != "Tout") filt <- filt %>% filter(souspref == input$souspref_suivi)
    if (!is.null(input$ZD_suivi) && input$ZD_suivi != "Tout") filt <- filt %>% filter(ZD == input$ZD_suivi)
    if (!is.null(input$segment_suivi) && input$segment_suivi != "Tout") filt <- filt %>% filter(segment == input$segment_suivi)
    if (!is.null(input$quarter_suivi) && input$quarter_suivi != "Tout") filt <- filt %>% filter(quarter == input$quarter_suivi)
    return(filt)
  })
  
  update_all_inputs_suivi <- function(df) {
    updateSelectInput(session, "region_suivi",
                      choices = c("Tout", sort(unique(as.character(df$region)))),
                      selected = if (input$region_suivi %in% df$region) input$region_suivi else "Tout")
    updateSelectInput(session, "depart_suivi",
                      choices = c("Tout", sort(unique(as.character(df$depart)))),
                      selected = if (input$depart_suivi %in% df$depart) input$depart_suivi else "Tout")
    updateSelectInput(session, "souspref_suivi",
                      choices = c("Tout", sort(unique(as.character(df$souspref)))),
                      selected = if (input$souspref_suivi %in% df$souspref) input$souspref_suivi else "Tout")
    updateSelectInput(session, "ZD_suivi",
                      choices = c("Tout", sort(unique(as.character(df$ZD)))),
                      selected = if (input$ZD_suivi %in% df$ZD) input$ZD_suivi else "Tout")
    updateSelectInput(session, "segment_suivi",
                      choices = c("Tout", sort(unique(as.character(df$segment)))),
                      selected = if (input$segment_suivi %in% df$segment) input$segment_suivi else "Tout")
    updateSelectInput(session, "quarter_suivi",
                      choices = c("Tout", sort(unique(as.character(df$quarter)))),
                      selected = if (input$quarter_suivi %in% df$quarter) input$quarter_suivi else "Tout")
  }
  
  observe({
    update_all_inputs_suivi(fichier_suivi)
  })
  
  observeEvent({
    input$region_suivi
    input$depart_suivi
    input$souspref_suivi
    input$ZD_suivi
    input$segment_suivi
    input$quarter_suivi
  }, {
    update_all_inputs_suivi(filtered_data_suivi())
  })
  
  output$nb_zd <- renderText({
    zd_count <- filtered_data_suivi() %>% pull(ZD) %>% unique() %>% length()
    paste("Nombre de ZD :", zd_count)
  })
  
  output$nb_individus <- renderText({
    total_indivs <- filtered_data_suivi() %>%
      summarise(total = sum(nb_indivs_seg, na.rm = TRUE)) %>%
      pull(total)
    paste("Nombre total d'individus :", total_indivs)
  })
  
  output$nb_menages <- renderText({
    total_menages <- filtered_data_suivi() %>%
      summarise(total = sum(nb_mens_seg, na.rm = TRUE)) %>%
      pull(total)
    paste("Nombre total de menages :", total_menages)
  })
  
  output$barplot_menages_region <- renderPlotly({
    df <- filtered_data_suivi()
    df_region <- df %>%
      group_by(region) %>%
      summarise(menages = sum(nb_mens_seg, na.rm = TRUE)) %>%
      arrange(desc(menages)) %>%
      ungroup()
    
    n_colors <- nrow(df_region)
    couleurs <- colorRampPalette(brewer.pal(8, "Set3"))(n_colors)
    
    p <- ggplot(df_region, aes(x = reorder(region, menages), y = menages, fill = region,
                               text = paste0("Region : ", region, "<br>Ménages : ", menages))) +
      geom_bar(stat = "identity", width = 0.7) +
      coord_flip() +
      theme_minimal(base_family = "Arial") +
      scale_fill_manual(values = couleurs) +
      labs(
        title = "",
        x = "Region",
        y = "Nombre de menages",
        fill = "Region"
      ) +
      theme(
        plot.title = element_text(size = 15, face = "bold", hjust = 0.5),
        axis.text = element_text(size = 10),
        legend.position = "none"
      )
    
    ggplotly(p, tooltip = "text")
  })
  
  
  # ===== Onglet Matrice de suivi =====
  
  ordre_trimestre <- function(vec) {
    extract_parts <- function(x) {
      parts <- regmatches(x, regexec("T(\\d)_?(\\d{4})", x))[[1]]
      c(trimestre = as.numeric(parts[2]), annee = as.numeric(parts[3]))
    }
    parts_list <- lapply(vec, extract_parts)
    df <- data.frame(
      trimestre = sapply(parts_list, function(x) x["trimestre"]),
      annee = sapply(parts_list, function(x) x["annee"]),
      original = vec,
      stringsAsFactors = FALSE
    )
    df <- df[order(df$annee, df$trimestre), ]
    factor(df$original, levels = unique(df$original))
  }
  
  filtered_data_followup <- reactive({
    filt <- fichier_followup
    if (input$region_followup != "Tout") filt <- filt %>% filter(region == input$region_followup)
    if (input$depart_followup != "Tout") filt <- filt %>% filter(depart == input$depart_followup)
    if (input$souspref_followup != "Tout") filt <- filt %>% filter(souspref == input$souspref_followup)
    if (input$zd_followup != "Tout") filt <- filt %>% filter(zd == input$zd_followup)
    if (input$segment_followup != "Tout") filt <- filt %>% filter(segment == input$segment_followup)
    filt
  })
  
  update_all_inputs_followup <- function(df) {
    updateSelectInput(session, "region_followup",
                      choices = c("Tout", sort(unique(as.character(df$region)))),
                      selected = if (input$region_followup %in% df$region) input$region_followup else "Tout")
    updateSelectInput(session, "depart_followup",
                      choices = c("Tout", sort(unique(as.character(df$depart)))),
                      selected = if (input$depart_followup %in% df$depart) input$depart_followup else "Tout")
    updateSelectInput(session, "souspref_followup",
                      choices = c("Tout", sort(unique(as.character(df$souspref)))),
                      selected = if (input$souspref_followup %in% df$souspref) input$souspref_followup else "Tout")
    updateSelectInput(session, "zd_followup",
                      choices = c("Tout", sort(unique(as.character(df$zd)))),
                      selected = if (input$zd_followup %in% df$zd) input$zd_followup else "Tout")
    updateSelectInput(session, "segment_followup",
                      choices = c("Tout", sort(unique(as.character(df$segment)))),
                      selected = if (input$segment_followup %in% df$segment) input$segment_followup else "Tout")
  }
  
  observe({
    update_all_inputs_followup(fichier_followup)
  })
  
  observeEvent({
    input$region_followup
    input$depart_followup
    input$souspref_followup
    input$zd_followup
    input$segment_followup
  }, {
    update_all_inputs_followup(filtered_data_followup())
  })
  
  output$nb_interro <- renderText({
    total <- filtered_data_followup() %>% summarise(total = sum(first_total, na.rm = TRUE)) %>% pull(total)
    paste("Nombre d'interrogations :", total)
  })
  
  output$nb_reinterro <- renderText({
    total <- filtered_data_followup() %>%
      mutate(pondere = first_total * (1 + proportion)) %>%
      summarise(total = sum(pondere, na.rm = TRUE)) %>%
      pull(total)
    paste("Nombre estimé avec réinterrogation :", round(total))
  })
  
  output$Taux_reinterro <- renderText({
    reinterro <- filtered_data_followup() %>%
      mutate(pondere = first_total * (1 + proportion)) %>%
      summarise(total = sum(pondere, na.rm = TRUE)) %>%
      pull(total)
    interrog <- filtered_data_followup() %>%
      summarise(total = sum(first_total, na.rm = TRUE)) %>%
      pull(total)
    taux <- if (interrog > 0) round(100 * (reinterro - interrog) / interrog, 2) else 0
    paste("Taux de réinterrogation :", taux, "%")
  })
  
  output$evolution_interro <- renderPlot({
    data <- filtered_data_followup() %>%
      group_by(first_quarter) %>%
      summarise(total = sum(first_total, na.rm = TRUE)) %>%
      ungroup() %>%
      mutate(first_quarter = ordre_trimestre(first_quarter))
    
    ggplot(data, aes(x = first_quarter, y = total, group = 1)) +
      geom_line(color = "blue") +
      geom_point(color = "blue", size = 2) +
      labs(title = "Evolution des premières interrogations", x = "Trimestre", y = "Total") +
      theme_minimal()
  })
  
  output$evolution_reinterro <- renderPlot({
    data <- filtered_data_followup() %>%
      group_by(current_quarter) %>%
      summarise(total = sum(resurvey_count, na.rm = TRUE)) %>%
      ungroup() %>%
      mutate(current_quarter = ordre_trimestre(current_quarter))
    
    ggplot(data, aes(x = current_quarter, y = total, group = 1)) +
      geom_line(color = "darkred") +
      geom_point(color = "darkred", size = 2) +
      labs(title = "Evolution des réinterrogations", x = "Trimestre", y = "Total") +
      theme_minimal()
  })
  
}

shinyApp(ui = ui, server = server)
