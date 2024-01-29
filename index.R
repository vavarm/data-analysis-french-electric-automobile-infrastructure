# import libraries
library(shiny)
library(shinyWidgets)

source("ui.R")
source("server.R")

shinyApp(ui = ui, server = server)
