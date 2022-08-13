#' Creates a plot of activities as small multiples
#'
#' Creates a plot of activities as small multiples. The concept behind this plot was originally inspired by \href{https://www.madewithsisu.com/}{Sisu}.
#' @param data A data frame output from process_data()
#' @param labels If TRUE, adds distance labels to each facet
#' @param scales If "fixed", track size reflects absolute distance travelled
#' @export
#'
# Plot of activities as small multiples
plot_facets <- function(data, labels = FALSE, scales = "free", color = FALSE) {

  # Constants
  possible_values_scales<- c("free", "fixed")

  # Check if the scales argument is correct
  if (!(scales %in% possible_values_scales)) {
    stop("This argument value for `scales` is not available! Use 'free' or 'fixed' instead!")
  }

  # Check if the data is joined with activities.
  if (color) {
    if (sum(colnames(data) == "Activity.Type") == 0) {
      stop("The data frame does not contain 'Activity.Type' column. Load activities with process_activities function and run join_data_activities function first!")
    }
  }

  # Summarise data
  summary <- data %>%
    dplyr::group_by(id) %>%
    dplyr::summarise(lon = mean(range(lon)),
                     lat = mean(range(lat)),
                     distance = sprintf("%.1f", max(cumdist)))

  # Decide if tracks will all be scaled to similar size ("free") or if
  # track sizes reflect absolute distance in each dimension ("fixed")
  if (scales == "fixed") {
    data <- data %>%
      dplyr::group_by(id) %>% # for each track,
      dplyr::mutate(lon = lon - mean(lon), # centre data on zero so facets can
                    lat = lat - mean(lat)) # be plotted on same distance scale
  } else {
    scales = "free" # default, in case a non-valid option was specified
  }

  # Decide if plot is colored by activity type or not and create a plot
  if (color) {
    p <- ggplot2::ggplot() + ggplot2::geom_path(ggplot2::aes(lon, lat, group = id, color = Activity.Type), data, size = 0.35, lineend = "round", alpha = 0.5) + ggplot2::scale_color_brewer(palette = "Dark2", name = NULL) # color by activity type
  } else {
    p <- ggplot2::ggplot() + ggplot2::geom_path(ggplot2::aes(lon, lat, group = id), data, size = 0.35, lineend = "round")
  }

  p <- p + ggplot2::facet_wrap(~id, scales = scales) + ggplot2::theme_void() +
    ggplot2::theme(panel.spacing = ggplot2::unit(0, "lines"),
                   strip.background = ggplot2::element_blank(), strip.text = ggplot2::element_blank(),
                   plot.margin = ggplot2::unit(rep(1, 4), "cm"),
                   legend.position = "bottom") # place a legend on the bottom of a plot

  if (scales == "fixed") {
    p <- p + ggplot2::coord_fixed() # make aspect ratio == 1
  }

  # Add labels
  if(labels) {
    p <- p +
      ggplot2::geom_text(ggplot2::aes(lon, lat, label = distance), data = summary,
                         alpha = 0.25, size = 3)
  }

  # Return plot
  p
}
