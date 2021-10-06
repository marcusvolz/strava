#' Creates a plot of elevation profiles as small multiples
#'
#' Creates a plot of elevation profiles as small multiples
#' @param data A data frame output from process_data()
#' @param scale_free_y If TRUE, the y-scale is "free"; otherwise it is "fixed"
#' @export
plot_elevations <- function(data, scale_free_y = FALSE) {
  # Compute total distance for each activity
  dist <- data %>%
    dplyr::group_by(id) %>%
    dplyr::summarise(dist = max(cumdist))

  # Normalise distance
  data <- data %>%
    dplyr::left_join(dist, by = "id") %>%
    dplyr::mutate(dist_scaled = cumdist / dist) %>%
    dplyr::arrange(id, cumdist)

  # Create plot
  p <- ggplot2::ggplot() +
    ggplot2::geom_line(ggplot2::aes(dist_scaled, ele, group = id), data, alpha = 0.75) +
    ggplot2::facet_wrap(~id, scales = ifelse(scale_free_y, "free_y", "fixed")) +
    ggplot2::theme_void() +
    ggplot2::theme(panel.spacing = ggplot2::unit(0, "lines"),
                   strip.background = ggplot2::element_blank(),
                   strip.text = ggplot2::element_blank(),
                   plot.margin = ggplot2::unit(rep(1, 4), "cm"))
  p
}
