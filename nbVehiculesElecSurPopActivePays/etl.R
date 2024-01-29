popActiveParPaysPath <- "data/popActiveParPays/popActiveParPays.csv"
popActiveParPays <- read.csv(popActiveParPaysPath, sep = ",")
popActiveParPays
# create a datatable with only the columns Country and "2022"
popActiveParPays <- popActiveParPays[, c("CountryName", "X2022")]
popActiveParPays
# rename the columns
colnames(popActiveParPays) <- c("Pays", "PopulationActive")

nbVehiculesElecVendusParPaysPath <- "data/nbVehiculesElecVendusParPays/IEA-EV-dataEV salesCarsHistorical.csv"
nbVehiculesElecVendusParPays <- read.csv(nbVehiculesElecVendusParPaysPath, sep = ",")
# select only the rows with a year equal to 2022
nbVehiculesElecVendusParPays2022 <- nbVehiculesElecVendusParPays[nbVehiculesElecVendusParPays$year == "2022",]
nbVehiculesElecVendusParPays2022
# group by region
nbVehiculesElecVendusParPays2022 <- aggregate(nbVehiculesElecVendusParPays2022$value, list(nbVehiculesElecVendusParPays2022$region), FUN=sum)
nbVehiculesElecVendusParPays2022
# rename the columns
colnames(nbVehiculesElecVendusParPays2022) <- c("Country", "NbVehiculesElecVendus2022")

# get countries in french
pays <- read.csv("data/pays/countries.csv", sep = ",")
# get countries in english
paysEn <- read.csv("data/countries/countries.csv", sep = ",")
# merge the two dataframes by id
pays <- merge(pays, paysEn, by.x = "id", by.y = "id")
# select only the column we want to display
pays <- pays[, c("name.x", "name.y")]
# rename the columns
colnames(pays) <- c("Pays", "Country")

# merge the countries with the population active
popActiveParPays<- merge(pays, popActiveParPays, by.x = "Pays", by.y = "Pays")
# merge the population active with the number of electric vehicles sold
popActiveParPaysNbVehiculesElecVendus2022 <- merge(popActiveParPays, nbVehiculesElecVendusParPays2022, by.x = "Country", by.y = "Country")
popActiveParPaysNbVehiculesElecVendus2022
# create a new column with the number of electric vehicles sold per 1000 active people
popActiveParPaysNbVehiculesElecVendus2022$NbVehiculesElecVendus2022Par1000Actifs <- popActiveParPaysNbVehiculesElecVendus2022$NbVehiculesElecVendus2022 / popActiveParPaysNbVehiculesElecVendus2022$PopulationActive * 1000
popActiveParPaysNbVehiculesElecVendus2022
# sort the dataframe by the number of electric vehicles sold per 1000 active people
popActiveParPaysNbVehiculesElecVendus2022 <- popActiveParPaysNbVehiculesElecVendus2022[order(popActiveParPaysNbVehiculesElecVendus2022$NbVehiculesElecVendus2022Par1000Actifs, decreasing = TRUE),]
# select only the columns we want to display
popActiveParPaysNbVehiculesElecVendus2022 <- popActiveParPaysNbVehiculesElecVendus2022[, c("Pays", "NbVehiculesElecVendus2022Par1000Actifs")]
# round the number of electric vehicles sold per 1000 active people
popActiveParPaysNbVehiculesElecVendus2022$NbVehiculesElecVendus2022Par1000Actifs <- round(popActiveParPaysNbVehiculesElecVendus2022$NbVehiculesElecVendus2022Par1000Actifs, digits = 1)
# display the dataframe
popActiveParPaysNbVehiculesElecVendus2022

# write the dataframe in a csv file
write.csv(popActiveParPaysNbVehiculesElecVendus2022, "data/etl.csv", row.names = FALSE)
