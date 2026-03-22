install.packages(c('r5r', 'rJavaEnv', 'mapview'))

#check version of Java currently installed (if any) 
rJavaEnv::java_check_version_rjava()

options(java.parameters = "-Xmx2G")
options(java.parameters = c("-Xmx2G", "-XX:ActiveProcessorCount=4"))

library(r5r)
library(sf)
library(data.table)
library(ggplot2)
library(mapview)
library(tmap)


#the folder has osm.pbf and gtfs in Milan
data_path <- "data/r5_milan"

list.files(data_path)
r5r_network <- build_network(data_path = data_path)


#create origin and destination
origin <- 
  data.frame(id = "origin", lat = 45.477012, lon = 9.155919)

destination <- 
  data.frame(id = "dest", lat = 45.451357, lon = 9.202834)


mode <- c("WALK", "TRANSIT")
max_walk_time <- 30 # minutes
departure_datetime <- as.POSIXct("10-02-2026 08:00:00",
                                 format = "%d-%m-%Y %H:%M:%S")

#calculate detailed itineraries
det <- detailed_itineraries(
  r5r_network,
  origins = origin,
  destinations = destination,
  mode = mode,
  departure_datetime = departure_datetime,
  max_walk_time = max_walk_time,
  shortest_path = FALSE
)

#view detailed itineraries
mapview(det, zcol = "mode", lwd = 5)

str(det)

#extract OSM network
street_net <- r5r::street_network_to_sf(r5r_network)

#extract public transport network
#transit_net <- r5r::transit_network_to_sf(r5r_network)

#get bounding box of journies
det_sub <- subset(det, option < 4)
bb <- st_bbox(det_sub)

#crop street network edges to this area
edges_crop <- st_crop(street_net$edges, bb)

#plot
fig <- ggplot() +
  geom_sf(data = edges_crop, color = "gray85", linewidth = 0.1) +
  geom_sf(data = det_sub, aes(color = mode)) +
  scale_color_manual(values = c("#701705", "#F87C63")) +
  facet_wrap(~option, strip.position = "bottom") +
  theme_void() +
  theme(strip.text = element_blank(), legend.position = 'right', legend.justification = 'top',
        plot.background = element_rect(fill = "white", color = NA))
fig


ggsave(file.path('img/det_route_comparison.png'), fig, width = 7, height = 4)


r5r::stop_r5(r5r_network)
rJava::.jgc(R.gc = TRUE)