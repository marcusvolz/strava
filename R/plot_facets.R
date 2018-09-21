#' Creates a plot of activities as small multiples
#'
#' Creates a plot of activities as small multiples. The concept behind this plot was originally inspired by \href{https://www.madewithsisu.com/}{Sisu}.
#' @param data A data frame output from process_data()
#' @param labels If TRUE, adds distance labels to each facet
#' @param scales If "fixed", track size reflects absolute distance travelled
#' @keywords
#' @export
#' @examples
#' plot_facets()

plot_facets <- function(data, labels = FALSE, scales = "free") {
  # Summarise data
  summary <- data %>%
    dplyr::group_by(id) %>%
    dplyr::summarise(lon = mean(range(lon)),
                     lat = mean(range(lat)),
                     distance = sprintf("%.1f", max(cumdist)))
  
  # Decide if tracks will all be scaled to similar size ("free") or if
  # track sizes reflect absolute distance in each dimension ("fixed")
  if (scales == "fixed") {
    data <- data %>% dplyr::group_by(id) %>% # for each track,
      dplyr::mutate(lon = lon - mean(lon), # centre data on zero so facets can
                    lat = lat - mean(lat)) # be plotted on same distance scale
  } else {
    scales = "free" # default, in case a non-valid option was specified
  }

  # Create plot
  p <- ggplot2::ggplot() +
    ggplot2::geom_path(ggplot2::aes(lon, lat, group = id), data, size = 0.35, lineend = "round") +
    ggplot2::facet_wrap(~id, scales = scales) +
    ggplot2::theme_void() +
    ggplot2::theme(panel.spacing = ggplot2::unit(0, "lines"),
                   strip.background = ggplot2::element_blank(),
                   strip.text = ggplot2::element_blank(),
                   plot.margin = ggplot2::unit(rep(1, 4), "cm"))
  
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
