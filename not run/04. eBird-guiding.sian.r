#----------------------------------- load packages
library(rebird)
library(tidyverse)
library(lubridate)
library(data.table)
#----------------------------------- set path
data_in <- "/Users/root1/Google Drive/救救水G專案--鳥導的旅遊報告/"
setwd(data_in)
#----------------------------------- input data
bird <- read.csv2("MyEbirdData.csv",
                  encoding = "big5",
                  sep = ",") %>%
  setDT %>%
  #--------------------------------- renames
  setnames(c('Submission.ID', 'Duration..Min.', 'Checklist.Comments', 'Taxonomic.Order'), 
           c('Submission ID', 'Duration (Min)', 'Checklist Comments', 'Taxonomic Order')) %>%
  #--------------------------------- add "datetime" column
  .[, datetime := paste(Date, Time)] %>%
  .[, datetime := parse_date_time(datetime, "%m-%d-%Y %H:%M %p")]
#----------------------------------- formatting time 
timeformat <- function(t) {
  strptime(t, format = "%Y-%m-%d %H:%M")
}
#-----------------------------------> here to select the time range <---
birdsel <- bird %>%
  .[datetime >= timeformat("2016-11-16 23:59") &
      datetime <= timeformat("2017-11-28 23:59"), ]
#----------------------------------- select data and add nicknames
itinerary <- birdsel %>%
  .[, list(`Submission ID`,
           Date,
           Time,
           datetime,
           `Duration (Min)`,
           Protocol,
           Location,
           `Checklist Comments`)] %>%
  unique %>%                         # remove duplicate
  .[, nickname := " "] %>%           # add nicknames
  .[order(datetime), ]               # order by datetime
#----------------------------------- export a location table to add nicknames
write_excel_csv(itinerary, "Limosa_itinerary.csv")
#=================================== read the new file with nicknames
nicknames <- read.csv2("Limosa_itineraryOK.csv",
                       fileEncoding = "BIG-5",
                       sep = ",") %>%
  setDT %>%
  setnames(c('Submission.ID', 'Duration..Min.', 'Checklist.Comments'), 
           c('Submission ID', 'Duration (Min)', 'Checklist Comments')) %>%
  .[, -1]                            # remove first column 
#----------------------------------- join the nicknames back
birdsel <- nicknames[birdsel, on = c("Submission ID")] %>%
  .[!is.na(nickname), ]

itineraryOK <- birdsel %>%
  .[, list(
    `Submission ID`,
    Date,
    Time,
    `Duration (Min)`,
    Protocol,
    nickname,
    Location,
    `Checklist Comments`
  )] %>%
  unique %>%
  .[, eBirdLink := paste0("http://ebird.org/ebird/view/checklist/",
                          `Submission ID`)]
#----------------------------------- export the itinerary
write_excel_csv(itineraryOK, "Limosa_itinerary_output.csv")
#=================================== generate the checklist
specieslist <- birdsel %>%
  .[order(`Taxonomic Order`, datetime, nickname), ] %>%  # order by these three columns
  #--------------------------------- select columns
  .[, list(
    `Submission ID`,
    Date,
    Time,
    Protocol,
    nickname,
    `Taxonomic Order`,
    Count,
    `All Obs Reported` = All.Obs.Reported,
    `Area Covered (ha)` = Area.Covered..ha.,
    `Number of Observers` = Number.of.Observers,
    `Breeding Code` = Breeding.Code,
    `Species Comments` = Species.Comments
  )] %>%
  #--------------------------------- add new column: 'SP'
  .[, SP := paste0(Date, " ", nickname, " ", Count, " ", `Species Comments`)] %>%
  #--------------------------------- add new column: 'eBirdHyperlink'
  .[, eBirdHyperlink := paste0("http://ebird.org/ebird/view/checklist/",`Submission ID`)] %>%
  #--------------------------------- select columns that we want
  .[, list(
    Date,
    Time,
    `Breeding Code`,
    `Species Comments`,
    SP,
    eBirdHyperlink
  )]
#----------------------------------- export the itinerary
write_excel_csv(specieslist, "Limosa_species_output.csv") #Export the itinerary
#====================================