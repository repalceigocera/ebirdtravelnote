#----------------------------------- set path
data_in <- "C:/Users/MinSian/Desktop/eBird/"
setwd(data_in)
#-----------------------------------load packages
library(rebird)
library(tidyverse)
library(lubridate)
library(data.table)
#-----------------------------------mainchecklist
mainchecklist <-
    ebirdtaxonomy(c(
        "domestic",
        "form",
        "hybrid",
        "intergrade",
        "issf",
        "slash",
        "species",
        "spuh"
    ))

#-----------------------------------input data
bird <- fread(
    "MyEbirdData.csv",
    na.strings = "NA",
    encoding = "UTF-8",
    fill = TRUE,
    sep = ","
) %>%           #-------------------add "datetime" column
    .[, datetime := paste(Date, Time)] %>%
    .[, datetime := parse_date_time(datetime, "%m-%d-%Y %I:%M %p")]

                #-------------------function
timeformat <- function(t) {
    strptime(t, format = "%Y-%m-%d %H:%M")
}

#-----------------------------------set the range of the data
birdsel <- bird %>%
    .[datetime >= timeformat("2017-01-01 00:00") &
          datetime <= timeformat("2017-01-20 00:00"),]

                #-------------------list the locations and add nicknames
itinerary <- birdsel %>%
    .[, list(`Submission ID`,
             Date,
             Time,
             `Duration (Min)`,
             Protocol,
             Location,
             `Checklist Comments`)] %>%
    unique %>%
    .[, nickname := ""]
                #-------------------export a location table to add nicknames
write.csv(itinerary,
          row.names = FALSE,
          "itinerary.sian.csv",
          fileEncoding = "BIG-5")

#===================================read the new file with nicknames
nicknames <- fread("itinerary.sian.csv",
                   na.strings = "")
                #-------------------join the nicknames back
itineraryOK <- nicknames[birdsel, on = c("Submission ID")] %>%
    .[!is.na(nickname),] %>%      # exclude checklists without nicknames
    .[, list(                     # generate the itinerary we want again
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
                #-------------------export the itinerary
write.csv(
    itineraryOK,
    row.names = FALSE,
    "itineraryOK.sian.csv",
    fileEncoding = "BIG-5"
)
#===================================