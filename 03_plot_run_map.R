# Plot activities as small multiples

# Load packages
library(ggart) # devtools::install_github("marcusvolz/ggart")
library(tidyverse)

# Read in pre-processed data
data <- readRDS("processed/data.RDS")

# Specify lat / lon window
lon_min <- 144.9
lon_max <- 145.73
lat_min <- -37.475
lat_max <- -38.1

# Create plot
p <- ggplot() +
  geom_path(aes(lon, lat, group = id),
            data %>% filter(lon > lon_min, lon < lon_max, lat < lat_min, lat > lat_max),
            alpha = 0.3, size = 0.3, lineend = "round") +
  coord_equal() +
  theme_blankcanvas(margin_cm = 0)

# Save plot
ggsave("plots/map001.png", p, width = 20, height = 15, units = "cm", dpi = 600)
