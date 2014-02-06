library(data.table)
setwd("D:/Temp/on-time-flight-data")
save(flights,file="flights.Rda")
load(file="flights.Rda")
nrow(flights)
airportCodes <- data.frame(code=unique(flights$Origin),stringsAsFactors=FALSE)
head(airportCodes,n=100)


flights_2007 <- fread("D:/Temp/on-time-flight-data/2007.csv",header=TRUE,) 
setkey(flights_2007,Dest)

flights.busiestAirports <- data.table("Dest"=flights.new.sum[,c("Dest")])

flights.filtered <- merge(flights, flights.busiestAirports )
flights.filtered2 <- merge(flights_2007, flights.busiestAirports )

flights.filtered <- rbind(flights.filtered,flights.filtered2)
flights.filtered <- data.table(flights.filtered)

DT_flights <- data.table(flights)
setkey(DT_flights,Origin)
airportCodes <- data.frame(code=unique(DT_flights$Dest),stringsAsFactors=FALSE)

airportCodes <- data.frame(code=unique(flights.filtered$Dest),stringsAsFactors=FALSE)
setkey(flights.filtered,Dest)

for (i in 1:nrow(airportCodes)) {
  current_airport <- airportCodes[i, "code"]
  print(current_airport)
  df_temp <- subset(flights.filtered,Dest == current_airport & Year == 2007)
  #df_temp <- head(df_temp,n=1000)
  df_temp <- df_temp[sample(nrow(df_temp), 10000,replace=TRUE), ]
  #df[sample(nrow(df), 3), ]
  print(nrow(df_temp))
  write.csv(df_temp,paste0("busy-airports/2007/","flights.",current_airport,".csv"),row.names=FALSE)
  rm(df_temp)
  # do more things with the data frame...
}



#setwd("M:/Dropbox/MyFiles/Presentations/RMOUG 2014/Intro to R/sample-CSVs")
namePattern <- "flights\\.(J|Y)[A-Z]{2,3}\\.csv"
namePattern <- "flights\\.[A-Z]{2,3}\\.csv"
namePattern <- ".+2010.+\\.csv\\.gz"
namePattern <- "On_Time_On_Time_Performance_2010_1\\.csv\\.gz"
#filesToImport <- list.files(path="D:/Temp/on-time-flight-data/split-CSVs" ,pattern=namePattern,full.names=TRUE)
filesToImport <- list.files(path="D:/Temp/on-time-flight-data/busy-airports" ,pattern=namePattern,full.names=TRUE,recursive=TRUE)
filesToImport <- list.files(path="D:/Temp/on-time-flight-data/2013" ,pattern=namePattern,full.names=TRUE,recursive=TRUE)

rm(flights.new)
flights.new <- data.table()
for (f in filesToImport) {
  print(f)
  df_temp <- data.table(read.csv(f, head=TRUE,sep=",",stringsAsFactors=FALSE))
  
  #df_temp$file <- f
  #df_temp$fileSize <- file.info(f)[,"size"]
  flights.new <- rbind(flights.new,df_temp)
  rm(df_temp)
}

save(flights.new,file="flights.new.2010.Rda")



namePattern <- ".+2011.+\\.csv\\.gz"
filesToImport <- list.files(path="D:/Temp/on-time-flight-data/2013" ,pattern=namePattern,full.names=TRUE,recursive=TRUE)

rm(flights.new)
flights.new <- data.table()
for (f in filesToImport) {
  print(f)
  df_temp <- data.table(read.csv(f, head=TRUE,sep=",",stringsAsFactors=FALSE))
  flights.new <- rbind(flights.new,df_temp)
  rm(df_temp)
}

save(flights.new,file="flights.new.2011.Rda")



namePattern <- ".+2012.+\\.csv\\.gz"
filesToImport <- list.files(path="D:/Temp/on-time-flight-data/2013" ,pattern=namePattern,full.names=TRUE,recursive=TRUE)

rm(flights.new)
flights.new <- data.table()
for (f in filesToImport) {
  print(f)
  df_temp <- data.table(read.csv(f, head=TRUE,sep=",",stringsAsFactors=FALSE))
  flights.new <- rbind(flights.new,df_temp)
  rm(df_temp)
}

save(flights.new,file="flights.new.2012.Rda")





