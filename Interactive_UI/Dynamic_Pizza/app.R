#
# Author:   Cristian E. Nuno
# Purpose:  Reproducible Example of Interactive UI for a Shiny App
# Date:     November 18, 2017
#

###############################
## Import Necessary Packages ##
###############################
library( shiny )              # Web Application Framework for R
library( shinydashboard )     # Create Dashboards with 'Shiny'
library( leaflet )            # Create Interactive Web Maps with the JavaScript 'Leaflet' Library
library( htmltools )          # Tools for HTML
library( htmlwidgets )        # HTML Widgets for R
library( dplyr )              # A Grammar of Data Manipulation
library( magrittr )           # Ceci n'est pas une pipe
library( DT )                 # A Wrapper of the JavaScript Library 'DataTables'
library( mapview )            # Interactive Viewing of Spatial Data in R
library( webshot )            # Take a screenshot of a URL
library( stringr )            # Simple, Consistent Wrappers for Common String Operations
##############################
## Create Reproducible Data ##
##############################

# Requirements:
# Must have coordinate pair
# Must be data showing different types
# Within each type, there must be different values.
#
#
# My example: pizza.
chicago.pizza <- data.frame( Pizzeria = c( rep( x = "Giordano's Pizzeria"
                                                , times = 2
                                                )
                                        , rep( x = "Lou Malnati's Pizzeria"
                                               , times = 2 
                                               )
                                        , rep( x = "Domino's Pizza"
                                               , times = 2
                                               )
                                        , rep( x = "Gino's East"
                                               , times = 2
                                               )
                                        )
                             , Website = c( "https://giordanos.com/locations/hyde-park/"
                                            , "https://giordanos.com/locations/mccormick-place-west-loop/"
                                            , "https://www.loumalnatis.com/chicago-river-north"
                                            , "https://www.loumalnatis.com/evanston"
                                            , "https://www.dominos.com/en/"
                                            , "https://www.dominos.com/en/"
                                            , "http://www.ginoseast.com/locations/river-north#home"
                                            , "http://www.ginoseast.com/locations/south-loop#home"
                                            )
                             , Phone = c( "773.947.0200"
                                          , "312.421.1221"
                                          , "312.828.9800"
                                          , "847.328.5400"
                                          , "312.644.7440"
                                          , "312.666.5900"
                                          , "312.988.4200"
                                          , "312.939.1818"
                                          )
                             , Full.Address = c( "5311 S Blackstone Ave, Chicago, IL 60615"
                                                 , "815 W Van Buren St #115, Chicago, IL 60607"
                                                 , "439 North Wells Street, Chicago, IL 60654"
                                                 , "1850 Sherman Avenue, Evanston, IL 60201"
                                                 , "143 W Division St, Chicago, IL 60610"
                                                 , "1234 Canal St, Chicago, IL 60607"
                                                 , "500 N LaSalle Dr, Chicago, IL 60654"
                                                 , "521 S Dearborn St, Chicago, IL 60605"
                                                 )
                             , Lat = c( 41.799115
                                        , 41.876448
                                        , 41.890344
                                        , 42.051465
                                        , 41.903763
                                        , 41.8662688
                                        , 41.891038
                                        , 41.875234
                                        )
                             , Lon = c( -87.590199
                                        , -87.647936
                                        , -87.633743
                                        , -87.682001
                                        , -87.633175
                                        , -87.6578169
                                        , -87.633104
                                        , -87.628985
                                        )
                             , Community_Area = c( "Hyde Park"
                                                   , "Near West Side"
                                                   , "Near North Side"
                                                   , NA
                                                   , "Near North Side"
                                                   , "Near West Side"
                                                   , "Near North Side"
                                                   , "Loop"
                                                   )
                             , Description = c( "Take a bite of Giordano’s pizzas and dishes and we think you’ll agree that you’ve gone to pizza heaven! Stop by our South Blackstone Avenue location and try us for yourself. Prefer eating at home? Order for pickup or delivery!"
                                                , "What better way to start a night at the United Center or end a trip to the UIC campus than with a trip to Giordano’s? Will a full bar, dining room and private room, we have your needs covered! Prefer eating in? Take advantage of convenient online ordering, and request pickup or delivery."
                                                , "Lou Malnati’s River North was the sixth Lou Malnati's Pizzeria to open and the first within the Chicago city limits. This location offers dine in, carryout, delivery, group ordering, and drop-off catering.  Inside features a full service bar and a cozy atmosphere.  During the warmer months, al fresco dining is an option.  We know there are many restaurants in River North to choose from, but if you head to Lou’s we promise you won’t be disappointed!"
                                                , "Nestled between the growing downtown Evanston district and illustrious Northwestern University, Lou’s in Evanston is a favorite of students and residents alike.  This location offers dine in, carryout, and delivery as well as catering services.  In the warmer months, outdoor seating is available."
                                                , "Delivery/carryout chain offering a wide range of pizza, plus chicken & other sides."
                                                , "Delivery/carryout chain offering a wide range of pizza, plus chicken & other sides."
                                                , "Gino’s East River North is home to Gino’s Brewing Company and offers signature craft brews that pair perfectly with our legendary deep dish pizza. And don’t forget to bring your markers and leave your mark on our 2nd floor graffiti zones! Gino’s East River North is also home to The Comedy Bar. Located on the 3rd floor, shows run Wednesday-Saturday. Buy advance tickets or ask your server for reservations."
                                                , "Gino’s East South Loop is located in the heart of the historic Printer's Row district, not far from museum campus."
                                                )
                             , Deep.Dish = c( rep( x = "The Special"
                                                   , times = 2
                                                   )
                                              , rep( x = "The Malnati Chicago Classic"
                                                     , times = 2
                                                     )
                                              , NA
                                              , NA
                                              , rep( x = "Meaty Legend"
                                                     , times = 2
                                                     )
                                              )
                             , Yelp.Rating = c( 2.5
                                                , 3.5
                                                , 4
                                                , 4 
                                                , 1.5
                                                , 2
                                                , 3.5
                                                , 3.5
                                                )
                             , stringsAsFactors = FALSE
                             ) # done creating chicago.pizza data frame
