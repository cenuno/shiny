#
# Author:     Cristian E. Nuno
# Date:       January 20, 2018
# Purpose:    Change color of Cicle Marker as mouse hovers over them
#

# load necessary packages
library( leaflet )
library( shiny )
library( sp )
library( rgdal )

# load necessary data
cps.school.location.sy1718 <-
  rgdal::readOGR( dsn = "https://data.cityofchicago.org/api/geospatial/4g38-vs8v?method=export&format=GeoJSON"
                  , layer = "OGRGeoJSON"
                  , stringsAsFactors = FALSE
                  )

## make UI ##
ui <- shiny::fluidPage(
  title = "Chicago Public Schools - School Locations SY1718"
  , leaflet::leafletOutput( outputId = "map"
                            , height = 900
  )
  , theme = "dynamic_colors.css"
)

## make Server ##
server <- function( input, output){
  
  # render the map
  output$map <- leaflet::renderLeaflet({
    leaflet() %>%
      addTiles( urlTemplate = "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_nolabels/{z}/{x}/{y}.png") %>%
      setView( lng = -87.567215
               , lat = 41.822582
               , zoom = 11 ) %>%
      addCircleMarkers( lng = as.numeric( cps.school.location.sy1718$long )
                        , lat = as.numeric( cps.school.location.sy1718$lat )
                        , color = "#10539A"
                        , opacity = 0.5
                        , fillOpacity = 0.5
                        , stroke = FALSE
                        , radius = 10
      ) 
  })
  
} # end of server

# run Shiny app
shinyApp( ui = ui, server = server )

