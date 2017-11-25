#
# Author:   Cristian E. Nuno
# Date:     November 25, 2017
# Purpose:  Highlighting Polygons on a Leaflet map
#           based on a user-click. Clearing the highlights
#           with a Shiny action button.
#

# import necessary packages
library( shiny )
library( shinydashboard )
library( leaflet )
library( magrittr )

# import City of Chicago current community area boundaries
comarea606 <- readRDS( gzcon( url( "https://github.com/cenuno/shiny/raw/master/cps_locator/Data/raw-data/comarea606_raw.RDS" ) ) )

# create the UI
ui <- fluidPage(
  # place the contents inside a box
  shinydashboard::box(
    width = 12
    , title = "Click on the map!"
    # separate the box by a column
    , column(
      width = 2
      , shiny::actionButton( inputId = "clearHighlight"
                             , icon = icon( name = "eraser")
                             , label = "Clear the Map"
                             , style = "color: #fff; background-color: #D75453; border-color: #C73232"
      )
    )
    # separate the box by a column
    , column(
      width = 10
      , leaflet::leafletOutput( outputId = "myMap"
                                , height = 600
      )
    )
  ) # end of the box
) # end of fluid page

# create the server
server <- function( input, output, session ){
  
  # create foundational map
  foundational.map <- shiny::reactive({
    leaflet() %>%
      addTiles( urlTemplate = "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png") %>%
      setView( lng = -87.534256
               , lat = 41.941696
               , zoom = 11
      ) %>%
      addPolygons( data = comarea606
                   , fillOpacity = 0
                   , opacity = 0.2
                   , color = "#000000"
                   , weight = 2
                   , layerId = comarea606$community
                   , group = "click.list"
      )
  })
  
  output$myMap <- renderLeaflet({
    
    foundational.map()
    
  }) # end of leaflet::renderLeaflet({})
  
  # store the list of clicked polygons in a vector
  click.list <- shiny::reactiveValues( ids = vector() )
  
  # observe where the user clicks on the leaflet map
  # during the Shiny app session
  # Courtesy of two articles:
  # https://stackoverflow.com/questions/45953741/select-and-deselect-polylines-in-shiny-leaflet
  # https://rstudio.github.io/leaflet/shiny.html
  shiny::observeEvent( input$myMap_shape_click, {
    
    # store the click(s) over time
    click <- input$myMap_shape_click
    
    # store the polygon ids which are being clicked
    click.list$ids <- c( click.list$ids, click$id )
    
    # filter the spatial data frame
    # by only including polygons
    # which are stored in the click.list$ids object
    lines.of.interest <- comarea606[ which( comarea606$community %in% click.list$ids ) , ]
    
    # if statement
    if( is.null( click$id ) ){
      # check for required values, if true, then the issue
      # is "silent". See more at: ?req
      req( click$id )
      
    } else if( !click$id %in% lines.of.interest@data$id ){
      
      # call the leaflet proxy
      leaflet::leafletProxy( mapId = "myMap" ) %>%
        # and add the polygon lines
        # using the data stores from the lines.of.interest object
        addPolylines( data = lines.of.interest
                      , layerId = lines.of.interest@data$id
                      , color = "#6cb5bc"
                      , weight = 5
                      , opacity = 1
        ) 
      
    } # end of if else statement
    
  }) # end of shiny::observeEvent({})
  
  
  # Create the logic for the "Clear the map" action button
  # which will clear the map of all user-created highlights
  # and display a clean version of the leaflet map
  shiny::observeEvent( input$clearHighlight, {
    
    # recreate $myMap
    output$myMap <- leaflet::renderLeaflet({
      
      # first
      # set the reactive value of click.list$ids to NULL
      click.list$ids <- NULL
      
      # second
      # recall the foundational.map() object
      foundational.map()
      
    }) # end of re-rendering $myMap
    
  }) # end of clearHighlight action button logic
  
} # end of server

## run shinyApp ##
shiny::shinyApp( ui = ui, server = server)
