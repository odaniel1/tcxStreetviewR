#' Download a tcx file from Strava.
#'
#' This function downloads a tcx. file from Strava.
#' @param route_id The route id; this is the number that appears in the URL for the route.
#' @param write_dir The directory to write the tcx file to.
#' @param strava_key The API key for Strava.
#' @param strava_secret The API secret for Strava.
#' @examples

download_route_tcx <- function(route_id, write_dir, strava_key, strava_secret){
  
  library(httr)
  
  # strava_key <- readChar("./strava_key.txt", file.info("./strava_key.txt")$size)
  # strava_secret <- readChar("./strava_secret.txt", file.info("./strava_secret.txt")$size)
  
  my_app <- oauth_app("strava",key = strava_key,secret = strava_secret)
  
  my_endpoint <- oauth_endpoint(request = NULL,
                                authorize = "https://www.strava.com/oauth/authorize",
                                access = "https://www.strava.com/oauth/token"
  )
  
  strava_token <- oauth2.0_token(
    my_endpoint, my_app,
    scope = "view_private", type = NULL, use_oob = FALSE,
    as_header = FALSE, use_basic_auth = FALSE, cache = FALSE
  )
  
  url <- paste0("https://www.strava.com/api/v3/routes/", route_id, "/export_tcx")
  write_path <- paste0(write_dir, "/", route_id, ".tcx")
  
  print(write_path)
  
  GET(url, strava_token, write_disk(write_path, overwrite = TRUE))
}