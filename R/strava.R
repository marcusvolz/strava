#' @import dplyr
#' @import ggplot2
#' @import gtools
#' @import mapproj
#' @importFrom ggTimeSeries ggplot_calendar_heatmap
#' @importFrom stats end start time
NULL

globalVariables(
  c(".", "active", "cumdist", "dist_scaled", "dist_to_prev", "distance",
    "duration", "ele", "end_time", "lat", "lon", "radius", "start_time",
    "time_diff_to_prev", "wday", "x", "y", "year")
)
