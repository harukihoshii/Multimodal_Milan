install.packages(c('r5r', 'rJavaEnv'))

#check version of Java currently installed (if any) 
rJavaEnv::java_check_v ersion_rjava()

## if this is the first time you use {rJavaEnv}, you might need to run this code
## below to consent the installation of Java.
# rJavaEnv::rje_consent(provided = TRUE)

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

data_path <- "data/r5_milan"
list.files(data_path)



#indicate the path where OSM and GTFS data are stored
r5r_network <- build_network(data_path = data_path)

#create origin and destination
origin_point <- st_point(c(145.023898, -37.812544))
origin <- st_sf(
  id = 1,
  geometry = st_sfc(origin_point, crs = 4326)
)

dest_point <- st_point(c(144.966844, -37.817966))
destination <- st_sf(
  id = 1,
  geometry = st_sfc(dest_point, crs = 4326)
)

mode <- c("WALK", "TRANSIT")
max_walk_time <- 60 # minutes
departure_datetime <- as.POSIXct("01-02-2026 09:00:00",
                                 format = "%d-%m-%Y %H:%M:%S")
departure_datetime
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


r5r::stop_r5(r5r_network)
rJava::.jgc(R.gc = TRUE)