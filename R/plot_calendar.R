#' Display Strava activities as calendar heat map
#'
#' @param data A data frame output from process_data()
#'
#' @return A plot displaying calendar heat map
#' @export
#'
#' @examples
plot_calendar <- function(data) {
  summary <- data %>%
    mutate(
      time = lubridate::date(data$time),
      year = strftime(data$time, format = "%Y"),
      date_without_month = strftime(data$time, format = "%j"),
      month = strftime(data$time, format = "%m"),
      day_of_month = strftime(data$time, format = "%d"),
      year_month = strftime(data$time, format = "%Y-%m")
    ) %>%
    group_by(time, year, date_without_month, month, day_of_month, year_month) %>%
    summarise(total_dist = sum(dist_to_prev), total_time = sum(time_diff_to_prev)) %>%
    mutate(speed = (total_dist) / (total_time / 60^2)) %>%
    mutate(pace = (total_time / 60) / (total_dist)) %>%
    mutate(type = "day") %>%
    ungroup() %>%
    mutate(id = as.numeric(row.names(.)))

  # Generate plot data
  time_min <- "2011-12-31"
  time_max <- lubridate::today()
  max_dist <- 30

  daily_data <- summary %>%
    group_by(time) %>%
    summarise(dist = sum(total_dist)) %>%
    ungroup() %>%
    mutate(time = lubridate::date(time)) %>%
    filter(complete.cases(.), time > time_min, time < time_max) %>%
    mutate(dist_scaled = ifelse(dist > max_dist, max_dist, dist))


  # Create plot
  ggTimeSeries::ggplot_calendar_heatmap(
    daily_data,
    "time", "dist_scaled",
    dayBorderSize = 0.5,
    dayBorderColour = "white",
    monthBorderSize = 0.75,
    monthBorderColour = "transparent",
    monthBorderLineEnd = "round"
  ) +
    xlab(NULL) +
    ylab(NULL) +
    scale_fill_continuous(name = "km", low = "#DAE580", high = "#236327", na.value = "#EFEDE0") +
    facet_wrap(~Year, ncol = 1) +
    ggthemes::theme_tufte() +
    theme(strip.text = element_text(), axis.ticks = element_blank(), legend.position = "bottom")
}