namePattern <- ".+2013.+\\.csv\\.gz"
filesToImport <- list.files(path="D:/Temp/on-time-flight-data/2013" ,pattern=namePattern,full.names=TRUE,recursive=TRUE)

rm(flights.new)
flights.new <- data.table()
for (f in filesToImport) {
  print(f)
  df_temp <- data.table(read.csv(f, head=TRUE,sep=",",stringsAsFactors=FALSE))
  flights.new <- rbind(flights.new,df_temp)
  rm(df_temp)
}

save(flights.new,file="flights.new.2013.Rda")



load(file="flights.new.2013.Rda")


flights <- flights.new
rm(flights.new)
load(file="flights.new.2012.Rda")
flights <- rbind(flights.new,flights)
rm(flights.new)
load(file="flights.new.2011.Rda")
flights <- rbind(flights.new,flights)
rm(flights.new)
load(file="flights.new.2010.Rda")
flights <- rbind(flights.new,flights)
rm(flights.new)



load(file="flights.new.2010.Rda")


library(lubridate)

#flights.new$date  <- as.POSIXct(items.narrow$birthday, format = "%m/%d/%Y",tz="UTC") # create a new column in the data.frame of type POSIXct (date)
flights.new$date  <- ymd(paste(flights.new$Year,flights.new$Month,flights.new$DayofMonth,sep="-")) #lubridate version of above
flights.narrow <- data.frame(flights.new)[,c("date","UniqueCarrier","FlightNum","Origin","Dest","Distance","TaxiIn","TaxiOut",
                                "CarrierDelay","WeatherDelay","NASDelay","SecurityDelay","LateAircraftDelay")] # subset down to just a few columns

flights.weather <- subset(flights.narrow,WeatherDelay > 0)
flights.weather$month <- month(flights.weather$date,label=TRUE)

flights.weather.sub <- subset(data.frame(flights.weather), Origin %in% c('CLE','BUF'))
library(plyr)
flights.weather.sum <- ddply(flights.weather, .(month=month(date,label=TRUE),Dest), summarise, 
                                                WeatherDelay=mean(WeatherDelay),
                                                flightCount=length(FlightNum))

flights.weather.sum2 <- ddply(flights.weather, .(Origin), summarise, 
                             WeatherDelaySum=sum(WeatherDelay),
                             flightCount=length(WeatherDelay))

library(ggplot2)
#ggplot(data=subset(flights.weather.sum, Origin %in% c('BUF','JFK','ORD','DEN')) ,aes(x=month,y=WeatherDelay),color=Origin)+
ggplot(data=flights.weather.sum,aes(x=month,y=WeatherDelay),color=Dest)+
  geom_boxplot()+
  geom_point(alpha=0.8,position = position_jitter(width = .4,height=0),aes(color=Dest,size=flightCount))
  #facet_grid(Dest ~ .)

ggplot(data=subset(flights.weather.sum, Origin %in% c('BUF','JFK','ORD','DEN')) ,aes(x=Origin,y=WeatherDelay),color=Origin)+
  #geom_boxplot()+
  geom_point(alpha=0.8,position = position_jitter(width = .4,height=0),aes(color=Origin))





setkey(flights.new,Dest)
airports <- data.table(read.csv("D:/Temp/on-time-flight-data/airports.csv"))
setkey(airports,iata)
airports <- rename(airports, c("iata"="Dest"))
airports$latLong <- paste(airports$lat,airports$long,sep=":")
flights.new.merged <- merge(x=flights.new,y=airports)








idx_iostat_rm <- !with(iostat2.melt, FUNCTION_NAME %in% subset(iostat2.totals,value==0)$FUNCTION_NAME)
iostat2.melt<- iostat2.melt[idx_iostat_rm,]
idx_max <- with(x.melt, grepl("max", variable))

airports.main <- airports
idx_rm <- !with(airports.main, grepl("(Municipal|County|Muni|Regional)", airport))
airports.main<- airports.main[idx_rm,]
idx_rm <- with(airports.main, grepl("[[:alpha:]]{3}", Dest))
airports.main<- airports.main[idx_rm,]
flights.new.merged <- merge(x=flights.new,y=airports.main)



require(dplyr) 



flights.new.sum <- data.frame(flights.new.merged) %.%
  group_by(Dest,latLong) %.%
  summarise(Flights = as.numeric(length(FlightNum)),
            Delay=round(mean(ArrDelay,na.rm = TRUE)),1) %.%
  arrange(desc(Flights)) %.%
  head(10)

