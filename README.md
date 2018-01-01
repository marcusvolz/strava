# Strava

Create artistic visualisations with your Strava exercise data

## Examples

### Facets

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

1. Log in to [Strava](https://www.strava.com/)
2. Select "[Settings](https://www.strava.com/settings/profile)" from the main drop-down menu at top right of the screen
3. Select "Download all your activities" from lower right of screen
4. Wait for an email to be sent
5. Click the link in email to download zipped folder containing activities
6. Unzip files

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
