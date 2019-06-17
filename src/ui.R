if (!require('shiny')) install.packages('shiny')
library(shiny)
if (!require('leaflet')) install.packages('leaflet')
library(leaflet)
if (!require('DT')) install.packages('DT')
library(DT)

## UI ##
ui <- fluidPage(
    titlePanel("Voos!"),

    mainPanel(
        tabsetPanel(
            tabPanel("Mapa", leafletOutput('map')),
            tabPanel("Tabela", DTOutput("tb1"))
        )
    )
)

