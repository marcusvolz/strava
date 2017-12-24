# Analyse Strava Data
# Marcus Volz
# 2017-12-24
# Based on code from "http://www.r-bloggers.com/stay-on-track-plotting-gps-tracks-with-r/"

# Strava bulk export instructions ----
# 1. Log in to Strava
# 2. Select "Settings" from the main drop-down menu at top right of the screen
# 3. Select "Download all your activities" from lower right of screen
# 4. Wait for an email to be sent
# 5. Click the link in email to download zipped folder containing activities
# 6. Unzip files into data folder

# Load packages ----
library(sp)
library(XML)
library(tidyverse)

# Function for processing a Strava gpx file
process_gpx <- function(file) {
  # Parse GPX file and generate R structure representing XML tree
  pfile <- htmlTreeParse(file = file,
                         error = function (...) {},
                         useInternalNodes = TRUE)
  
  coords <- xpathSApply(pfile, path = "//trkpt", xmlAttrs)
  lat <- as.numeric(coords["lat", ])
  lon <- as.numeric(coords["lon", ])
  ele <- as.numeric(xpathSApply(pfile, path = "//trkpt/ele", xmlValue))
  time <- xpathSApply(pfile, path = "//trkpt/time", xmlValue)
  
  # Put everything in a data frame
  result <- data.frame(lat = lat, lon = lon, ele = ele, time = time) %>%
    mutate(dist_to_prev = c(0, spDists(x = as.matrix(.[, 1:2]), longlat = TRUE, segments = TRUE)),
           cumdist = cumsum(dist_to_prev),
           time = as.POSIXct(.$time, format = "%Y-%m-%dT%H:%M:%OS")) %>%
    mutate(time_diff_to_prev = as.numeric(difftime(time, lag(time, default = .$time[1]))),
           cumtime = cumsum(time_diff_to_prev))
  result
}

# Process all the files
data <- paste("data/", list.files(path = "data/", pattern = "*.gpx"), sep = "") %>%
  map_df(process_gpx, .id = "id") %>%
  mutate(id = as.integer(id))

# Write data to file
saveRDS(data, "processed/data.RDS")
