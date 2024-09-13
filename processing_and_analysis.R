library(tidyverse)
library(dplyr)
library(tidyr)
library(readr)
library(lubridate)

# ----------------------- Data processing  ---------------------- #

daily_activity <-  read.csv("./datasets/dailyActivity_merged.csv")
hourly_calories <-  read.csv("./datasets/hourlyCalories_merged.csv") 
hourly_intensities <-  read.csv("./datasets/hourlyIntensities_merged.csv")
hourly_steps <-  read.csv("./datasets/hourlySteps_merged.csv")
#   minute_sleep <- read.csv("./datasets/minuteSleep_merged.csv") 

## Print type of date column of every table to verify if it's consistent

print_type <-  function(df,column_name){
  cat(colnames(df %>% select(all_of(column_name))), " - ", typeof(df[[column_name]]))
}

print_type(daily_activity, "ActivityDate")
print_type(hourly_calories, "ActivityHour")
print_type(hourly_intensities, "ActivityHour")
print_type(hourly_steps, "ActivityHour")
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
#   minute_sleep$date <- mdy_hms(minute_sleep$date)

str(daily_activity)
str(hourly_calories)

## filter and removing irrelevant columns of activity table

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
                 str_replace_all(., "^_", "") %>%           # remove "_" at the beginningda
                 str_to_lower(.)                            # finally covert to lowercase
    )
}


daily_activity <- convert_name(daily_activity)
hourly_calories <-  convert_name(hourly_calories)
hourly_intensities <- convert_name(hourly_intensities)
hourly_steps <- convert_name(hourly_steps)
#   minute_sleep <- convert_name(minute_sleep)



# dropping duplicates and NA

sum(duplicated(daily_activity))  #0 
sum(duplicated(hourly_calories)) # 0 
sum(duplicated(hourly_intensities)) # 0
sum(duplicated(hourly_steps)) # 0 
#   sum(duplicated(minute_sleep)) # 525 duplicated rows 

# merge the hourlys tables
merge_hourly  = hourly_calories %>% 
  merge(hourly_intensities, by = c("id", "activity_hour")) %>% 
  merge(hourly_steps, by = c("id", "activity_hour")) 

#
sum(is.na(merge_hourly))



## data integrity-validation and processing is done  