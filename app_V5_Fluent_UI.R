library(shiny)
library(shiny.fluent)
library(leaflet)
library(readr)

# Load data
data <- read_csv("data/Data Providers.csv") 

ui <- fluentPage(
  title = "Mint Provider Search Platform",
  div(
    ComboBox.shinyInput("locationFilter",
                        label = "Choose a Location:",
                        options = lapply(unique(data$Exact_Location), function(x) {
                          list(key = x, text = x)
                        }),
                        defaultSelectedKey = unique(data$Exact_Location)[1]
    )
  ),
  Stack(
    tokens = list(childrenGap = 10),
    Label("Provider Search Near You", className = "ms-fontSize-22 ms-fontWeight-semibold"),
    ComboBox.shinyInput("locationFilter",
                        label = "Choose a Location:",
                        options = lapply(unique(data$Exact_Location), function(x) {
                          list(key = x, text = x)
                        }),
                        defaultSelectedKey = unique(data$Exact_Location)[1]
    ),
    leafletOutput("map", height = "480px")
  )
)

server <- function(input, output, session) {
  observe({
    updateChoiceGroup(session, "locationFilter",
                      options = lapply(unique(data$Exact_Location), function(x) {
                        list(key = x, text = x)
                      })
    )
  })
  
  filteredData <- reactive({
    req(input$locationFilter)
    dplyr::filter(data, Exact_Location == input$locationFilter)
  })
  
  output$map <- renderLeaflet({
    req(filteredData())
    if (nrow(filteredData()) == 0) {
      return(NULL)
    }
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
