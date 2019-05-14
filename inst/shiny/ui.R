source("global.R")

fluidPage(
  titlePanel("TCX Streetview Checker"),
  
  sidebarLayout(
    
    # Side bar.
    sidebarPanel(
      
      p("This app has been developed to help route planners (predominantly for road cycling)",
        "to identify points on a planned route that may be unsuitable for road bikes."),
      p("This is achieved by checking whether each road on the route is visible on",
        "Google Streetview."),
      div(style = "margin-top:-1.5em",hr()),
      
      h4("Step 1: Upload route."),
      
      # HTML options.
      tags$head(
        tags$style(
          HTML(
            "#inputs-table {border-collapse: collapse;}
            #inputs-table td {padding: 5px;vertical-align: bottom;}"
          ))),
      
      # File upload.
      tags$table(id = "inputs-table", style = "width: 100%",
                 tags$tr(
                   tags$td(style = "width: 100%", fileInput("tcx_file", label = "Upload route (.tcx)", accept = ".tcx"))
                 )
      ),
      
      # URL entry form.
      div(style = "margin-top:-3em",
          tags$table(id = "inputs-table", style = "width: 100%",
                     tags$tr(
                       tags$td(style = "width: 70%", textInput("route_url", "Or, enter Strava route URL",value = "https://www.strava.com/routes/18558756")),
                       
                       tags$td(style = "width: 30%; text-align: right"
                               , div(class = "form-group shiny-input-container"
                                     , actionButton("download_tcx", "Get Route!", width = "100%")))
                     )
          )),
      
      div(style = "margin-top:-1.5em",hr()),
      h4("Step 2: Select range"),
      p("To check only a section of your route (faster!), select the region by clicking and dragging the",
        "elevation plot."),
      
      div(style = "margin-top:-0.5em",hr()),
      h4("Step 3: Check Route"),
      p("Once ready, click the Check Streetview button below. The time taken will depend on length of route."),
      p("To speed up the calculation time you can adjust the sample frequency: by default every 50m of the route",
        "is checked on Streetview."),
      
      # First row - URL entry form.
      tags$table(id = "inputs-table", style = "width: 100%",
                 tags$tr(
                   tags$td(style = "width: 70%; text-align: right"
                           , div(class = "form-group shiny-input-container",
                                 actionButton("check_streetview", "Check Streetview",
                                              width = "100%",style="color: #fff; background-color: #0dc5c1; border-color: #0dc5c1"))),
                   tags$td(style = "width: 30%", numericInput("sample_freq", label = "Freq. (m)", min = 50, value = 200))
                 )
      )
    )
    
    # Main body.
    ,mainPanel(
      leafletOutput("map", height = 500) %>% withSpinner(8,color="#0dc5c1"),
      
      plotlyOutput("altPlot", height = 200)
      # verbatimTextOutput("zoom"),
    )
  )
)

