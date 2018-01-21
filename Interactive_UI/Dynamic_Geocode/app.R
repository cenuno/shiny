#
# Author:   Cristian E. Nuno
# Date:     January 14, 2018
# Purpose:  Dynamically Geocode an Address
#

## import necessary packages ##
library( ggmap )
library( magrittr )
library( leaflet)
library( shiny )

ui <- fluidPage(
  tags$head(
    tags$style(
      HTML(
        '
        .outer {
        position: fixed;
        top: 80px;
        left: 0;
        right: 0;
        bottom: 0;
        overflow: hidden;
        padding: 0;
        }
        
        #controls-filters {
        background-color: white;
        border:none;
        padding: 10px 10px 10px 10px;
        z-index:150;
        }
        '
      )
    )
  )
  , titlePanel( title = "Test App")
  , absolutePanel(
    id = "controls-filters"
    , class = "panel panel-default"
    , fixed = TRUE
    , draggable = TRUE
    , top = 100
    , left = "auto"
    , right = 20
    , bottom = "auto"
    , width = 330
    , height = "auto"
    , tags$script(' $(document).on("keydown", function (e) {
                                Shiny.onInputChange("lastkeypresscode", e.keyCode);
                                      });
                                      ')
    , textInput( inputId = "txt"
                 , label = NULL
                 , width = "400px"
                 , value = ""
                 , placeholder = "An address, location, or place"
                 )
    )
  , div(class = "outer", leafletOutput( outputId = "map"
                                        , height = 900
                                        )
        )
      )

server <- function(input, output) {
  
  # create leaflet map
  foundational.map <- shiny::reactive({
    leaflet( options = leafletOptions( zoomControl = FALSE, dragging = FALSE  ) ) %>%
    # add background to map
    addTiles( urlTemplate = "https://{s}.tile.openstreetmap.se/hydda/base/{z}/{x}/{y}.png" )
    
  })
  
  # display leaflet map
  output$map <- leaflet::renderLeaflet({
    foundational.map()
  })
  
  # observe keyboard event
  observe({
    # use user.txt() for geocoding
    if( !is.null( input$lastkeypresscode ) ){
      
      if( input$lastkeypresscode == 13 ){
          
        # geocode the address stored in input$txt
        txt2geocode <- suppressWarnings(
          ggmap::geocode( location = input$txt
                          , source = "google"
                          , output = "latlon"
                          , messaging = FALSE
          )
        )
          
          # only return a non NA coordinate pair
          if( is.na( txt2geocode$lon ) | is.na( txt2geocode$lat ) ){
            stop("The address failed to obtain a valid coordinate pair.\nEnsure spelling is correct and revise your search.")
          } else{
        
            # update the leaflet map
            leaflet::leafletProxy( mapId = "map" ) %>%
              
              # set zoom level
              # so that all 77 community areas can be seen when the
              # map is opened
              # Note: the lng/lat pair is northeast of Promontory Point
              # between West Pershing Rd and W 47th st
              setView( lng = txt2geocode$lon
                       , lat = txt2geocode$lon
                       , zoom = 10 ) %>%
              
              addMarkers( lng = txt2geocode$lon
                          , lat = txt2geocode$lon
                          , label = input$txt
              )
            
        } # end of if txt2geocode returns non NA coordinate pair
        
      } # only run when input$keylastpresscode is equal to 13
      
    } # only run when input$keylastpresscode is non null

  }) # end of observe({})
  
} # end of server
  
# Run app
shinyApp(ui, server)
