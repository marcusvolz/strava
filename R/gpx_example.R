#' Get an example gpx
#'
#' Get an exampe gpx file from the package
#'
#' @param name Name of the gpx file. Leave blank to display the list of
#' examples
#'
#' @export
#' @examples
#' # list all examples
#' gpx_example()
#' # Return the path to one example
#' gpx_example("trail_roche_doetre")
gpx_example <- function(name = NULL) {
  # If there is no name, we return all
  # the activities

  if (is.null(name)) {
    fls <- list(
      running = list.files(
        path = system.file(
          "gpx",
          "running",
          package = "strava"
        ),
        pattern = "gpx",
        recursive = TRUE
      ),
      cycling = list.files(
        path = system.file(
          "gpx",
          "running",
          package = "strava"
        ),
        pattern = "gpx",
        recursive = TRUE
      )
    )
    return(fls)
  }

  fls <- list.files(
    path = system.file(
      "gpx",
      package = "strava"
    ),
    pattern = "gpx",
    full.names = TRUE,
    recursive = TRUE
  )
  grep(name, fls, value = TRUE)
}