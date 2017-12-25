# Strava

Artistic visualisations of Strava activity data

## Examples

### Facets

![facets](https://github.com/marcusvolz/strava/blob/master/plots/facets001.png "Facets, showing activity outlines")

### Map

![map](https://github.com/marcusvolz/strava/blob/master/plots/map001.png "Map, showing activites on a map")

## How to use

### Bulk export from Strava

1. Log in to [Strava](https://www.strava.com/)
2. Select "[Settings](https://www.strava.com/settings/profile)" from the main drop-down menu at top right of the screen
3. Select "Download all your activities" from lower right of screen
4. Wait for an email to be sent
5. Click the link in email to download zipped folder containing activities
6. Unzip files into data folder

### Install R packages

For example:

```bash
$ R
```
```r
install.packages(c("sp", "XML", "tidyverse", "devtools"))
devtools::install_github("marcusvolz/ggart")
quit()
Save workspace image? [y/n/c]: n
```

### Run the scripts

```bash
mkdir processed
Rscript 01_process_data.R
Rscript 02_plot_run_facets.R
Rscript 03_plot_run_map.R
open plots/*.png
```
