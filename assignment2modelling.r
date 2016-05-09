
library(readr)
library(dplyr)
library(tidyr)
library(nlme)
library(gee)
library(geepack)

energy_consumption <- read_csv("energy_consumption.csv")
#measured over slightly different timescales assumed same as the periods are similar
energy_consumption = rename(energy_consumption , `2005-07` =  `2006-08` )
#reshapes according to year
energy_consumption <-  energy_consumption %>% gather ( year , energyvalue , `1990-92`: `2005-07` )


fat_consumption <- read_csv("fat_consumption.csv")
#reshapes according to year
fat_consumption <-  fat_consumption %>% gather ( year , fatvalue , `1990-92`:`2005-07` )

protein_consumption <- read_csv ("protein_consumption.csv")
#reshapes according to year
protein_consumption  <- protein_consumption %>% gather ( year , proteinvalue , `1990-92`:`2005-07` )


country_groupings <- read_csv("countrygroupings.csv")

continentlist <- read_csv("Countries-Continents.csv")

#checks if the country name and country match
#energy_consumption$`Country name` %in% country_groupings$Country

#renaming the country name column to country
#backquote needed due to space in name
energy_consumption = rename(energy_consumption , Country =  `Country name` )

#join on fat consumption and country groupings
energy_country_frame <- left_join(energy_consumption, country_groupings, by = "Country"   )


#join on continent list
continentlist <- continentlist [1:2]

energy_country_frame <- left_join( energy_country_frame, continentlist , by = "Country"   )


#JOINING PROTEIN
#renaming Country Name to Country and getting rid of country code
protein_consumption <- rename(protein_consumption, Country= `Country name`)
protein_consumption <- protein_consumption[-1]
#joining protein
energy_protein_country_frame <- left_join (protein_consumption, energy_country_frame,  by = c( "Country"="Country", "year" = "year" ))

#JOINING FAT
#renaming Country NAme to Country 
fat_consumption <- rename(fat_consumption, Country= `Country name`)
#joining fat
energy_protein_fat_country_frame <- left_join (fat_consumption, energy_protein_country_frame,  by = c( "Country"="Country", "year" = "year" ))

#SETTING UP FACTORS FOR MODELLING
energy_protein_fat_country_frame$`World Group` <- as.factor(energy_protein_fat_country_frame$`World Group`)


energy_protein_fat_country_frame$Continent  <- as.factor( energy_protein_fat_country_frame$Continent) 

energy_protein_fat_country_frame$year <- as.factor(energy_protein_country_frame$year)



#looking for missing values

missingcontinentlist <- is.na (energy_protein_fat_country_frame$Continent)
missingcontinentframe <- energy_protein_fat_country_frame[missingcontinentlist,]


#quick conceit to get the basic modelling working
energy_protein_country_frame_complete <-  energy_protein_fat_country_frame[ complete.cases(energy_protein_fat_country_frame),]

linearfit <- glm( fatvalue ~ year + Continent+ `World Group` + energyvalue + proteinvalue, data= energy_protein_country_frame_complete)

summary(linearfit)

plot(linearfit)


energy_protein_country_frame_complete <- rename ( energy_protein_country_frame_complete, WorldGroup = `World Group` )

energy_protein_country_frame_complete$year <- as.factor(energy_protein_country_frame_complete$year)

energy_protein_country_frame_complete$Region <- as.factor(energy_protein_country_frame_complete$Region)

energy_protein_country_frame_complete$countryid <- as.factor(  energy_protein_country_frame_complete$Country)

energy_protein_country_frame_complete$countryid <- as.numeric(energy_protein_country_frame_complete$countryid )

geefit <- geeglm(fatvalue ~ Continent+WorldGroup+energyvalue+proteinvalue, id = countryid, data= na.omit(energy_protein_country_frame_complete))

summary(geefit)





#TODO
#fix list of missing continents from missingcontinentframe
