# Month history plot
year_grid_history_plot <- function(data = activities, by_unit = "Count", by_activity = "All", from_date = "5 years") {
  
  # Constants
  possible_values_unit <- c("Distance", "Time", "Count")
  possible_values_activity <- c("All",
                                activities %>% dplyr::select(Activity.Type) %>% unique() %>% dplyr::pull())
  possible_values_date <- c("5 years", "10 years")
  
  if (!(by_unit %in% possible_values_unit)) {
    stop("This argument value for 'by_activity' is not available! Use 'Distance', 'Time' or 'Count' instead.")
  }
  
  # Check if the by_activity argument is correct.
  if (!(by_activity %in% possible_values_activity)) {
    available_activity_types <- paste0("'", possible_values_activity, "'", collapse  = ", ")
    stop(paste("This argument value for `by_unit` is not available! Use one of those activities instead:", available_activity_types))
  }
  
  # Check if the from_date agrument is correct.
  if (from_date %in% c("5  years", "10 years") || stringr::str_length(as.character(from_date)) != 4) {
    stop("This argument value for 'from_date' is not available! Use '5 years', '10 years' or type year.")
  } 
  
  # Adjusting data frame used in further calculations
  activities_month <- activities %>%
    dplyr::select(2,4,7, Moving.Time) %>%
    dplyr::arrange(Activity.Date) %>%
    dplyr::mutate(Activity.Date = as.Date(lubridate::floor_date(Activity.Date, "month")), Count = 1,)
  
  # Checking if the from_date argument is correctly formatted
  if (!from_date %in% c("5 years", "10 years")) {
    from_date <- paste(as.character(from_date), "01", "01", sep = "-")
    if (as_date(from_date) > max(activities_month$Activity.Date)) {
      stop(paste0("This argument value for `from_date` does not contain any activities! The last activity was in ", format(max(activities_month$Activity.Date), format = "%B %Y"), ". Change the starting month before this date."))
    }
  }  
  
  # Filtering by activity
  if (by_activity != "All") { 
    activities_month <- activities_month %>%
      dplyr::filter(Activity.Type == by_activity)
  } 
  
  # Filter activities by a  given from_date argument
  if (from_date == "5 years") {
    activities_month <- activities_month %>%
      dplyr::filter(Activity.Date >= as.Date(lubridate::floor_date(now(), "year")) - lubridate::years(5))
  } else if (from_date == "10 years") {
    activities_month <- activities_month %>%
      dplyr::filter(Activity.Date >= as.Date(lubridate::floor_date(now(), "year")) - lubridate::years(10))
  } else {
    activities_month <- activities_month %>%
      dplyr::filter(Activity.Date >= as_date(from_date))
  }
  
  # Make a data frame of months to add months when there was no activity.
  month_data <- data.frame(Activity.Date = seq.Date(
    from = floor_date(min(as.Date(activities_month$Activity.Date)), "year"),
    to = (ceiling_date(max(as.Date(activities_month$Activity.Date)), "year")) - months(1), 
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
    tidyr::replace_na(list(Distance = 0, Moving.Time = 0, Count = 0))
  
  # Calculate unit and define plot title by unit
  if (by_unit == "Distance") {
    activities_month <- activities_month %>%
      dplyr::mutate(unit = max(cumsum(Distance)))
    title <- paste("Distance in km on", tolower(by_activity), "activities")
  } else if (by_unit == "Time") {
    activities_month <- activities_month %>%
      dplyr::mutate(unit = max(cumsum(Moving.Time) / 3600))
    title <- paste("Time in hours spent on", tolower(by_activity), "activities")
  } else {
    activities_month <- activities_month %>%
      dplyr::mutate(unit = max(cumsum(Count)))
    title <- paste("Number of", tolower(by_activity), "activities")
  }
  
  # Select variables
  activities_month <- activities_month %>%
    dplyr::filter(row_number() == 1) %>%
    dplyr::select(year, month_int, month, Axis.labels, unit)
  
  # Get unique years in the data frame 
  unique_years <- unique(activities_month$year) %>% sort(decreasing = TRUE)
  
  # Make a function to split data frame by year and then calculate spline 
  splines_function <- function(data, i) {
    year_activities_month <- data %>% filter(year == i) %>%
      bind_rows(data.frame(year = i, month_int = c(0, 13), unit = 0)) %>%
      arrange(month_int)
    spline_int <- as.data.frame(spline(year_activities_month$month_int, year_activities_month$unit)) %>%
      mutate(y = ifelse(y <0, 0, y))
    spline_int <- data.frame(year = i, spline(spline(spline_int$x,  spline_int$y)))
  }
  
  # Apply splines to each year and return a row binned data frame
  splines_connected <- lapply(unique_years, splines_function, data = activities_month) %>% 
    do.call(what = rbind.data.frame) %>% 
    mutate(y = ifelse(y < 0, 0, y))
  
  # Prepare a color palette
  palette <- wes_palette("Zissou1", n = length(unique_years), type ="continuous")
  
  # Make a color palette data frame with years
  color <- data.frame(palette = factor(palette), year = unique_years)
  
  # Make a function to plot each individyal year separately
  plot_data_column = function (data, i) {
    
    color_1 <- color %>% filter(year == i) %>% select(-year) %>% mutate(palette = as.character(palette)) %>% pull(palette)
    
    p <- data %>% 
      filter(year == i) %>% 
      ggplot(aes(x = x, y = y)) +
      geom_area(fill = "white", show.legend = FALSE) +
      geom_area(fill = color_1, alpha = 0.7, show.legend = FALSE) +
      geom_line() +
      scale_y_continuous(breaks = c(0), labels = c(as.character(i)), expand = c(0, max(splines_connected$y) + 5)) +
      scale_x_continuous(breaks = unique(activities_month$month_int), labels = unique(activities_month$month)) +
      labs(title = NULL, y = NULL, x = NULL) +
      coord_cartesian(ylim = c(0, max(splines_connected$y) + 5)) +
      theme_minimal() +
      theme(axis.text.x = element_blank(),
            axis.ticks = element_blank(),
            text = element_text(color = "black", face = "bold"),
            panel.grid = element_blank(),
            panel.background = element_blank(),
            panel.border = element_blank(),
            plot.background = element_blank(),
            plot.margin = unit(c(0, 0, 0, 0), "cm")) +
      if (i == min(unique_years)) {
        theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, color = "black", face = "bold"))
      } else {
        theme(axis.text.x = element_blank())
      }
    p
  }
  
  # Make a list of all plots
  plot <- lapply(unique_years, plot_data_column, data = splines_connected)
  
  # Connect plots and apply a title on top
  plot <- patchwork::wrap_plots(plot, ncol = 1) + patchwork::plot_annotation(title = title, theme = theme(plot.title = element_text(hjust = 0.5, vjust = 0, face = "bold")))
  
  # Show plot
  plot
}