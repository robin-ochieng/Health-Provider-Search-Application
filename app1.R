library(shiny)
library(bs4Dash)
library(fresh)
library(readr) 
library(leaflet)
library(dplyr)
library(scales)
library(DT)
library(rnaturalearth)


# Load data outside the server function
data <- read_csv("data/Data Providers.csv") 

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

ui = dashboardPage(
    dark = NULL,
    help = NULL,
    fullscreen = FALSE,
    scrollToTop = TRUE,
    options = NULL,
    freshTheme = freshTheme,
    header = dashboardHeader(
      title = dashboardBrand(
        title = "Mint Dashboard",
        color = "primary",
        #href = "https://adminlte.io/themes/v3",
        image = "https://adminlte.io/themes/v3/dist/img/AdminLTELogo.png"
      )
    ),
    sidebar = dashboardSidebar(
      sidebarMenu(
        menuItem("Data View", tabName = "dataView", icon = icon("table")),
        menuItem("Map View", tabName = "mapView", icon = icon("globe"))
      )
    ),
    body = dashboardBody(
      tabItems(
        tabItem(tabName = "dataView",
                bs4Card(
                  title = "Data View",
                  collapsible = TRUE,
                  width = 12,
                  dataTableOutput("dataTableView")  # Display data table here
                )
        ),
        tabItem(tabName = "mapView",  # New tab for the map
                leafletOutput("map")  # Output for the leaflet map
        )
      )
    ),
    controlbar = dashboardControlbar(),
    title = "DashboardPage"
  )

server = function(input, output, session) {
    
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
    output$map <- renderLeaflet({
      # Filter data for East Africa
      data <- data %>%
        filter(County %in% c("Kenya", "Uganda", "Tanzania", "Rwanda", "Burundi"))
      
      # Use color palette to distinguish providers by category
      pal <- colorFactor(palette = "viridis", domain = data$Category)
      
      # Create leaflet map
      leaflet(data = data) %>%
        addTiles() %>%  # Add default OpenStreetMap tiles
        addCircleMarkers(
          lng = ~Longitude, lat = ~Latitude,
          color = ~pal(Category),
          radius = 6,
          popup = ~paste("<b>Provider Name:</b>", Provider_Name, "<br/>",
                         "<b>Category:</b>", Category, "<br/>",
                         "<b>Speciality:</b>", Speciality, "<br/>",
                         "<b>Physical Address:</b>", `Physical Address`, "<br/>",
                         "<b>Contacts:</b>", Contacts)
        ) %>%
        setView(lng = 37.9062, lat = -1.3086, zoom = 6)  # Center map on East Africa
    })
  }
  
shinyApp(ui = ui, server = server)