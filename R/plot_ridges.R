#' Plot ridges of Strava activities by weekdays
#'
#' @param data A data frame output from process_data()
#'
#' @return A plot displaying ridges
#' @export
plot_ridges <- function(data) {
  # Function for processing an activity on a minute-by-minute basis; active = 1, not active = 0
  compute_day_curve <- function(df_row) {
    start <- as.numeric(activity_time[df_row, "start_time"])
    end <- as.numeric(activity_time[df_row, "end_time"])
    wday <- as.character(activity_time[df_row, "wday"])

    result <- data.frame(time = seq(as.POSIXct("00:00:00", format = "%H:%M:%S"),
                                    as.POSIXct("23:59:58", format = "%H:%M:%S"),
                                    by = 60
    )) %>%
      mutate(
        end_time = lead(time, default = as.POSIXct("23:59:59", format = "%H:%M:%S")),
        active = ifelse(time > start & end_time < end, 1, 0), wday = wday
      )

    result
  }

  activity_time <- data %>%
    group_by(id) %>%
    summarise(start = min(time), end = max(time)) %>%
    mutate(
      start_time = as.POSIXct(strftime(start, format = "%H:%M:%S"), format = "%H:%M:%S"),
      end_time = as.POSIXct(strftime(end, format = "%H:%M:%S"), format = "%H:%M:%S"),
      duration = end_time - start_time,
      wday = lubridate::wday(start, week_start = 1)
    )

  # Process all activities
  plot_data <- 1:nrow(activity_time) %>%
    purrr::map_df(~ compute_day_curve(.x), .id = "id") %>%
    filter(!is.na(active), active > 0) %>%
    mutate(wday = as.factor(wday))

  plot_data$wday <- factor(plot_data$wday, levels = rev(levels(plot_data$wday)))

  # Create plot
  p <- ggplot() +
    ggridges::geom_density_ridges(aes(x = time, y = wday), plot_data, size = 0.5) +
    ggridges::theme_ridges() +
    scale_y_discrete(expand = c(0.01, 0), labels = c("Sun", "Sat", "Fri", "Thu", "Wed", "Tue", "Mon")) +
    scale_x_datetime(expand = c(0, 0), date_labels = "%I:%M %p") +
    theme(panel.grid = element_blank(), plot.margin = unit(rep(1, 4), "cm")) +
    xlab(NULL) +
    ylab(NULL)

  p
}
