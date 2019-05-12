check_segment_streetview <- function(segment, freq, cores = NULL){
  
  checkpoint_df <- reduce_segment_to_freq(segment, freq)
  
  checkpoint_df <- get_streetview_status(checkpoint_df, cores = cores)
  
  segment <- merge_freq_to_segment(segment, checkpoint_df)
  
  return(segment)
}


