# import libraries
library(shiny)
library(shinyWidgets)
library(plotly)

addResourcePath("root", "./")

# get datasets
df_acp <- read.csv("acpVehicles/data/ElectricCarData_Clean.csv", sep = ",")
#
df_evoVentesOccasNeuf <- read.csv("evolutionVentesOccasNeuf/data/etl.csv", sep = ",")
#
popActiveParPaysNbVehiculesElecVendus2022 <- read.csv("nbVehiculesElecSurPopActivePays/data/etl.csv", sep = ",")
paysWithoutFrance <- popActiveParPaysNbVehiculesElecVendus2022[popActiveParPaysNbVehiculesElecVendus2022$Pays != "France",]$Pays
# reorder by alphabetical order
paysWithoutFrance <- paysWithoutFrance[order(paysWithoutFrance)]
#
df_evoImmat <- read.csv("evolutionImmat/evolution_nbVoiture.csv")
#
df_evoNbBornes <- read.csv("evolutionNbBornes/data/bornes.csv", header = TRUE, stringsAsFactors = FALSE)

# define UI
ui <- tabsetPanel(
  tabPanel(
    "Accueil",
    fluidPage(
      titlePanel("Accueil"),
      mainPanel(
        fluidPage(
        h1("Bienvenue sur notre application"),
        h2("Cette application a été réalisée dans le cadre du projet Data Science par Matéo, Maxys, Valentin et Suzanne"),
        hr(),
        h1("Thème 3 : Véhicules électriques"),
        h2("Problématique : Quelle est l'évolution des infrastructures et du parc électriques en France ? Est-elle suffisante pour totalement passer à l'électrique ? Les acteurs de l'électrique, vont-ils dans ce sens ?"),
        img(src="PDA.png", height = 200, width = 200),
        )
      ),
    ),
  ),
    tabPanel(
      "ACP véhicules",
      fluidPage(
      titlePanel("ACP véhicules"),
      sidebarLayout(
        sidebarPanel(
          textOutput("sum_eigenvalues"),
          h3("sources:"),
          a(href="https://www.kaggle.com/datasets/geoffnel/evs-one-electric-vehicle-dataset/", "Kaggle"),
        ),
      mainPanel(
        # display the barplots in rows
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
        ),
      ),
      ),
    ),
    ),
    tabPanel(
      "Evolution des ventes entre véhicules d'occasion et véhicules neufs",
      fluidPage(
        titlePanel("Evolution des ventes entre véhicules d'occasion et véhicules neufs"),
        sidebarLayout(
          sidebarPanel(
            pickerInput(
              inputId = "Annee",
              label = "Choisissez les années à afficher",
              choices = df_evoVentesOccasNeuf$Annee,
              selected = df_evoVentesOccasNeuf$Annee,
              multiple = TRUE
            ),
            checkboxInput(
              inputId = "showPercentage",
              label = "Afficher le pourcentage de voitures d'occasion vendues",
              value = TRUE),
            h3("sources:"),
            a(href="https://www.statistiques.developpement-durable.gouv.fr/immatriculations-des-voitures-particulieres-en-2022-forte-baisse-dans-le-neuf-comme-dans-loccasion", "Data Gouv"),
          ),
          mainPanel(
            plotOutput("barplotEvoVentesOccasNeuf")
          )
        ),
      ),
    ),
    tabPanel(
      "Ratio entre le nombre de véhicules électriques et la population active par pays",
      fluidPage(
        titlePanel("Ratio entre le nombre de véhicules électriques et la population active par pays"),
        sidebarLayout(
          sidebarPanel(
            pickerInput(
              inputId = "pays",
              label = "Choisissez les pays à afficher",
              choices = paysWithoutFrance,
              selected = paysWithoutFrance,
              multiple = TRUE,
              options = list(`actions-box` = TRUE)
            ),
            h3("sources:"),
            a(href="https://donnees.banquemondiale.org/indicator/SL.TLF.TOTL.IN", "Banque mondiale"),
            a(href="https://github.com/dataforgoodfr/batch11_e_cartomobile/blob/main/e_cartomobile/data_extract/data_for_viz/IEA-EV-dataEV%20salesCarsHistorical.csv", "DataForGood France"),
          ),
          mainPanel(
            fluidRow(
              plotOutput("evRatioPopAct")
            )
          ),
        ),
      ),
    ),
    tabPanel(
      "Evolution des immatriculations de voitures électriques",
      fluidPage(
        titlePanel("Evolution des immatriculations de voitures électriques"),
        sidebarLayout(
          sidebarPanel(
            h3("sources:"),
            a(href="https://www.statistiques.developpement-durable.gouv.fr/donnees-2020-sur-les-immatriculations-des-vehicules ", "Data Gouv"),
          ),
          mainPanel(
            # Display the plot in the main body
            fluidRow(
                plotlyOutput("evPlot")
            )
          ),
        ),
      ),
    ),
    tabPanel(
      "Evolution du nombre de bornes de recharge",
      fluidPage(
        titlePanel("Evolution du nombre de bornes de recharge"),
        sidebarLayout(
          sidebarPanel(
            h3("sources:"),
            a(href="https://www.data.gouv.fr/fr/datasets/fichier-consolide-des-bornes-de-recharge-pour-vehicules-electriques/", "Data Gouv"),
          ),
          mainPanel(
            fluidRow(
              plotlyOutput("evBornes"),
              plotlyOutput("evBornesCumul"),
            ),
            fluidRow(
              plotlyOutput("evPointsCharge"),
              plotlyOutput("evPointsChargeCumul")
            ),
          ),
        ),
      ),
    ),
    tabPanel(
      "Densité des points de charge par départements",
      titlePanel("Densité des points de charge par départements"),
      sidebarLayout(
        sidebarPanel(
          h3("sources:"),
          a(href="https://www.data.gouv.fr/fr/datasets/fichier-consolide-des-bornes-de-recharge-pour-vehicules-electriques/", "Data Gouv"),
          a(href="https://www.data.gouv.fr/fr/datasets/voitures-particulieres-immatriculees-par-commune-et-par-type-de-recharge/", "Data Gouv"),
          a(href="https://france-geojson.gregoiredavid.fr/", "GeoJSON"),
        ),
        mainPanel(
          tags$iframe(src = "root/carteFinale.html", width = "100%", height = "600px")
        ),
      )
    )
  )
