library(FactoMineR)
library(factoextra)
library(ggplot2)
library(plotly)
library(dplyr)

# Importation des données
data <- read.csv("borne/bornes.csv", header = TRUE, stringsAsFactors = FALSE)

data$date_mise_en_service <- as.Date(data$date_mise_en_service)

# Regrouper les données par année
annees <- format(data$date_mise_en_service, "%Y")
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

ggplotly(p1)
ggplotly(p2)

# Faire la meme chose mais pour le nombre de point de charge par années
# Regrouper les données par année
sub_data <- subset(data, !is.na(data$date_mise_en_service))
point_de_charge <- sub_data$nbre_pdc
annees <- format(sub_data$date_mise_en_service, "%Y")
# Pour toutes les bornes qui n'ont pas de date_mise_en_service, on les retire du point de charge
test <- table(sub_data$nbre_pdc)
somme <- sum(sub_data$nbre_pdc)

dataFrame <- data.frame(point_de_charge, annees)
# Compter le nombre de bornes par année
pointDECHARGE <- data %>%
  filter(!is.na(date_mise_en_service)) %>%
  group_by(annees = format(date_mise_en_service, "%Y")) %>%
  summarise(Freq = sum(nbre_pdc))

p3 <- ggplot(pointDECHARGE, aes(x = annees, y = Freq, fill = annees)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(x = "Années", y = "Nombre de nouveau point de charge", title = "Nombre de nouveau point de charge par année") +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme_minimal()

ggplotly(p3)

# cumulé
pointDECHARGECUMU <- data %>%
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

ggplotly(p4)

