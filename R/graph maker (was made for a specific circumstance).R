rm(list=ls())

library(DAISIE)
library(tidyverse)
library(testit)
library(ggplot2)

#load all the functions from the repository
setwd("~/studie biologie/jaar 2/Community Research")

## finds all .R files within a folder and sources them by Ahmadou Dicko
sourceEntireFolder <- function(folderName, verbose=FALSE, showWarnings=TRUE) { 
  files <- list.files(folderName, full.names=TRUE)
  
  # Grab only R files
  files <- files[ grepl("\\.[rR]$", files) ]
  
  if (!length(files) && showWarnings)
    warning("No R files in ", folderName)
  
  for (f in files) {
    if (verbose)
      cat("sourcing: ", f, "\n")
    ## TODO:  add caught whether error or not and return that
    try(source(f, local=FALSE, echo=FALSE), silent=!verbose)
  }
  return(invisible(NULL))
}
sourceEntireFolder(folderName = "DAISIE/R")


#determine the parameter values for the nonoceanic island simulation
pars = c(2.5,2.6,20,0.009,1.01) #anagenis rate, extinction rate, carrying capacity, immigration, cladogenesis
time=4 #island age in million of years
M=1000 #mainland species pool
nonoceanic= c(0.1,0.3)
#run the simulation
island_replicates=DAISIE_sim_nonoceanic(time=time,M=M,pars=pars,replicates=10, nonoceanic = nonoceanic, divdepmodel = "CS")

#save the simulation parameter values
save(pars,M, time, nonoceanic, file="simulations/pars_nonoceanic_sim_1.Rdata")


###maximum likelihood parameter values in a dataframe

#create empty dataframe DASIEMLSUM
lambda_c <- factor()
mu <- factor()
K <- factor()
gamma <- factor()
lambda_a <- factor()
loglik <- factor()
df <- factor()
conv <- factor()
DAISIEMLSUM <- data.frame(lambda_c,mu,K,gamma,lambda_a
                          ,loglik,df,conv)

#To test if it works
DAISIE::DAISIE_ML(datalist=island_replicates[[1]], initparsopt = pars, ddmodel=11, idparsopt = 1:5, parsfix = NULL, idparsfix = NULL)

#create a dataframe containing the maximum likelihood parameters of each replicate
for (i in 1:length(island_replicates)){
  DAISIEML <- DAISIE::DAISIE_ML(datalist=island_replicates[[i]], initparsopt = pars, ddmodel=11, idparsopt = 1:5, parsfix = NULL, idparsfix = NULL)
  DAISIEMLSUM <- rbind(DAISIEMLSUM, DAISIEML)
}

#save the dataframe
save(DAISIEMLSUM,file="ML_values_sim_1.Rdata")

##creates a violin plot with dots for a single predicted variable or the log likelihood(change the variable by chancing the y value)

ggplot(AllData,aes(x=category,y=loglik)) +geom_violin() + geom_dotplot(binaxis = "y", binwidth = 2, stackdir="center") +ylim(-120, -20) + scale_x_discrete(limits=c("oceanic", "nonoceanic")) + xlab("") + ylab("logarithm of the likelihood") + theme(axis.title =element_text(size=18), axis.text = element_text(size=18))

ggplot(AllData,aes(x=category,y=gamma)) +geom_violin() + geom_dotplot(binaxis = "y", binwidth = 0.0002, stackdir="center")  + scale_x_discrete(limits=c("oceanic", "nonoceanic")) + xlab("") + ylab("gamma (immigration rate)") +geom_hline(yintercept = 0.009) + theme(axis.title =element_text(size=18), axis.text = element_text(size=18)) + scale_y_continuous(breaks=c(seq(0,0.012,0.002)))


ggplot(AllData,aes(x=category,y=mu)) +geom_violin() + geom_dotplot(binaxis = "y", binwidth = 0.1, stackdir="center")  + scale_x_discrete(limits=c("oceanic", "nonoceanic")) + ylab("mu (extinction rate)") +geom_hline(yintercept = 2.6)

ggplot(AllData,aes(x=category,y=log(lambda_a))) +geom_violin() + geom_dotplot(binaxis = "y", binwidth = 1, stackdir="center")  + scale_x_discrete(limits=c("oceanic", "nonoceanic")) + ylab("log lamda a (anagenesis rate)") + geom_hline(yintercept = 0.9162907)

ggplot(AllData,aes(x=category,y=log(lambda_c))) +geom_violin() + geom_dotplot(binaxis = "y", binwidth = 0.1, stackdir="center")  + scale_x_discrete(limits=c("oceanic", "nonoceanic")) + ylab("log lamda c (cladogenesis rate)") + geom_hline(yintercept = 0.9162907)

ggplot(AllData,aes(x=category,y=K)) +geom_violin() + geom_dotplot(binaxis = "y", binwidth = 1, stackdir="center")  + scale_x_discrete(limits=c("oceanic", "nonoceanic")) + ylab("K (carrying capacity)") + geom_hline(yintercept = 20)


ggplot(testdata,aes(x=0,y=gamma)) +geom_violin() + geom_dotplot(binaxis = "y", binwidth = .0001, stackdir="center") + geom_hline(yintercept=0.009950331)

DAISIEMLSUM$category <- c(rep("nonoceanic",9))
testdata$category <- c(rep("oceanic",7))
testdata <- within(testdata, rm(ï..))

AllData <- rbind(DAISIEMLSUM,testdata)

load("ML_values_sim_1.Rdata")
testdata <- read.csv("maximum likelihood parameter values.csv")
