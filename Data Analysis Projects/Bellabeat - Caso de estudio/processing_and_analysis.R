library(tidyverse)
library(dplyr)
library(tidyr)
library(readr)
library(lubridate)
library(ggplot2)
library(forcats)

# ----------------------- Data processing  ---------------------- #

daily_activity <-  read.csv("./datasets/dailyActivity_merged.csv")
hourly_calories <-  read.csv("./datasets/hourlyCalories_merged.csv") 
hourly_intensities <-  read.csv("./datasets/hourlyIntensities_merged.csv")
hourly_steps <-  read.csv("./datasets/hourlySteps_merged.csv")
heartrate_seconds <- read.csv("./datasets/heartrate_seconds_merged.csv")



## Print type of date column of every table to verify if it's consistent

print_type <-  function(df,column_name){
  cat(colnames(df %>% select(all_of(column_name))), " - ", typeof(df[[column_name]]))
}

print_type(daily_activity, "ActivityDate")
print_type(hourly_calories, "ActivityHour")
print_type(hourly_intensities, "ActivityHour")
print_type(hourly_steps, "ActivityHour")
print_type(heartrate_seconds, "Time")
#   print_type(minute_sleep, "date")

# Preview data

head(daily_activity,3)

# All tables has wrong type in date column.
# Also, the names of every column of all tables isn't in lower case


## Fixing date format

daily_activity$ActivityDate <- as.Date(daily_activity$ActivityDate, "%m/%d/%Y")
hourly_calories$ActivityHour <- mdy_hms(hourly_calories$ActivityHour)
hourly_intensities$ActivityHour <- mdy_hms(hourly_intensities$ActivityHour)
hourly_steps$ActivityHour <- mdy_hms(hourly_steps$ActivityHour)
heartrate_seconds$Time <- mdy_hms(heartrate_seconds$Time)
# minute_sleep$date <- mdy_hms(minute_sleep$date)



str(daily_activity)
str(hourly_calories)

## filter and removing irrelevant data from daily activity table

print(daily_activity %>%  
  group_by(Id) %>%  
  summarise(count = n()), n=25)

print(sum(daily_activity$TotalDistance!=daily_activity$TrackerDistance)) # only 16 values are different
print(sum(daily_activity$TotalDistance==0 & daily_activity$TrackerDistance==0)) # there are 63 records with this condition

daily_activity %>% 
  filter(TotalDistance==0 & TrackerDistance == 0) %>% 
  group_by(Id) %>%  
  summarize(count = n(),
            steps_max = sum(TotalSteps), 
            sedentary_hours_min = min(SedentaryMinutes)/60,
            sedentary_hours_max = max(SedentaryMinutes)/60,
            colories_mean =  mean(Calories))

# In the last group_by code, we observed some users that has total distance equal to 0, and the following was noticed:
# 1. Almost all users has Total Steps equal to zero.
# 2. Some user has at least less than 24 hours of sedentary hours, with a total steps equal to zero.
# 3. The user with Id = 4057192912 has only four steps in total, with 24 hours of sedentary hours as minimum and maximum.

# Therefore, this data could affect the result of the analysis 

## 

daily_activity %>% group_by(Id) %>%
  summarise(difference = mean(TotalDistance - TrackerDistance)) %>% arrange(-difference) 
# we could consider these columns as the same

daily_activity$TotalDistance <-  pmax(daily_activity$TotalDistance, daily_activity$TrackerDistance)

# rm not relevant columns
daily_activity <-  daily_activity %>% subset(select = -c(TrackerDistance, LoggedActivitiesDistance, SedentaryActiveDistance))



## Renaming columns of every table 

convert_name <- function(df){
  df %>%  
    rename_all(~str_replace_all(., "([A-Z])", "_\\1") %>%  # add "_" between upper       
                 str_replace_all(., "^_", "") %>%           # remove "_" at the beginning
                 str_to_lower(.)                            # finally convert to lowercase
    )
}