# check dim
dim( chicago.pizza ) # [1] 8 10

# check colnames
colnames( chicago.pizza )
# [1] "Pizzeria"       "Website"        "Phone"          "Full.Address"   "Lat"           
# [6] "Lon"            "Community_Area" "Description"    "Deep.Dish"      "Yelp.Rating"  

# import City of Chicago current community area boundaries
comarea606 <- readRDS( gzcon( url( "https://github.com/cenuno/shiny/raw/master/cps_locator/Data/raw-data/comarea606_raw.RDS" ) ) )

# create pizzaIcon
# Courtesy of Oleksiy, on SO, from September 20, 2017
# https://stackoverflow.com/questions/46286599/custom-markers-on-shiny-leaflet-map
pizzaIcon <- leaflet::iconList(
  gpIcon = leaflet::makeIcon(
    iconUrl = "https://giordanos.com/content/uploads/logo-red.png"
    , iconWidth = 96
    , iconHeight = 46
  )
  , lmIcon = leaflet::makeIcon(
    iconUrl = "https://www.loumalnatis.com/resources/assets/images/logo2x.png"
    , iconWidth = 96
    , iconHeight = 46
  )
  , dpIcon = leaflet::makeIcon(
    iconUrl = "http://diylogodesigns.com/blog/wp-content/uploads/2017/08/Dominos-Pizza-icon-logo-vector-png.png"
    , iconWidth = 66
    , iconHeight = 96
  )
  , geIcon = leaflet::makeIcon(
    iconUrl = "http://molisepr.com/blog/wp-content/uploads/2015/06/Ginos-East.jpg"
    , iconWidth = 96
    , iconHeight = 46
  )
) # end of iconList

