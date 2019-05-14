#' Get the status of a single latitude/longitude pair from streetview.
#'
#' This function takes as an input a latitude/longitude pair, and returns the response
#' from the Google Static Streetview API as to whether or not there is an image on record.
#' @param latitude A latitude value
#' @param longitude A longitude value
#' @param api_key The API key for Google Static Streetview
#' @param api_secret The API secret for Google Static Streetview
#' @export
#' @examples
#' get_single_streetview_status()
get_single_streetview_status <- function(latitude = NULL, longitude = NULL, api_key = NULL, api_secret = NULL){
  
#   key <- readChar("./google_API_key.txt", file.info("./google_API_key.txt")$size)
#   secret <- readChar("./signing_secret.txt", file.info("./signing_secret.txt")$size)
  
  require(jsonlite)
  
  url <- paste0("https://maps.googleapis.com/maps/api/streetview/metadata?size=600x300",
    "&location=",latitude, ",", longitude, "&key=", api_key, "&secret=", api_secret)
  
  api_response <- jsonlite::fromJSON(url)
  
  if(api_response$status != "OK"){ return(api_response$status) }
  else if(api_response$copyright != "© Google"){ return("OK - Image Not Owned by Google")}
  else{ return(api_response$status) }
}

get_single_streetview_status <- Vectorize(get_single_streetview_status)


#---------------------------------------------------------------------------------------------------------------------

#' Get the status of a collection of latitude/longitude pairs.
#'
#' This function takes as an input a data frame containing latitude/longitude pairs, and returns the data frame
#' with an additional column indicating the response from the Google Static Streetview API as to whether or not
#' there is an image on record.
#' @param segment A data frame containing latitude and longitude variables.
#' @param api_key The API key for Google Static Streetview
#' @param api_secret The API secret for Google Static Streetview
#' @param cores The number of cores to use for parallel processing
#' @export
#' @examples
#' get_streetview_status()
get_streetview_status <- function(segment, api_key, api_secret, cores = NULL){
  
  if(is.null(cores)){
    segment <- segment %>%
      mutate(
        streetview_status = get_single_streetview_status(LatitudeDegrees,LongitudeDegrees, api_key, api_secret)
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