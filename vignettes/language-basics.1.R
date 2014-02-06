# vectors
x <- 1
x
str(x)

x[1]



x <- c(1,2,3,4) # hmmm, what does "c" stand for? 
x
str(x)
x[1]
x[3]

x+100 # I wonder what this will do?


x <- seq(1:30)
x
x+100
x <- x+100

x <- letters[1:26] # hmmm, what's this "letters" thing?
x
x+100 # that should work...

paste(x,100)



# matrix
m <- matrix(data=cbind(rnorm(30, 0), rnorm(30, 2), rnorm(30, 5)), nrow=30, ncol=3)
str(m)

m$V1 <- as.character(m$V1)



# data frame