library(shiny)
library(shinycssloaders)
library(tidyverse)
library(leaflet)
library(zoo)
library(plotly)
library(dotenv)
library(httr)

# Read API secrets from system environment. WARNING - If hosting on github, the .env file should
# always be added to .gitignore to stop API secrets from being committed.
google_auth <- data_frame(key = Sys.getenv("google_key"), secret = Sys.getenv("google_secret"))
strava_auth <- data_frame(key = Sys.getenv("strava_key"), secret = Sys.getenv("strava_secret"))


# Auth flow for Strava API
strava_app <- oauth_app("strava",key = strava_auth$key,secret = strava_auth$secret)

strava_endpoint <- oauth_endpoint(request = NULL,
                              authorize = "https://www.strava.com/oauth/authorize",
                              access = "https://www.strava.com/oauth/token"
)

strava_token <- oauth2.0_token(
  strava_endpoint, strava_app,
  scope = "view_private", type = NULL, use_oob = FALSE,
  as_header = FALSE, use_basic_auth = FALSE, cache = FALSE
)
