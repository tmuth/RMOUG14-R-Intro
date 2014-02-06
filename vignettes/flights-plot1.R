require(dplyr) 
library(plyr)
library(data.table)

setwd("M:/Dropbox/MyFiles/Presentations/RMOUG 2014/Intro to R/data/flights-split")
load("flights.new.Rda")

setkey(flights.new,Origin)
airports <- data.table(read.csv("airports.csv"))
airports <- rename(airports, c("iata"="Origin"))
setkey(airports,Origin)
airports$latLong <- paste(airports$lat,airports$long,sep=":")
flights.new.merged <- merge(x=flights.new,y=airports)


flights.sum <- ddply(flights.new.merged,  .(Origin,latLong),
      summarize, 
      Delay=round(mean(ArrDelay,na.rm = TRUE),1))

require(googleVis)
sites2 <- gvisGeoChart(flights.sum ,locationvar="latLong",hovervar="Origin", 
                       sizevar="Delay",
                       options=list(height=600, width=800, region="US", displayMode='markers',DataMode='markers',
                                    resolution="provinces" , gvis.editor="Edit",
                                    colorAxis="{colors:['#f5f5f5', '#ff0000']}"))
plot(sites2)