library(tidyverse)
library(dplyr)
library(tidyr)
library(readr)
library(lubridate)
library(data.table)
library(ggplot2)

# ------------ cleaning and processing-------------------------

# 3. Stacking all tables into a big table
n <-  length(colnames(data_cp))
all_trips <-  data.frame(matrix(ncol = n, nrow = 0))
colnames(all_trips) <- colnames((data_cp))
for(i in 1:12){
  csv_name <- paste0(datapath,file_year,file_months[i],"-divvy-tripdata.csv")
  data_tmp <-  read_csv(file = csv_name)
  all_trips <- rbind(all_trips,data_tmp) 
}



# 1. Create a copy and removing columns

all_trips_table <- as.data.table(all_trips) # copy using a table

# dropping columns
all_trips_table[, c("start_lat", "start_lng", "end_lat", "end_lng") := NULL]

# 2. Creating a new columns
all_trips_table[, `:=`(started_at = as_datetime(started_at),
                    ended_at = as_datetime(ended_at))]

all_trips_table[, `:=`(started_date = as.Date(started_at),
                       started_year = format(as.Date(started_at),'%Y'),
                       started_month = format(as.Date(started_at),'%B'),
                       started_day = format(as.Date(started_at), '%d'),
                       day_of_week = format(as.Date(started_at), "%A"),
                       ended_date = as.Date(ended_at))] #,
                       #ended_year = format(as.Date(ended_at), '%Y'),
                       #ended_month = format(as.Date(ended_at), '%m'),
                       #ended_day = format(as.Date(ended_at), '%d'),
                       #ended_day_of_week = format(as.Date(ended_at), '%A'))]

all_trips_table[, ride_length :=round(as.numeric( difftime(ended_at, started_at, units = "mins")),2)]


# check if there is a n.a values
all_trips_table[!complete.cases(all_trips_table)]   # return an empty table  with 16 columns, therefore, there's not missing values




# removing zero and negative values of ride_length
all_trips_table <- all_trips_table[ride_length > 0]


# filling missing station values 
all_trips_table[start_station_name == "", start_station_name := "unknown station",]
all_trips_table[end_station_name == "", end_station_name := "unknown station",]

# verification
all_trips_table[start_station_name == "" | end_station_name == "",]






# assign order to the day_of_weekend column

day_levels = c("domingo", "lunes", "martes", "miércoles", "jueves", "viernes", "sábado")
mounth_levels = c("enero","febrero","marzo","abril","mayo","junio","julio","agosto",    
                  "septiembre","octubre","noviembre","diciembre")


all_trips_table[,  `:=`( day_of_week = ordered(day_of_week, levels = day_list),
                         started_month = ordered(started_month, levels = mounth_levels))]


# q1 <- quantile(all_trips_table$ride_length,0.25,names =FALSE)
# q3 <- quantile(all_trips_table$ride_length,0.75,names =FALSE)
# 
# iqr <- q3-q1
# 
# lower_bound <- q1 - 1.5*iqr
# upper_bound <- q3 + 1.5*iqr

# ride_length histogram without filtering 

all_trips_table %>% 
  ggplot(aes(x = ride_length, y = "")) +
  geom_boxplot(width = 0.5, color = "#00acc0", fill = "#00acc0", alpha = 0.3,
               outlier.colour = "#006874", outlier.fill = "#006874", outlier.size = 1.5) +
  stat_summary(fun = median, geom = "point", color = "#E57373", size = 2) +
  stat_summary(fun = mean, geom = "point", color = "#005187", size = 2) +
  theme_minimal() +
  theme(axis.text.y = element_blank(), 
        axis.ticks.y = element_blank(), 
        axis.title.y = element_blank()) +
  labs(title = "Distribución de ride_length", 
       x = "Duración del viaje (minutos)",
       caption = "Gráfico propio elaborado con datos de Cyclistic")



# boxplot for the range 3 to 1440 minutes of ride_length


all_trips_table[ride_length < 60*24 & ride_length > 3] %>% 
  ggplot(aes(x = ride_length, y = "")) +
  geom_boxplot(width = 0.5, color = "#00acc0", fill = "#00acc0", alpha = 0.3,
               outlier.colour = "#006874", outlier.fill = "#006874", outlier.size = 1.5) +
  stat_summary(fun = median, geom = "point", color = "#E57373", size = 2) +
  stat_summary(fun = mean, geom = "point", color = "#005187", size = 2) +
  theme_minimal() +
  theme(axis.text.y = element_blank(), 
        axis.ticks.y = element_blank(), 
        axis.title.y = element_blank()) +
  labs(title = "Distribución de ride_length", 
       x = "Duración del viaje (minutos)",
       caption = "Gráfico propio elaborado con datos de Cyclistic")






# creating the ge_mode function

get_mode <- function(x) {
  uniq_vals <- unique(x)
  uniq_vals[which.max(tabulate(match(x, uniq_vals)))]
}

# evaluating the mode, mean and median before drooping outliers 

c("mode" = get_mode(all_trips_table$ride_length), 
  "median" = median(all_trips_table$ride_length, na.rm = TRUE), 
  "mean" = mean(all_trips_table$ride_length, na.rm = TRUE))


all_trips_table <- all_trips_table[ride_length < 60*24 & ride_length > 3,]



