library(tidyverse)
library(dplyr)
library(tidyr)
library(readr)

## Get the number of uniques Id

list_csv <- list.files(path = "./datasets", pattern = "*.csv")

file_conn <- file("table_csv_info.txt")
close(file_conn)

# Table head
write("| Nombre archivo (.csv)| Id (unicos) | Columnas |", file = "table_csv_info.txt", append = TRUE)
write("|----------------------|-------------|----------|", file = "table_csv_info.txt", append = TRUE)


for(name in list_csv){
  
  data_csv<-  read_csv(paste("./datasets/",name, sep=""),show_col_types = FALSE)
  message <-paste("|", tools::file_path_sans_ext(name), 
                  "|", n_distinct(data_csv$Id),
                  "|")
  data_csv_col = list(name, colnames(data_csv))
  write(message, file = "table_csv_info.txt", append = TRUE)
  print(message)
}

rm(data_csv,list_csv, file_conn, message, name)










