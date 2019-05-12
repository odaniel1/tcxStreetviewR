#' Run the graphical interface to the app in a web browser
#' @export
launch <- function() {
  shiny::runApp(system.file("shiny", package = "tcxStreetviewR"),
                display.mode = "normal",
                launch.browser = TRUE)
}