daily_activity <- convert_name(daily_activity)
hourly_calories <-  convert_name(hourly_calories)
hourly_intensities <- convert_name(hourly_intensities)
hourly_steps <- convert_name(hourly_steps)
heartrate_seconds <- convert_name(heartrate_seconds)
#   minute_sleep <- convert_name(minute_sleep)



# dropping duplicates and NA

sum(duplicated(daily_activity))  #0 
sum(duplicated(hourly_calories)) # 0 
sum(duplicated(hourly_intensities)) # 0
sum(duplicated(hourly_steps)) # 0 
sum(duplicated(heartrate_seconds)) # 0 

# merge the hourlys tables
merge_hourly  = hourly_calories %>% 
  merge(hourly_intensities, by = c("id", "activity_hour")) %>% 
  merge(hourly_steps, by = c("id", "activity_hour")) 


# sum(is.na(merge_hourly)) # 0 

## adding day of the week and if it is weekend or not.

Sys.setlocale("LC_TIME", "en_US.UTF-8")


merge_hourly <- merge_hourly %>%  
    mutate(date = as.Date(activity_hour), 
           time = format(activity_hour, format = "%H:%M:%S")) %>%
    mutate(day = weekdays(date), 
           is_weekend = ifelse( weekdays(date) %in% c("Saturday", "Sunday"), "Yes", "No")) %>% 
    select(-activity_hour) 


daily_activity <-  daily_activity %>% 
    mutate(day = weekdays(activity_date), 
           is_weekend = ifelse( weekdays(activity_date) %in% c("Saturday", "Sunday"), "Yes", "No")) 


hourly_heart_rate <- heartrate_seconds %>%  
  mutate(date = as.Date(time), 
         time_hour = format(time, format = "%H:00:00" )) %>% 
  group_by(id, date, time_hour) %>% 
  summarise(average_heart_rate = mean(value)) %>% 
  rename(time = time_hour) 

##  merging heart rate and merge-hourly

mean_intensity <- mean(merge_hourly$total_intensity[merge_hourly$total_intensity > 0], na.rm = TRUE)

merge_heart_rate <-  hourly_heart_rate %>%  
  inner_join(merge_hourly, by = c("id", "date", "time")) %>%
  filter(average_intensity > 0) %>% 
  mutate(intensity_label = case_when(
    total_intensity < mean_intensity ~ "Low",
    total_intensity >= mean_intensity & total_intensity <= 60 ~ "Moderate",
    total_intensity > 60 ~ "High"
  )) %>% 
  pivot_longer(cols = c("average_heart_rate", "min_heart_rate", "max_heart_rate"),
               names_to = "type",
               values_to = 'hr_value') %>% 
  mutate(time = hms::as_hms(time))


# group by hour 
hourly_summary <-  merge_hourly %>%
  group_by(time, is_weekend) %>% 
  summarise(mean_calories_sample = mean(calories),
            median_intensity = median(total_intensity),
            median_total_step = median(step_total)) %>%  ungroup()



day_levels <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")

daily_activity$day <- factor(daily_activity$day, levels = day_levels)
merge_hourly$day <- factor(merge_hourly$day, levels = day_levels)


## data integrity-validation and processing is done  

#----------------------------- Plots ------------------------------------#


# mean_steps of all user by hour distribution
hourly_summary %>%
  arrange(time) %>% 
  ggplot(aes(x=median_total_step, y = time)) + 
    geom_bar(stat = "identity") + 
    coord_flip() + 
    ylab("") + 
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) # test


# median steps at week
is_weekend_label = c("During the week", "Weekend")
names(is_weekend_label) = c("No", "Yes")

