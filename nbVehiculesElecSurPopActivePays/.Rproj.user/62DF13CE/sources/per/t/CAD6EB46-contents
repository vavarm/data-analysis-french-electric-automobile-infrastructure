# import libraries
library(shiny)
library(ggplot2)

server <- shinyServer(function(input, output) {
  output$plot <- renderPlot({
    ggplot(popActiveParPaysNbVehiculesElecVendus2022[popActiveParPaysNbVehiculesElecVendus2022$Pays %in% append(input$pays, 'France'),], aes(x = reorder(Pays, NbVehiculesElecVendus2022Par1000Actifs), y = NbVehiculesElecVendus2022Par1000Actifs, fill = ifelse(Pays == "France", "France", "Other"))) +
      geom_bar(stat = "identity") +
      coord_flip() +
      labs(title = "Nombre de véhicules électriques vendus par 1000 personnes actives en 2022", x = "Pays", y = "Nombre de véhicules électriques vendus par 1000 personnes actives") +
      geom_text(aes(label = NbVehiculesElecVendus2022Par1000Actifs), hjust = -0.1, size = 3) +
      scale_fill_manual(values = c("France" = "#FF0000", "Others" = "#000000")) +
      guides(fill=FALSE)
  })
})