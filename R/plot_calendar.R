#' Display Strava activities as calendar heat map
#'
#' @param data A data frame output from process_data()
#'
#' @return A plot displaying calendar heat map
#' @export
#'
#' @examples
plot_calendar <- function(data) {
  distance_per_date <- data %>%
    mutate(date = lubridate::date(time)) %>%
    group_by(date) %>%
    summarise(dist = sum(dist_to_prev))

  ggTimeSeries::ggplot_calendar_heatmap(
    distance_per_date,
    "date", "dist",
    dayBorderSize = 0.5,
    dayBorderColour = "white",
    monthBorderSize = 0.75,
    monthBorderColour = "transparent",
    monthBorderLineEnd = "round"
  ) +
    xlab(NULL) +
    ylab(NULL) +
    scale_fill_continuous(
      name = "km",
      low = "#DAE580",
      high = "#236327",
      na.value = "#EFEDE0"
      ) + # trans = "log" if needed
    facet_wrap(~Year, ncol = 1) +
    ggthemes::theme_tufte() +
    theme(strip.text = element_text(), axis.ticks = element_blank(), legend.position = "bottom")
}
