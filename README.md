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
install.packages(c("devtools", "mapproj", "tidyverse"))
devtools::install_github("marcusvolz/strava")
```

### Load the libraries

```R
library(strava)
library(tidyverse)
```

### Process the data

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

```R
p3 <- plot_elevations(data)
ggsave("plots/elevations001.png", p3, width = 20, height = 20, units = "cm")
```

### Plot Calendar

See the following gist: https://gist.github.com/marcusvolz/84d69befef8b912a3781478836db9a75

### Plot Ridges

See the following gist: https://gist.github.com/marcusvolz/854f3bab1f63aa8a938b5026820682fa

### Plot Ridges

Code to come.
