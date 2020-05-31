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
plot_map <- function(data, lon_min = NA, lat_min = NA, lon_max = NA, lat_max = NA) {
  data %>%
    ggplot(aes(lon, lat, group = id)) +
    geom_path(
      alpha = 0.3,
      size = 0.3,
      lineend = "round"
    ) +
    coord_map(xlim = c(lon_min, lon_max), ylim = c(lat_min, lat_max)) +
    theme_void()
}
