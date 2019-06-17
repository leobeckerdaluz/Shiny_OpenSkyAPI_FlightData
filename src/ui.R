if (!require('shiny')) install.packages('shiny')
library(shiny)
if (!require('leaflet')) install.packages('leaflet')
library(leaflet)
if (!require('DT')) install.packages('DT')
library(DT)

## UI ##
ui <- fluidPage(
    titlePanel("Flights"),

    mainPanel(
        tabsetPanel(
            tabPanel("Mapa", leafletOutput('map', height=480, width=1250)),
            tabPanel("Tabela", DTOutput("tb1"))
        )
    )
)