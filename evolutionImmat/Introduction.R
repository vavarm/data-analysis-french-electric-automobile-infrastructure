library(FactoMineR)
library(factoextra)
library(ggplot2)
library(plotly)

# Importation des données
data <- read.csv("evolution_nbVoiture.csv")

# Prendre les noms de colonnes dans la variable annee
annee <- colnames(data)
# Retirer la première colonne et les X dans les noms
annee <- annee[-1]
annee <- gsub("X", "", annee)

# Pour toutes les valeurs dans data, les ajouter dans la variable nbVehicule
nbVehicule <- c()
for (i in 1:nrow(data)) {
  for (j in 2:ncol(data)) {
    nbVehicule <- c(nbVehicule, data[i,j])
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

# Faire un graphique pour voir l'évolution du nombre de véhicule avec les prédictions
p <- ggplot(plot_data_future, aes(x = annee, y = nbVehicules)) +
  geom_line(color = "darkgreen", linetype = "dashed") +
  geom_point(color = "darkgreen") +
  # En vert les années de 2000 à 2020
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
    axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0))  # Ajuster la marge du titre de l'axe y
  ) +
  scale_x_continuous(breaks = seq(2000, 2035, by = 1)) +
  # scale y axis qui est "normal" jusqu'en 2020 et log à partir de 2021
  scale_y_log10(labels = scales::comma) +

ggplotly(p)

