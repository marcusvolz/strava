#' Display Strava activities as calendar heat map
#'
#' @param data A data frame output from process_data()
#' @param unit A string ("distance" or "time") defining which unit to display
#'
#' @return A plot displaying calendar heat map
#' @export
plot_calendar <- function(data, unit = "distance") {
  if (!(unit %in% c("distance", "time"))) {
    stop("This unit doesn't exist! Use 'time' or 'distance' instead!")
  }

  unit_per_date <- data %>%
    mutate(date = lubridate::date(time)) %>%
    group_by(date) %>%
    summarise(
      distance = sum(dist_to_prev),
      time = sum(time_diff_to_prev) / 3600,
      unit = !!sym(unit)
    ) %>%
    ungroup() %>%
    tidyr::complete(
      date = seq(min(date), max(date), by = "1 day"),
      fill = list(dist = NA)
    )

  ggTimeSeries::ggplot_calendar_heatmap(
    unit_per_date,
    "date", "unit",
    dayBorderSize = 0.5,
    dayBorderColour = "white",
    monthBorderSize = 0.75,
    monthBorderColour = "transparent",
    monthBorderLineEnd = "round"
  ) +
    xlab(NULL) +
    ylab(NULL) +
    scale_fill_continuous(
      name = if (unit == "distance") "km" else "hr",
      low = "#FFE6D6",
      high = "#FE5502",
      na.value = "#f9f8f8"
    ) +
    facet_wrap(~Year, ncol = 1) +
    ggthemes::theme_tufte() +
    theme(strip.text = element_text(), axis.ticks = element_blank(), legend.position = "bottom")
}
