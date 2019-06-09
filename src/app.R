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

# ## GET FILES ##
# # Get all filepaths
# diretorios <- c("calsign1", "calsign2", "calsign3", "calsign4", "calsign5")
# # # Get only folder names
# #folder_names <- list.dirs(path = "./motionsense", full.names = FALSE, recursive = TRUE)
# #folder_names <- folder_names[-1]
# # # Nomeia a lista de diretórios
# #names(diretorios) <- folder_names
# ICAO24_list = c("e4936a", "e4904c", "e48ac5")


# # Shiny App
if(!exists("ui", mode="function"))
	source("ui.R")
if(!exists("server", mode="function"))
	source("server.R")

shinyApp(ui, server)