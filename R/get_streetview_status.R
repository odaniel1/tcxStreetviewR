get_single_streetview_status <- function(latitude = NULL, longitude = NULL, key = NULL, secret = NULL){

  key <- readChar("./google_API_key.txt", file.info("./google_API_key.txt")$size)
  secret <- readChar("./signing_secret.txt", file.info("./signing_secret.txt")$size)
  
  require(jsonlite)
  
  url <- paste0("https://maps.googleapis.com/maps/api/streetview/metadata?size=600x300",
    "&location=",latitude, ",", longitude, "&key=", key, "&secret=", secret)
  
  api_response <- jsonlite::fromJSON(url)
  
  if(api_response$status != "OK"){ return(api_response$status) }
  else if(api_response$copyright != "© Google"){ return("OK - Image Not Owned by Google")}
  else{ return(api_response$status) }
}

get_single_streetview_status <- Vectorize(get_single_streetview_status)


#---------------------------------------------------------------------------------------------------------------------

get_streetview_status <- function(segment, cores = NULL){
  
  if(is.null(cores)){
    segment <- segment %>%
      mutate(
        streetview_status = get_single_streetview_status(LatitudeDegrees,LongitudeDegrees)
      )    
  } else{
    
    require(parallel)
    cl <- makeCluster(min(detectCores(), cores))
    clusterExport(cl, c('segment', 'get_single_streetview_status'), envir=environment())
    
    segment$streetview_status <- parApply(cl, segment, 1,
        function(x) get_single_streetview_status(latitude = x['LatitudeDegrees'], longitude = x['LongitudeDegrees'])
    )
    
    stopCluster(cl)
  }
  
  return(segment)
}