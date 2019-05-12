library(httr)

strava_key <- readChar("./strava_key.txt", file.info("./strava_key.txt")$size)
strava_secret <- readChar("./strava_secret.txt", file.info("./strava_secret.txt")$size)

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

download_route_tcx <- function(route_id, write_dir){
  
  url <- paste0("https://www.strava.com/api/v3/routes/", route_id, "/export_tcx")
  write_path <- paste0(write_dir, "/", route_id, ".tcx")
  
  print(write_path)
  
  GET(url, strava_token, write_disk(write_path, overwrite = TRUE))
}