#' Individual plot of selected activity by date on google map
#'
#' Plots activities over time by month
#' @param data A data frame output from process_activities()
#' @param activity_date Date of activity
#' @param zoom Zoom used by google maps. Depending on activity range it will need to be adjusted. Higher value is higher zoom.
#' @param label If TRUE each km will be labeled on a map
#'
#' @return A plot of activities over time by month
#' @export
#'
# Creates an individual plot of selected activity on google map
individual_plot_map <- function(data, activity_date = "last", zoom = 14, color = "pace", label = FALSE) {

  # Constants
  possible_values_color<- c("pace", "elevation", "speed")

  # Check if the color argument is correct
  if (!(color %in% possible_values_color)) {
    stop("This argument value for `color` is not available! Use 'pace', 'elevation' or 'speed' instead.")
  }

  # Check if there is a ele column in the data frame
  if (color == "ele") {
    if (sum(colnames(data) == "ele") == 0) {
      stop("The data frame does not contain 'ele' column! Try running process_data function with argument 'old_gpx_format' = TRUE or use 'pace' or 'speed' instead.")
    }
  }

  # Check if the activity_date argument is correct
  if (activity_date == "last") {
    data_individual <- data %>%
      dplyr::filter(Activity.Date == max(Activity.Date))
  } else if (is.Date(as.Date(activity_date)) == TRUE) { # Check if the argument is given as a date format
    if(as.Date(activity_date) %in% as.Date(data$Activity.Date)) { # Filter data frame for a given date
      data_individual <- data %>%
        dplyr::filter(format(Activity.Date, "%Y-%m-%d") == activity_date)
    } else {
      stop("There is no activity found on this date! Change the activity_date argument.")
    }
  } else {
    stop("The date format is wrong! You need to type 'YYYY-MM-DD' in the activity_date argument instead.")
  }

  # Load time formatter. Source: https://r-graphics.org/recipe-axes-time-rel
  timeHMS_formatter <- function(x) {
    h <- floor(x/60)
    m <- floor(x %% 60)
    s <- round(60*(x %% 1))                   # Round to nearest second
    lab <- sprintf('%02d:%02d:%02d', h, m, s) # Format the strings as HH:MM:SS
    lab <- gsub('^00:', '', lab)              # Remove leading 00: if present
    lab <- gsub('^0', '', lab)                # Remove leading 0 if present
  }

  # Adjusting a data frame
  data_individual<- data_individual %>%
    dplyr::ungroup() %>%
    dplyr::select(lon, lat, Activity.Date, dist_to_prev, time_diff_to_prev, cumdist, time, Activity.Type, if (color == "ele") {ele} ) %>%
    dplyr:: mutate(Activity.Date = as_date(Activity.Date),
                   pace = (time_diff_to_prev / dist_to_prev / 60), # Add a pace variable in min/km
                   speed = (1000 * dist_to_prev / time_diff_to_prev) * 3.6, # Add a speed variable in km/h
                   floor_distance = floor(cumdist)) # Add a floored distance in order to add labels to a plot. It is necessary in data_individual_points.

  # Calculate necessary values for a plot
  if (color == "pace") {
    data_individual<- data_individual %>%
      dplyr::filter(pace < 11.5, pace > 2)
    mean_pace <- round(mean(data_individual$pace))
    seq <- seq(mean_pace - 2, mean_pace + 2, by = 1) # Make a sequence to use as a scale in a plot
    seq_hms <- timeHMS_formatter(seq) # Transform a sequence to time
    unit = "[min/km]"
    title = "Pace"
  } else if (color == "speed"){ #
    data_individual<- data_individual %>%
      dplyr::filter(speed < 60, speed > 4)
    mean_speed <- round(mean(data_individual$speed))
    unit = "[km/h]"
    title = "Speed"

    if (max(data_individual$speed) > 35) { # This is done mainly for activities where there are lots of outliers. This makes a scale to take mean speed in a center.
      seq <- seq(floor(mean_speed * 0.5), ceiling(mean_speed * 1.5), length.out = 5)
    } else {
      seq <- seq(0, ceiling(max(data_individual$speed)), length.out = 5)
    }
  } else {
    color = "ele"
    unit = "[m]"
    title = "Elevation"
  }

  # Transform data to use as a label in a plot
  data_individual_points <- data_individual %>%
    dplyr::select(lon, lat, floor_distance) %>%
    dplyr::group_by(floor_distance) %>%
    dplyr::filter(floor_distance > 0, row_number() == 1)  %>%
    dplyr::ungroup()

  # Google map plot. Right now Google requires API key to enable using Google Maps.
  p <- ggmap::ggmap(get_googlemap(center = c(
    lon = mean_lon <- mean(range(data_individual$lon)),
    lat = mean(range(data_individual$lat))),
    zoom = zoom, scale = 2,
    maptype ='terrain',
    color = 'color')) +
    ggplot2::geom_path(data = data_individual, aes(lon, lat, color = !!sym(color)), size = 0.7,
                       lineend = "round") +
    labs(title = paste(title, unit, "of", tolower(data_individual$Activity.Type), "activity on", format(as.Date(data_individual$Activity.Date), "%A, %d %B %Y")),
         y = NULL,
         x = NULL) +
    theme(legend.key.width = unit(1.6, "cm"),
          legend.key.height = unit(0.4, "cm"),
          legend.title = element_blank(),
          plot.title = element_text(vjust = 2, hjust = 0.5),
          axis.ticks = element_blank(),
          axis.text = element_blank(),
          legend.position = "bottom")

  # Add a scale on a given color argument
  if(color == "pace") {
    p <- p + scale_colour_viridis_c(option = "inferno", direction = -1, labels = seq_hms, limits = c(min(seq), max(seq)))
  } else if (color == "speed") {
    p <- p + scale_colour_viridis_c(option = "inferno", direction = 1, labels = seq, limits = c(min(seq), max(seq)), breaks = seq)
  } else {
    p <- p + scale_colour_viridis_c(option = "inferno")
  }

  # Add km labels for progress in the activity
  if (label) {
    p  <- p + geom_label(data = data_individual_points, mapping = aes(lon, lat, label = floor_distance), size = 3)
  }
  p
}
