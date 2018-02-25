#' Plots activities superimposed on a map
#'
#' Plots activities superimposed on a map
#' @param data A data frame output from process_data()
#' @param lon_min Minimum longitude
#' @param lon_max Maximum longitude
#' @param lat_min Minimum latitude
#' @param lat_max Maximum latitude
#' @keywords
#' @export
#' @examples
#' plot_map()

plot_map <- function(data, lon_min = -180, lon_max = 180, lat_min = -90, lat_max = 90) {
  # Create plot
  p <- ggplot2::ggplot() +
    ggplot2::geom_path(ggplot2::aes(lon, lat, group = id),
              data %>% dplyr::filter(lon > lon_min, lon < lon_max, lat > lat_min, lat < lat_max),
              alpha = 0.3, size = 0.3, lineend = "round") +
    ggplot2::coord_map() +
    ggplot2::theme_void()

  # Return plot
  p
}
