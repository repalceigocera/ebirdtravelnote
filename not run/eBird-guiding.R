library('plyr')
library('dplyr')
#library('ggplot2')
#library('scales')
#library('readxl')
library('WriteXLS')
library('data.table')
library('rebird')

setwd("C:/R/eBird")

##Read the main ebird checklist

mainchecklist<-ebirdtaxonomy(cat=c("domestic", "form", "hybrid", "intergrade", "issf", "slash", "species", "spuh"))

##Read the bird exported data

#bird <-read.csv("MyEBirdData.csv", header=T, fill=T, encoding="UTF-8", sep = ",") 

bird<- fread("MyEbirdData.csv", sep=",", encoding = "UTF-8", fill=T, na.strings = "NA")

##Set the range of the data
##ref: https://www.stat.berkeley.edu/~s133/dates.html
## https://stackoverflow.com/questions/11609252/r-tick-data-merging-date-and-time-into-a-single-object
##SOlve the am/pm https://stackoverflow.com/questions/17240428/how-do-you-convert-time-stamp-that-has-am-pm-at-the-end-of-the-string


date1<-strptime("2017/01/01 00:00",format="%Y/%m/%d %H:%M")
date2<-strptime("2017/01/20 00:00",format="%Y/%m/%d %H:%M")

bird$datetime <- as.POSIXct(mdy_hm(paste(bird$Date, bird$Time)),format="%m-%d-%Y %I:%M %p")

birdsel<-bird %>% filter(datetime>date1 & datetime<date2) 


##List the locations and add nicknames

itinerary<-birdsel %>% arrange(datetime) %>% summarise(`Submission ID`, Date, Time, `Duration (Min)`,Protocol, Location, `Checklist Comments`) %>% unique() #Generate the itinerary
itinerary["nickname"]<-"" #Create a empty row 
 
write.csv(itinerary, file="itinerary.csv", fileEncoding = "BIG-5") #Export a location table to add nicknames


nicknames<- fread("itinerary.csv", sep=",", encoding = "UTF-8", fill=T, na.strings = "NA") #read the new file with nicknames
birdsel<-left_join(birdsel, nicknames[,c(2,9)], by="Submission ID")  #Join the nicknames back

birdsel<-birdsel %>% filter(nickname!="")  #Exclude checklists without nicknames

##Generate the itinerary we want again
itineraryOK<-birdsel %>% arrange(datetime) %>% summarise(`Submission ID`, Date, Time, `Duration (Min)`,Protocol, nickname, Location, `Checklist Comments`) %>% unique()
#attach hyperlink of each checklist
itineraryOK <-itineraryOK %>% mutate(eBirdLink=paste0("http://ebird.org/ebird/view/checklist/",.$`Submission ID`))


write.csv(itineraryOK, file="itineraryOK.csv", fileEncoding = "BIG-5") #Export the itinerary


