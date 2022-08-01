#' Processes activities file and stores the result in a data frame
#'
#' @param path The file path to the directory containing the activities file
#' @export
#' 
# Process  activities
process_activities <- function(path) {
  activities <- read.csv(path)
  
  #Converting data
  activities <- activities %>%
    mutate(Activity.Date = mdy_hms(Activity.Date))
}