# make icon data frame
chicago.pizza <- chicago.pizza %>%
  mutate( iconType = c( "gpIcon"
                        , "gpIcon"
                        , "lmIcon"
                        , "lmIcon"
                        , "dpIcon"
                        , "dpIcon"
                        , "geIcon"
                        , "geIcon"
                        )
          )
# check dim
dim( chicago.pizza ) # [1]  8 11

# check colnames
colnames( chicago.pizza ) 
# [1] "Pizzeria"       "Website"        "Phone"          "Full.Address"  
# [5] "Lat"            "Lon"            "Community_Area" "Description"   
# [9] "Deep.Dish"      "Yelp.Rating"    "iconType"   


###################################
## build a basic shiny dashboard ##
###################################

############ Building the Dashboard##################

# A dashboard has 2 parts: a user-interface (ui) and a server

# The UI consists of a header, a sidebar, and a body.

# The server consists of functions that produce any objects
# that are called inside the UI

## customize header ##
header <- dashboardHeader( title = "Exploring a Few Chicago Pizzerias"
                           , titleWidth = "325" # The width of the title area. This must either be a number which specifies the width in pixels, or a string that specifies the width in CSS units.
                           ,  tags$li( a( href = "https://cenuno.github.io/"
                                               , img( src = "https://github.com/cenuno/Spatial_Visualizations/raw/master/Images/UrbanDataScience_logo_2017-08-26.png"
                                                      , title = "Urban Data Science (GitHub)"
                                                      , height = "30px"
                                               )
                                               , style = "padding-top:10px; padding-bottom:10px;"
                           )
                           , class = "dropdown"
                           ) # end of Urban Data Science Logo
) # end of header

## customize sidebar
sidebar <- dashboardSidebar(
  
  # initialize sidebar Menu
  sidebarMenu(
    menuItem( text = "Home"
              , tabName = "Home"
              , icon = icon("home")
    ) # end of menuItem
    
  ) # end of sidebar Menu
  
  , collapsed = TRUE
  
) # end of sidebar customization

## customize body ##
body <- dashboardBody( 
  
  # Add some custom CSS to make the title background area the same
  # color as the rest of the header.
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "dynamic_pizza.css")
  )
  
  , fluidRow( 
    box( title = NULL
         , status = "info"
         , solidHeader = TRUE
         , collapsible = FALSE
         , width = 12
         
         # create first column
         , column(
           width = 2
           
           # Name the section
           , shiny::h1( "Geography Preference")
           
           # create a paragraph break
           , shiny::p()
           
           # Give click instructions
           , shiny::h3( "Click Map to Highlight")
           
           # start community area user-click DataTable output
           , DT::dataTableOutput( outputId = "ccaDT" )
           
           # add a paragraph break
           , shiny::p()
           
           # start clear highlights button
           , shiny::actionButton( inputId = "clearHighlight"
                                  , icon = icon( name = "eraser" )
                                  , label = "Clear Map of Highlights"
                                  , style = "font-size: 19px;
                                  height: 50px;
                                  width: 100%; 
                                  color: #FFFFFF; 
                                  background-color: #FC9CB0; 
                                  border-color: #FC9CB0"
                                  )
           
           
           # add horizontal line
           , shiny::hr()
           
           # name the section
           , shiny::h1("Pizza Preference")
           
           # add a paragraph break
           , shiny::p()
           
           # start drop down pizzeriaType menu
           , shiny::selectizeInput( inputId = "pizzeriaType"
                                    , label = shiny::h3( "Select Your Favorite Pizzeria:" ) 
                                    , choices = c("All"
                                                  , sort( unique( chicago.pizza$Pizzeria ) )
                                                  )
                                    , selected = "All"
                                  ) # end of drop down pizerriaType menu
           
           # create placeholder for second widget
           , shiny::uiOutput( outputId = "yelp" )
           
           # add a paragraph break
           , shiny::p()
           
           # create placeholder for export leaflet map widget
           , shiny::downloadButton( outputId = "downloadMap"
                                  , icon = icon( name = "camera-retro" )
                                  , label = "Download Map"
                                  , style = "font-size: 19px;
                                  text-align: center;
                                  align-content: center;
                                  height: 50px;
                                  width: 100%; 
                                  color: #FFFFFF; 
                                  background-color: #C2D7AF; 
                                  border-color: #C2D7AF"
                                  )

         ) # end of first column
         
         # create placeholder for leaflet map
         , column(
           width = 10
           , leaflet::leafletOutput( outputId = "chicagoPizzaMap"
                                     , height = 800
                                     )
         ) # end of second column
    ) # end of box 1
  ) # end of fluidRow1
  
  , fluidRow(
    box( title = "View the Data"
      , status = "info"
      , solidHeader = TRUE
      , collapsible = FALSE
      , width = 12
      , DT::dataTableOutput( outputId = "pizzaDT" )
    ) # end of box 2
  ) # end of fluidRow2
  ) # end of dashboard body

