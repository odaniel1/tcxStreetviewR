source("global.R")

library("tcxStreetviewR")

function(input, output) {
  
  # ------------------------------------------------------------------------------------------
  # Download route
  
  course_df <- eventReactive(input$download_tcx, {
    
    route_id <- input$route_url %>% str_replace("https://www.strava.com/routes/", "")

    temp_dir <- tempdir()

    download_route_tcx(route_id, temp_dir, strava_auth$key, strava_auth$secret)

    # CHANGE NEEDED TO REFLECT USE OF READ TCX FROM cycleRTools
    route_df <- cycleRtools::read_tcx(paste0(temp_dir, "/", route_id, ".tcx"), format = FALSE) %>%
      mutate(
        `Distance (Km)` = round(DistanceMeters/1000, 1),
        `Altitude (m)` = rollapply(AltitudeMeters,30, mean, align='center',fill=NA) %>% round(1)
      )
    
    return(route_df)
  })
  
  # ------------------------------------------------------------------------------------------
  # Load course (if defined)
  # course_df <- reactive({
  # 
  #   # Check if user has entered a tcx file.
  #   if(is.null(input$tcx_file)){
  #     course_df <- data_frame(
  #       Time = character(),
  #       AltitudeMeters = numeric(),
  #       DistanceMeters = numeric(),
  #       LatitudeDegrees = numeric(),
  #       LongitudeDegrees = numeric()
  #     )
  # 
  #     # If so convert to data frame.
  #   } else {
  #     course_df <- read_tcx(input$tcx_file$datapath) %>%
  #       mutate(
  #         `Distance (Km)` = round(DistanceMeters/1000, 1),
  #         `Altitude (m)` = rollapply(AltitudeMeters,30, mean, align='center',fill=NA) %>% round(1)
  #       )
  #   }
  # 
  #   return(course_df)
  # })
  
  # ------------------------------------------------------------------------------------------
  # Define range data frame.
  
  segment_df <- reactive({
    
    zr_names <- zoom_range() %>% names()
    
    if(is.null(zr_names)){ course_df()}
    else if(identical(zr_names, "xaxis.autorange") ){ course_df()}
    else if(identical(zr_names, "xaxis.range")){
      course_df() %>% filter(between(`Distance (Km)`, zoom_range()$`xaxis.range`[1], zoom_range()$`xaxis.range`[2] ))
    }
    else if(identical(zr_names, c("xaxis.range[0]","xaxis.range[1]") )){
      course_df() %>% filter(between(`Distance (Km)`, zoom_range()$`xaxis.range[0]`, zoom_range()$`xaxis.range[1]` ))
    }
  })  
  
  # ------------------------------------------------------------------------------------------
  # Define data frame with street view checked. 
  checked_df <- eventReactive(input$check_streetview, {
    check_segment_streetview(segment_df(), freq = input$sample_freq, api_key = google_auth$key, api_secret = google_auth$secret, cores = 4)
  })
  
  # -----------------------------------------------------------------------------------------
  # Prepare leaflet map.
  output$map <- renderLeaflet({
    
    lf <- leaflet() %>% addTiles
    
    if(is.null(course_df()) == FALSE & input$check_streetview == 0){
      lf <- lf %>%
        addPolylines(data = cbind(course_df()$LongitudeDegrees, course_df()$LatitudeDegrees), color = "grey" )
    }
    
    if(is.null(segment_df()) == FALSE & input$check_streetview == 0){
      lf <- lf %>%
        addPolylines(data = cbind(segment_df()$LongitudeDegrees, segment_df()$LatitudeDegrees),color = "#0dc5c1" )
    }
    
    if(input$check_streetview != 0){
      
      print(checked_df() %>% sample_n(10))
      
      lf <- lf %>%
        addPolylines(data = cbind(course_df()$LongitudeDegrees, course_df()$LatitudeDegrees), color = "grey" )
      
      lf <- lf %>% addPolylines(data = cbind(segment_df()$LongitudeDegrees, segment_df()$LatitudeDegrees),color = "green" )
      
      checked_red <- checked_df() %>% filter(status_color == "red")
      
      for( group in unique(checked_red$status_group)){
        segment_group <- checked_red %>% filter(status_group == group)
        lf <- lf %>% addPolylines(lng=~LongitudeDegrees, lat=~LatitudeDegrees,data= segment_group, color = ~status_color)
      }
    }
    
    # hover_coords <- event_data("plotly_hover", source = "alt_plot")
    # hover_lat_lng <- course_df() %>%
    #   filter(`Distance (Km)` == hover_coords$x, `Altitude (m)` == hover_coords$y) %>%
    #   select(LatitudeDegrees, LongitudeDegrees)
    # 
    # lf <- lf %>% addCircleMarkers(lng = hover_lat_lng$LongitudeDegrees, lat = hover_lat_lng$LatitudeDegrees, stroke = FALSE, radius = 8, fillOpacity = 1)
    
    lf
    
  })
  
  # -----------------------------------------------------------------------------------------
  # Prepare Altitude Plot.
  output$altPlot <- renderPlotly({
    if(nrow(course_df()) == 0){ return(NULL) }
    
    plot_ly( source = "alt_plot") %>%
      add_lines(data = course_df(), x = ~`Distance (Km)`, y = ~`Altitude (m)`, type = 'scatter',
                mode = 'lines', line = list(color = "#0dc5c1", width = 2)) %>%
      rangeslider() 
  })
  
  zoom_range <- reactive({ event_data("plotly_relayout", source = "alt_plot") })
  
  # -----------------------------------------------------------------------------------------
  # End of server.R
}

