library(shiny)
library(bslib)
library(readr)
library(leaflet)
library(geosphere)
library(shinyjs)
library(shinycssloaders)
library(DT)

# Load data outside the server function
data <- read_csv("data/Data Providers.csv") 


ui <- fluidPage(
  theme = bs_theme(
    version = 4,  
    bootswatch = "flatly"  
  ),
  useShinyjs(), 
  includeCSS("www/css/custom_styles.css"),
  includeScript("www/js/app_scripts.js"),
  tags$head(
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=Mulish:wght@400;700&display=swap")
  ),
  
  # Header
  titlePanel(
    div(
      img(src = "images/kenbright.png", class = "logo-image"),  # Class reference for styling
      div("Provider Search Portal", class = "main-title"),
      class = "header-title"  # Class reference for styling
    ),
    windowTitle = "Provider Search"
  ),
  
  # Sidebar with input for location filter
  sidebarLayout(
    sidebarPanel(
      selectInput("locationFilter", "Choose a Location:", choices = unique(data$Exact_Location)),
      selectInput("categoryFilter", "Select Category:", choices = c("All", unique(data$Category)))
    ),
    
    # Main panel displaying the map
    mainPanel(
      div(class = "card",
          div(class = "card-header",
              h5("Providers Map", class = "card-title")  # Title for the map card
          ),
          div(class = "card-body",
              leafletOutput("map", height = "600px") %>% withSpinner(type = 6)
          )
      )
    )
  )
)


server <- function(input, output, session) {
  
  # Ensuring reactive data is properly filtered and accessed
  filteredData <- reactive({
    req(input$locationFilter, input$categoryFilter)
    data_filtered <- data %>%
      dplyr::filter(Exact_Location == input$locationFilter) %>%
      dplyr::filter(if (input$categoryFilter != "All") Category == input$categoryFilter else TRUE)
    data_filtered
  })
  
  output$map <- renderLeaflet({
    req(filteredData())
    if(is.null(filteredData())) return(NULL)
    
    # Create a popup HTML content for each provider
    popups <- lapply(1:nrow(filteredData()), function(i) {
      row <- filteredData()[i, ]
      sprintf("<strong>%s</strong><br/>Contacts: %s<br/>Category: %s<br/>Speciality: %s<br/>Address: %s<br/>County: %s",
              row$Provider_Name, row$Contacts, row$Category, row$Speciality, row$`Physical Address`, row$County)
    })
    
    leaflet(data = filteredData()) %>% 
      addTiles() %>%
      addMarkers(~Longitude, ~Latitude, popup = popups, options = popupOptions(closeButton = TRUE))
  })
  
  
}

shinyApp(ui = ui, server = server)