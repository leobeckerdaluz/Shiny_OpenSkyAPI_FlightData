## UI ##
ui <- fluidPage(
    titlePanel("Voos!"),

    sidebarLayout(
        sidebarPanel(
            selectInput("ICAO24",
                        "Lista de ICAOs",
                        # choices = c(ICAO24_list),
                        choices = c(1,2,3,4,5),
                        selected = 1
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

