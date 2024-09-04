library(shiny)
library(bs4Dash)
library(fresh)
library(readr)
library(leaflet)
library(geosphere)
library(shinyjs)
library(shinycssloaders)
library(DT)

# Load data outside the server function
data <- read_csv("data/Data Providers.csv") 
print(colnames(data))

# Create a fresh theme with lighter colors
freshTheme = create_theme(
  bs4dash_vars(
    navbar_light_color = "#5E81AC",  # A soft blue for the navbar
    navbar_light_active_color = "#2C3E50",  # Darker blue for active elements
    navbar_light_hover_color = "#34495E"  # Even darker blue on hover
  ),
  bs4dash_yiq(
    contrasted_threshold = 150,  # Adjust contrast threshold for better readability
    text_dark = "#34495E",  # Dark grey for texts
    text_light = "#FFFFFF"  # White for lighter texts
  ),
  bs4dash_layout(
    main_bg = "#ECF0F1"  # Light grey background for the main area
  ),
  bs4dash_sidebar_light(
    bg = "#BDC3C7",  # Light grey for the sidebar background
    color = "#2C3E50",  # Dark blue for text
    hover_color = "#34495E",  # Darker blue on hover
    submenu_bg = "#ECF0F1",  # Light grey for submenu background
    submenu_color = "#2C3E50",  # Dark blue for submenu text
    submenu_hover_color = "#34495E"  # Darker blue on hover for submenu
  ),
  bs4dash_status(
    primary = "#3498DB",  # Bright blue for primary status
    danger = "#E74C3C",  # Bright red for danger status
    light = "#ECF0F1"  # Light grey for light status
  ),
  bs4dash_color(
    gray_900 = "#2C3E50",  # Dark blue for darkest grey
    white = "#FFFFFF"  # White
  )
)

ui <- dashboardPage(
  dark = NULL,
  help = NULL,
  fullscreen = FALSE,
  scrollToTop = TRUE,
  options = NULL,
  useShinyjs(),  # Initialize shinyjs in your UI
  includeScript("www/app_scripts.js"), 
  freshTheme = freshTheme,
  header = dashboardHeader(
    title = dashboardBrand(
      title = "Provider Search Platform",
      color = "primary"
    )
  ),
  sidebar = dashboardSidebar(
    sidebarMenu(
      menuItem("Data View", tabName = "dataView", icon = icon("table")),
      menuItem("Provider Search", tabName = "providerSearch", icon = icon("search"))  # New menu item for provider search
    )
  ),
  body = dashboardBody(
    title = "Mint Dashboard",
    tabItems(
      tabItem(tabName = "dataView",
              bs4Card(
                title = "Data View",
                collapsible = TRUE,
                width = 12,
                DT::DTOutput("dataTableView")
              )),
      tabItem(tabName = "providerSearch",
              bs4Card(
                title = "Provider Search Near You",
                selectInput("locationFilter", "Choose a Location:", choices = unique(data$Exact_Location)),
                collapsible = TRUE,
                width = 12,
                leafletOutput("map", height = "480px") %>% withSpinner()
              ))
    )
  ),
  controlbar = dashboardControlbar(),
  footer = dashboardFooter()
)

server <- function(input, output, session) {
  output$dataTableView <- renderDT({
    datatable(data,
              options = list(
                dom = 't', # This option is to show only the table without the default DataTables controls
                paging = FALSE, # Disable pagination
                ordering = TRUE, # Enable column ordering
                info = FALSE, # Disable showing table information
                searching = FALSE, # Disable search box
                scrollX = TRUE,
                columnDefs = list(
                  list(className = 'dt-center', targets = '_all') # Center text in all columns
                ),
                initComplete = JS(
                  "function(settings, json) {", 
                  "$(this.api().table().header()).css({'background-color': '#007bff', 'color': 'white', 'text-align': 'center'});", 
                  "}"
                )
              ))
  })
  
  # Ensuring reactive data is properly filtered and accessed
  filteredData <- reactive({
    req(input$locationFilter)
    print(paste("Filtering data for location:", input$locationFilter))
    tryCatch({
      filtered <- dplyr::filter(data, Exact_Location == input$locationFilter)
      print(paste("Number of rows after filter:", nrow(filtered)))
      filtered
    }, error = function(e) {
      print(paste("Error in filtering data:", e$message))
      NULL  # Return NULL if there's an error
    })
  })
  
  output$map <- renderLeaflet({
    req(filteredData())
    if(is.null(filteredData())) {
      print("Filtered data is NULL")
      return(NULL)
    }
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