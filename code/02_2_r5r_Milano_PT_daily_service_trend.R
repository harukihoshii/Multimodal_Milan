#install.packages(c('r5r', 'rJavaEnv', 'mapview'))

#check version of Java currently installed (if any) 
rJavaEnv::java_check_version_rjava()

#below to consent the installation of Java.
#rJavaEnv::rje_consent(provided = TRUE)
#install Java 21
rJavaEnv::java_quick_install(version = 21)

#check if Java was successfully installed
rJavaEnv::java_check_version_rjava()
options(java.parameters = "-Xmx2G")
options(java.parameters = c("-Xmx2G", "-XX:ActiveProcessorCount=4"))


library(r5r)
library(sf)
library(data.table)
library(ggplot2)
library(mapview)
library(lubridate)


#set date of analysis
analysis_date <- "16-02-2026"
date_format <- "%d-%m-%Y %H:%M:%S"

#the folder has osm.pbf and gtfs in Milan
data_path <- "data/r5_milan"
#check files inside the folder
list.files(data_path)
#path with OSM and GTFS data
r5r_network <- build_network(data_path = data_path)


#create origin and destination
origin <- 
  data.frame(id = "origin", lat = 45.477012, lon = 9.155919)
destination <- 
  data.frame(id = "dest", lat = 45.451357, lon = 9.202834)

#create sequence of departure times (every 30 min from 6am to 10pm)
start_time <- as.POSIXct(paste(analysis_date, "06:00:00"), format = date_format)
end_time <- as.POSIXct(paste(analysis_date, "22:00:00"), format = date_format)

#generate time sequence
departure_times <- seq(from = start_time, to = end_time, by = "30 min")

results_list <- list()
mode_pt <- c("WALK", "TRANSIT")
mode_car <- c("CAR")
max_walk_time <- 30 # minutes

#loop through each departure time
for (i in seq_along(departure_times)) {
  
  cat("Processing departure time:", format(departure_times[i], "%H:%M:%S"), "\n")
  
  #calculate detailed itineraries
  det <- detailed_itineraries(
    r5r_network,
    origins = origin,
    destinations = destination,
    mode = mode_pt,
    departure_datetime = departure_times[i],
    max_walk_time = max_walk_time,
    shortest_path = FALSE
  )
  
  #keep only the first row if det has any rows
  if (nrow(det) > 0) {
    results_list[[i]] <- det[1, ] |> sf::st_drop_geometry()
  }
}

#combine all first rows into a single sf object
all_itineraries <- do.call(rbind, results_list)

#view the results
print(all_itineraries)

#convert departure_time to POSIXct if it's character
all_itineraries$departure_time <- as.POSIXct(paste(analysis_date, all_itineraries$departure_time),
                                             format = date_format)

#extract date for title
plot_date <- format(all_itineraries$departure_time[1], "%B %d, %A")
plot_weekday <- format(all_itineraries$departure_time[1], "%A")

#plot daily trend
ggplot(all_itineraries, aes(x = departure_time, y = total_duration)) +
  geom_ribbon(aes(ymin = min(total_duration), ymax = total_duration), 
              fill = "#2c3e50", alpha = 0.1) +
  geom_line(color = "#2c3e50", linewidth = 0.8) +
  geom_point(color = "#2c3e50", size = 2, alpha = 0.7) +
  labs(
    title = "Transit journey duration",
    subtitle = paste(plot_weekday, "·", plot_date),
    x = NULL,
    y = "Duration (minutes)"
  ) +
  scale_x_datetime(
    date_breaks = "2 hours",
    date_labels = "%H:%M"
  ) +
  theme_minimal(base_size = 13, base_family = "sans") +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "#e0e0e0", linewidth = 0.3),
    plot.title = element_text(face = "bold", size = 16, margin = margin(b = 5)),
    plot.subtitle = element_text(color = "#666666", size = 11, margin = margin(b = 15)),
    axis.title.y = element_text(margin = margin(r = 10), color = "#666666", size = 10),
    axis.text = element_text(color = "#666666"),
    axis.text.x = element_text(margin = margin(t = 5)),
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    plot.margin = margin(20, 20, 20, 20)
  )

#save 
ggsave("img/milano_transit_duration_plot.png", width = 10, height = 6, dpi = 300, bg = "white")


r5r::stop_r5(r5r_network)
rJava::.jgc(R.gc = TRUE)