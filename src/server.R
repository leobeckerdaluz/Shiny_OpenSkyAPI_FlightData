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
    get_states_df = get_states_df[!is.na(get_states_df$true_track),]
    # Converte as colunas e Longitude e Latitude de factor pra numérico com o sub por ser decimal
    get_states_df <- transform(get_states_df, 
                    LONGITUDE = as.numeric(as.character(sub("," , ".", get_states_df$LONGITUDE))), 
                    LATITUDE = as.numeric(as.character(sub("," , ".", get_states_df$LATITUDE))),
                    true_track = as.numeric(as.character(sub("," , ".", get_states_df$true_track))))

    # Cria a coluna de ícones com valor teste
    get_states_df$icon <- "testeICON"

    # print("")
    # print("STATES antes: ")
    # print(get_states_df[1:5,])

    #===================================================
    # # Define as coordenadas a cada 90º
    # diff <- 90
    # norte2leste1 <- diff/2 
    # leste2sul1 <- norte2leste1+diff
    # sul2oeste1 <- leste2sul1+diff
    # oeste2norte1 <- sul2oeste1+diff
    # # print(paste("norte: ", oeste2norte1, " até ", norte2leste1))
    # # print(paste("leste: ", norte2leste1, " até ", leste2sul1))
    # # print(paste("sul: ", leste2sul1, " até ", sul2oeste1))
    # # print(paste("oeste: ", sul2oeste1, " até ", oeste2norte1))

    # # Processa o valor de TRUE_TRACK e seta o ícone
    # result <- sapply(get_states_df$true_track, function(x) { 
    #     if ((x >= oeste2norte1 && x <= 360) || (x >= 0 && x < norte2leste1)){
    #         # print(paste(x," é norte!"))
    #         x <- "norte.png"
    #     }
    #     else if (x >= norte2leste1 && x < leste2sul1){
    #         # print(paste(x," é leste!"))
    #         x <- "leste.png"
    #     }
    #     else if (x >= leste2sul1 && x < sul2oeste1){
    #         # print(paste(x," é sul!"))
    #         x <- "sul.png"
    #     }
    #     else if (x >= sul2oeste1 && x < oeste2norte1){
    #         # print(paste(x," é oeste!"))
    #         x <- "oeste.png"
    #     }
    #     else{
    #         print(paste(x," deu creps!"))
    #         x <- "oeste.png"
    #     }
    # })
    #===================================================

    #===================================================
    # Define as coordenadas a cada 45º
    diff <- 45
    nordeste1norte2 <- diff/2
    leste1nordeste2 <- nordeste1norte2+diff
    sudeste1leste2 <- leste1nordeste2+diff
    sul1sudeste2 <- sudeste1leste2+diff
    sudoeste1sul2 <- sul1sudeste2+diff
    oeste1sudoeste2 <- sudoeste1sul2+diff
    noroeste1oeste2 <- oeste1sudoeste2+diff
    norte1noroeste2 <- noroeste1oeste2+diff

    print(paste("norte: ", norte1noroeste2, " até ", nordeste1norte2))
    print(paste("nordeste: ", nordeste1norte2, " até ", leste1nordeste2))
    print(paste("leste: ", leste1nordeste2, " até ", sudeste1leste2))
    print(paste("sudeste: ", sudeste1leste2, " até ", sul1sudeste2))
    print(paste("sul: ", sul1sudeste2, " até ", sudoeste1sul2))
    print(paste("sudoeste: ", sudoeste1sul2, " até ", oeste1sudoeste2))
    print(paste("oeste: ", oeste1sudoeste2, " até ", noroeste1oeste2))
    print(paste("noroeste: ", noroeste1oeste2, " até ", norte1noroeste2))

    filespath <- "images/"
    # Processa o valor de TRUE_TRACK e seta o ícone
    result <- sapply(get_states_df$true_track, function(x) { 
        if ((x >= norte1noroeste2 && x <= 360) || (x >= 0 && x < nordeste1norte2)){
            # print(paste(x," é norte!"))
            x <- paste(filespath, "norte.png", sep="")
        }
        else if (x >= nordeste1norte2 && x < leste1nordeste2){
            # print(paste(x," é nordeste!"))
            x <- paste(filespath, "nordeste.png", sep="")
        }
        else if (x >= leste1nordeste2 && x < sudeste1leste2){
            # print(paste(x," é leste!"))
            x <- paste(filespath, "leste.png", sep="")
        }
        else if (x >= sudeste1leste2 && x < sul1sudeste2){
            # print(paste(x," é sudeste!"))
            x <- paste(filespath, "sudeste.png", sep="")
        }
        else if (x >= sul1sudeste2 && x < sudoeste1sul2){
            # print(paste(x," é sul!"))
            x <- paste(filespath, "sul.png", sep="")
        }
        else if (x >= sudoeste1sul2 && x < oeste1sudoeste2){
            # print(paste(x," é sudoeste!"))
            x <- paste(filespath, "sudoeste.png", sep="")
        }
        else if (x >= oeste1sudoeste2 && x < noroeste1oeste2){
            # print(paste(x," é oeste!"))
            x <- paste(filespath, "oeste.png", sep="")
        }
        else if (x >= noroeste1oeste2 && x < norte1noroeste2){
            # print(paste(x," é noroeste!"))
            x <- paste(filespath, "noroeste.png", sep="")
        }
        else{
            print(paste(x," deu creps!"))
            x <- paste(filespath, "oeste.png", sep="")
        }
    })
    #===================================================

    # Seta os ícones com o resultado do processamento
    get_states_df$icon <- result
    
    # print("")
    # print("STATES depois: ")
    # print(get_states_df[1:500,]$icon)
    # ------------------------ END GET ------------------------
    return (get_states_df)
}

## SERVER ##
server <- function(input, output, session) {
    shipIcon <- makeAwesomeIcon(icon = "samuicon",
                            iconRotate = 60,
                            squareMarker = TRUE,
                            markerColor = "black")

    output$map <- renderLeaflet({
        csv_data <- read.csv("../states.csv")

        # # Faz uma atualização dos dados de voos atuais
        current_status <<- get_current_status()

        # first_lat = current_status[1,]$LATITUDE
        # first_lng = current_status[1,]$LONGITUDE
       
        leaflet()%>%
        addTiles() %>%
        # setView(lng=first_lng, 
                # lat=first_lat, 
                # zoom=6
        # ) %>%
        
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
        
        # samu = makeIcon("samuicon.png"),

        # # Adiciona marcadores através de pontos obtidos do GET
        # x <- "airplane.png"
        # x <- "http://www.iconarchive.com/download/i91814/icons8/windows-8/Transport-Airplane-Mode-On.ico"
        
        # shipIcon <- makeIcon("airplane.png", iconRotate = 90)
        
        # addAwesomeMarkers( data = current_status,
        # addAwesomeMarkers( data = csv_data,
        addMarkers( data = current_status,
                    lng = ~LONGITUDE, 
                    lat = ~LATITUDE,
                    # icon = list(
                        # iconUrl = "http://www.iconarchive.com/download/i91814/icons8/windows-8/Transport-Airplane-Mode-On.ico",
                        # iconSize = c(20, 20)
                    # ),
                    icon = makeIcon(~icon, iconWidth = 15, iconHeight = 15,),
                    # icon = JS(paste('L.icon({ iconUrl:', x, ', iconSize: [40, 40] })'))
                    # icon = makeIcon("", iconWidth = 24, iconHeight = 24)
                    # options = markerOptions(rotationAngle = c(90))
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