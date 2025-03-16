library(tidyverse)
library(dplyr)
library(tidyr)
library(readr)
library(lubridate)

#-----------------Column Verification-------------------------#

datapath <-  './datasets/'
file_year <-  "2024"
file_months <-  1:12
for(number in 1:length(file_months)){
  if (number < 10){
    file_months[number] <-  paste0("0",number)
  }
}

# 1. Verify consistence in the colname of each table


# - structure of name year+month+-divvy-tripdata.csv
data_cp = read.csv(file = paste0(datapath,file_year,file_months[9],"-divvy-tripdata.csv")) #for ttest

tables_info = list()
for(i in 1:12){
  csv_name <- paste0(datapath,file_year,file_months[i],"-divvy-tripdata.csv")
  data_tmp <-  read.csv(file = csv_name,nrows = 1000)
  # str(dara_tmp)
  cols_names_tmp <- colnames(data_tmp)
  table_cols <- paste0(cols_names_tmp)
  table_info <-  table_info %>% 
                 append(paste0(" | ", paste0(cols_names_tmp, collapse = " | "), " |"))
  
}

table_info <-  length(unique(table_info)) == 1 # if TRUE then all columns are the same otherwise not
table_info # print TRUE



# 2. Verify data type of each column of arbitrary table

for(i in 1:length(cols_names_tmp)){
  column_info <-  paste("| ",cols_names_tmp[i]," | ", typeof(data_cp[[cols_names_tmp[i]]])," |")
  print(column_info)
}
  

unique(all_trips[["rideable_type"]]) # we only have electric_bike, classic_bic and electric_scooter
unique(all_trips[["member_casual"]]) # in the table we only have member and casual



