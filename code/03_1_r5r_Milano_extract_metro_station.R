library(dplyr)
library(gtfstools)
library(accessibility)
library(mapview)
library(sf)


milano <- "data/r5_milan/gtfs.zip"


#read gtfs
milano_gtfs <- read_gtfs(milano)


#check unique route types
unique(milano_gtfs$route$route_type)


#check stops
milano_gtfs$stops

#check how many unique metro routes the gtfs has
count(milano_gtfs$routes[route_type == 1])


#count routes with route_type == 1
routes_type1 <- milano_gtfs$routes %>% 
  filter(route_type == 1)

print(paste("Number of routes with route_type 1:", nrow(routes_type1)))


#get shapes for routes with route_type == 1
#get the trip IDs associated with route_type == 1
trips_type1 <- milano_gtfs$trips %>%
  filter(route_id %in% routes_type1$route_id)


#get unique stop_ids from stop_times for these trips
stops_type1 <- milano_gtfs$stop_times %>%
  filter(trip_id %in% trips_type1$trip_id) %>%
  pull(stop_id) %>%
  unique()


#convert stops to sf (spatial) points
metro_stops_sf <- convert_stops_to_sf(milano_gtfs, 
                                         stop_id = stops_type1, 
                                         crs = 4326)


#view detailed itineraries
mapview(metro_stops_sf)


#export as geopackage
st_write(metro_stops_sf, "data/data_inter/Milano_metro_stops.gpkg", driver = "GPKG")