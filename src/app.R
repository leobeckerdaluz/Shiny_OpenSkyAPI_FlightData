# # Shiny App
if(!exists("ui", mode="function"))
	source("ui.R")
if(!exists("server", mode="function"))
	source("server.R")

shinyApp(ui, server)