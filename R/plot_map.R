#' Plots activities superimposed on a map
#'
#' Plots activities superimposed on a map
#' @param data A data frame output from process_data()
#' @param lon_min Minimum longitude (optional)
#' @param lon_max maximum longitude (optional)
#' @param lat_min Minimum latitude (optional)
#' @param lat_max Maximum latitude (optional)
#'
#' @return A heat map of activities
#' @export
#'
#' @examples
plot_map <- function(data, lon_min = -180, lon_max = 180, lat_min = -90, lat_max = 90) {
  data %>%
    filter(
      between(lon, lon_min, lon_max),
      between(lat, lat_min, lat_max)
    ) %>%
    ggplot(aes(lon, lat, group = id)) +
    geom_path(
      alpha = 0.3,
      size = 0.3,
      lineend = "round"
    ) +
    coord_map() +
    theme_void()
}
