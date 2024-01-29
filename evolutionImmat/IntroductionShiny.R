# Faire la page shiny où l'on peut voir le graphique avec les points qui affiche la valeur au survole de la souris
library(shiny)
library(shinydashboard)
library(ggplot2)
library(plotly)

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "Electric Vehicle Registration"),
  dashboardSidebar(),
  dashboardBody(
    # Display the plot in the main body
    fluidRow(
      box(
        title = "Electric Vehicle Registration",
        status = "primary",
        solidHeader = TRUE,
        width = 12,
        plotlyOutput("evPlot")
      )
    )
  )
)

# Define server
server <- function(input, output) {
  # Render the plot
  output$evPlot <- renderPlotly({
    p <- ggplot(plot_data_future, aes(x = annee, y = nbVehicules)) +
      geom_line(color = "darkgreen", linetype = "dashed") +
      geom_point(color = "darkgreen") +
      geom_line(data = plot_data, aes(x = annee, y = nbVehicules), color = "green") +
      geom_point(data = plot_data, aes(x = annee, y = nbVehicules), color = "green") +
      labs(
        title = "Nombre d'immatriculations des voitures particulières \n neuves électriques en France de 2000 à 2035",
        x = "Années",
        y = "Immatriculations des voitures particulières neuves"
      ) +
      theme_minimal() +
      theme(
        plot.title = element_text(hjust = 0.5),
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0))
      ) +
      scale_x_continuous(breaks = seq(2000, 2035, by = 1)) +
      scale_y_log10(labels = scales::comma)

    ggplotly(p) %>% config(displayModeBar = FALSE, editable = FALSE)

    })
}

# Run the app
shinyApp(ui, server)

