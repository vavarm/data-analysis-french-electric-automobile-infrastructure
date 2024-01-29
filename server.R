# import libraries
library(shiny)
library(shinyWidgets)
library(ggplot2)
library(FactoMineR)
library(factoextra)
library(plotly)

source("ui.R")

# define server
server <- shinyServer(function(input, output) {
  ###### ACP ######
  # ACP on df on variables:
  # quali: Brand, Model
  # quanti: AccelSec, TopSpeed_KmH, Range_Km, Efficiency_WhKm, Seats, PriceEuro
  # Select relevant variables for PCA
  quali_vars <- c("Brand")
  quanti_vars <- c("AccelSec", "TopSpeed_KmH", "Range_Km", "Efficiency_WhKm", "Seats", "PriceEuro")
  # inverse the AccelSec values
  df_acp$AccelSec <- 1 / df_acp$AccelSec
  df_pca <- df_acp[, c(quanti_vars, quali_vars)]
  
  # Perform PCA
  resPCA <- PCA(df_pca, graph = FALSE, quali.sup = quali_vars)
  
  # Display the sum of the two first eigen values
  output$sum_eigenvalues <- renderText({
    paste("Part des deux premières valeurs propres: ", sum(resPCA$eig[1:2, 2]), "%")
  })
  output$plotEigen <- renderPlot({
    # Plot the bar plot of the first two principal components
    barplot(resPCA$eig[, 2],
            names.arg = rownames(resPCA$eig), col = "skyblue",
            main = "Bar Plot of Eigenvalues",
            xlab = "Principal Components", ylab = "Eigenvalues"
    )
  })
  output$plotCumulativeEigen <- renderPlot({
    barplot(resPCA$eig[, 3],
            names.arg = rownames(resPCA$eig), col = "skyblue",
            main = "Bar Plot of cumulative Eigenvalues",
            xlab = "Principal Components", ylab = "Cumulative Eigenvalues"
    )
  })
  output$plotOfInd <- renderPlot({
    plot.PCA(resPCA, axes = c(1, 2), choix = "ind")
  })
  
  output$plotOfIndWithBrands <- renderPlot({
    # Get individual coordinates
    ind_coords <- resPCA$ind$coord
    
    # Create a new data frame with individual coordinates and Brand information
    ind_df <- data.frame(Brand = df_pca$Brand, ind_coords)
    
    # Calculate average coordinates for each Brand
    avg_coords <- aggregate(. ~ Brand, data = ind_df, FUN = mean)
    
    # Plot the individuals with ggplot2
    ggplot(ind_df, aes(x = Dim.1, y = Dim.2, color = Brand)) +
      geom_point(size = 3) +
      geom_text(data = avg_coords, aes(label = Brand), size = 5, color = "black") +
      theme(legend.position = "none")
  })
  
  output$plotOfVar <- renderPlot({
    # plot the variables
    plot.PCA(resPCA, axes = c(1, 2), choix = "var")
  })
  
  output$plotOfVarContribAxis1 <- renderPlot({
    fviz_contrib(resPCA, choice = "var", axes = 1)
  })
  
  output$plotOfVarContribAxis2 <- renderPlot({
    fviz_contrib(resPCA, choice = "var", axes = 2)
  })
  ###### Fin ACP ######
  
  
  ###### Evolution des ventes entre véhicules d'occasion et véhicules neufs ######*

  output$barplotEvoVentesOccasNeuf <- renderPlot({
    
    max_first_axis <- max(df_evoVentesOccasNeuf[df_evoVentesOccasNeuf$Annee %in% input$Annee, ]$Occasion + df_evoVentesOccasNeuf[df_evoVentesOccasNeuf$Annee %in% input$Annee, ]$Neuf)
    min_first_axis <- 0
    max_second_axis <- 100
    min_second_axis <- 0
    
    print(df_evoVentesOccasNeuf)
    # print the dataframe with the selected years
    print(df_evoVentesOccasNeuf[df_evoVentesOccasNeuf$Annee %in% input$Annee, ])
    
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
      ggplot(df_evoVentesOccasNeuf[df_evoVentesOccasNeuf$Annee %in% input$Annee, ], aes(x = factor(Annee))) +
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
      ggplot(df_evoVentesOccasNeuf[df_evoVentesOccasNeuf$Annee %in% input$Annee, ], aes(x = factor(Annee))) +
        geom_bar(aes(y = TotalVentes, fill = "Neufs"), stat = "identity") +
        geom_bar(aes(y = Occasion, fill = "Occasions"), stat = "identity") +
        scale_y_continuous(limits=c(min_first_axis, max_first_axis), labels = scales::comma_format(scale = 1e-6)) +
        labs(x = "Année", y = "Nombre de voitures vendues (en millions)", fill = "Type de vente") +
        theme(legend.position = "bottom")
    }
    
  })

  ###### Fin Evolution des ventes entre véhicules d'occasion et véhicules neufs ######
  
  ###### Evolution Immat ######
  
  # Prendre les noms de colonnes dans la variable annee
  annee <- colnames(df_evoImmat)
  # Retirer la première colonne et les X dans les noms
  annee <- annee[-1]
  annee <- gsub("X", "", annee)
  
  # Pour toutes les valeurs dans data, les ajouter dans la variable nbVehicule
  nbVehicule <- c()
  for (i in 1:nrow(df_evoImmat)) {
    for (j in 2:ncol(df_evoImmat)) {
      nbVehicule <- c(nbVehicule, df_evoImmat[i,j])
    }
  }
  
  annee <- as.numeric(annee)
  # Faire une régression exponentielle pour avoir une courbe plus lisse
  regression <- lm(log(nbVehicule) ~ annee)
  predicted_values <- exp(predict(regression, newdata = data.frame(annee = annee)))
  predicted_values <- as.numeric(round(predicted_values))
  
  nbVehicules <- nbVehicule
  nbVehicules <- as.numeric(nbVehicules)
  
  plot_data <- data.frame(annee,nbVehicules)
  
  # Prédire les valeurs pour les années 2021 à 2035
  future_years <- seq(2021, 2035, by = 1)
  predicted_values_future <- exp(predict(regression, newdata = data.frame(annee = future_years)))
  
  # Ajouter les prédictions au data.frame plot_data
  plot_data_future <- data.frame(annee = c(plot_data$annee, future_years),
                                 nbVehicules = c(plot_data$nbVehicules, round(predicted_values_future)))
  
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
  
  ###### Fin Evolution Immat ######
  
  ###### Evolution nombre bornes de recharge ######
  
  df_evoNbBornes$date_mise_en_service <- as.Date(df_evoNbBornes$date_mise_en_service)
  
  # Regrouper les données par année
  annees <- format(df_evoNbBornes$date_mise_en_service, "%Y")
  # Enlever les NA de la colonne annees
  annees <- as.factor(annees[!is.na(annees)])
  # Compter le nombre de bornes par année
  bornes_par_annee <- table(annees)
  
  # Créer un data frame avec les données
  df <- data.frame(bornes_par_annee)

  # ggplot du nombre de nouvelles des bornes par année
  p1 <- ggplot(df, aes(x = annees, y = bornes_par_annee, fill= annees)) +
    geom_bar(stat = "identity") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    labs(x = "Années", y = "Nombre de bornes", title = "Nombre de nouvelles des bornes par année") +
    theme(plot.title = element_text(hjust = 0.5)) +
    theme_minimal()
  
  # ggplot du nombre cumulées des bornes par année
  p2 <- ggplot(df, aes(x = annees, y = cumsum(bornes_par_annee), fill= annees)) +
    geom_bar(stat = "identity") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    labs(x = "Années", y = "Nombre de bornes", title = "Nombre cumulées des bornes par année") +
    theme(plot.title = element_text(hjust = 0.5)) +
    theme_minimal()
  
output$evBornes <- renderPlotly({
  ggplotly(p1) %>% config(displayModeBar = FALSE, editable = FALSE)
})
output$evBornesCumul <- renderPlotly({
  ggplotly(p2) %>% config(displayModeBar = FALSE, editable = FALSE)
})
  
  # Faire la meme chose mais pour le nombre de point de charge par années
  # Regrouper les données par année
  sub_data <- subset(df_evoNbBornes, !is.na(df_evoNbBornes$date_mise_en_service))
  point_de_charge <- sub_data$nbre_pdc
  annees <- format(sub_data$date_mise_en_service, "%Y")
  # Pour toutes les bornes qui n'ont pas de date_mise_en_service, on les retire du point de charge
  test <- table(sub_data$nbre_pdc)
  somme <- sum(sub_data$nbre_pdc)
  
  dataFrame <- data.frame(point_de_charge, annees)
  # Compter le nombre de bornes par année
  pointDECHARGE <- df_evoNbBornes %>%
    filter(!is.na(date_mise_en_service)) %>%
    group_by(annees = format(date_mise_en_service, "%Y")) %>%
    summarise(Freq = sum(nbre_pdc))
  
  p3 <- ggplot(pointDECHARGE, aes(x = annees, y = Freq, fill = annees)) +
    geom_bar(stat = "identity") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    labs(x = "Années", y = "Nombre de nouveau point de charge", title = "Nombre de nouveau point de charge par année") +
    theme(plot.title = element_text(hjust = 0.5)) +
    theme_minimal()

output$evPointsCharge <- renderPlotly({
  ggplotly(p3) %>% config(displayModeBar = FALSE, editable = FALSE)
})
  
  # cumulé
  pointDECHARGECUMU <- df_evoNbBornes %>%
    filter(!is.na(date_mise_en_service)) %>%
    group_by(annees = format(date_mise_en_service, "%Y")) %>%
    summarise(Freq = sum(nbre_pdc)) %>%
    mutate(Freq = cumsum(Freq))
  
  p4 <- ggplot(pointDECHARGECUMU, aes(x = annees, y = Freq, fill = annees)) +
    geom_bar(stat = "identity") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    labs(x = "Années", y = "Nombre cumulé de nouveau point de charge", title = "Nombre cumulé de nouveau point de charge par année") +
    theme(plot.title = element_text(hjust = 0.5)) +
    theme_minimal()
  
output$evPointsChargeCumul <- renderPlotly({
  ggplotly(p4) %>% config(displayModeBar = FALSE, editable = FALSE)
})
  
  ##### Fin Evolution nombre bornes de recharge ######

  ##### Ratio nombre de véhicules électriques / population active #####

output$evRatioPopAct <- renderPlot({
  ggplot(popActiveParPaysNbVehiculesElecVendus2022[popActiveParPaysNbVehiculesElecVendus2022$Pays %in% append(input$pays, 'France'),], aes(x = reorder(Pays, NbVehiculesElecVendus2022Par1000Actifs), y = NbVehiculesElecVendus2022Par1000Actifs, fill = ifelse(Pays == "France", "France", "Other"))) +
    geom_bar(stat = "identity") +
    coord_flip() +
    labs(title = "Nombre de véhicules électriques vendus par 1000 personnes actives en 2022", x = "Pays", y = "Nombre de véhicules électriques vendus par 1000 personnes actives") +
    geom_text(aes(label = NbVehiculesElecVendus2022Par1000Actifs), hjust = -0.1, size = 3) +
    scale_fill_manual(values = c("France" = "#FF0000", "Others" = "#000000")) +
    guides(fill=FALSE)
})

  ##### Fin Ratio nombre de véhicules électriques / population active #####
})