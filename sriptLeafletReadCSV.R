library(leaflet)
library(magrittr)

csv_file_path = "./voo.csv"
csv_data <- read.csv(csv_file_path)
csv_data

#pal <- colorFactor(palette = c("blue", "red", "green"),
#              levels = c("Public", "Private", "For-Profit"))
pal <- colorNumeric(palette = c("green", "yellow", "red"), domain = c(600:12000))

leaflet()%>%
  addTiles() %>%
  #addPolylines(data = mydf2, lng = ~long, lat = ~lat, group = ~group)
  #addMarkers(data = csv_data, 
  #             lng = ~LONGITUDE, 
  #             lat = ~LATITUDE, 
  #             group = ~TIMESTAMP)
  addMarkers(data = csv_data[1,], 
             icon = list(
               iconUrl = 'http://www.iconarchive.com/download/i91814/icons8/windows-8/Transport-Airplane-Mode-On.ico',
               iconSize = c(20, 20)
             )) %>%
  addCircleMarkers(data = csv_data, 
                   lng = ~LONGITUDE, 
                   lat = ~LATITUDE, 
                   radius = 2,
                   color = ~pal(COLOR))
  
                 
