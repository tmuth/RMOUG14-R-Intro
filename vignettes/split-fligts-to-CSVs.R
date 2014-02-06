library(data.table)
setwd("M:/Dropbox/MyFiles/Presentations/RMOUG 2014/Intro to R/data/flights-split")

setkey(flights,Year,Origin,Month)
airportCodes <- data.table(code=unique(flights$Origin),stringsAsFactors=FALSE)
flightYears <- data.table(year=unique(flights$Year),stringsAsFactors=FALSE)


for (y in 1:nrow(flightYears)){
  current_year <- flightYears[y, year]
  print(current_year)
  
  dir.create(file.path(getwd(), current_year), showWarnings = FALSE)
  
  for (i in 1:nrow(airportCodes)) {
    current_airport <- airportCodes[i, code]
    print(current_airport)
    outputPath <- file.path(getwd(), current_year,current_airport)
    dir.create(outputPath, showWarnings = FALSE)
    
    
    for (m in 1:12){
      df_temp <- flights[Origin == current_airport & Year == current_year & Month == m]
      df_temp <- df_temp[sample(nrow(df_temp), 100,replace=TRUE), ]
      write.csv(df_temp,paste0(outputPath,"/flights.",current_year,".",current_airport,".",m,".csv"),row.names=FALSE)
      rm(df_temp)
    }
    
    
  }
  
}
