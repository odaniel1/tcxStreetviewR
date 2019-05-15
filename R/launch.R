#' Run the graphical interface to the app in a web browser
#' @param google_auth A pair containing valid credentials (key,secret) for the Google Static Streetview API.
#' @param strava_auth A pair containing valid credentials (key,secret) for the Strava API.
#' @examples
#' @export

launch <- function(){
  
shiny::runApp(system.file("shiny", package = "tcxStreetviewR"),
                display.mode = "normal",
                launch.browser = TRUE)
}
