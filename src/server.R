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

get_current_status <- function() {
    # -------------------------- GET --------------------------
    print(" ")
    print("Buscando os voos atuais")

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
    names(get_states_df) <- c("icao24", "callsign", "origin_country", "time_position", "last_contact", "LONGITUDE", "LATITUDE", "altitude", "on_ground", "velocity", "true_track", "vertical_rate", "sensors", "geo_altitude", "squawk", "spi", "position_source")

    # Tira os que tem Latitude e Longitude <NA>
    get_states_df = get_states_df[!is.na(get_states_df$LATITUDE),]
    ### get_states_df <- get_states_df[complete.cases(get_states_df[ , 6:7]),]
    get_states_df = get_states_df[!is.na(get_states_df$LONGITUDE),]
    # Converte as colunas e Longitude e Latitude de factor pra numérico com o sub por ser decimal
    get_states_df <- transform(get_states_df, 
                    LONGITUDE = as.numeric(as.character(sub("," , ".", get_states_df$LONGITUDE))), 
                    LATITUDE = as.numeric(as.character(sub("," , ".", get_states_df$LATITUDE))))

    # df <- get_states_df
    # for (row in 1:50) { 
    #     if (is.na(df$LATITUDE[row]) | is.na(df$LONGITUDE[row])) {
    #     print(paste("latitude: ", row, " - ", df$LATITUDE[row], " / ", df$LONGITUDE[row], sep=""))
    #     }
    #     if (!is.numeric(df$LATITUDE[row]) | !is.numeric(df$LONGITUDE[row])) {
    #     print(paste("Não é numerico: ", row, " - ", df$LATITUDE[row], " / ", df$LONGITUDE[row], sep=""))
    #     }
    #     if (is.numeric(df$LATITUDE[row]) | is.numeric(df$LONGITUDE[row])) {
    #     print(paste("É numerico: ", row, " - ", df$LATITUDE[row], " / ", df$LONGITUDE[row], sep=""))
    #     }
    #     print(paste("Classe Latitude: ", class(df$LATITUDE)))
    #     print(paste("Classe Longitude: ", class(df$LONGITUDE)))
    # }

    return (get_states_df)
    # ------------------------ END GET ------------------------
}

