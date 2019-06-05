if (!require('shiny')) install.packages('shiny')
library(shiny)
if (!require('leaflet')) install.packages('leaflet')
library(leaflet)
if (!require('magrittr')) install.packages('magrittr')
library(magrittr)
if (!require('httr')) install.packages('httr')
require("httr")
if (!require('jsonlite')) install.packages('jsonlite')
require("jsonlite")

## GET FILES ##
# Get all filepaths
diretorios <- c("calsign1", "calsign2", "calsign3", "calsign4", "calsign5")
# # Get only folder names
#folder_names <- list.dirs(path = "./motionsense", full.names = FALSE, recursive = TRUE)
#folder_names <- folder_names[-1]
# # Nomeia a lista de diretórios
#names(diretorios) <- folder_names

ICAO24_list = c("e4936a", "e4904c", "e48ac5")

## UI ##
ui <- fluidPage(
  titlePanel("Voos!"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("ICAO24",
                  "Lista de ICAOs",
                  choices = c(ICAO24_list),
                  selected=ICAO24_list[1]
      ),

      selectInput("sub_folder",
                  "Lista de sub_folder",
                  choices = 1:24,
                  selected=1
      )
    ),
    
    
    mainPanel(
      #plotOutput("distPlot")
      leafletOutput("mymap",height = 500)
    )
  )
)


## SERVER ##
server <- function(input, output) {
  output$mymap <- renderLeaflet({
    #file <- paste(input$ICAO24, "/sub_", input$sub_folder, ".csv", sep="")
    #motion_part <- read.csv2(file, header = TRUE, 
    #                         sep = ",", stringsAsFactors = FALSE)
    
    #=================================================================================
    # GET CSV
    teste <- input$ICAO24
    
    csv_file_path = "../voo.csv"
    csv_data <- read.csv(csv_file_path)
    csv_data

    states_file_path = "../states.csv"
    states_data <- read.csv(states_file_path)
    states_data
    
    #pal <- colorFactor(palette = c("blue", "red", "green"),
    #              levels = c("Public", "Private", "For-Profit"))
    pal <- colorNumeric(palette = c("green", "yellow", "red"), domain = c(600:12000))
    #=================================================================================
    
    first_lat = csv_data[1,]$LATITUDE
    first_lng = csv_data[1,]$LONGITUDE
    
    # -------------------------- GET --------------------------
    url1 <- paste("https://leobeckerdaluz:caio123456@opensky-network.org/api/tracks/all?icao24=", teste, "&time=0", sep = "")
    # url1 = "https://leobeckerdaluz:caio123456@opensky-network.org/api/tracks/all?icao24=e4936a&time=0"
    # url1 <- "https://opensky-network.org/api/states/all"
    get_prices <- GET(url1)
    get_prices_text <- content(get_prices, "text")
    get_prices_json <- fromJSON(get_prices_text, flatten = TRUE)
    get_prices_df <- as.data.frame(get_prices_json)
    icao24 <- get_prices_df[1,]$icao24
    path_df <- as.data.frame(get_prices_json$path)
    names(path_df) <- c("TIMESTAMP", "LATITUDE", "LONGITUDE", "COLOR", "ANGLE", "on_ground")
    # ------------------------ END GET ------------------------

    m <- leaflet() %>%
      addTiles() %>%
      setView(lng=first_lng, 
              lat=first_lat , 
              zoom=7) %>%
      # addPolylines(data = csv_data, 
      #              lng = ~LONGITUDE, 
      #              lat = ~LATITUDE, 
      #              color = "green") %>%
      #addMarkers(data = csv_data, 
      #             lng = ~LONGITUDE, 
      #             lat = ~LATITUDE, 
      #             group = ~TIMESTAMP)
      # addMarkers( data = csv_data[1,], 
      #             icon = list(
      #               iconUrl = 'http://www.iconarchive.com/download/i91814/icons8/windows-8/Transport-Airplane-Mode-On.ico',
      #               iconSize = c(20, 20)
      #             ),
      #             popup = "caiosamu"
      # ) %>%
      # addMarkers( data = states_data, 
      #             icon = list(
      #               iconUrl = 'http://www.iconarchive.com/download/i91814/icons8/windows-8/Transport-Airplane-Mode-On.ico',
      #               iconSize = c(20, 20)
      #             )) %>%
      addCircleMarkers( data = path_df, 
                        lng = ~LONGITUDE, 
                        lat = ~LATITUDE, 
                        radius = 2,
                        color = ~pal(COLOR))
  })
}


## SHINY APP ##
shinyApp(ui = ui, server = server)