# tcxStreetviewR
This is a shiny app to help route planners (predominantly road cyclists) to ensure that their route sticks to roads, and not off-road tracks and bridle paths.

The user uploads a route in `.tcx` format, and the app then checks whether or not Google Streetview has visited locations along the route.

## How to add your API credentials
This app requires API credentials for the both the  [Google Street View Static API](https://developers.google.com/maps/documentation/streetview/intro), and the [Strava API](https://developers.strava.com/). These should be saved in a `.env` file, inside the directory `inst/shiny`. Copy the file strcuture indicated below, replacing the holding text with your own API credentials.

```
# Key and Secret for Google Streetview Static API 
google_key="my-google-secret"
google_secret="my-google-key"

# Key and Secret for Strava API
strava_key="my-strava-key"
strava_secret="my-strava-secret"
```

*Warning:* These credentials should never be pushed to github; to safeguard against this add the line `inst/shiny/.env` to your `.gitignore` file.