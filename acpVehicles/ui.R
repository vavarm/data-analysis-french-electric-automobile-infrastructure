# import libraries
library(shiny)
library(shinyWidgets)

df <- read.csv("data/ElectricCarData_Clean.csv", sep = ",")

# define UI
ui <- fluidPage(
  titlePanel("ACP sur un dataset sur des véhicules électriques"),
  sidebarLayout(
    sidebarPanel(
      textOutput("sum_eigenvalues")
    ),
    mainPanel(
      # display the barplots in a row
      fluidRow(
        column(6, plotOutput("plotEigen")),
        column(6, plotOutput("plotCumulativeEigen"))
      ),
      fluidRow(
        column(6, plotOutput("plotOfInd")),
        column(6, plotOutput("plotOfIndWithBrands"))
      ),
      fluidRow(
        column(4, plotOutput("plotOfVar")),
        column(4, plotOutput("plotOfVarContribAxis1")),
        column(4, plotOutput("plotOfVarContribAxis2"))
      )
    )
  )
)
