library(tidyverse)
library(dplyr)
library(tidyr)
library(readr)
library(lubridate)
library(data.table)
library(ggplot2)
library(scales)
library(patchwork)
library(cowplot)


#------------------- Descriptive Analysis Preview-----------------------------#


# Poosible colors for the plots and dashboards


# 00acc0  like cyan-- check the cyclistic logo
# eeff41 like yellow -- check the cyclistic logo

# 006874 darker than 00acc0


###############################################################################

# Conduct descriptive analysis.

# data visualization of frecuency table


user_colors <- c("miembro"="#006874", "casual" = "#00acc0")
another_color <- "#eeff41"
almwhite <- "#ebebeb" 
dark_base <- "#132729"

caption_description <- "Grafico propio basado en datos de Cyclistic"


theme_cyclistic <- theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 11, face = "italic"),
    legend.position = "right",
    legend.title = element_text(size = 9, face = "bold"),
    legend.text = element_text(size = 8),
    plot.caption.position = "plot"
  )

# How many users use the service

plot_1 <- frecuency_table[, .(total_users = sum(users_count)), 
                    by = .(member_casual)] %>% 
  ggplot(aes(x ="", y=total_users, fill = member_casual)) +
  geom_bar(stat = 'identity', width = 1.1, color = almwhite) +
  coord_polar(theta = "y", start = 0) +
  scale_y_continuous(expand = c(0, 0)) +
  geom_text(aes(label = paste0(round(total_users/sum(total_users)*100,1),"%")),
            position = position_stack(vjust = 0.5), size = 4.2, color = "white")  +
  scale_fill_manual(values = user_colors) +
  labs(title = "Porcentaje de usuarios en 2024",
       subtitle = "Comparación entre miembros y usuarios casuales",
       caption = "Gráfico propio basado en datos de Cyclistic",
       fill = "Tipo de usuario") + theme_void()  +
  theme_cyclistic


#  preference of rideable_type by users

plot_2 <- frecuency_table[, .(total_users = sum(users_count)),
                by = .(member_casual, rideable_type)] %>% 
  ggplot(aes(x = reorder(rideable_type,-total_users),y = total_users,
             fill = member_casual)) +
  geom_bar(stat = "identity", width = 0.75, position = "dodge2") +
  geom_text(aes(label = ifelse(total_users >= 1e6, 
                               paste0(round(total_users / 1e6, 1), "M"), 
                               paste0(round(total_users / 1e3, 0), "K"))),
            position = position_dodge(width = 0.75), vjust = -0.5, size = 3.2) +
  scale_fill_manual(values = user_colors) + 
  labs(title = "¿Qué tipo de transporte prefieren los usuarios?",
       subtitle = "Comparación entre los miembros y usuarios casuales en el uso de bicletas o scooters",
       caption = caption_description,
       fill = "Tipo de usuario") +
  ylab("") + xlab("") + theme_minimal() +
  theme_cyclistic +
  scale_y_continuous(label = label_number(scale_cut = cut_short_scale()),
                     limits = c(0,2e6)) 



# Information about year and month

## Percentage of mothly users

percentage_month <- frecuency_table[,.(total = sum(users_count)), by = .(member_casual, month)][,
                      prop_users := total/sum(total)*100, 
                    by = month][,
                                prop_users := ifelse(member_casual == "casual", -prop_users, prop_users)
                    ]



## Number of users by month (for plot 3)


users_group <- factor(frecuency_table[, .(total_users = sum(users_count)), 
                                      by = .(member_casual, month)]$member_casual, c("miembro", "casual"))

max_values_month <- frecuency_table[, .(total_users = sum(users_count)), 
                                    by = .(member_casual, month)][, .SD[which.max(total_users)], by = member_casual]


# for plot 4
abreviaturas <- c(
  "enero" = "ene",  "febrero" = "feb",  "marzo" = "mar",
  "abril" = "abr","mayo" = "may","junio" = "jun",
  "julio" = "jul","agosto" = "ago","septiembre" = "sep",
  "octubre" = "oct","noviembre" = "nov","diciembre" = "dic"
)

## Number of users time sertes (for plot 5)


total_daily <- all_trips_table[,.(daily_count=.N, week_number = week(started_date)),
                               by = .(member_casual, started_date)] 


total_daily <- total_daily[, .(mean_week_count = mean(daily_count)), by = .(week_number, member_casual)][total_daily, on = .(week_number, member_casual)]



titles_size <- 9