## SERVER ##
server <- function(input, output, session) {
    output$map <- renderLeaflet({
        # Faz uma atualização dos dados de voos atuais
        current_status <<- get_current_status()

        first_lat = csv_data[1,]$LATITUDE
        first_lng = csv_data[1,]$LONGITUDE
       
        leaflet()%>%
        addTiles() %>%
        setView(lng=first_lng, 
                lat=first_lat, 
                zoom=6
        ) %>%
        
        # addPolylines(data = csv_data, 
        #              lng = ~LONGITUDE, 
        #              lat = ~LATITUDE, 
        #              color = "green") %>%
        
        # addMarkers(data = csv_data, 
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

        # # Adiciona marcadores através de pontos obtidos do GET
        addMarkers( data = current_status,
                    lng = ~LONGITUDE, 
                    lat = ~LATITUDE, 
                    icon = list(
                        iconUrl = 'http://www.iconarchive.com/download/i91814/icons8/windows-8/Transport-Airplane-Mode-On.ico',
                        iconSize = c(20, 20)
                    ),
        ) 
    })

    observeEvent(input$map_marker_click, {
        # click = input$map_click
        click <- input$map_marker_click
        
        # print(click)

        # Obtém o data frame de voos atuais
        # current_status <- get_states_csv()
        # Printa alguns valores para análise
        print(paste("latitude df[1,]: ", current_status[1,]$LATITUDE))
        print(paste("latitude df[1,] class: ", class(current_status[1,]$LATITUDE)))
        print(paste("latitude event: ", click$lat))
        print(paste("latitude event class: ", class(click$lat)))
        print(paste("longitude event: ", click$lng))
        print(paste("longitude event class: ", class(click$lng)))

        # busca qual o index onde está a latitude e longitude
        index <- which(current_status$LATITUDE == click$lat)
        print(paste("INDEX:", index, sep=""))
        if(!is.null(index))
            print(current_status[index,])
        else
            print("index é null!")

        # Obtém a linha do data frame do voo
        flight <- current_status[index,]
        
        # Apresenta dados do voo
        flight_icao24 <- flight$icao24
        flight_lat <- flight$LATITUDE
        flight_lng <- flight$LONGITUDE
        flight_callsign <- flight$callsign
        flight_origin_country <- flight$origin_country
        flight_time_position <- flight$time_position
        flight_last_contact <- flight$last_contact
        flight_altitude <- flight$altitude
        flight_on_ground <- flight$on_ground
        flight_velocity <- flight$velocity
        flight_true_track <- flight$true_track
        flight_vertical_rate <- flight$vertical_rate
        flight_sensors <- flight$sensors
        flight_geo_altitude <- flight$geo_altitude
        flight_squawk <- flight$squawk
        flight_spi <- flight$spi
        flight_position_source <- flight$position_source
        
        print("")
        print(paste("ICAO24: ", flight_icao24))
        print(paste("Latitude: ", flight_lat))
        print(paste("Longitude: ", flight_lng))

        content <- paste(sep = "",
            "<b>ICAO24: ",flight_icao24,"</b><br/>",
            "<b>LAT</b>: ", flight_lat,"<br/>",
            "<b>LONG</b>: ", flight_lng,"<br/>",
            "<b>CALLSIGN</b>: ", flight_callsign,"<br/>",
            "<b>ALTITUDE</b>: ", flight_altitude,"<br/>",
            "<b>ON GROUND</b>: ", flight_on_ground,"<br/>",
            "<b>VELOCITY</b>: ", flight_velocity,"<br/>",
            "<b>TRUE TRACK</b>: ", flight_true_track,"<br/>",
            "<b>VERTICAL RATE</b>: ", flight_vertical_rate,"<br/>",
            "<b>ORIGIN COUNTRY</b>: ", flight_origin_country,"<br/>",
            "<b>TIME POSITION</b>: ", flight_time_position,"<br/>",
            "<b>LAST CONTACT</b>: ", flight_last_contact,"<br/>",
            "<b>AEE CARALHO!</b>"
        )

        leafletProxy('map') %>%
        addPopups(  lng=click$lng, 
                    lat=click$lat, 
                    popup=content,
                    options = popupOptions(closeButton = TRUE))

        
         # -------------------------- GET FLIGHT --------------------------
        # source("credentials.R")
        # # print(api_user)
        # # url1 <- paste("https://",api_user,":",api_password,"@opensky-network.org/api/tracks/all?icao24=", teste, "&time=0", sep = "")
        url1 <- "https://leobeckerdaluz:caio123456@opensky-network.org/api/tracks/all?icao24=e4936a&time=0"
        # # print(url1)
        # get_prices <- GET(url1)
        # get_prices_text <- content(get_prices, "text")
        # get_prices_json <- fromJSON(get_prices_text, flatten = TRUE)
        # get_prices_df <- as.data.frame(get_prices_json)
        # path_df <- as.data.frame(get_prices_json$path)
        # names(path_df) <- c("TIMESTAMP", "LATITUDE", "LONGITUDE", "COLOR", "ANGLE", "on_ground")
        # ------------------------ END GET -------------------------------


        # pal <- colorNumeric(palette = c("green", "yellow", "red"), domain = c(600:12000))

        # # Adiciona marcadores da trajetória do voo
        # addCircleMarkers(   data = path_df, 
        #                     lng = ~LONGITUDE, 
        #                     lat = ~LATITUDE, 
        #                     radius = 3,
        #                     color = ~pal(COLOR),
        #                     layerId = ~COLOR
        # )


        # addPopups(-122.327298, 47.597131, content,
        # )

        # addMarkers( lng = click$lng, 
                    # lat = click$lat)
    })
}