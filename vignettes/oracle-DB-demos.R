# http://cran.r-project.org/web/packages/ROracle/index.html
# http://www.inside-r.org/node/48947
library(ROracle)
ora <- Oracle() ## or dbDriver("Oracle")
con <- dbConnect(ora, username = "hr", password = "hr",
                 dbname = "pdborcl")

DF_EMPLOYEES <- dbGetQuery(con, "select * from employees")

DF_DEPARTMENTS <- dbGetQuery(con, "select * from departments")

#DF_EMPLOYEES <- dbGetQuery(con, "select * from employees where deptno = :1",
#                 data = data.frame(depno = 10))

DF_EMPLOYEES.merged <- merge(DF_EMPLOYEES,DF_DEPARTMENTS[,c("DEPARTMENT_NAME","DEPARTMENT_ID")],by="DEPARTMENT_ID")

library(ggplot2)

plot.1 <- ggplot(data=DF_EMPLOYEES.merged,aes(x=JOB_ID,y=SALARY,colour=DEPARTMENT_NAME))
  

plot.1 + geom_point()

plot.1 + geom_boxplot()

plot.1 + geom_boxplot() + geom_point()

plot.1 + geom_boxplot() + geom_point(alpha=0.3)

plot.1 + geom_boxplot() + 
  geom_jitter(alpha=0.3)


plot.1 + geom_boxplot(colour="black") + 
  geom_jitter(alpha=0.5,aes(colour=DEPARTMENT_NAME),size=4) +
  theme(axis.text.x=element_text(angle=-30, hjust=-.1,vjust=1,size=8))

ggplot(data=DF_EMPLOYEES.merged,aes(x=JOB_ID,y=SALARY))+
  #geom_boxplot()+
  geom_point()
axis.text.x=element_text(angle=-30, hjust=-.1,vjust=1,size=6)