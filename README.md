# Strava

Create artistic visualisations with your Strava exercise data

## Examples

### Facets

![facets](https://github.com/marcusvolz/strava/blob/master/plots/facets001.png "Facets, showing activity outlines")

### Map

![map](https://github.com/marcusvolz/strava/blob/master/plots/map001.png "Map, showing activities on a map")

### Elevations

![map](https://github.com/marcusvolz/strava/blob/master/plots/elevations001.png "Facets, showing elevation profiles")

## How to use

### Bulk export from Strava

1. Log in to [Strava](https://www.strava.com/)
2. Select "[Settings](https://www.strava.com/settings/profile)" from the main drop-down menu at top right of the screen
3. Select "Download all your activities" from lower right of screen
4. Wait for an email to be sent
5. Click the link in email to download zipped folder containing activities
6. Unzip files

### Install the package

```bash
devtools::install_github("marcusvolz/strava")
```

### Process the data

```bash
data <- process_data(<gpx file path>)
```

### Plot activities as small multiples

```bash
p1 <- plot_facets(data)
ggsave("plots/facets001.png", p1, width = 20, height = 20, units = "cm")
```

### Plot activity map

```bash
p2 <- plot_map(data, lon_min = 144.9, lon_max = 145.73, lat_min = -38.1, lat_max = -37.475)
ggsave("plots/map001.png", p2, width = 20, height = 15, units = "cm", dpi = 600)
```

### Plot elevation profiles

```bash
p3 <- plot_elevations(data)
ggsave("plots/elevations001.png", p3, width = 20, height = 20, units = "cm")
```
