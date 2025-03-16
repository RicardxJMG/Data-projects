library(tidyverse)
library(dplyr)
library(tidyr)
library(readr)
library(lubridate)
library(data.table)
library(ggplot2)

#------------------- Descriptive Analysis Preview-----------------------------#

# Conduct descriptive analysis.

# descriptive statistics without filtering outliers

all_trips_table[, .(mean_ride_length = mean(ride_length),
                                   min_ride_length = min(ride_length),
                                   max_ride_length = max(ride_length),
                                  median_ride_length = median(ride_length)), by = member_casual]



# almost same as above, but the ride length between the 25 and 75 percentiles
all_trips_table[ride_length>=quantile(ride_length, 0.25) & ride_length <= quantile(ride_length,0.85),
                .(mean_ride_length = mean(ride_length),
                  min_ride_length = min(ride_length),
                  max_ride_length = max(ride_length),
                  median_ride_length = median(ride_length)), by = member_casual]



#  looking hypotesis test with t-student test
t.test(ride_length ~ member_casual, data = all_trips_table)

# the test display:
# t = 193.88, df = 2554550, p-value < 2.2e-16
# alternative hypothesis: true difference in means between group casual and group member is not equal to 0
# 95 percent confidence interval


# the following graphs will be in a dashboard but more beauty

# counting the users

plot_1 =all_trips_table[,
                .(total_members = round(.N*100/dim(all_trips_table)[1],2) ),
                by = .(member_casual)] %>% 
                ggplot(aes(x = "", y = total_members, fill = member_casual)) +
                geom_bar(stat = "identity", width = 1.23, color = "white") + 
                coord_polar("y", start = 0) + theme_void() 



# ride length mean by day of week respect of memberms

plot_2 <- all_trips_table[, .(mean_ride_day = mean(ride_length)),
                by =.(member_casual, day_of_week)][order(day_of_week)] %>% 
                ggplot(aes(day_of_week, mean_ride_day, fill = member_casual)) +
                geom_col(position = "dodge", width = 0.75) + theme_minimal()  



# which is the favorite ride type of of members and casuals.

plot_3 <- all_trips_table[, .(ride_type_count = .N )  , by = .(member_casual, rideable_type)] %>% 
      ggplot(aes(x = member_casual, y = ride_type_count, fill = rideable_type)) +
      geom_col(position = "dodge", width = 0.75) + theme_minimal()


# which is mean number of ride type by day of members and casual


plot_4 <- all_trips_table[, .(count = .N), by = .(member_casual, rideable_type, day_of_week)][,
                 .(mean_count = mean(count)), by = .(member_casual, rideable_type, day_of_week)] %>% 
  ggplot(aes(x = day_of_week, y = mean_count, fill = rideable_type)) +
  geom_col(position = "dodge", width = 0.75) + 
  facet_wrap(~member_casual) +
  theme_minimal()





# Poosible colors for the plots and dashboards


# 00acc0  like cyan-- check the cyclistic logo
# eeff41 like yellow -- check the cyclistic logo







