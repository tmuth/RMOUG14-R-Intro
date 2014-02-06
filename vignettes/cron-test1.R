#args<-commandArgs(TRUE)
#if(length(args[1])>0 & !is.na(args[1])){
#  print(args[1])
#}
.libPaths( c( .libPaths(), "C:/Users/tmuth/Documents/R/win-library/3.0") )


setwd("M:/Dropbox/MyFiles/Presentations/RMOUG 2014/Intro to R/cron")
namePattern <- "flights\\.[A-Z]{2,3}\\.csv"
filesToImport <- list.files(path="incoming/" ,pattern=namePattern,full.names=TRUE,recursive=FALSE)


if(!length(filesToImport) > 0){
  stop("There are no files to import at this time.")
}


library(dplyr)
library("data.table") 
library(ggplot2) 


flights.new <- data.table()
for (f in filesToImport) {
  df_temp <- read.csv(f, head=TRUE,sep=",",stringsAsFactors=FALSE,)
  flights.new <- rbind(flights.new,df_temp)
  rm(df_temp)
}

 

flights.new.sum <- data.frame(flights.new) %.%
  group_by(Dest) %.%
  summarise(Flights = as.numeric(length(FlightNum)),
            Delay=round(mean(ArrDelay,na.rm = TRUE)),1) %.%
  arrange(desc(Flights)) %.%
  head(10)

outFileName=paste0("outgoing-plots/","agv-delays_",format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), ".pdf")

pdf(outFileName, width = 11, height = 8.5,useDingbats=FALSE)

ggplot(data=flights.new.sum,aes(x=Dest,y=Delay))+
  geom_bar(stat="identity")

dev.off()




for (f in filesToImport) {

  file.rename(from=f,
              to=paste0(dirname(f),"/../archived/",basename(f)))
  
}