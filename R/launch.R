#' Run the graphical interface to the app in a web browser
#' @export
launch <- function() {
  shiny::runApp(system.file("shiny", package = "tcx-streetview-checker"),
                display.mode = "normal",
                launch.browser = TRUE)
}