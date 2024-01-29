# import libraries
library(shiny)
library(shinyWidgets)
library(ggplot2)

source("ui.R")

# define server
server <- shinyServer(function (input, output) {
  output$barplot <- renderPlot({
    
    max_first_axis <- max(df[df$Annee %in% input$Annee, ]$Occasion + df[df$Annee %in% input$Annee, ]$Neuf)
    min_first_axis <- 0
    max_second_axis <- 100
    min_second_axis <- 0
    
    print(df)
    # print the dataframe with the selected years
    print(df[df$Annee %in% input$Annee, ])
    
    cat("Max first axis: ", max_first_axis, "\n")
    cat("Min first axis: ", min_first_axis, "\n")
    cat("Max second axis: ", max_second_axis, "\n")
    cat("Min second axis: ", min_second_axis, "\n")
    
    # scale and shift variables calculated based on desired mins and maxes
    scale = (max_second_axis - min_second_axis)/(max_first_axis - min_first_axis)
    shift = min_first_axis - min_second_axis
    
    cat("Scale: ", scale)
    
    cat("Shift: ", shift)
    
    # Function to scale secondary axis
    scale_function <- function(x, scale, shift){
      return ((x)*scale - shift)
    }
    
    # Function to scale secondary variable values
    inv_scale_function <- function(x, scale, shift){
      return ((x + shift)/scale)
    }
    
    if (input$showPercentage){
      ggplot(df[df$Annee %in% input$Annee, ], aes(x = factor(Annee))) +
        geom_bar(aes(y = TotalVentes, fill = "Neufs"), stat = "identity") +
        geom_bar(aes(y = Occasion, fill = "Occasions"), stat = "identity") +
        geom_point(aes(y = inv_scale_function(PercentageOccas * 100, scale, shift)), color = "blue", size = 3) +
        geom_text(aes(y = inv_scale_function(PercentageOccas * 100, scale, shift), label = paste(round(PercentageOccas * 100), "%")),
                  vjust = -0.5, color = "blue", position = position_dodge(width = 0.8)) +
        geom_line(aes(y = inv_scale_function(PercentageOccas * 100, scale, shift)), color = "blue", group = 1) +
        scale_y_continuous(limits=c(min_first_axis, max_first_axis), labels = scales::comma_format(scale = 1e-6),
                           sec.axis = sec_axis(~ scale_function(., scale, shift),
                                               name = "Pourcentage de voitures d'occasion vendues")) +
        labs(x = "Année", y = "Nombre de voitures vendues (en millions)", fill = "Type de vente") +
        theme(legend.position = "bottom", axis.line.y.right = element_line(color = "blue"), axis.text.y.right = element_text(color = "blue"), axis.title.y.right = element_text(color = "blue"))
    } else {
      ggplot(df[df$Annee %in% input$Annee, ], aes(x = factor(Annee))) +
        geom_bar(aes(y = TotalVentes, fill = "Neufs"), stat = "identity") +
        geom_bar(aes(y = Occasion, fill = "Occasions"), stat = "identity") +
        scale_y_continuous(limits=c(min_first_axis, max_first_axis), labels = scales::comma_format(scale = 1e-6)) +
        labs(x = "Année", y = "Nombre de voitures vendues (en millions)", fill = "Type de vente") +
        theme(legend.position = "bottom")
    }
    
  })
})