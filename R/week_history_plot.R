#' Plots activities over time by week inspired by Strava week plot
#'
#' Plots activities over time by week
#' @param data A data frame output from process_activities()
#' @param by_unit Unit type
#' @param by_activity Activity type
#' @param from_date Filtering a date to start from given argument
#'
#' @return A plot of activities over time by week
#' @export
#'
# Week history plot
week_history_plot <- function(data = activities, by_unit = "Distance", by_activity = "All", from_date = "Last 12 months") {

  # Constants
  possible_values_unit <- c("Distance", "Time", "Count")
  possible_values_activity <- c("All",
                                activities %>% dplyr::select(Activity.Type) %>% unique() %>% dplyr::pull())
  pissible_values_date <- c("Last 12 months", "Last year", "All")

  # Check if the by_unit argument is correct.
  if (!(by_unit %in% possible_values_unit)) {
    stop("This argument value for `by_activity` is not available! Use 'Distance', 'Time' or 'Count' instead!")
  }

  # Check if the by_activity argument is correct.
  if (!(by_activity %in% possible_values_activity)) {
    available_activity_types <- paste0("'", possible_values_activity, "'", collapse  = ", ")
    stop(paste("This argument value for `by_unit` is not available! Use one of those activities instead:", available_activity_types))
  }

  # Check if the from_date argument is correct.
  if (!(from_date %in% pissible_values_date)) {
    stop("This argument value for `from_date` is not available! Use 'Last 12 months', 'Last year' or 'All' instead!")
  }

  # Adjusting data frame
  activities_ex <- activities %>%
    dplyr::mutate(Activity.Date = as.Date(Activity.Date, format = "%d/%m/%Y"), Count = 1) %>%
    dplyr::select(Activity.Date, Activity.Type, Distance, Moving.Time, Count)

  # Making a day data frame from the first day in activities data to the last
  ts <- seq.POSIXt(as.POSIXlt(min(activities_ex$Activity.Date)), as.POSIXlt(max(activities_ex$Activity.Date)-1), by="day")
  ts <- as.Date(format.POSIXct(ts,"%d/%m/%Y"), format = "%d/%m/%Y")
  df <- data.frame(Activity.Date = ts)

  # Joining data frame by filling date
  activities_extended <- dplyr::full_join(df,activities_ex, by = "Activity.Date")

  # Filter for activity argument if not 'All'
  if (by_activity != "All") {
    activities_extended <- activities_extended %>%
      tidyr::replace_na(list(Activity.Type = by_activity)) %>%
      dplyr::filter(Activity.Type == by_activity)
  }

  # Adjusting data frame
  activities_extended <- activities_extended %>%
    dplyr::mutate(
      week = as.numeric(strftime(Activity.Date, format = "%V")),
      year = year(Activity.Date)) %>%
    tidyr::replace_na(list(Moving.Time = 0, Distance = 0, Count = 0)) %>%
    dplyr::group_by(year, week) %>%
    dplyr::mutate(Moving.Time = Moving.Time / 3600) %>%
    dplyr::rename(Distance.1 = Distance) %>%
    dplyr::mutate(
      Time = max(cumsum(Moving.Time)),
      Distance = max(cumsum(Distance.1)),
      Count = max(cumsum(Count))) %>%
    dplyr::filter(row_number() == 1)

  # Adjusting the weeks that are present in two years. For example in 2021 the first week of 2021 was 53rd week from 2020. The activities from 2021 are joined with the ones from last year.
  suppressWarnings(
    activities_extended <- activities_extended %>%
      dplyr::ungroup() %>%
      dplyr::mutate(lead = ifelse(week == lead(week), 1, 0), lag = ifelse(week == lag(week), 1, 0)) %>%
      tidyr::replace_na(list(lead = 0)) %>%
      tidyr::replace_na(list(Moving.Time = 0, Distance = 0)) %>%
      dplyr::mutate(
        Distance = ifelse(lead, Distance[] + Distance[-1], Distance),
        Time = ifelse(lead, Time[] + Time[-1], Time),
        Count = ifelse(lead, Count[] + Count[-1], Count)) %>%
      dplyr::filter(lag != 1) %>%
      dplyr::select(-lead, -lag)
  )

  # Filter activities based on from_date argument
  if (from_date == "Last 12 months") { # Filter for activities in the last 12 months from today
    activities_extended <- activities_extended %>%
      dplyr::filter(Activity.Date > lubridate::today() - 365)
  } else if (from_date  == "Last year") { # Filter for activities from a year ago
    activities_extended <- activities_extended %>%
      dplyr::filter(year >= lubridate::year(today()) - 1, year < lubridate::year(today()))
  } else if (from_date != "All") {
    if (as_date(from_date) > max(activities_extended$Activity.Date)) {
      stop(paste0("This argument value for `from_date` does not contain any activities! The last activity was in ", format(max(activities_extended$Activity.Date), format = "%Y-%m-%d"), ". Change the 'from_date' argument at least a week before this date."))
    }
  }

  # Stop if there were no activities in given from_date argument period
  if (sum(activities_extended$Count != 0) == 0) {
    stop(paste("There were no", tolower(by_activity), "activities in this time period! Choose different argument values."))
  }

  # Filtering for max by_unit activity
  max <- activities_extended %>%
    dplyr::ungroup() %>%
    dplyr::select(!!sym(by_unit)) %>%
    dplyr::filter(!!sym(by_unit) == max(!!sym(by_unit))) %>%
    dplyr::filter(row_number() == 1)

  # Flooring max value
  max <- floor(as.integer(max))

  # Making a data frame to use it as a gradient. Inspiration: https://stackoverflow.com/questions/61775003/ggplot2-create-shaded-area-with-gradient-below-curve
  grad_df <- data.frame(yintercept = seq(0, max, length.out = 1000), alpha = seq(0.9, 0.1, length.out = 1000))


  # Make a min and max data by month
  min_date <- lubridate::floor_date(min(activities_extended$Activity.Date), "month")
  max_date <- lubridate::ceiling_date(max(activities_extended$Activity.Date), "month")

  # Make a data frame for grey vertical lines by month in a plot
  month_df <- data.frame(xintercept = seq.Date(floor_date(min(activities_extended$Activity.Date), "month"), max(activities_extended$Activity.Date) + 31, by = "month"), max = max) %>% dplyr::group_by(xintercept)

  # Make a unit
  if (by_unit == "Distance") {
    unit <- "km"
  } else if (by_unit == "Count") {
    if (max < 2)  {
      unit <- "time"
    } else {
      unit <- "times"
    }
  } else {
    if (max <= 2) {
      unit <- c("hours", "hour", "hours")
    }
    if (max <= 1) {
      unit <- c("hours", "hour", "hour")
    } else {
      unit <- "hours"
    }
  }

  breaks <- "1 month"

  # Remove x axis labels to avoid overlapping
  if(nrow(activities_extended) > 96)  {
    breaks <- "4 months"
  }

  p <- activities_extended %>%
    ggplot() +
    geom_area(aes(x = Activity.Date, y = floor(!!sym(by_unit))),
              fill = "#fc4c02",
              alpha = 0.9) +
    geom_hline(data = grad_df,
               aes(yintercept = yintercept, alpha = alpha),
               size = 0.17,
               colour = "white") +
    annotate("segment", x = month_df$xintercept, xend = month_df$xintercept, y = 0, yend = month_df$max, colour = "lightgrey", size = 0.2) +
    annotate("segment", x = min_date, xend = as.Date(max_date), y = max, yend = max, colour = "lightgrey", size = 0.2) +
    annotate("segment", x = min_date, xend = as.Date(max_date), y = 0, yend = 0, colour = "lightgrey", size = 0.2) +
    geom_line(aes(x = Activity.Date, y = floor(!!sym(by_unit))),
              color = "#fc4c02",
              size = 0.7) +
    geom_point(aes(x = Activity.Date, y = floor(!!sym(by_unit))),
               shape = 21,
               fill = "white",
               color = "#fc4c02",
               stroke = 1,
               size = 1) +
    scale_alpha_identity() +
    scale_x_date(date_breaks = breaks,
                 date_labels = "%b %Y",
                 expand = c(0.01, 0.01)) +
    scale_y_continuous(breaks = seq(0, max, by = ifelse(by_unit != "Count", max/2, max)),
                       expand = c(0.03, 0.03), limits = c(0, max),
                       label = unit_format(unit = unit)) +
    labs(title = NULL, y = NULL, x = NULL) +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
      axis.text.y = element_text(hjust = 1),
      panel.grid = element_blank(),
      panel.background = element_rect(color = "white"),
      plot.background = element_rect(color = "white"),
      panel.border = element_blank()
    )
  p
}
