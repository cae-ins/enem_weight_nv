library(shiny)
library(dplyr)
library(haven)
library(plotly)

# === MODULE UI ===
tabUI <- function(id, titre, with_plots = TRUE) {
  ns <- NS(id)
  
  # UI de base avec sidebar + mainPanel
  sidebar <- sidebarPanel(
    selectInput(ns("region"), "Region :", choices = NULL),
    selectInput(ns("depart"), "Departement :", choices = NULL),
    selectInput(ns("souspref"), "Sous-prefecture :", choices = NULL),
    selectInput(ns("ZD"), "ZD :", choices = NULL)
  )
  
  if (with_plots) {
    main <- mainPanel(
      h4("Statistiques"),
      verbatimTextOutput(ns("nb_zd_enq_reg")),
      verbatimTextOutput(ns("nb_menages_enq")),
      verbatimTextOutput(ns("nb_indivs_enq")),
      verbatimTextOutput(ns("nb_indivs_enq_elig")),
      verbatimTextOutput(ns("nb_indivs_reg")),
      verbatimTextOutput(ns("nb_indivs_zd")),
      verbatimTextOutput(ns("nb_menages_reg")),
      verbatimTextOutput(ns("nb_menages_zd")),
      fluidRow(
        column(6, plotlyOutput(ns("pie_menages"))),
        column(6, plotlyOutput(ns("pie_individus")))
      ),
      fluidRow(
        column(6, plotlyOutput(ns("pie_individus_elig")))
      )
    )
  } else {
    main <- mainPanel(
      h4("Statistiques :"),
      verbatimTextOutput(ns("nb_zd_enq_reg")),
      verbatimTextOutput(ns("nb_indivs_zd")),
      verbatimTextOutput(ns("nb_menages_zd")),
      verbatimTextOutput(ns("nb_indivs_reg")),
      verbatimTextOutput(ns("nb_menages_reg"))
    )
  }
  
  tabPanel(
    titre,
    sidebarLayout(
      sidebar,
      main
    )
  )
}

