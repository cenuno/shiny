#
# Author:     Cristian E. Nuno
# Date:       January 20, 2018
# Purpose:    Change color and size of Cicle Marker as mouse hovers over it
#

# load necessary packages
library( leaflet )
library( shiny )


## make UI ##
ui <- shiny::fluidPage(
  title = "Test"
  , leaflet::leafletOutput( outputId = "myMap"
                            , height = 900
  )
  , theme = "dynamic_colors.css"
)

## make Server ##
server <- function( input, output){
  
  # render the map
  output$myMap <- leaflet::renderLeaflet({
    leaflet( options = leafletOptions( minZoom = 11 ) ) %>%
      addTiles( urlTemplate = "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_nolabels/{z}/{x}/{y}.png") %>%
      setView( lng = -87.655333
               , lat = 41.948438
               , zoom = 11 ) %>%
      addCircleMarkers( lng = c( -87.655333,  -87.633752)
                        , lat = c( 41.948438, 41.829902 )
                        , fillColor = "#10539A"
                        , fillOpacity = 0.75
                        , stroke = FALSE
                        , radius = 10 # units in meters for circles
      ) 
  })
  
  
} # end of server

# run Shiny app
shinyApp( ui = ui, server = server )

# end of script #
