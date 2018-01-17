#' Processes gpx files and stores the result in a data frame
#'
#' Processes gpx files and stores the result in a data frame
#' @param path The file path to the directory containing the gpx files
#' @keywords
#' @export
#' @examples
#' process_data()

process_data <- function(path) {
  # Function for processing a Strava gpx file
  process_gpx <- function(file) {
    # Parse GPX file and generate R structure representing XML tree
    pfile <- XML::htmlTreeParse(file = file,
                           error = function (...) {},
                           useInternalNodes = TRUE)

    coords <- XML::xpathSApply(pfile, path = "//trkpt", XML::xmlAttrs)

    # Check for empty file.
    if (length(coords) == 0) return(NULL)
    # dist_to_prev computation requires that there be at least two coordinates.
    if (ncol(coords) < 2) return(NULL)

    lat <- as.numeric(coords["lat", ])
    lon <- as.numeric(coords["lon", ])
    ele <- as.numeric(XML::xpathSApply(pfile, path = "//trkpt/ele", XML::xmlValue))
    time <- XML::xpathSApply(pfile, path = "//trkpt/time", XML::xmlValue)

    # Put everything in a data frame
    result <- data.frame(lat = lat, lon = lon, ele = ele, time = time) %>%
      dplyr::mutate(dist_to_prev = c(0, sp::spDists(x = as.matrix(.[, c("lon", "lat")]), longlat = TRUE, segments = TRUE)),
             cumdist = cumsum(dist_to_prev),
             time = as.POSIXct(.$time, tz = "GMT", format = "%Y-%m-%dT%H:%M:%OS")) %>%
      dplyr::mutate(time_diff_to_prev = as.numeric(difftime(time, dplyr::lag(time, default = .$time[1]))),
             cumtime = cumsum(time_diff_to_prev))
    result
  }

  # Process all the files
  data <- list.files(path = path, pattern = "*.gpx", full.names = TRUE) %>%
    purrr::map_df(process_gpx, .id = "id") %>%
    dplyr::mutate(id = as.integer(id))
}
