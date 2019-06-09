if (!require('shiny')) install.packages('shiny')
library(shiny)
if (!require('leaflet')) install.packages('leaflet')
library(leaflet)

## UI ##
ui <- fluidPage(
    titlePanel("Voos!"),

    sidebarLayout(
        sidebarPanel(
            selectInput("ICAO24",
                        "Lista de ICAOs",
                        choices = c(ICAO24_list),
                        selected = ICAO24_list[1]
            ),

            selectInput("sub_folder",
                        "Lista de sub_folder",
                        choices = 1:24,
                        selected = 1
            )
        ),
        mainPanel(
            #plotOutput("distPlot")
            # leafletOutput("mymap",height = 500)
            leafletOutput('map')
        )
    )
)

