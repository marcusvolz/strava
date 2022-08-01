#' Joins data and activities data frames
#'
#' @export
#'
# Join data and activities
join_data_activities <- function() {
  activities <- activities[!(activities$Filename==""),]
  activities <- activities[grepl("gpx$", activities$Filename),]
  
  #Correcting ID
  activities <- rowid_to_column(activities, "id")
  
  #Joining data frames
  data <- data %>%
    inner_join(activities, by = "id")
}