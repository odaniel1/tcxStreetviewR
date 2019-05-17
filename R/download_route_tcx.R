#' Download a tcx file from Strava.
#'
#' This function downloads a tcx. file from Strava.
#' @param route_id The route id; this is the number that appears in the URL for the route.
#' @param write_dir The directory to write the tcx file to.
#' @param strava_token An oauth token for the Strava API.
#' @export
#' @examples

download_route_tcx <- function(route_id, write_dir, strava_token){

  url <- paste0("https://www.strava.com/api/v3/routes/", route_id, "/export_tcx")
  write_path <- paste0(write_dir, "/", route_id, ".tcx")
  
  GET(url, strava_token, write_disk(write_path, overwrite = TRUE))
}