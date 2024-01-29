# import libraries
library(shiny)
library(shinyWidgets)

# import data
popActiveParPaysNbVehiculesElecVendus2022 <- read.csv("data/etl.csv", sep = ",")

paysWithoutFrance <- popActiveParPaysNbVehiculesElecVendus2022[popActiveParPaysNbVehiculesElecVendus2022$Pays != "France",]$Pays
# reorder by alphabetical order
paysWithoutFrance <- paysWithoutFrance[order(paysWithoutFrance)]

ui <- fluidPage(
  titlePanel("Nombre de véhicules électriques vendus par 1000 personnes actives en 2022"),
  sidebarLayout(
    sidebarPanel(
      pickerInput(
        inputId = "pays",
        label = "Choisissez les pays à afficher",
        choices = paysWithoutFrance,
        selected = paysWithoutFrance,
        multiple = TRUE,
        options = list(`actions-box` = TRUE)
      )
    ),
    mainPanel(
      plotOutput("plot")
    )
  )
)