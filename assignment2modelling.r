setwd("D:\\dropbox\\Dropbox\\36103\\assignment2")

library(readr)
library(dplyr)
library(tidyr)

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
energy_consumption = rename(energy_consumption , Country =  `Country name` )

#join on fat consumption and country groupings
energy_country_frame <- left_join(energy_consumption, country_groupings, by = "Country"   )


#join on continent list
continentlist <- continentlist [1:2]

energy_country_frame <- left_join(continentlist, fat_country_frame, by = "Country"   )


##TODO##
## join the three frames and create a composite frame
## http://stackoverflow.com/questions/26611717/can-dplyr-join-on-multiple-columns-or-composite-key

