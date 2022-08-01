# Strava

Create artistic visualisations with your Strava exercise data

For the Python version see https://github.com/marcusvolz/strava_py

## Examples

### Facets

A plot of activities as small multiples. The concept behind this plot was originally inspired by [Sisu](https://twitter.com/madewithsisu).

![facets](https://github.com/marcusvolz/strava/blob/master/inst/plots/facets001.png "Facets, showing activity outlines")

### Map

![map](https://github.com/marcusvolz/strava/blob/master/inst/plots/map001.png "Map, showing activities on a map")

### Elevations

![map](https://github.com/marcusvolz/strava/blob/master/inst/plots/elevations001.png "Facets, showing elevation profiles")

### Calendar

![map](https://github.com/marcusvolz/strava/blob/master/inst/plots/calendar001.png "Calendar map")

### Ridges

![map](https://github.com/marcusvolz/strava/blob/master/inst/plots/ridges001.png "Ridges")

### Packed circles

![map](https://github.com/marcusvolz/strava/blob/master/inst/plots/circles001.png "Packed circles")

### Activities by year ridges

![map](https://github.com/Vosbrucke/strava/blob/master/inst/plots/year_history_ridges.png "Activities by year ridges")

### Activities by year

![map](https://github.com/Vosbrucke/strava/blob/master/inst/plots/year_history_plot.png "Activities by year")

### Activities by month

![map](https://github.com/Vosbrucke/strava/blob/master/inst/plots/month_history_plot.png "Activities by month")

### Activities by week

![map](https://github.com/Vosbrucke/strava/blob/master/inst/plots/week_history_plot.png "Activities by week")

### Individual activity map

![map](https://github.com/Vosbrucke/strava/blob/master/inst/plots/individual_plot_map.png "Individual activity map")

## How to use

### Bulk export from Strava
The process for downloading data is described on the Strava website here: [https://support.strava.com/hc/en-us/articles/216918437-Exporting-your-Data-and-Bulk-Export#Bulk], but in essence, do the following:

1. Log in to [Strava](https://www.strava.com/)
2. Select "[Settings](https://www.strava.com/settings/profile)" from the main drop-down menu at top right of the screen
3. Select "[My Account](https://www.strava.com/account)" from the navigation menu to the left of the screen.
4. Under the "[Download or Delete Your Account](https://www.strava.com/athlete/delete_your_account)" heading, click the "Get Started" button.
5. Under the "Download Request", heading, click the "Request Your Archive" button. ***Don't click anything else on that page, i.e. particularly not the "Request Account Deletion" button.***
6. Wait for an email to be sent
7. Click the link in email to download zipped folder containing activities
8. Unzip files

### Install the packages

```R
install.packages(c("devtools", "mapproj", "tidyverse", "gtools", "lubridate", "wesanderson", "ggmap", "patchwork"))
devtools::install_github("marcusvolz/strava")
devtools::install_github("AtherEnergy/ggTimeSeries")
```

### Load the library

```R
library(strava)
```

### Process the data

Note: Strava changed the way that activity files are bulk exported in ~May 2018. The process_data function only works with gpx files, so if your exported files are in some other format they will need to be converted (or imported into R some other way). One way to do this is to use [GPSBabel](https://www.gpsbabel.org/index.html), which converts between different GPS data formats (e.g. fit to gpx).

```R
data <- process_data(<path to folder with gpx files>)
```

Load activities data
```R
activities <- process_activities(<path to activities.csv file>)
```

Join data with activities
```R
data <- join_data_activities()
```

There are some sample data included with the package:

```R
# Sample running data.
running <- process_data(system.file("gpx/running", package = "strava"))
# Sample cycling data.
cycling <- process_data(system.file("gpx/cycling", package = "strava"))
```

You can also list them all or get the path to a specific one using its name:

```R
# List all the examples (no argument)
gpx_example()
# Get a specific gpx (using its partial or full name)
gpx_example("734")
```

### Plot activities as small multiples

```R
p1 <- plot_facets(data)
ggsave("plots/facets001.png", p1, width = 20, height = 20, units = "cm")
```

### Plot activity map

```R
p2 <- plot_map(data, lon_min = 144.9, lon_max = 145.73, lat_min = -38.1, lat_max = -37.475)
ggsave("plots/map001.png", p2, width = 20, height = 15, units = "cm", dpi = 600)
```

### Plot elevation profiles

Note: Strava changed the way that activity files are bulk exported in ~May 2018. Unfortunately this plot will not work with files exported from Strava after this time.

```R
p3 <- plot_elevations(data)
ggsave("plots/elevations001.png", p3, width = 20, height = 20, units = "cm")
```

### Plot calendar

```R
p4 <- plot_calendar(data, unit = "distance")
ggsave("plots/calendar001.png", p4, width = 20, height = 20, units = "cm")
```

### Plot ridges

```R
p5 <- plot_ridges(data)
ggsave("plots/ridges001.png", p5, width = 20, height = 20, units = "cm")
```

### Plot packed circles

```R
p6 <- plot_packed_circles(data)
ggsave("plots/packed_circles001.png", p6, width = 20, height = 20, units = "cm")
```

### Plot year history ridges

```R
p7 <- year_history_ridges(activities)
ggsave("plots/year_history_ridges.png", p7, width = 20, height = 20, unit = "cm")
```

### Plot year history

```R
p8 <- year_history_plot(activities)
ggsave("plots/year_history_plot.png", p8, width = 25, height = 20, unit = "cm")
```

### Plot month history

```R
p9 <- month_history_plot(activities)
ggsave("plots/month_history_plot.png", p9, width = 25, height = 15, unit = "cm")
```

### Plot week history

```R
p10 <- week_history_plot(activities)
ggsave("plots/week_history_plot.png", p10, width = 25, height = 15, unit = "cm")
```

### Plot individual map

```R
p11 <- individual_plot_map(data)
ggsave("plots/individual_plot_map.png", p11, width = 20, height = 20, unit = "cm")
```
