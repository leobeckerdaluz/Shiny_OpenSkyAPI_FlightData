if (!require('shiny')) install.packages('shiny')
if (!require('leaflet')) install.packages('leaflet')
if (!require('magrittr')) install.packages('magrittr')
library(leaflet)
library(magrittr)
library(shiny)

## GET FILES ##
# Get all filepaths
diretorios <- c("calsign1", "calsign2", "calsign3", "calsign4", "calsign5")
# # Get only folder names
#folder_names <- list.dirs(path = "./motionsense", full.names = FALSE, recursive = TRUE)
#folder_names <- folder_names[-1]
# # Nomeia a lista de diretórios
#names(diretorios) <- folder_names


## UI ##
ui <- fluidPage(
  titlePanel("Voos!"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("ICAO24",
                  "Lista de Voos",
                  choices = c(diretorios),
                  selected=diretorios[1]
      ),
      selectInput("sub_folder",
                  "Lista de sub_folder",
                  choices = 1:24,
                  selected=1
      )
    ),
    
    
    mainPanel(
      #plotOutput("distPlot")
      leafletOutput("mymap",height = 1000)
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
    
    
    csv_file_path = "../voo.csv"
    csv_data <- read.csv(csv_file_path)
    csv_data
    
    #pal <- colorFactor(palette = c("blue", "red", "green"),
    #              levels = c("Public", "Private", "For-Profit"))
    pal <- colorNumeric(palette = c("green", "yellow", "red"), domain = c(600:12000))
    #=================================================================================
    
    first_lat = csv_data[1,]$LATITUDE
    first_lng = csv_data[1,]$LONGITUDE
    
    m <- leaflet() %>%
      addTiles() %>%
      setView(lng=first_lng, 
              lat=first_lat , 
              zoom=10) %>%
      addPolylines(data = csv_data, 
                   lng = ~LONGITUDE, 
                   lat = ~LATITUDE, 
                   color = "green") %>%
      #addMarkers(data = csv_data, 
      #             lng = ~LONGITUDE, 
      #             lat = ~LATITUDE, 
      #             group = ~TIMESTAMP)
      #addMarkers(data = csv_data[1,], 
      #           icon = list(
      #             iconUrl = 'http://www.iconarchive.com/download/i91814/icons8/windows-8/Transport-Airplane-Mode-On.ico',
      #             iconSize = c(20, 20)
      #           )) %>%
      addCircleMarkers( data = csv_data, 
                        lng = ~LONGITUDE, 
                        lat = ~LATITUDE, 
                        radius = 2,
                        color = ~pal(COLOR))
  })
}


## SHINY APP ##
shinyApp(ui = ui, server = server)