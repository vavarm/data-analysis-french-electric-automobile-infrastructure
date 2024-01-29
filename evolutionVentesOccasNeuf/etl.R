# load data
df <- read.csv("data/evolutionVentesOccasNeuf.csv", sep = ",")

# add a column with the percentage of used cars sold
df$PercentageOccas <- df$Occasion / (df$Occasion + df$Neuf)

df$TotalVentes <- df$Occasion + df$Neuf

# write the data to a csv file
write.csv(df, "data/etl.csv", row.names = FALSE)
