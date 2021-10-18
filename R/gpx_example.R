#' Get an example gpx
#'
#' Get an exampe gpx file from the package
#'
#' @param name Name of the gpx file. Leave blank to display the list of
#' examples
#'
#' @export
#' @examples
#' gpx_example("trail_roche_doetre")
gpx_example <- function(name = NULL) {
  fls <- list.files(
    path = system.file(
      "gpxs",
      package = "strava"
    ),
    pattern = "gpx",
    full.names = TRUE
  )
  if (is.null(name)) {
    return(
      basename(fls)
    )
  }
  grep(name, fls, value = TRUE)
}
