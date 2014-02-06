# http://cran.r-project.org/web/packages/ROracle/index.html
# http://www.inside-r.org/node/48947
library(ROracle)
library(data.table)
library(stringr)
library(dplyr)
library(ggplot2)
library(scales)
library(reshape2)
library(ggthemes) 
library(gridExtra) 


ora <- Oracle() ## or dbDriver("Oracle")
con <- dbConnect(ora, username = "system", password = "oracle1",
                 dbname = "pdborcl")


# --------------------------

numSamples <- 10
sampleInterval <- 2

DF_LOG_EVENTS <- data.frame()

for (i in 1:numSamples){
  print(i)
  DF_TMP <- dbGetQuery(con,
                       "SELECT systimestamp ts,INST_ID,
                            EVENT,
                            WAIT_TIME_MILLI,
                            WAIT_COUNT
                            --LAST_UPDATE_TIME,
                            FROM sys.GV_$EVENT_HISTOGRAM 
                            -- where event in ('log file sync','log file parallel write') 
                            where event in ('db file scattered read','db file sequential read') 
                              --and WAIT_TIME_MILLI in (1,2,4) 
                       ")
  
  DF_LOG_EVENTS <- rbind(DF_LOG_EVENTS,DF_TMP)
  rm(DF_TMP)
  
  Sys.sleep(sampleInterval)
}






library(dplyr)
DF_LOG_EVENTS.diff <- DF_LOG_EVENTS %.%
    arrange(EVENT,WAIT_TIME_MILLI, TS) %.%
    group_by(EVENT,WAIT_TIME_MILLI) %.%
    mutate(diff = WAIT_COUNT - lag(WAIT_COUNT)) %.%
    filter(!is.na(diff))


DT_LOG_EVENTS.diff <- data.table(DF_LOG_EVENTS.diff)

DT_LOG_EVENTS.diff$EVENT <- str_trim(DT_LOG_EVENTS.diff$EVENT)
DT_LOG_EVENTS.diff$WAIT_TIME_MILLI <- as.numeric(as.character(DT_LOG_EVENTS.diff$WAIT_TIME_MILLI))
DT_LOG_EVENTS.diff[WAIT_TIME_MILLI>=64, WAIT_TIME_MILLI := 64]
DT_LOG_EVENTS.diff$WAIT_TIME_MILLI <- factor(DT_LOG_EVENTS.diff$WAIT_TIME_MILLI)

setkey(DT_LOG_EVENTS.diff,TS, EVENT, WAIT_TIME_MILLI)

DT_LOG_EVENTS.diff <- DT_LOG_EVENTS.diff[, list(WAIT_COUNT = sum(WAIT_COUNT)), by = list(TS, EVENT, WAIT_TIME_MILLI)]
DT_LOG_EVENTS.diff[with(DT_LOG_EVENTS.diff, grepl(64, WAIT_TIME_MILLI)),]$WAIT_TIME_MILLI<-"64+"

DT_LOG_EVENTS.group <- DT_LOG_EVENTS.diff[, list(WAIT_COUNT = sum(WAIT_COUNT)), by = list(EVENT, WAIT_TIME_MILLI)]

DT_LOG_EVENTS.group <- DT_LOG_EVENTS.group[, list(WAIT_TIME_MILLI=WAIT_TIME_MILLI,WAIT_PCT =WAIT_COUNT/ sum(WAIT_COUNT)), by = list(EVENT)]



io_hist_colors2 <- c("1" = "#315280", "2" = "#4575B4", "4" = "#74ADD1", "8" = "#ABD9E9",
                     "16" = "#FDAE61", "32" = "#F46D43", "64+"="#D73027")

gg_io_hist_colors2 <- scale_fill_manual(values = io_hist_colors2,name="wait ms" )

io_hist_plot <- ggplot(DT_LOG_EVENTS.group,aes(x=factor(WAIT_TIME_MILLI),fill = WAIT_TIME_MILLI,))+
  geom_bar(stat ='identity',aes(y=WAIT_PCT),width=1)+
  geom_text(aes(label=round(WAIT_PCT*100,0),y=WAIT_PCT),size=4)+
  facet_grid(. ~ EVENT,scales="free_y")+
  gg_io_hist_colors2+
  labs(title=paste0("I/O Wait Event Histogram - SSD"))+
  scale_y_continuous(labels = percent_format())+
  theme(axis.title.y  = element_blank(),legend.position =    "right" ,
        legend.key.size = unit(.25, "cm"),
        strip.text.x = element_text(size = 8))+
  xlab("Wait Milliseconds")

io_hist_plot




io_hist_area_plot <- ggplot()+
  #ggplot(DF_IO_WAIT_HIST_INT, aes(x = end,
  #                                                       fill = WAIT_TIME_MILLI))+
  #   geom_bar(stat = "identity", position = "stack",right=FALSE,drop=TRUE,
  #             aes(y = WAIT_COUNT)+
  geom_bar(data=DT_LOG_EVENTS.diff ,aes(x = TS, y = WAIT_COUNT,
                                        fill = WAIT_TIME_MILLI),stat = "identity", position = "stack",alpha=1)+
  facet_grid(EVENT ~ .,scales="free_y")+
  gg_io_hist_colors2+
  
  labs(title=paste0("I/O Wait Event Area Chart"))+
  theme(legend.key.size = unit(.25, "cm"),
        strip.text.y = element_text(size = 6))+
  scale_x_datetime(labels = date_format("%a, %b %d %I %p"),
                                   limits = c(min(DT_LOG_EVENTS.diff$TS),max(DT_LOG_EVENTS.diff$TS)))+
  #scale_y_continuous(labels = comma)+
  ylab("Wait Count")+
  theme(axis.title.x=element_blank(),legend.position =    "bottom" )

io_hist_area_plot
