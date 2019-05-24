library("tcxStreetviewR")

function(input, output) {
  
  # ------------------------------------------------------------------------------------------
  # Set initial default for route_df.
  route_df <- reactiveVal({
    data_frame(
            Time = character(),
            AltitudeMeters = numeric(),
            DistanceMeters = numeric(),
            LatitudeDegrees = numeric(),
            LongitudeDegrees = numeric()
          )
  })
  
  # ------------------------------------------------------------------------------------------
  # Updatee route_df based on URL.
  observeEvent(input$download_tcx, {
      url_route_id <- input$route_url %>% str_replace("https://www.strava.com/routes/", "")

      temp_dir <- tempdir()

      download_route_tcx(url_route_id, temp_dir, strava_token)

      url_route_df <- cycleRtools::read_tcx(paste0(temp_dir, "/", route_id, ".tcx"), format = FALSE) %>%
        mutate(
          `Distance (Km)` = round(DistanceMeters/1000, 1),
          `Altitude (m)` = rollapply(AltitudeMeters,30, mean, align='center',fill=NA) %>% round(1)
        )
      
      route_df(url_route_df)
})
  
  #------------------------------------------------------------------------------------------
  # Reading in from file.
  observeEvent(input$tcx_file, {
    file_route_df <- cycleRtools::read_tcx(input$tcx_file$datapath, format = FALSE) %>%
      mutate(
        `Distance (Km)` = round(DistanceMeters/1000, 1),
        `Altitude (m)` = rollapply(AltitudeMeters,30, mean, align='center',fill=NA) %>% round(1)
      )
    
    route_df(file_route_df)
  })

  # ------------------------------------------------------------------------------------------
  # Define range data frame.
  segment_df <- reactive({
    
    zr_names <- zoom_range() %>% names()
    
    if(is.null(zr_names)){ route_df()}
    else if(identical(zr_names, "xaxis.autorange") ){ route_df()}
    else if(identical(zr_names, "xaxis.range")){
      route_df() %>% filter(between(`Distance (Km)`, zoom_range()$`xaxis.range`[1], zoom_range()$`xaxis.range`[2] ))
    }
    else if(identical(zr_names, c("xaxis.range[0]","xaxis.range[1]") )){
      route_df() %>% filter(between(`Distance (Km)`, zoom_range()$`xaxis.range[0]`, zoom_range()$`xaxis.range[1]` ))
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
    
    # If no segment selected and streetview has not yet been checked, render complete route in cyan.
    if(identical(route_df(), segment_df()) == TRUE & input$check_streetview == 0){
      lf <- lf %>% 
        addPolylines(data = cbind(segment_df()$LongitudeDegrees, segment_df()$LatitudeDegrees),color = "#00A9A2" )
    }
    
    # If a segment is selected and streetview has not yet been checked, render segment in cyan and remaining
    # route in grey.
    if(identical(route_df(), segment_df()) == FALSE & input$check_streetview == 0){
      lf <- lf %>% 
        addPolylines(data = cbind(route_df()$LongitudeDegrees, route_df()$LatitudeDegrees),color = "grey" ) %>%
        addPolylines(data = cbind(segment_df()$LongitudeDegrees, segment_df()$LatitudeDegrees),color = "#00A9A2")
    }
    
    if(input$check_streetview != 0){
      
      lf <- lf %>%
        addPolylines(data = cbind(route_df()$LongitudeDegrees, route_df()$LatitudeDegrees), color = "grey" )
      
      lf <- lf %>% addPolylines(data = cbind(segment_df()$LongitudeDegrees, segment_df()$LatitudeDegrees),color = "green" )
      
      checked_red <- checked_df() %>% filter(status_color == "red")
      
      for( group in unique(checked_red$status_group)){
        segment_group <- checked_red %>% filter(status_group == group)
        lf <- lf %>% addPolylines(lng=~LongitudeDegrees, lat=~LatitudeDegrees,data= segment_group, color = ~status_color)
      }
    }
    
    # hover_coords <- event_data("plotly_hover", source = "alt_plot")
    # hover_lat_lng <- route_df() %>%
    #   filter(`Distance (Km)` == hover_coords$x, `Altitude (m)` == hover_coords$y) %>%
    #   select(LatitudeDegrees, LongitudeDegrees)
    # 
    # lf <- lf %>% addCircleMarkers(lng = hover_lat_lng$LongitudeDegrees, lat = hover_lat_lng$LatitudeDegrees, stroke = FALSE, radius = 8, fillOpacity = 1)
    
    lf
    
  })
  
  # -----------------------------------------------------------------------------------------
  # Prepare Altitude Plot.
  output$altPlot <- renderPlotly({
    if(nrow(route_df()) == 0){ return(NULL) }
    
    plot_ly( source = "alt_plot") %>%
      add_lines(data = route_df(), x = ~`Distance (Km)`, y = ~`Altitude (m)`, type = 'scatter',
                mode = 'lines', line = list(color = "#0dc5c1", width = 2)) %>%
      rangeslider() 
  })
  
  zoom_range <- reactive({ event_data("plotly_relayout", source = "alt_plot") })
  
  # -----------------------------------------------------------------------------------------
  # End of server.R
}

