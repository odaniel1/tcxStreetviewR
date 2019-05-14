#' Checks google streetview for a given segment at regular intervals along the route.
#' @param segment A data frame containing a strava route segment.
#' @param freq The frequency in meters at which to check the API.
#' @param api_key The key for the Google Static Streetview API.
#' @param api_secret The secret for the Google Static Streetview API
#' @export
#' @examples
#' check_segment_streetview()
check_segment_streetview <- function(segment, freq, api_key, api_secret, cores = NULL){
  
  checkpoint_df <- reduce_segment_to_freq(segment, freq)
  
  checkpoint_df <- get_streetview_status(checkpoint_df, api_key, api_secret, cores = cores)
  
  segment <- merge_freq_to_segment(segment, checkpoint_df)
  
  return(segment)
}