plot_1 <- hourly_summary%>% 
  ggplot(aes(x=median_total_step, y = time, fill = is_weekend)) + 
  geom_bar(stat = "identity", alpha = 0.5) + 
  coord_flip() + 
  ylab("") + xlab("") + 
  facet_wrap(~is_weekend, ncol = 1, scales = "free_y",
             labeller = labeller(is_weekend = is_weekend_label),
             strip.position = "left") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        legend.position = "none") +  
  labs(title =  "The Median Number of Steps",
       subtitle = "The median number of steps taken by the users on weekdays and weekends",
       caption = "Based in Data from FitBit") + 
  scale_fill_brewer(palette="Dark2")  # nice plot


# scatter plot between intensity and steps

merge_hourly %>% 
  filter(total_intensity != 0) %>% 
  group_by(time, day) %>% 
  summarise(mean_intensity = mean(total_intensity),
            mean_total_step = mean(step_total)) %>% 
  ggplot(aes(x = mean_intensity, y = mean_total_step)) +
  geom_point() # probably


## compare sedentary minutes per day and week

plot_2 <- daily_activity %>%  
  mutate(sedentary_hours =sedentary_minutes/60-7) %>%
  filter(sedentary_hours>0) %>% 
  ggplot(aes(x = day, y =sedentary_hours, fill = is_weekend)) + 
  geom_violin(trim=FALSE, alpha = 0.35) + 
  geom_boxplot(width=0.08, alpha =1) + 
  scale_fill_brewer(palette="Dark2") + theme_minimal() +
  labs(title = "Distribución de horas sedentarias",
       subtitle = "Distribución de las horas sedentarias de los usarios \n durante los siete días de la semana ",
        caption = "Basado en datos de FitBit") + 
  theme(legend.position = "none") + 
  xlab("") + ylab("") #nice


## scatter distance and sedentary 
daily_activity %>%  
  group_by(id,day) %>% 
  summarise(mean_total_distance = mean(total_distance), 
            mean_sedentary_hours = mean(sedentary_minutes/60)) %>% 
  ggplot(aes(x = mean_sedentary_hours, y= mean_total_distance, color = day)) +
  geom_point() + facet_wrap(~day) # not


## heart rate visite https://www.healthline.com/health/dangerous-heart-rate#seeing-a-doctor

heartrate_labels = c("Average Heart Rate",
                    "Maximum Heart Rate",
                    "Minimum Heart Rate")
names(heartrate_labels) = c("average_heart_rate",
                            "max_heart_rate",
                            "min_heart_rate")

type_labels = c("High \nIntensity.",
                "Moderate \nIntensity.",
                "Low \nIntensity.")
names(type_labels) = c("High", "Moderate", "Low")

plot_3 <- merge_heart_rate %>%  
  ggplot(aes(x= hr_value, y= calories)) + 
  geom_point() +
  facet_wrap(~intensity_label, scales = 'free_y', 
             labeller = labeller(intensity_label = type_labels)) + 
  scale_fill_viridis_c() +
  labs(title = "Comparación de Calorías vs Ritmo Cardíaco",
       subtitle = "Calorias quemadas de acuerdo a la frecuencia cardiaca, \nsegmentado por el tipo de intensidad.",
       caption = "Basado en datos de FitBit", 
       y = "Calorias Quemadas", x = "Frecuencia Cardiaca (bpm)") + 
  theme(legend.position = "none")
  

plot_4 <- daily_activity %>% 
  filter(total_distance!=0) %>% 
  ggplot(aes(x= day, y=total_distance, fill = is_weekend)) +
  geom_violin(trim=FALSE, alpha = 0.35) + 
  geom_boxplot(width=0.08, alpha =1) + 
  scale_fill_brewer(palette="Dark2") + theme_minimal() +
  labs(title = "Distribución de Distancia Total Recorrida",
       subtitle = "Distribuciones de la distancia total de los usuarios \n durante los siete días de la semana", 
       caption = "Basado en datos de FitBit") + 
  theme(legend.position = "none") + 
  xlab("") + ylab("Distancia recorrida [km]") #nice
