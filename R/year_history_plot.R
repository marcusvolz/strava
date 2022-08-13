#' Plots activities over time by year
#'
#' Plots activities over time by year
#' @param data A data frame output from process_activities()
#' @param by_activity Activity type
#' @param by_unit Unit type
#' @param background_color Background color (optional)
#'
#' @return A plot of activities over time by year
#' @export

# Year history plot function
year_history_plot <- function(data = activities, by_unit = "Distance", by_activity = "All", background_color = "white") {

  # ---- constants ----
  possible_values_unit<- c("Distance", "Time", "Count")
  possible_values_activity <- c("All",
                                data %>% dplyr::select(Activity.Type) %>% unique() %>% dplyr::pull())
  possible_values_background_color <- c("white", "lightgreen", "lightbrown")

  # Check if the by_unit argument is correct
  if (!(by_unit %in% possible_values_unit)) {
    stop("This argument value for `by_activity` is not available! Use 'Distance', 'Time' or 'Count' instead.")
  }

  # Check if the data is joined with activities.
  if (!(by_activity %in% possible_values_activity)) {
    available_activity_types <- paste0("'", possible_values_activity, "'", collapse  = ", ")
    stop(paste("This argument value for `by_unit` is not available! Use one of those activities instead:", available_activity_types))
  }

  # Check if the background_color argument is correct
  if (!(background_color %in% possible_values_background_color)) {
    stop("This argument value for `background_color` is not available! Use 'white', 'lightbrown' or 'lightgreen' instead.")
  }

  # Limiting columns
  activities_selected <- activities[c(2,4,6,7,15:25)]

  # Filter activities by by_activity argument
  if (!by_activity %in% "All") {
    activities_selected <- activities_selected %>%
      dplyr::filter(Activity.Type == by_activity)
  }

  # Adding unit variables to the data frame
  activities_selected <- activities_selected %>%
    dplyr::arrange(Activity.Date) %>%
    dplyr::mutate(year = lubridate::year(Activity.Date), day = lubridate::yday(Activity.Date)) %>%
    dplyr::group_by(year) %>%
    dplyr::mutate(Distance = cumsum(Distance), Time = cumsum(Moving.Time) / 3600, Count = cumsum(year/year))

  # Maxing a unit by year
  activities_selected_max <- activities_selected %>%
    dplyr::filter(year != year(now())) %>%
    dplyr::summarise(
      Activity.Date = ceiling_date(Activity.Date, unit = "year") - 1,
      Distance = max(Distance), Time = max(Time),
      Count = max(Count),
      .groups = 'keep') %>%
    cbind(day = 369)

  # Unit resetting
  activities_selected_reset <- activities_selected %>%
    dplyr::group_by(year) %>%
    dplyr::slice_head(n = 1) %>%
    dplyr::mutate(Activity.Date = Activity.Date - 1, Distance = 0, Time = 0, Count = 0) %>%
    dplyr::ungroup()

  # Binding two data frames to reset unit for each year
  activities_selected <- activities_selected %>%
    rbind(activities_selected_reset, activities_selected_max) %>%
    dplyr::arrange(Activity.Date) %>%
    dplyr::ungroup()

  # Selecting the current year to make the observations more visible
  activities_now <- activities_selected %>%
    dplyr::filter(year == max(year)) %>%
    dplyr::slice_tail(n = 1)

  # Make a data point for current date
  if (last(activities_selected$year) == year(today())) {
    activities_now <- activities_now %>%
      dplyr::mutate(Activity.Date = lubridate::now(), day = lubridate::yday(Activity.Date), Activity.Type = by_activity)
  }

  # Binding current date
  activities_selected <- activities_selected %>%
    rbind(activities_now)

  if (by_unit == "Distance") {
    unit = "km"
  } else if (by_unit == "Time") {
    unit = "hours"
  } else {
    unit = "times"
  }

  # Setting color for a scale
  palette <- wesanderson::wes_palette("Zissou1", n = length(unique(activities_selected$year)), type ="continuous")

  # Adding a sequence for y scale
  if (floor(max(activities_selected[by_unit])) == 1) { # Fixing a bug when there was only one activity in by_unit 'Count' value.
    seq <- seq(0, floor(max(activities_selected[by_unit])), by = floor(max(activities_selected[by_unit])))
  } else {
    seq <- seq(0, floor(max(activities_selected[by_unit])), by = floor(max(activities_selected[by_unit])/2))
  }

  # Customizing background color
  if (background_color == "lightgreen") {
    background_color <- "#FAFCFC"
  } else if (background_color == "lightbrown"){
    background_color <- "#FDFBF3"
  }

  #Final plot
  p  <- ggplot(data = activities_selected) +
    geom_step(mapping = aes(x = day, y = !!sym(by_unit), group = year, color = factor(year)), size = 0.5) +
    geom_point(mapping = aes(x = day, y = !!sym(by_unit), group = year, color = factor(year)), data = activities_selected_max, shape = 21, fill = background_color, size = 1, stroke = 1) +
    scale_color_manual(values = palette) +
    scale_x_continuous(limits =  c(0, 395), breaks = c(1, 91, 182, 273, 365), labels = c("1 Jan", "1 Apr", "1 Jul", "1 Oct","31 Dec")) +
    theme_classic() +
    labs(y = NULL, x = NULL, title = paste(by_activity, "activities","by year")) +
    scale_y_continuous(
      breaks = seq,
      labels = paste(seq, unit)) +
    theme(
      axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
      axis.text.y = element_text(hjust = 1, vjust = 0.3),
      axis.text = element_text(color = "#303030"),
      axis.ticks = element_blank(),
      axis.line = element_blank(),
      panel.grid.major.y = element_line(color =  "lightgrey", linetype =  "dotted"),
      panel.background = element_rect(fill = background_color),
      plot.background = element_rect(fill = background_color),
      panel.border = element_blank(),
      plot.title = element_text(vjust = 2, hjust = 0.5, color = "#303030"),
      plot.title.position = "plot",
      legend.position = "none"
    )

  if(last(activities_selected$year) == year(today())) {
    p <- p + geom_step(activities_selected %>%
                         dplyr::filter(year == max(year)), mapping = aes(x = day, y = !!sym(by_unit), color = factor(year)), size = 0.75) +
      geom_point(mapping = aes(x = day, y = !!sym(by_unit), group = year, color = factor(year)), data = activities_now, shape = 21, fill = background_color, size = 1, stroke = 1)
  }

  p <- p + geom_hline(yintercept = 0, color = "#303030") +
    geom_label(
      data = activities_selected %>% dplyr::group_by(year) %>% dplyr::slice_tail(n = 1),
      aes(x = day,  y = !!sym(by_unit), label = year, color = factor(year)),
      vjust = 0.46,
      hjust = -0.15,
      label.padding = unit(0.04, "lines"),
      label.r = unit(0.2, "lines"),
      label.size = NA,
      fill = background_color
    )
  p
}
