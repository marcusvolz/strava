#' Creates a plot of activities as small multiples
#'
#' Creates a plot of activities as small multiples
#' @param data A data frame output from process_data()
#' @param labels If TRUE, adds distance labels to each facet
#' @keywords
#' @export
#' @examples
#' plot_facets()

plot_facets <- function(data, labels = FALSE) {
  # Summarise data
  summary <- data %>%
    dplyr::group_by(id) %>%
    dplyr::summarise(lon = mean(range(lon)),
                     lat = mean(range(lat)),
                     distance = sprintf("%.1f", max(cumdist)))

  # Create plot
  p <- ggplot2::ggplot() +
    ggplot2::geom_path(ggplot2::aes(lon, lat, group = id), data, size = 0.35, lineend = "round") +
    ggplot2::facet_wrap(~id, scales = "free") +
    ggplot2::theme_void() +
    ggplot2::theme(panel.spacing = ggplot2::unit(0, "lines"),
                   strip.background = ggplot2::element_blank(),
                   strip.text = ggplot2::element_blank(),
                   plot.margin = ggplot2::unit(rep(1, 4), "cm"))

  # Add labels
  if(labels) {
    p <- p +
      ggplot2::geom_text(ggplot2::aes(lon, lat, label = distance), data = summary,
                         alpha = 0.25, size = 3)
  }

  # Return plot
  p
}
