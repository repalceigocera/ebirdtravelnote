#----------------------------------- set path
data_in <- "/Users/root1/Desktop/github/ebirdtravelnote/"
setwd(data_in)
#-----------------------------------load packages
library(knitr)
library(rmarkdown)
library(tidyverse)
library(kableExtra)
library(data.table)
#-----------------------------------input data
bird <- read.table(
  'MyEBirdData20170911.csv',
  fileEncoding = 'utf8',
  fill = TRUE,
  header = TRUE,
  sep = ","
) %>%
  setDT %>%
  .[1:5, list(Common.Name, 
           Scientific.Name, 
           Location, 
           Date)]

data <- fread('checklist.csv', 
              header = FALSE) %>%
  .[, 1:2]

fwrite(data, 
       'mdtext.txt',
       col.names = FALSE,
       quote = FALSE,
       sep = " ")



