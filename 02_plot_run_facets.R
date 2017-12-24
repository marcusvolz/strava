# Plot activities as small multiples

# Load packages
library(ggart) # devtools::install_github("marcusvolz/ggart")
library(tidyverse)

# Read in pre-processed data
data <- readRDS("processed/data.RDS")

# Create plot
p <- ggplot() +
  geom_path(aes(lon, lat, group = id), data, size = 0.35, lineend = "round") +
  facet_wrap(~id, scales = "free") +
  theme_blankcanvas(margin_cm = 1) +
  theme(panel.spacing = unit(0, "lines"))

# Save plot
ggsave("plots/facets001.png", p, width = 20, height = 20, units = "cm")
