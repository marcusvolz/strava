# Strava

Create artistic visualisations with your Strava exercise data

## Examples

### Facets

A plot of activities as small multiples. The concept behind this plot was originally inspired by [Sisu](https://www.madewithsisu.com/).

![facets](https://github.com/marcusvolz/strava/blob/master/plots/facets001.png "Facets, showing activity outlines")

### Map

![map](https://github.com/marcusvolz/strava/blob/master/plots/map001.png "Map, showing activities on a map")

### Elevations

![map](https://github.com/marcusvolz/strava/blob/master/plots/elevations001.png "Facets, showing elevation profiles")

### Calendar

![map](https://github.com/marcusvolz/strava/blob/master/plots/calendar001.png "Calendar map")

### Ridges

![map](https://github.com/marcusvolz/strava/blob/master/plots/ridges001.png "Ridges")

### Packed circles

![map](https://github.com/marcusvolz/strava/blob/master/plots/circles001.png "Packed circles")

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
install.packages(c("devtools", "mapproj", "tidyverse", "gtools"))
devtools::install_github("marcusvolz/strava")
```

### Load the library

```R
library(strava)
```

### Process the data

Note: Strava changed the way that activity files are bulk exported in ~May 2018. The process_data function only works with gpx files, so if your exported files are in some other format they will need to be converted (or imported into R some other way). One way to do this is to use [GPSBabel](https://www.gpsbabel.org/index.html), which converts between different GPS data formats (e.g. fit to gpx).

```R
data <- process_data(<gpx file path>)
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
p5 <- plot_calendar(data, unit = "distance")
ggsave("plots/calendar001.png", p5, width = 20, height = 20, units = "cm")
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
