#' Samples a provided route segment at regular intervals
#' @param segment A route segment in data frame format.
#' @param freq The frequency (in meters) at which to sample.
#' @export
#' @examples
#' reduce_segment_to_freq()
reduce_segment_to_freq <- function(segment, freq){
  
  require(tidyverse)
  
  segment <- segment %>% mutate(id = 1:n() -1)
  
  segment_dist <- max(segment$DistanceMeters) - min(segment$DistanceMeters)
  
  id_sample_freq <- round(freq * nrow(segment) / segment_dist)
  
  segment <- segment %>%
    mutate(
      checkpoint = ( (id %% id_sample_freq) == 0)
    )
  
  freq_df <- segment %>% filter(checkpoint == TRUE) %>% select(-id)
  
  return(freq_df)
}

#----------------------------------------------------------------------------------------------------------------------
#' Merges two data frames, and imputes missing streetview status values.
#' @param segment A route segment in data frame format.
#' @param checkpoints A subset of rows from segment argument, including a streetview_status field.
#' @export
#' @examples
#' merge_freq_to_segment()
merge_freq_to_segment <- function(segment, checkpoints){
  
  checkpoints <-checkpoints %>% select(LatitudeDegrees, LongitudeDegrees, streetview_status)
  
  segment <- segment %>%
    left_join(checkpoints) %>%
    mutate(
      streetview_status = streetview_status %>% accumulate(.f = function(x,y){if(is.na(y)){return(x)}else{return(y)}}),
      streetview_ok = streetview_status == "OK",
      streetview_ok_lag = lag(streetview_ok, default = TRUE),
      group_trip = ifelse(streetview_ok == streetview_ok_lag,0,1),
      status_group = accumulate(group_trip, `+`),
      status_color = ifelse(streetview_status == "OK", "green", "red")
    ) %>%
    select( -streetview_ok_lag, -group_trip)
  
  
}