plot_3 <- percentage_month %>% 
  ggplot(aes(x = prop_users, y = month, fill = member_casual)) +
  geom_col(width = 0.75, show.legend = F) +
  #  geom_text(aes(label = paste0(round(abs(prop_users),1), "%")),
  #            position = position_stack(),  size = 3.1
  #            ) +
  scale_fill_manual(values = user_colors) +
  scale_y_discrete(limits = rev(levels(percentage_month$month))) +  # revert the order fix the problem of order, thx deepseek
  scale_x_continuous(labels = function(x) paste0(abs(x), "%"), limits = c(-55,100), breaks = c(-50,-25,0,25,50,75)) +  
  labs(title = "Porcentaje mensual de usuarios",
       caption = caption_description) + 
  ylab("") + xlab("") +
  theme_minimal_vgrid(font_size = titles_size) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.title.position = "plot")


plot_4 <- frecuency_table[, .(total_users = sum(users_count)), 
                          by = .(member_casual, month)] %>% 
  ggplot(aes(x = month, y = total_users, 
             group = users_group, fill = member_casual)) +
  geom_area(position = "identity", show.legend = T) +
  geom_line(color = "#132729", linewidth = 1.15, show.legend = F) +  # Se fija un solo color
  geom_point(color = "#132729", shape = 18, size = 3, show.legend = F) +  
  geom_point(
    data = max_values_month, aes(x = month, y = total_users),
    shape = 18, color = another_color, size = 5, alpha = 0.95,
    inherit.aes = FALSE  # Ignora los mapeos del gráfico principal
  ) +
  scale_fill_manual(values = user_colors, name = "Tipo de usuario") +  
  scale_x_discrete(labels = abreviaturas) + 
  labs(title = "Total de usuarios mensualmente") +
  ylab("") + xlab("") + theme_minimal_hgrid(font_size = titles_size) +
  scale_y_continuous(label = label_number(scale_cut = cut_short_scale()),
                     limits = c(0,5e5)) +
  theme(plot.title = element_text(hjust = 0.35),
        plot.title.position = "plot")



plot_5 <-total_daily %>% 
  ggplot(aes(x = started_date, y = daily_count, group = member_casual, colour = member_casual)) +
  geom_line(linewidth = .642, show.legend = F) +
  geom_line(aes(x = started_date, y = mean_week_count), linewidth = 1.5, show.legend = T) +
  scale_colour_manual(values = user_colors,name = "Tipo de usuario" ) + 
  labs(
    title = "Evolución diaria y promedio semanal de usuarios"
  ) +
  xlab("") + ylab("") +
  theme_minimal_hgrid(font_size = titles_size) + 
  theme(plot.title = element_text(hjust = 0.5))

  
  
(plot_3 + plot_4)/plot_5 + plot_annotation(
  title = "¿Cómo ha sido el comportamiento de los usuarios durante el 2024?",
  caption = caption_description
)


### Ride length #######################################

users_names <- c('miembro' = "Miembro", 'casual' = "Usuario Casual")


ride_length_hour %>% 
ggplot(aes(x = hour, y = median_length, group = Q, color = Q)) +
  geom_line(linewidth = 1.2) +
  geom_point() +
  facet_wrap(member_casual~., labeller = as_labeller(users_names)) + 
  scale_color_manual(values = c("#ffc107", "#454545", "#6fb98f", "#5fd3bc"), name = "Trimestre") +
  labs(
    title = "¿Cómo varia el tiempo medio de uso entre los usuarios casuales y miembros a lo largo el día?",
    subtitle = "Comparación de los tiempos medios por trimestre para cada tipo de usuario",
    caption = caption_description
  ) +
  theme_minimal_hgrid(font_size = 10) +
  theme_cyclistic + 
  theme(axis.text.x = element_text(angle = 90, size = 8)) +
  ylab("") + xlab("")



ride_length_day %>% 
  ggplot(aes(x = day_of_week, y = month, fill = median_length)) +
  geom_tile() + 
  scale_fill_gradient(high = "#d4ff41", low = "#003940" ) +
  scale_y_discrete(limits =  rev(levels(ride_length_day$month))) +
  facet_wrap(~member_casual,  labeller = as_labeller(users_names)) +
  labs(title = "¿Cómo varia el tiempo medio de uso a lo largo del año entre los usuarios?",
       subtitle = "Variación mensual y semanal del tiempo medio de uso para usuarios casuales y miembros",
       caption = caption_description,
       fill = "Tiempo medio (min)") +
  theme_minimal_grid() +
  theme(axis.text.x = element_text(angle = 90, size = 8, hjust = 0.25, vjust = -.1),
        axis.text.y = element_text(size = 8),
        strip.text.x = element_text(size = 11, face = "bold")) + 
  ylab("") + xlab("")
























