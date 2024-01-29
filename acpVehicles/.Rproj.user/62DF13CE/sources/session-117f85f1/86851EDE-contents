# import libraries
library(shiny)
library(shinyWidgets)
library(ggplot2)
library(FactoMineR)
library(factoextra)

source("ui.R")

# define server
server <- shinyServer(function(input, output) {
  # ACP on df on variables:
  # quali: Brand, Model
  # quanti: AccelSec, TopSpeed_KmH, Range_Km, Efficiency_WhKm, Seats, PriceEuro
  # Select relevant variables for PCA
  quali_vars <- c("Brand")
  quanti_vars <- c("AccelSec", "TopSpeed_KmH", "Range_Km", "Efficiency_WhKm", "Seats", "PriceEuro")
  # inverse the AccelSec values
  df$AccelSec <- 1 / df$AccelSec
  df_pca <- df[, c(quanti_vars, quali_vars)]

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
})
