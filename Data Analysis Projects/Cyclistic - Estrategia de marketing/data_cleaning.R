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
                       month = format(as.Date(started_at),'%B'),
                       day = format(as.Date(started_at), '%d'),
                       day_of_week = format(as.Date(started_at), "%A"),
                       ended_date = as.Date(ended_at))] 
                       #ended_year = format(as.Date(ended_at), '%Y'),
                       #ended_month = format(as.Date(ended_at), '%m'),
                       #ended_day = format(as.Date(ended_at), '%d'),
                       #ended_day_of_week = format(as.Date(ended_at), '%A'))]

all_trips_table[, ride_length := round(as.numeric(difftime(ended_at, started_at, units = "mins")),2)]


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
mouth_levels = c("enero","febrero","marzo","abril","mayo","junio","julio","agosto",    
                  "septiembre","octubre","noviembre","diciembre")


all_trips_table[,  `:=`( day_of_week = ordered(day_of_week, levels = day_list),
                         month = ordered(month, levels = mounth_levels))]


# renaming value 
all_trips_table["member", on = "member_casual", member_casual := "miembro"]


# removing 
all_trips_table <- all_trips_table[started_date == ended_date,]
all_trips_table[, ended_date:=NULL]


##
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
  labs(title = "Distribución de ride_length con outliers", 
       x = "Duración del viaje (minutos)",
       caption = "Gráfico propio elaborado con datos de Cyclistic")



# boxplot for the range 3 to 1440 minutes of ride_length

q1 <- quantile(all_trips_table$ride_length,0.25,names =FALSE)
q3 <- quantile(all_trips_table$ride_length,0.75,names =FALSE)

iqr <- q3-q1

lower_bound <- 1
upper_bound <- q3 + 1.5*iqr

all_trips_table[between(ride_length, lower_bound, upper_bound)] %>% 
  ggplot(aes(x = ride_length, y = "")) +
  geom_boxplot(width = 0.5, color = "#00acc0", fill = "#00acc0", alpha = 0.3,
               outlier.colour = "#006874", outlier.fill = "#006874", outlier.size = 1.5) +
  stat_summary(fun = median, geom = "point", color = "#E57373", size = 2) +
  stat_summary(fun = mean, geom = "point", color = "#005187", size = 2) +
  theme_minimal() +
  theme(axis.text.y = element_blank(), 
        axis.ticks.y = element_blank(), 
        axis.title.y = element_blank()) +
  labs(title = "Distribución de ride_length filtrado", 
       x = "Duración del viaje (minutos)",
       caption = "Gráfico propio elaborado con datos de Cyclistic")


# creating the ge_mode function

get_mode <- function(x) {
  uniq_vals <- unique(x)
  uniq_vals[which.max(tabulate(match(x, uniq_vals)))]
}

# evaluating the mode, mean and median before drooping outliers, also


c("mode" = get_mode(all_trips_table$ride_length), 
  "median" = median(all_trips_table$ride_length), 
  "mean" = mean(all_trips_table$ride_length))


all_trips_table <- all_trips_table[between(ride_length, lower_bound, upper_bound)]





# new descriptive statistics metrics

c("mode" = get_mode(all_trips_table$ride_length), 
  "median" = median(all_trips_table$ride_length, na.rm = TRUE), 
  "mean" = mean(all_trips_table$ride_length, na.rm = TRUE))



# new tablest related to users frecuency 


frecuency_table <-  all_trips_table[,
                        .(is_weekend = ifelse(day_of_week %in% c("sábado", "domingo"), "Si", "No"), users_count = .N),
                        by = .(member_casual,day ,day_of_week, month, rideable_type)]

frecuency_table <- frecuency_table %>%
mutate(rideable_type = recode(rideable_type, 
                              "electric_bike" = "Bici eléctrica",
                              "classic_bike" = "Bici clásica",
                              "electric_scooter" = "Scooter"))

ride_length_hour <-all_trips_table[, hour := format(started_at, format = "%H:00")][,
              .(mean_length = mean(ride_length),
                median_length = median(ride_length)
                #Q = paste0("T", unique(quarter(started_date )))
                ),
              by = .(member_casual,hour, Q= paste0("T", quarter(started_date)))]

hours_factor <-  0:23

for(h in hours_factor){
  hours_factor[h+1] <- paste0(h,":00") 
}

for(h in 0:9){
  hours_factor[h+1] <- paste0("0", hours_factor[h+1])
}



Q_factor <- c("T1", "T2", "T3", "T4")

ride_length_hour[, `:=`(hour = ordered(hour, levels = hours_factor),
                        Q = ordered(Q, levels = Q_factor))]



ride_length_day <-  all_trips_table[, 
                      .(mean_length = mean(ride_length), 
                        median_length = median(ride_length), 
                        n_rides = .N),
                      by=.(member_casual, day_of_week, month)]

