flights.new.sum.Jan <- filter(data.frame(flights.new.merged),Month == 1) %.%
  group_by(Dest,latLong) %.%
  summarise(Flights = as.numeric(length(FlightNum)),
            Delay=round(mean(ArrDelay,na.rm = TRUE)),1) %.%
  arrange(desc(Flights)) %.%
  head(10)



setkey(flights.new.sum,NULL)
key(flights.new.sum)
arrange(flights.new.sum,desc(numFlights))

flights.new.merged2 <- subset(flights.new.merged ,Dest == "ABE")


require(googleVis)
#placeNames <- as.character(NucData$Name)
#plotData<-data.frame(name=placeNames,latLong=unlist(NucData$Location))
sites <- gvisMap(plotData,locationvar="latLong",tipvar="name", 
                 options=list(displayMode = "Markers", mapType='normal', colorAxis = "{colors:['red', 'grey']}",
                              useMapTypeControl=TRUE, enableScrollWheel='TRUE'))

sites <- gvisMap(flights.new.sum ,locationvar="latLong",tipvar="Dest", 
                 options=list(displayMode = "Markers", mapType='normal', colorAxis = "{colors:['red', 'grey']}",
                              useMapTypeControl=TRUE, enableScrollWheel='TRUE'))
plot(sites)

AndrewGeo <- gvisGeoMap(Andrew, locationvar="LatLong", numvar="Speed_kt", 
                        hovervar="Category", 
                        options=list(height=600, width=800, region="US"))

sites2 <- gvisGeoChart(flights.new.sum ,locationvar="latLong",hovervar="Dest", 
                       sizevar="Flights",colorvar="Delay",
                     options=list(height=600, width=800, region="US", displayMode='markers',DataMode='markers',
                                  resolution="provinces" , gvis.editor="Edit",
                                  colorAxis="{colors:['#f5f5f5', '#ff0000']}"))
plot(sites2)


delay <- filter(delay, count > 20, dist < 2000)












popular.airports1 <- flights.new %.%
  group_by(Origin) %.%
  summarise(Flights = as.numeric(length(FlightNum))) %.%
  arrange(desc(Flights)) %.%
  head(20)


flights.new.sum1 <- data.table(flights.new.sum1)
setkey(flights.new.sum1,Dest)


flights.new.sum1 <- rename(flights.new.sum1, c("Dest"="Origin"))

setkey(flights.new.sum1,Origin)
setkey(flights.new,Origin)
flights.new.sub2 <-  merge(flights.new,flights.new.sum1)



load(file="flights.new.2010.Rda")
flights.new[,(65:110):=NULL]
setkey(flights.new,Dest,Origin)
flights.popular <- flights.new[Origin %in% popular.airports1$Origin]

flights.popular.samp <- data.table()

for (i in 1:nrow(popular.airports1)) {
  current_airport <- popular.airports1[i, "Origin"]
  print(current_airport)
  df_temp <- flights.new[Origin == current_airport ]
  df_temp <- df_temp[sample(nrow(df_temp), 10000,replace=TRUE), ]
  
  flights.popular.samp <- rbind(flights.popular.samp,df_temp)
  
  
  #df_temp <- df_temp[sample(nrow(df_temp), 10000,replace=TRUE), ]
  #df[sample(nrow(df), 3), ]
  #print(nrow(df_temp))
  #write.csv(df_temp,paste0("busy-airports/2007/","flights.",current_airport,".csv"),row.names=FALSE)
  rm(df_temp)
  # do more things with the data frame...
}

save(flights.popular.samp,file="flights.popular.samp.2010.Rda")







namePattern <- "flights\\.popular\\.samp\\.20[[:digit:]]{2}\\.Rda"
filesToImport <- list.files(pattern=namePattern,full.names=TRUE,recursive=TRUE)

rm(flights.popular.samp)
flights <- data.table()
for (f in filesToImport) {
  print(f)
  load(file=f)
  flights <- rbind(flights,flights.popular.samp)
}

save(flights,file="flights.popular.samp.combined.Rda")



library(lubridate)
flights$FlightDate <- ymd(flights$FlightDate) 
str(flights)



load(file="flights.popular.samp.combined.Rda")
