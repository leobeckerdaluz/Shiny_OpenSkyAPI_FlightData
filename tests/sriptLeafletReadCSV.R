# library(leaflet)
# library(magrittr)

# csv_file_path = "./voo.csv"
# csv_data <- read.csv(csv_file_path)
# csv_data

# #pal <- colorFactor(palette = c("blue", "red", "green"),
# #              levels = c("Public", "Private", "For-Profit"))
# pal <- colorNumeric(palette = c("green", "yellow", "red"), domain = c(600:12000))

# leaflet()%>%
#   addTiles() %>%
#   #addPolylines(data = mydf2, lng = ~long, lat = ~lat, group = ~group)
#   #addMarkers(data = csv_data, 
#   #             lng = ~LONGITUDE, 
#   #             lat = ~LATITUDE, 
#   #             group = ~TIMESTAMP)
#   addMarkers(data = csv_data[1,], 
#              icon = list(
#                iconUrl = 'http://www.iconarchive.com/download/i91814/icons8/windows-8/Transport-Airplane-Mode-On.ico',
#                iconSize = c(20, 20)
#              )) %>%
#   addCircleMarkers(data = csv_data, 
#                    lng = ~LONGITUDE, 
#                    lat = ~LATITUDE, 
#                    radius = 2,
#                    color = ~pal(COLOR))
  







get_direction <- function(true_track) {
	if (true_track > 50)
		direction <- "esquerda"

	direction <- "esquerda"
	return (direction) 
}


if (!require('httr')) install.packages('httr')
require("httr")
if (!require('jsonlite')) install.packages('jsonlite')
require("jsonlite")      

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
print(paste("leste: ", leste1nordeste2, " até ", leste1nordeste2))
print(paste("sudeste: ", sudeste1leste2, " até ", sul1sudeste2))
print(paste("sul: ", sul1sudeste2, " até ", sudoeste1sul2))
print(paste("sudoeste: ", sudoeste1sul2, " até ", oeste1sudoeste2))
print(paste("oeste: ", oeste1sudoeste2, " até ", noroeste1oeste2))
print(paste("noroeste: ", noroeste1oeste2, " até ", norte1noroeste2))

# Processa o valor de TRUE_TRACK e seta o ícone
result <- sapply(get_states_df$true_track, function(x) { 
    if ((x >= norte1noroeste2 && x <= 360) || (x >= 0 && x < nordeste1norte2)){
        # print(paste(x," é norte!"))
        x <- "norte.png"
    }
    else if (x >= nordeste1norte2 && x < leste1nordeste2){
        # print(paste(x," é nordeste!"))
        x <- "nordeste.png"
    }
    else if (x >= leste1nordeste2 && x < leste1nordeste2){
        # print(paste(x," é leste!"))
        x <- "leste.png"
    }
    else if (x >= sudeste1leste2 && x < sul1sudeste2){
        # print(paste(x," é sudeste!"))
        x <- "sudeste.png"
    }
    else if (x >= sul1sudeste2 && x < sudoeste1sul2){
        # print(paste(x," é sul!"))
        x <- "sul.png"
    }
    else if (x >= sudoeste1sul2 && x < oeste1sudoeste2){
        # print(paste(x," é sudoeste!"))
        x <- "sudoeste.png"
    }
    else if (x >= oeste1sudoeste2 && x < noroeste1oeste2){
        # print(paste(x," é oeste!"))
        x <- "oeste.png"
    }
    else if (x >= noroeste1oeste2 && x < norte1noroeste2){
        # print(paste(x," é noroeste!"))
        x <- "noroeste.png"
    }
    else{
        print(paste(x," deu creps!"))
        x <- "left.png"
    }
})
#===================================================

# # Seta os ícones com o resultado do processamento
# get_states_df$icon <- result
# print("")
# print("STATES depois: ")
# print(get_states_df$icon)