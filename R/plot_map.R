#' Plots activities superimposed on a map
#'
#' Plots activities superimposed on a map
#' @param data A data frame output from process_data()
#' @param by_activity Activity type (optional)
#' @param lon_min Minimum longitude (optional)
#' @param lon_max maximum longitude (optional)
#' @param lat_min Minimum latitude (optional)
#' @param lat_max Maximum latitude (optional)
#' @param color lines color (optional)
#'
#' @return A heat map of activities
#' @export
#'
# Plots activities superimposed on a map
plot_map <- function(data, by_activity = "All", lon_min = NA, lon_max = NA, lat_min = NA, lat_max = NA, color = "black") {

  # Constants
  possible_values_activity <- c("All",
  data %>% select(Activity.Type) %>% unique() %>% pull())

  # Check if the data is joined with activities.
  if (!(by_activity %in% possible_values_activity)) {
    available_activity_types <- paste0("'", possible_values_activity, "'", collapse  = ", ")
    stop(paste("This argument value for `by_unit` is not available! Use one of those activities instead:", available_activity_types))
  }

  # Check if the data is joined with activities.
  if (sum(colnames(data) == "Activity.Type") == 0) {
    stop("The data frame does not contain 'Activity.Type' column. Load activities with process_activities function and run join_data_activities function first!")
  }

  if (by_activity != "All") {
  data_plot <-  data %>%
    filter(Activity.Type == by_activity)
  }

    ggplot(data = data_plot, aes(lon, lat, group = id)) +
    geom_path(
      alpha = 0.3,
      size = 0.3,
      lineend = "round",
      color = color
    ) +
    coord_map(xlim = c(lon_min, lon_max), ylim = c(lat_min, lat_max)) +
    theme_void() +
    theme(legend.position = "none")
}
