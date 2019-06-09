if (!require('httr')) install.packages('httr')
require("httr")
if (!require('jsonlite')) install.packages('jsonlite')
require("jsonlite")

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