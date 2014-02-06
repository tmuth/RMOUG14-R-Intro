library(data.table)
setwd("M:/Dropbox/MyFiles/Presentations/RMOUG 2014/Intro to R/data/flights-split")

# flights.2010.ATL.11.csv
namePattern <- "*.csv" # all CSVs
namePattern <- "flights\\..+\\.csv" # flight.*.csv
namePattern <- "flights\\.[[:digit:]]{4}\\.[[:alpha:]]{3}\\.[[:digit:]]{1,2}\\.csv" # full regex of file pattern
namePattern <- "flights\\.2012\\.[[:alpha:]]{3}\\.[[:digit:]]{1,2}\\.csv" # just 2012
namePattern <- "flights\\.2012\\.(ATL|SFO)\\.11\\.csv" # just 2012, ATL or SFO, November (11)

filesToImport <- list.files(path=getwd() ,pattern=namePattern,full.names=TRUE,recursive=TRUE)


rm(flights.new)
flights.new <- data.table()
for (f in filesToImport) {
  print(f)
  df_temp <- data.table(read.csv(f, head=TRUE,sep=",",stringsAsFactors=FALSE))
  flights.new <- rbind(flights.new,df_temp)
  rm(df_temp)
}

save(flights.new,file="flights.new.Rda")
rm(flights.new)
load("flights.new.Rda")
