#' Plots activities over time by month
#'
#' Plots activities over time by month
#' @param data A data frame output from process_activities()
#' @param by_unit Unit type
#' @param by_activity Activity type
#' @param from_date Filtering a date to start from given argument
#'
#' @return A plot of activities over time by month
#' @export
#'
# Month history plot
month_history_plot <- function(data = activities, by_unit = "Distance", by_activity = "All", from_date = "Last 12 months") {

  # Constants
  possible_values_unit <- c("Distance", "Time", "Count")
  possible_values_activity <- c("All",
                                activities %>% dplyr::select(Activity.Type) %>% unique() %>% dplyr::pull())

  if (!(by_unit %in% possible_values_unit)) {
    stop("This argument value for 'by_activity' is not available! Use 'Distance', 'Time' or 'Count' instead.")
  }

  # Check if the by_activity argument is correct
  if (!(by_activity %in% possible_values_activity)) {
    available_activity_types <- paste0("'", possible_values_activity, "'", collapse  = ", ")
    stop(paste("This argument value for `by_unit` is not available! Use one of those activities instead:", available_activity_types))
  }

  # Check if the from_date argument is correct
  if (!from_date %in% c("All", "Last 12 months")) {
    if_error <- tryCatch(as.Date(from_date), error = function(i) i)
    if (any(class(if_error) == "error") == TRUE && is.Date(as_date(from_date)) == TRUE) {
      stop("This argument value for 'from_date' is not available! Use 'All', 'Last 12 months' or format date as 'YYYY-MM-DD' instead.")
    }
  }

  # Adjusting data frame used in further calculations
  activities_month <- activities %>%
    dplyr::select(2,4,7, Moving.Time) %>%
    dplyr::arrange(Activity.Date) %>%
    dplyr::mutate(Activity.Date = as.Date(lubridate::floor_date(Activity.Date, "month")), Count = 1,)

  # Checking if the from_date argument is correctly formatted
  if (!from_date %in% c("All", "Last 12 months")) {
    if (as_date(from_date) > max(activities_month$Activity.Date)) {
      stop(paste0("This argument value for `from_date` does not contain any activities! The last activity was in ", format(max(activities_month$Activity.Date), format = "%B %Y"), ". Change the starting month before this date."))
    }
  }

  # Filtering by activity
  if (by_activity != "All") {
    activities_month <- activities_month %>%
      dplyr::filter(Activity.Type == by_activity)
  }

  # Make a data frame of months to add months when there was no activity.
  month_data <- data.frame(Activity.Date = seq.Date(
    from = floor_date(min(as.Date(activities$Activity.Date)), "month"),
    to = (floor_date(max(as.Date(activities$Activity.Date)), "month")),
    by = "month"))

  # Joining two data frames
  activities_month <- activities_month %>%
    dplyr::right_join(month_data, by = "Activity.Date") %>%
    dplyr::arrange(Activity.Date)

  # Adjusting data frame
  activities_month <- activities_month %>%
    dplyr::mutate(year = lubridate::year(Activity.Date),
                  month_int = lubridate::month(Activity.Date),
                  month = toupper(as.factor(month(Activity.Date, label = TRUE))),
                  Axis.labels = paste(month, year)) %>% # Making x axis labels
    dplyr::group_by(year, month_int) %>%
    dplyr::mutate(Distance = max(cumsum(Distance)),
                  Time = max(cumsum(Moving.Time) / 3600),
                  Count = max(cumsum(Count))) %>%
    tidyr::replace_na(list(Distance = 0, Time = 0, Count = 0)) %>%
    dplyr::filter(row_number() == 1) %>%
    dplyr::select(-Moving.Time) %>%
    dplyr::ungroup()

  # Filter activities by a  given from_date argument
  if (from_date == "Last 12 months") {
    activities_month <- activities_month %>%
      dplyr::filter(Activity.Date >= as.Date(lubridate::floor_date(now(), "month")) - lubridate::years(1))
  }  else if (from_date !=  "All") {
    activities_month <- activities_month %>%
      dplyr::filter(Activity.Date >= as_date(from_date))
  }

  # Stop if there were no activities in given from_date argument period
  if (sum(activities_month$Count != 0) == 0) {
    stop(paste("There were no", tolower(by_activity), "activities in this time period! Choose different argument values."))
  }

  # Filtering for last month
  last_activity <- activities_month %>%
    dplyr::select(Activity.Date, !!sym(by_unit)) %>%
    dplyr::filter(Activity.Date == last(Activity.Date))

  # Getting value for last month
  last <- last_activity %>%
    dplyr::select(-Activity.Date)

  #  Filtering for max in possible units and filter for max in selected unit
  max_activities_month <- activities_month %>%
    dplyr::filter(Time == max(Time) | Count == max(Count) | Distance == max(Distance)) %>%
    dplyr::filter(!!sym(by_unit) == max(!!sym(by_unit)))

  # Getting max value for max month
  max <- max_activities_month %>%
    dplyr::select(!!sym(by_unit))

  # Determine units used in a plot
  if (by_unit == "Distance") {
    unit_max <- "km"
    unit <- "km"
  } else if (by_unit == "Count") {
    if (max > 1) {
      unit_max <- "activities"
    } else {
      unit_max <- "activity"
    }
    if (last > 1) {
      unit <- "activities"
    } else {
      unit <- "activity"
    }
  } else {
    unit_max <- "hours"
    if (round(last == 1)) {
      unit <- "hour"
    } else {
      unit <- "hours"
    }
  }

  # Remove x axis labels to avoid overlapping
  if(nrow(activities_month) > 24)  {
    activities_month <- activities_month %>%
      mutate(Axis.labels = ifelse(!month_int %in% c(1, 4, 7, 10), "", Axis.labels))
  }

  p <- activities_month %>%
    ggplot() +
    geom_col(aes(Activity.Date, !!sym(by_unit)), color = "black", fill = "black", width = 1) +
    geom_col(data = last_activity, aes(Activity.Date, !!sym(by_unit)), color = "#fc4c02", fill = "#fc4c02", width = 1.1) +
    geom_point(data = max_activities_month, aes(Activity.Date, !!sym(by_unit)), color = "black", size = 1) +
    geom_text(data = max_activities_month, aes(Activity.Date, !!sym(by_unit)), size = 3.4, hjust = -0.2, angle = 90, color = "black", label = paste(round(max), unit_max)) +
    geom_point(data = last_activity, aes(Activity.Date, !!sym(by_unit)), color = "#fc4c02", size = 1) +
    geom_text(data = last_activity, aes(Activity.Date, !!sym(by_unit)), size = 3.4, hjust = -0.2, angle = 90, color = "#fc4c02", label = paste(round(last), unit)) +
    theme_minimal() +
    scale_x_continuous(breaks = activities_month$Activity.Date, labels = activities_month$Axis.labels) +
    labs(title = "", y = "", x = "") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, color = "black"),
          axis.text.y = element_blank(),
          panel.grid = element_blank(),
          panel.background = element_rect(color = "white"),
          plot.background = element_rect(color = "white"),
          panel.border = element_blank()) +
    coord_cartesian(ylim = c(0, 1.4*as.integer(max)))

  p
}
