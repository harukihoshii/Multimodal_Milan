#check if Java was successfully installed
rJavaEnv::java_check_version_rjava()
options(java.parameters = "-Xmx2G")
options(java.parameters = c("-Xmx2G", "-XX:ActiveProcessorCount=4"))

library(r5r)
library(accessibility)
library(sf)
library(data.table)
library(ggplot2)
library(dplyr)
library(mapview)
library(webshot2)
library(tmap)


#metro stations
metro_stops_sf <- st_read("data/data_inter/Milano_metro_stops.gpkg")
metro_stops_sf$id <- metro_stops_sf$stop_id
metro_stops_sf$opportunities <- 1


data_path <- "data/r5_milan"
list.files(data_path)
r5r_network <- build_network(data_path = data_path)


mode <- c("WALK", "TRANSIT")
max_walk_time <- 30 # minutes
travel_time_cutoff <- 30
time_window <- 30
departure_datetime <- as.POSIXct("01-02-2026 06:00:00",
                                 format = "%d-%m-%Y %H:%M:%S")

departure_datetime


#calculate accessibility
access_6am <- r5r::accessibility(
  r5r_network,
  origins = metro_stops_sf,
  destinations = metro_stops_sf,
  mode = mode,
  decay_function = "step",
  cutoffs = travel_time_cutoff,
  departure_datetime = departure_datetime,
  max_walk_time = max_walk_time,
  time_window = time_window,
  progress = FALSE
)

#merge accessibility estimates
access_6am_sf <- left_join(metro_stops_sf, access_6am, by = c('stop_id'='id'))


mapview(access_6am_sf, zcol = "accessibility")


tmap_mode("plot")

#map
tube_access_6am_img <- tm_shape(access_6am_sf) +
  tm_dots(fill = "accessibility", 
          fill.scale = tm_scale_continuous(values = "wes.zissou1", midpoint = 50),
          fill.legend = tm_legend(frame = FALSE, 
                                  item.height = 3, 
                                  item.width = 1.5,
                                  ticks.col = "white", 
                                  col = "white")) + 
  tm_layout(frame = FALSE,
            bg.color = "white") +
  tm_legend(frame = FALSE) +
  tm_basemap("CartoDB.PositronNoLabels")

tmap_save(tube_access_6am_img, 
          filename = "img/tube_accessibility.png", 
          width = 8, 
          height = 4, 
          dpi = 300)

r5r::stop_r5(r5r_network)
rJava::.jgc(R.gc = TRUE)