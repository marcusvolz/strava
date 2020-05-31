#' Display Strava activities as packed circles
#'
#' @param data A data frame output from process_data()
#' @param circle_size A string ("distance" / "duration" / "speed") defining sizes of circles
#' @param circle_fill A string ("distance" / "duration" / "speed") defining fills of circles
#'
#' @return A plot with Strava activities as packed circles
#' @export
#'
#' @examples
plot_packed_circles <- function(data, circle_size = "duration", circle_fill = "distance") {
  # ---- functions ----
  compute_cluster <- function(cluster_year) {
    year_summary <- summary %>%
      filter(year == cluster_year)

    bind_cols(
      year_summary,
      packcircles::circleProgressiveLayout(select(year_summary, !!sym(circle_size)))
    )
  }

  # ---- constants ----
  possible_values <- c("distance", "duration", "speed")
  if (!(circle_size %in% possible_values)) {
    stop("This argument value for `circle_size` is not available! Use 'duration', 'distance', or 'speed' instead!")
  }

  if (!(circle_fill %in% possible_values)) {
    stop("This argument value for `circle_fill` is not available! Use 'duration', 'distance', or 'speed' instead!")
  }

  legend_title <- purrr::set_names(
    c("distance (km)", "duration (h)", "speed (km/h)"),
    possible_values
  )

  # ---- body ----
  summary <- data %>%
    mutate(year = lubridate::year(time)) %>%
    group_by(year, id) %>%
    summarise(
      distance = sum(dist_to_prev),
      duration = sum(time_diff_to_prev) / 60^2,
      speed = distance / duration
    ) %>%
    ungroup()

  plot_data <- purrr::map_df(seq(min(summary$year), max(summary$year)), compute_cluster)

  ggplot(plot_data) +
    ggforce::geom_circle(aes(x0 = x, y0 = y, r = radius, fill = !!sym(circle_fill)),
      size = 0.25
    ) +
    viridis::scale_fill_viridis(name = legend_title[circle_fill]) +
    facet_wrap(~year, strip.position = "bottom") +
    coord_equal() +
    ggforce::theme_no_axes() +
    theme(
      strip.text = element_text(), legend.position = "right", panel.spacing = unit(2, "lines"),
      panel.border = element_blank(), strip.background = element_blank()
    )
}