# === MODULE SERVER ===
tabServer <- function(id, fichier, with_plots = TRUE) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    fichier <- fichier %>%
      mutate(
        region = as_factor(region),
        depart = as_factor(depart),
        souspref = as_factor(souspref),
        ZD = as_factor(ZD)
      )
    
    filtered_data <- reactive({
      filt <- fichier
      if (!is.null(input$region) && input$region != "Tout") filt <- filt %>% filter(region == input$region)
      if (!is.null(input$depart) && input$depart != "Tout") filt <- filt %>% filter(depart == input$depart)
      if (!is.null(input$souspref) && input$souspref != "Tout") filt <- filt %>% filter(souspref == input$souspref)
      if (!is.null(input$ZD) && input$ZD != "Tout") filt <- filt %>% filter(ZD == input$ZD)
      filt
    })
    
    update_all_inputs <- function(df) {
      updateSelectInput(session, "region",
                        choices = c("Tout", sort(unique(as.character(df$region)))),
                        selected = if (input$region %in% df$region) input$region else "Tout")
      
      updateSelectInput(session, "depart",
                        choices = c("Tout", sort(unique(as.character(df$depart)))),
                        selected = if (input$depart %in% df$depart) input$depart else "Tout")
      
      updateSelectInput(session, "souspref",
                        choices = c("Tout", sort(unique(as.character(df$souspref)))),
                        selected = if (input$souspref %in% df$souspref) input$souspref else "Tout")
      
      updateSelectInput(session, "ZD",
                        choices = c("Tout", sort(unique(as.character(df$ZD)))),
                        selected = if (input$ZD %in% df$ZD) input$ZD else "Tout")
    }
    
    observe({ update_all_inputs(fichier) })
    
    observeEvent({
      input$region
      input$depart
      input$souspref
      input$ZD
    }, {
      update_all_inputs(filtered_data())
    })
    
    # STATISTIQUES ET GRAPHIQUES selon with_plots
    
    if (with_plots) {
      # Comme dans ton premier module, avec tous les outputs
      output$nb_zd_enq_reg <- renderText({
        total <- filtered_data() %>% summarise(total = sum(nb_zd_strat, na.rm = TRUE)) %>% pull(total)
        paste("Nombre de ZD enquêtées dans la zone sélectionnée :", total)
      })
      output$nb_menages_enq <- renderText({
        total <- filtered_data() %>% summarise(total = sum(nb_mens_enq, na.rm = TRUE)) %>% pull(total)
        paste("Nombre de ménages enquêtés :", total)
      })
      output$nb_indivs_enq <- renderText({
        total <- filtered_data() %>% summarise(total = sum(nb_indivs_enq, na.rm = TRUE)) %>% pull(total)
        paste("Nombre d'individus enquêtés :", total)
      })
      output$nb_indivs_enq_elig <- renderText({
        total <- filtered_data() %>% summarise(total = sum(nb_indivs_enq_elig, na.rm = TRUE)) %>% pull(total)
        paste("Nombre d'individus enquêtés et éligibles :", total)
      })
      output$nb_indivs_reg <- renderText({
        total <- filtered_data() %>% summarise(total = sum(nb_indivs_reg, na.rm = TRUE)) %>% pull(total)
        paste("Nombre total d'individus recensés :", total)
      })
      output$nb_indivs_zd <- renderText({
        total <- filtered_data() %>% summarise(total = sum(nb_indivs_zd, na.rm = TRUE)) %>% pull(total)
        paste("Nombre total d'individus dans les ZD :", total)
      })
      output$nb_menages_reg <- renderText({
        total <- filtered_data() %>% summarise(total = sum(nb_mens_reg, na.rm = TRUE)) %>% pull(total)
        paste("Nombre total de ménages recensés :", total)
      })
      output$nb_menages_zd <- renderText({
        total <- filtered_data() %>% summarise(total = sum(nb_mens_zd, na.rm = TRUE)) %>% pull(total)
        paste("Nombre total de ménages dans les ZD :", total)
      })
      
      output$pie_menages <- renderPlotly({
        df <- filtered_data()
        total <- sum(df$nb_mens_seg, na.rm = TRUE)
        enquetes <- sum(df$nb_mens_enq, na.rm = TRUE)
        non_enquetes <- total - enquetes
        
        plot_ly(
          labels = c("Ménages enquêtés", "Ménages non enquêtés"),
          values = c(enquetes, max(non_enquetes, 0)),
          type = 'pie',
          textinfo = 'label+percent+value',
          marker = list(colors = c("#2E86C1", "#AED6F1"))
        ) %>% layout(title = "Répartition des ménages")
      })
      
      output$pie_individus <- renderPlotly({
        df <- filtered_data()
        total <- sum(df$nb_indivs_seg, na.rm = TRUE)
        enquetes <- sum(df$nb_indivs_enq, na.rm = TRUE)
        non_enquetes <- total - enquetes
        
        plot_ly(
          labels = c("Individus enquêtés", "Individus non enquêtés"),
          values = c(enquetes, max(non_enquetes, 0)),
          type = 'pie',
          textinfo = 'label+percent+value',
          marker = list(colors = c("#27AE60", "#A9DFBF"))
        ) %>% layout(title = "Répartition des individus")
      })
      
      output$pie_individus_elig <- renderPlotly({
        df <- filtered_data()
        enquetes <- sum(df$nb_indivs_enq, na.rm = TRUE)
        eligibles <- sum(df$nb_indivs_enq_elig, na.rm = TRUE)
        ineligibles <- enquetes - eligibles
        
        plot_ly(
          labels = c("Individus enquêtés éligibles", "Individus enquêtés non éligibles"),
          values = c(eligibles, max(ineligibles, 0)),
          type = 'pie',
          textinfo = 'label+percent+value',
          marker = list(colors = c("#8E44AD", "#D2B4DE"))
        ) %>% layout(title = "Éligibilité des individus")
      })
      
    } else {
      # Version simplifiée pour T3, sans graphiques
      output$nb_zd_enq_reg <- renderText({
        total <- filtered_data() %>% summarise(total = sum(nb_zd_strat, na.rm = TRUE)) %>% pull(total)
        paste("Nombre de ZD enquêtées :", total)
      })
      
      output$nb_indivs_zd <- renderText({
        total <- filtered_data() %>% summarise(total = sum(nb_indivs_zd, na.rm = TRUE)) %>% pull(total)
        paste("Nombre d'individus par ZD :", total)
      })
      
      output$nb_menages_zd <- renderText({
        total <- filtered_data() %>% summarise(total = sum(nb_mens_zd, na.rm = TRUE)) %>% pull(total)
        paste("Nombre de ménages par ZD :", total)
      })
      
      output$nb_indivs_reg <- renderText({
        total <- filtered_data() %>% summarise(total = sum(nb_indivs_reg, na.rm = TRUE)) %>% pull(total)
        paste("Nombre d'individus par région :", total)
      })
      
      output$nb_menages_reg <- renderText({
        total <- filtered_data() %>% summarise(total = sum(nb_mens_reg, na.rm = TRUE)) %>% pull(total)
        paste("Nombre de ménages par région :", total)
      })
    }
  })
}

# === DONNÉES ===
fichier_T1 <- read_dta("C:/Users/User/Documents/Travaux de stage/data/04_weights/Menage/T1_2025/weights_columns_T1_2025.dta")
fichier_T4 <- read_dta("C:/Users/User/Documents/Travaux de stage/data/04_weights/Menage/T4_2024/weights_columns_T4_2024.dta")
fichier_T3 <- read_dta("C:/Users/User/Documents/Travaux de stage/data/04_weights/Menage/T3_2024/weights_columns_T3_2024.dta")

# === UI GLOBAL ===
ui <- fluidPage(
  titlePanel("Application Shiny – Données T1_2025, T3_2024 et T4_2024"),
  tabsetPanel(
    tabUI("T1", "Point sur T1_2025", with_plots = TRUE),
    tabUI("T3", "Point sur T3_2024", with_plots = FALSE),
    tabUI("T4", "Point sur T4_2024", with_plots = TRUE)
  )
)

# === SERVER GLOBAL ===
server <- function(input, output, session) {
  tabServer("T1", fichier_T1, with_plots = TRUE)
  tabServer("T3", fichier_T3, with_plots = FALSE)
  tabServer("T4", fichier_T4, with_plots = TRUE)
}

# Lancement de l’application
shinyApp(ui, server)
