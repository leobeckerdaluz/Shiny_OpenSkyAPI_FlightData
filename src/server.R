if (!require('httr')) install.packages('httr')
require("httr")
if (!require('jsonlite')) install.packages('jsonlite')
require("jsonlite")

get_current_status <- function() {
    # -------------------------- GET --------------------------
    print(" ")
    print("Buscando os voos atuais")
    print(" ")

    # Seta a URL para o GET
    url1 <- paste("https://opensky-network.org/api/states/all")
    # Invoca o GET
    get_states <- GET(url1)
    # Obtém o conteúdo da resposta na forma de texto
    get_states_text <- content(get_states, "text")
    # Converte a resposta textual para um JSON
    get_states_json <- fromJSON(get_states_text, flatten = TRUE)
    # Transforma o JSON em um data.frame
    get_states_df <- as.data.frame(get_states_json$states)
    # Nomeia cada coluna da forma correta
    names(get_states_df) <- c("icao24", "callsign", "origin_country", "time_position", "last_contact", "LONGITUDE", "LATITUDE", "COLOR", "on_ground", "velocity", "true_track", "vertical_rate", "sensors", "geo_altitude", "squawk", "spi", "position_source")

    # Tira os que tem Latitude e Longitude <NA>
    get_states_df = get_states_df[!is.na(get_states_df$LATITUDE),]
    ### get_states_df <- get_states_df[complete.cases(get_states_df[ , 6:7]),]
    get_states_df = get_states_df[!is.na(get_states_df$LONGITUDE),]
    # Converte as colunas e Longitude e Latitude de factor pra numérico com o sub por ser decimal
    get_states_df <- transform(get_states_df, 
                    LONGITUDE = as.numeric(as.character(sub("," , ".", get_states_df$LONGITUDE))), 
                    LATITUDE = as.numeric(as.character(sub("," , ".", get_states_df$LATITUDE))))

    df <- get_states_df
    for (row in 1:50) { 
        if (is.na(df$LATITUDE[row]) | is.na(df$LONGITUDE[row])) {
        print(paste("latitude: ", row, " - ", df$LATITUDE[row], " / ", df$LONGITUDE[row], sep=""))
        }
        if (!is.numeric(df$LATITUDE[row]) | !is.numeric(df$LONGITUDE[row])) {
        print(paste("Não é numerico: ", row, " - ", df$LATITUDE[row], " / ", df$LONGITUDE[row], sep=""))
        }
        if (is.numeric(df$LATITUDE[row]) | is.numeric(df$LONGITUDE[row])) {
        print(paste("É numerico: ", row, " - ", df$LATITUDE[row], " / ", df$LONGITUDE[row], sep=""))
        }
        print(paste("Classe Latitude: ", class(df$LATITUDE)))
        print(paste("Classe Longitude: ", class(df$LONGITUDE)))
    }

    return (get_states_df)
    # ------------------------ END GET ------------------------
}

get_states_df_use <- get_current_status()

## SERVER ##
server <- function(input, output, session) {
    output$map <- renderLeaflet({
        #=================================================================================
        # GET CSVs
        teste <- input$ICAO24

        csv_file_path = "../voo.csv"
        csv_data <- read.csv(csv_file_path)
        csv_data

        states_file_path = "../states.csv"
        states_data <- read.csv(states_file_path)
        states_data
        #=================================================================================

        #pal <- colorFactor(palette = c("blue", "red", "green"),
        #              levels = c("Public", "Private", "For-Profit"))
        pal <- colorNumeric(palette = c("green", "yellow", "red"), domain = c(600:12000))

        first_lat = csv_data[1,]$LATITUDE
        first_lng = csv_data[1,]$LONGITUDE

        # -------------------------- GET FLIGHT --------------------------
        # url1 <- paste("https://leobeckerdaluz:caio123456@opensky-network.org/api/tracks/all?icao24=", teste, "&time=0", sep = "")
        # # url1 = "https://leobeckerdaluz:caio123456@opensky-network.org/api/tracks/all?icao24=e4936a&time=0"
        # get_prices <- GET(url1)
        # get_prices_text <- content(get_prices, "text")
        # get_prices_json <- fromJSON(get_prices_text, flatten = TRUE)
        # get_prices_df <- as.data.frame(get_prices_json)
        # path_df <- as.data.frame(get_prices_json$path)
        # names(path_df) <- c("TIMESTAMP", "LATITUDE", "LONGITUDE", "COLOR", "ANGLE", "on_ground")
        # ------------------------ END GET -------------------------------

        leaflet()%>%
        addTiles() %>%
        setView(lng=first_lng, 
                lat=first_lat, 
                zoom=7
        ) %>%
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

        # Adiciona marcadores através de pontos estáticos de um csv
        # addMarkers( data = states_data,
        #             lng = ~LONGITUDE, 
        #             lat = ~LATITUDE, 
        #             icon = list(
        #                 iconUrl = 'http://www.iconarchive.com/download/i91814/icons8/windows-8/Transport-Airplane-Mode-On.ico',
        #                 iconSize = c(20, 20)
        #             ),
        #             popup = "LEO",
        #             layerId = ~LONGITUDE  
        # ) %>%

        # Adiciona marcadores através de pontos obtidos do GET
        addMarkers( data = get_states_df_use,
                    lng = ~LONGITUDE, 
                    lat = ~LATITUDE, 
                    icon = list(
                        iconUrl = 'http://www.iconarchive.com/download/i91814/icons8/windows-8/Transport-Airplane-Mode-On.ico',
                        iconSize = c(20, 20)
                    )
        ) 

        # addCircleMarkers(   data = path_df, 
        #                     lng = ~LONGITUDE, 
        #                     lat = ~LATITUDE, 
        #                     radius = 3,
        #                     color = ~pal(COLOR),
        #                     layerId = ~COLOR
        # )
    })


    observeEvent(input$map_click, {
        click = input$map_click
        leafletProxy('map')%>%addMarkers(lng = click$lng, lat = click$lat)
    })
}



