# Medical Providers Search Site

## Overview
Medical Providers Search Site is a Shiny application designed to help users find medical providers based on specific locations and specialties interactively. This tool is intended for patients, healthcare professionals, or anyone interested in accessing information about medical providers with ease.

## Features
- **Location-Based Searching**: Allows users to select a location to find nearby medical providers.
- **Category Filtering**: Users can filter providers by categories such as specialty, services offered, etc.
- **Interactive Map Visualization**: View search results on an interactive map, showing details like provider name, address, and specialty.
- **Responsive Design**: Ensures the application is usable on both desktop and mobile devices.

## Getting Started
These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites
What you need to install the software:
- R (version 4.0.0 or later)
- RStudio (recommended for ease of use)
- Required R packages:
  ```R
  install.packages(c("shiny", "bslib", "readr", "leaflet", "geosphere", "shinyjs", "shinycssloaders", "DT"))


### Installation
1. Clone the repo: 
 ```bash
    git clone https://yourrepositorylink.com/path/to/repo.git
```
2. Open the project in RStudio or your preferred R environment.
3. Install all required dependencies as listed above.
4. Run the application:
```R
    shiny::runApp('path/to/app')
```

### Usage
After launching the application, you can:
- Choose a location from the dropdown menu to see providers in that area.
- Use category filters to refine your search results.
- Click on any provider marker in the map to view detailed information.

### Contributing
Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.
1. Fork the Project
2. Create your Feature Branch (git checkout -b feature/AmazingFeature)
3. Commit your Changes (git commit -m 'Add some AmazingFeature')
4. Push to the Branch (git push origin feature/AmazingFeature)
5. Open a Pull Request