#' Title
#'
#' @param data
#'
#' @return
#' @export
#'
#' @examples
plot_packed_circles <- function(data) {
  # Function for circle packaging
  compute_cluster <- function(cluster_year) {
    temp <- summary %>%
      filter(year == cluster_year)

    packcircles::circleProgressiveLayout(temp$total_dist) %>%
      cbind(temp)
  }

  summary <- data %>%
    mutate(
      time = as.Date(data$time),
      year = as.integer(strftime(data$time, format = "%Y")),
      date_without_month = strftime(data$time, format = "%j"),
      month = strftime(data$time, format = "%m"),
      day_of_month = strftime(data$time, format = "%d"),
      year_month = strftime(data$time, format = "%Y-%m")
    ) %>%
    group_by(time, year, date_without_month, month, day_of_month, year_month) %>%
    summarise(total_dist = sum(dist_to_prev), total_time = sum(time_diff_to_prev)) %>%
    mutate(
      speed = (total_dist) / (total_time / 60^2),
      pace = (total_time / 60) / (total_dist),
      type = "day"
    ) %>%
    ungroup() %>%
    mutate(id = as.numeric(row.names(.)))

  # Create packed circles by year
  result <- seq(min(summary$year), max(summary$year)) %>%
    purrr::map_df(~ compute_cluster(.x), .id = "id2") %>%
    mutate(speed = total_dist / total_time)

  # Create plot
  ggplot() +
    ggforce::geom_circle(aes(x0 = x, y0 = y, r = radius, fill = speed), result, size = 0.25) +
    viridis::scale_fill_viridis(option = "D", direction = 1, name = "speed (km/h)") +
    facet_wrap(~year, strip.position = "bottom") +
    coord_equal() +
    ggforce::theme_no_axes() +
    theme(
      strip.text = element_text(), legend.position = "right", panel.spacing = unit(2, "lines"),
      panel.border = element_blank(), strip.background = element_blank()
    ) +
    ggtitle("Strava runs as packed circles", subtitle = "Run distance mapped to circle area")
}
