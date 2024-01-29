# import libraries
library(shiny)
library(shinyWidgets)

df <- read.csv("data/etl.csv", sep = ",")

# define UI
ui <- fluidPage(
  titlePanel("Evolution des ventes de voitures neuves et d'occasion en France"),
  sidebarLayout(
    sidebarPanel(
      pickerInput(
        inputId = "Annee",
        label = "Choisissez les années à afficher",
        choices = df$Annee,
        selected = df$Annee,
        multiple = TRUE
      ),
      checkboxInput(
        inputId = "showPercentage",
        label = "Afficher le pourcentage de voitures d'occasion vendues",
        value = TRUE)
    ),
    mainPanel(
      plotOutput("barplot")
    )
  )
)