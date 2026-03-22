# Public Transport in Milan

Running multimodal routing using r5r.

Tested:
- Running example code from r5r documentation.
- Trip duration between origin and destination for a specific time period.
- Tube station accessibility from all other stations.

## Top 2 Routes by Walk + Transit
Shortest path by duration using transit at 8am.

![Figure 1: Routes](/img/det_route_comparison.png)

## Change in Trip Duration During the Day
For the same origin–destination pair as above, plotting how long it takes to travel at different times during the day.

![Figure 2: Routes](/img/milano_transit_duration_plot.png)

## Mapping Tube Station Accessibility
Mapping the count of stations reachable within 30 minutes.

![Figure 3: Tube station accessibility](/img/tube_accessibility.png)

## Data Sources

- [OpenStreetMap](https://download.geofabrik.de/)
- [Transitland](https://www.transit.land/feeds/f-u0nd-comunedimilano)