## Shiny UI ##
ui <- dashboardPage(
  header
  , sidebar
  , body
)

# Define server logic
server <- function(input, output, session) {
  
  
  # create reactive data frame
  datasetInput <- shiny::reactive({
    
    # if 'All' is selected for 
    # input$pizzeriaType
    # add all pizzerias onto map
    # by keeping the original data frame intact
    if( input$pizzeriaType == "All" ){
      
      # return chicago.pizza to the Global Environment
      return( chicago.pizza )
      
      # if input$pizzeriaType is anything but 'All'
      # and input$yelpRating is NULL
      } else if( input$pizzeriaType != "All" & is.null( input$yelpRating ) ) {
        # make sure requirements are met
        # Courtesy of RStudio Shiny
        # http://shiny.rstudio.com/articles/req.html
        req( input$yelpRating )
        
      # if 'All' is  NOT selected for 
      # input$pizzeriaType but 
      # 'All" is selected for input$yelpRating
      # filter original data frame
      # to only include certain pizzerias
    } else if( input$pizzeriaType != "All" & input$yelpRating == "All" ){
      
      # subset chicago.pizza
      # so that it only includes rows
      # whose $Pizzeria column contains the 
      # value based on input$pizzeriaType
      chicago.pizza <- chicago.pizza[ which(
        chicago.pizza$Pizzeria %in% input$pizzeriaType
      ) , ]
      
      # return the subset of chicago.pizza to the
      # Global Environment
      return( chicago.pizza )
      
      # if 'All' is  NOT selected for both
      # input$pizzeriaType and input$yelpRating
      # filter original data frame
      # to only include certain pizzerias
    } else if( input$pizzeriaType != "All" & input$yelpRating != "All" ){
      
      # subset the chicago.pizza df
      # to include rows whose $Pizzeria column
      # is equal to the input$pizzeriaType and
      # whose $Yelp.Rating is equal to to the
      # input$yelpRating
      chicago.pizza <- chicago.pizza[ which(
        chicago.pizza$Pizzeria %in% input$pizzeriaType &
          chicago.pizza$Yelp.Rating %in% input$yelpRating
      ) , ]
      
      # return the subset of chicago.pizza
      # the Global Environment
      return( chicago.pizza )
    } # end of if else statement
  })
  
  
  
  # create a second UI filter
  # only when the user selects a 
  # a specific pizzeria.
  # This second filter "disappears" whenever
  # the user selects the "All" choice.
    output$yelp <- shiny::renderUI({
      if( input$pizzeriaType != "All" ){
        
      shiny::selectizeInput( inputId = "yelpRating"
                             , label = shiny::h3( 
                               paste0( "Which "
                                       , input$pizzeriaType
                                       , " has a better Yelp Rating?"
                                       ) # make text dynamic
                             ) # end of label
                             , choices = c( "All"
                                            , sort( unique( chicago.pizza$Yelp.Rating[
                                              which( chicago.pizza$Pizzeria %in% input$pizzeriaType )
                                              ] ) ) 
                             )
                             , selected = "All"
                             # , multiple = TRUE
      ) # end of Yelp Rating menu
      }
    })
    
    # Create foundational leaflet map
    # and store it as a reactive expression
    foundational.map <- shiny::reactive({
      leaflet() %>%
        # set zoom level
        # so that all 77 community areas can be seen when the
        # map is opened
        # Note: the lng/lat pair is northeast of Promontory Point
        # between West Pershing Rd and W 47th st
        setView( lng = -87.567215
                 , lat = 41.822582
                 , zoom = 11
        ) %>%
        
        # add background to map
        addTiles( urlTemplate = "https://{s}.tile.openstreetmap.se/hydda/base/{z}/{x}/{y}.png" ) %>%
        
        # add zoom out button
        addEasyButton( easyButton(
          icon = "ion-android-globe", title = "Zoom Back Out"
          , onClick = leaflet::JS("function(btn, map){ map.setZoom(11); }")
        ) ) %>%
        
        # add polygon to map
        addPolygons( data = comarea606
                     , fillOpacity = 0
                     , opacity = 0.8
                     , color = "#ED7B46" # orange colored polygons
                     , weight = 3
                     , layerId = comarea606$community
                     , group = "click.list"
                     , label = str_to_title( comarea606@data$community )
                     , labelOptions = popupOptions( textsize = "25px"
                                                    , textOnly = TRUE
                                                    , style = list(
                                                      "color" = "#000000" # 
                                                      , "font-family" = "Ostrich Sans Black black"
                                                      , "font-weight" =  "bold"
                                                    )
                     )
                     , highlightOptions = highlightOptions( color = "#161F48"
                                                            , weight = 10
                                                            , opacity = 0.2 # make the hover light so that the label is still readable
                     )
        )
      
    }) # end of foundational leaflet map

  # render leaflet output
  output$chicagoPizzaMap <- leaflet::renderLeaflet({
    
    # call reactive map
    foundational.map()
      
  }) # end of render leaflet
  
  
  # store the list of clicked polygons in a vector
  click.list <- shiny::reactiveValues( ids = vector() )
  
  # observe where the user clicks on the leaflet map
  # during the Shiny app session
  # Courtesy of two articles:
  # https://stackoverflow.com/questions/45953741/select-and-deselect-polylines-in-shiny-leaflet
  # https://rstudio.github.io/leaflet/shiny.html
  shiny::observeEvent( input$chicagoPizzaMap_shape_click, {
    
    # store the click(s) over time
    click <- input$chicagoPizzaMap_shape_click
    
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
      leaflet::leafletProxy( mapId = "chicagoPizzaMap" ) %>%
        # and add the polygon lines
        # using the data stored from the lines.of.interest object
        addPolylines( data = lines.of.interest
                      , color = "#161F48"
                      , weight = 5
                      , opacity = 1
        ) 
      
      # create the cca DataTable output
      output$ccaDT <- DT::renderDataTable({
        
        # transform $community from UPPERCASE
        # to Title Case using the `stringr` package
        lines.of.interest@data$community <- 
          stringr::str_to_title( string = 
                                   lines.of.interest@data$community
                                 )
        
        # create the datatable
        datatable( data = lines.of.interest@data[ c( "community"
                                                      , "area_numbe"
                                                      )
                                                    ] # limit the df to only two columns
                   , rownames = FALSE
                   , caption = "Table 1. Community Areas of Interest"
                   , colnames = c( "Community Area Name"
                                     , "Community Area Number"
                                     )
                   , extensions = "Buttons"
                   , options = list( 
                     autoWidth = TRUE
                     , dom = "Blfrtip" # customize the download button so that the "Show X entries" button remains, https://github.com/cenuno/shiny/tree/master/DT-Download-All-Rows-Button#customizing-dt-download-button
                     , searching = FALSE # disable the search box, courtesy of https://shiny.rstudio.com/gallery/datatables-options.html
                     , paging = FALSE # disable pagination, courtesy of https://shiny.rstudio.com/gallery/datatables-options.html
                     , buttons = list(
                       list( extend = "collection"
                             , buttons = c( "csv"
                                            , "pdf"
                             )
                             , text = "Download Community Area Info"
                       ) # end of download button
                     ) # end of buttons customization
                    
                     
                     # set to TRUE to configure the table to automatically fill it's containing element.
                     , fillContainer = TRUE
  
                     # enable vertical scrolling to freeze number of observable rows
                     , scrollY = "100px"
                     
                   ) # end of options customization
                   
        ) # end of DT creation
        
      }) # end of rendering DT
      
    } # end of if else statement
    
  }) # end of shiny::observeEvent({})
  
  
  # function with all the features that we want to add to the map
  AddDynamicFeatures <- function( map.object ){
    
    # make north compass icon
    northArrowIcon <- "<img src='http://ian.umces.edu/imagelibrary/albums/userpics/10002/normal_ian-symbol-north-arrow-2.png' style='width:40px;height:60px;'>"
    
    # make custom map title
    mapTitle <- paste0(
      "<p style='color:#ED7B46; font-size:20px;'>"
      , "Exploring "
      , paste( unique( datasetInput()$Pizzeria )
               , collapse = ", "
      )
      , "</p>"
    )
    
    # initialize map object here 
    map.object %>%
      
      # clear all background markers
      clearControls() %>%
      
      # clear all markers
      clearMarkers() %>%
      
      # add pizza markers
      addMarkers( data = datasetInput()
                  , lng = ~Lon
                  , lat = ~Lat
                  , icon = ~pizzaIcon[ datasetInput()$iconType ]
      ) %>%
      
      # add custom title
      addControl( html = mapTitle
                  , position = "topright"
      ) %>%
      
      # add north arrow marker
      addControl( html = northArrowIcon
                  , position = "bottomright"
      )
    
  } # end of add dynamic features
  
  # create a reactive observer
  shiny::observe({
    
    # which sends commands to a Leaflet instance in a shiny app
    # that customizes the foundational Leaflet map
    # based on user input
    leafletProxy( mapId = "chicagoPizzaMap" ) %>%
      
      # by adding dynamic features, conveniently stored in 
      # the `AddDynamicFeatures()` function
      # where "chicagoPizzaMap" is the map.object 
      AddDynamicFeatures()
    
  })
  
  # Create the logic for the "Clear the map" action button
  # which will clear the map of all user-created highlights
  # and display a clean version of the leaflet map
  shiny::observeEvent( input$clearHighlight, {
    
    # recreate $chicagoPizzaMap
    output$chicagoPizzaMap <- leaflet::renderLeaflet({
      
      # first
      # set the reactive value of click.list$ids to NULL
      click.list$ids <- NULL
      
      # second
      # recall the foundational.map() object
      foundational.map() %>%
        
        # by adding dynamic features, conveniently stored in 
        # the `AddDynamicFeatures()` function
        # where "chicagoPizzaMap" is the map.object 
        AddDynamicFeatures()
      
    }) # end of re-rendering $chicagoPizzaMap
    
    # undo the output$ccaDT
    output$ccaDT <- renderDataTable({})
    
  }) # end of clearHighlight action button logic
  
  # store the current user-created version
  # of the Leaflet map for download in 
  # a reactive expression
  # Courtesy of Davide, SO June 2, 2016:
  # https://stackoverflow.com/questions/35384258/save-leaflet-map-in-shiny?noredirect=1&lq=1
  # Courtesy of SBista, SO May 30, 2017:
  # https://stackoverflow.com/questions/44259716/how-to-save-a-leaflet-map-in-shiny/44261618#44261618
  user.created.map <- reactive({
    # we need to specify coordinates (and zoom level) that we are currently viewing
    bounds <- input$chicagoPizzaMap_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    # call the foundational Leaflet map
    foundational.map() %>%
      
      # add the dynamic features based on UI
      AddDynamicFeatures() %>%
          
          # store the view based on UI
          setView( lng = ( lngRng[1] + lngRng[2] ) / 2
                   ,  lat = ( latRng[1] + latRng[2] ) / 2
                   , zoom = input$chicagoPizzaMap_zoom
          ) %>%
          
          # and add the polygon lines
          # by filting comarea606 by those $community values
          # which appear in click.list$ids
          addPolylines( data = comarea606[ which( comarea606$community %in% click.list$ids ) , ]
                        , color = "#161F48"
                        , weight = 5
                        , opacity = 1
          ) 
        

  }) # end of storing user created map
  
  
  output$downloadMap <- downloadHandler(
    # A string of the filename, including extension,
    # that the user's web browser should default to
    # when downloading the file;
    # or a function that returns such a string.
    filename = paste0( Sys.Date()
             , "_ChicagoPizza"
             , ".pdf"
             )

    # A function that takes a single argument file
    # that is a file path (string) of a nonexistent temp file,
    # and writes the content to that file path.
    , content = function( file ) {

      # temporarily switch to the temp dir, in case you do not have write
      # permission to the current working directory
      owd <- setwd( tempdir() )
      on.exit( setwd( owd ) )
      
      shiny::observe( input$chicagoPizzaMap_shape_click,{
        # using mapshot to save leaflet map as a PDF
        mapshot( x = user.created.map()
                 , file = file
                 , cliprect = "viewport" # the clipping rectangle matches the height & width from the viewing port
                 , selfcontained = FALSE # when this was not specified, the function for produced a PDF of two pages: one of the leaflet map, the other a blank page.
        )
      })

      
      # these two functions, when used together
      # also worked to produce a PDF output of the leaflet map
      # using saveWidget and webshot (old)
      # htmlwidgets::saveWidget( widget = user.created.map()
      #                          , file = "temp.html"
      #                          , selfcontained = FALSE
      #                          )
      # webshot::webshot( url = "temp.html"
      #                   , file = file
      #                   , cliprect = "viewport"
      #                   )
      
    }
    
  ) # end of downloadHandler
  
  # Create an HTML table widget using
  # the DataTables library
  # and allows for the user to download the data
  output$pizzaDT <- DT::renderDataTable({
    
      DT::datatable( data = datasetInput() # reactive data changes based on UI
                     , extensions = 'Buttons'
                     , caption = "Table 2. Sample of Chicago Pizzerias"
                     , options = list( 
                       autoWidth = TRUE
                       , paging = FALSE # disable pagination, courtesy of https://shiny.rstudio.com/gallery/datatables-options.html
                       , dom = "Blfrtip"
                       , buttons = list(
                         list( extend = "collection"
                               , buttons = c( "csv"
                                              , "pdf"
                                              )
                               , text = "Download Chicago Pizza"
                               ) # end of download button
                      ) # end of buttons customization
                       
                     # customize the length menu
                     , lengthMenu = list( c(10, -1) # declare values
                                          , c("10", "All" ) # declare titles
                     ) # end of lengthMenu customization
                     
                     # enable horizontal scrolling due to many columns
                     , scrollX = TRUE
                     
                     ) # end of options customization
                     
      ) # end of DT creation
      
  }) # end of render DT
  
} # end of server

## run shinyApp ##
shiny::shinyApp( ui = ui, server = server)

## end of shinyApp ##
