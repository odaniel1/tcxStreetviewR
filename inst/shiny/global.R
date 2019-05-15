library(shiny)
library(shinycssloaders)
library(tidyverse)
library(leaflet)
library(zoo)
library(plotly)
library(dotenv)

# Read API secrets from system environment. WARNING - If hosting on github, the .env file should
# always be added to .gitignore to stop API secrets from being committed.
google_auth <- data_frame(key = Sys.getenv("google_key"), secret = Sys.getenv("google_secret"))
strava_auth <- data_frame(key = Sys.getenv("strava_key"), secret = Sys.getenv("strava_secret"))
