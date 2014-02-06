library(RCurl)

setwd("D:/Temp/on-time-flight-data/2013")
for (y in 2010:2010){
  print(y)
  for (m in 1:12){
    print(m)
    url <- paste0("http://www.transtats.bts.gov/Download/On_Time_On_Time_Performance_",y,"_",m,".zip")
    print(url)
    #content = getBinaryURL(url)
    #write(content, file = paste0("On_Time_On_Time_Performance_",y,"_",m,".zip"))
    download.file(url = url, destfile=paste0("On_Time_On_Time_Performance_",y,"_",m,".zip"),
                  quiet = FALSE, mode = "wb")
  }
}

