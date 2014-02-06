library(jsonlite)
library(httr)

# another source is https://apex.oracle.com/pls/apex/dbtools/features/top?n=4
#get data
data1 <- fromJSON("http://apex.oracle.com/pls/apex/dbtools/names/random?num=100")
summary(data1$items)
head(data1$items)

nrow(data1$items)

save(data1,file="data1.items.Rda")


items.narrow <- data1$items[,c("gender","occupation", "country","feetinches","birthday")] # subset down to just a few columns
rm(data1) # remove it since we're done with it
head(items.narrow)
items.narrow$birthdate  <- as.POSIXct(items.narrow$birthday, format = "%m/%d/%Y",tz="UTC") # create a new column in the data.frame of type POSIXct (date)
#items.narrow$birthdate2  <- mdy(items.narrow$birthday) #lubridate version of above
str(items.narrow)




library(lubridate)
items.narrow$age <- round(new_interval(items.narrow$birthdate, now()) / duration(num = 1, units = "years")) # add an age column
head(items.narrow)
summary(items.narrow)
length(unique(items.narrow$occupation)) # how many distinct occupations? 
length(unique(items.narrow$country)) # how many distinct countries? 








library(ggplot2)
ggplot(data=items.narrow,aes(x=country,y=age))+
  geom_point()

ggplot(data=items.narrow,aes(x=country,y=age))+
  geom_boxplot()







items.narrow.short = subset(items.narrow,country %in% c('DE','BR','NZ'))






ggplot(data=items.narrow.short,aes(x=country,y=age))+
  geom_boxplot()+
  geom_point()





ggplot(data=items.narrow.short,aes(x=country,y=age))+
  geom_boxplot()+
  geom_point(alpha=0.3,position = position_jitter(width = .2,height=0),aes(color=gender))




ggplot(data=items.narrow.short,aes(x=country,y=age,fill=gender))+
  geom_boxplot(position="dodge")



ggplot(data=items.narrow.short,aes(x="",y=age,fill=gender))+
  geom_boxplot(position="dodge")+
  facet_wrap(country ~ gender,ncol=2)



