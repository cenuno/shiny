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
# Here in Chicago, I love Lou Malnati's deep dish pizza. 
# But some prefer Giordano's. 
# I'm going to make reproducible data showing
# Two Lou Malnati's locations and two Giordano's locations. 
# Then, I'll show a sample of their different menu options.
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
                                        , 41.9010214
                                        , 41.8662688
                                        , 41.8910349
                                        , 41.875234
                                        )
                             , Lon = c( -87.590199
                                        , -87.647936
                                        , -87.633743
                                        , -87.682001
                                        , -87.6503791
                                        , -87.6578169
                                        , -87.6506138
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
                             # , logoIcon = as.list( icons(  leaflet::makeIcon( iconUrl = "https://giordanos.com/content/uploads/logo-red.png"
                             #                                         , iconWidth = 96
                             #                                         , iconHeight = 46
                             #                                         , iconAnchorX = 76
                             #                                         , iconAnchorY = 45
                             # )
                             # , leaflet::makeIcon( iconUrl = "https://giordanos.com/content/uploads/logo-red.png"
                             #                      , iconWidth = 96
                             #                      , iconHeight = 46
                             #                      , iconAnchorX = 76
                             #                      , iconAnchorY = 45
                             # )
                             # , leaflet::makeIcon( iconUrl = "https://www.loumalnatis.com/resources/assets/images/logo2x.png"
                             #                      , iconWidth = 96
                             #                      , iconHeight = 46
                             #                      , iconAnchorX = 76
                             #                      , iconAnchorY = 45
                             # )
                             # , leaflet::makeIcon( iconUrl = "http://diylogodesigns.com/blog/wp-content/uploads/2017/08/Dominos-Pizza-icon-logo-vector-png.png"
                             #                      , iconWidth = 96
                             #                      , iconHeight = 46
                             #                      , iconAnchorX = 76
                             #                      , iconAnchorY = 45
                             # )
                             # , leaflet::makeIcon( iconUrl = "http://molisepr.com/blog/wp-content/uploads/2015/06/Ginos-East.jpg"
                             #                      , iconWidth = 96
                             #                      , iconHeight = 46
                             #                      , iconAnchorX = 76
                             #                      , iconAnchorY = 45
                             # )
                             # ) )
                             , stringsAsFactors = FALSE
                             ) # done creating chicago.pizza data frame
# check dim
dim( chicago.pizza ) # [1] 8 10

# check colnames
colnames( chicago.pizza )
# [1] "Pizzeria"       "Website"        "Phone"          "Full.Address"   "Lat"           
# [6] "Lon"            "Community_Area" "Description"    "Deep.Dish"      "Yelp.Rating"  

###################################
## build a basic shiny dashboard ##
###################################

############ Building the Dashboard##################

# A dashboard has 2 parts: a user-interface (ui) and a server

# The UI consists of a header, a sidebar, and a body.

# The server consists of functions that produce any objects
# that are called inside the UI

## customize header ##
header <- dashboardHeader( title = "Chicago Deep Dish"
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
  fluidRow( 
    box( title = "Battle of Two Pizzerias: Giordano's v. Lou Malnati's"
         , status = "info"
         , solidHeader = TRUE
         , collapsible = FALSE
         , width = 12
         
         # create first column
         , column(
           width = 2
           
           # start drop down pizzeriaType menu
           , shiny::selectizeInput( inputId = "pizzeriaType"
                                    , label = shiny::h3( "Select Your Favorite Pizzeria:" ) 
                                    , choices = c("All"
                                                  , sort( unique( chicago.pizza$Pizzeria ) ) 
                                    )
                                    , selected = "All"
                                    #, multiple = TRUE
           ) # end of drop down pizerriaType menu
           
           # create placeholder for second widget
           , shiny::uiOutput( outputId = "yelpFly" )
           
           # create placeholder for export leaflet map widget
           # , shiny::downloadButton( outputId = "downloadMap"
           #                          , "Download Map"
           #                          )
           
         ) # end of first column
         
         # create placeholder for leaflet map
         , column(
           width = 10
           , leaflet::leafletOutput( outputId = "myMap"
                                     , height = 600
                                     )
           
           # add a placeholder for the map to change dynamically
           , shiny::plotOutput( outputId = "dynamicMap"
                                , height = 3
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
      , DT::dataTableOutput( outputId = "myDT" )
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
  datasetInput <- reactive({
    
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
        # return NULL to the Global Environment
        return( NULL )
        
      
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
  
  
  # create widget on the fly
    output$yelpFly <- shiny::renderUI({
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
    

  # render leaflet output
  output$myMap <- leaflet::renderLeaflet({
    
    leaflet( data = "myMap" ) %>%
            # set zoom level
            setView( lng = -87.651304
                     , lat = 41.921438
                     , zoom = 11
            ) %>%

            # add background to map
            # addProviderTiles( providers$Hydda.Base ) %>%
            addTiles( urlTemplate = "https://{s}.tile.openstreetmap.se/hydda/full/{z}/{x}/{y}.png" ) %>%

            # add zoom out button
            addEasyButton( easyButton(
              icon = "ion-android-globe", title = "Zoom Back Out"
              , onClick = leaflet::JS("function(btn, map){ map.setZoom(11); }")
            ) ) 
      
  }) # end of render leaflet
  
  # create dynamic parts of map
  output$dynamicMap <- shiny::renderPlot({
    
    # make north compass icon
    northArrowIcon <- "<img src='http://ian.umces.edu/imagelibrary/albums/userpics/10002/normal_ian-symbol-north-arrow-2.png' style='width:40px;height:60px;'>"
    
      # if 'All' is selected for
      # both input$pizzeriaType
      # add all pizzerias onto map
      if( input$pizzeriaType == "All" ){

          # make pizzeria marker
          pizzaIcon <- leaflet::makeIcon(
            iconUrl = ifelse( test = chicago.pizza$Pizzeria %in% "Giordano's Pizzeria"
                              , yes = "https://github.com/cenuno/shiny/raw/master/Images/Pizza_Logos/giordanos_logo.png"
                              , no = "https://github.com/cenuno/shiny/raw/master/Images/Pizza_Logos/lm_logo.png"
            )
            , iconWidth = 96
            , iconHeight = 46
            , iconAnchorX = 76
            , iconAnchorY = 45
          )

          # make custom map title
          mapTitle <- paste0(
            "<p style='color:#ed7b46; font-size:15px;'>"
            , "Exploring "
            , paste( unique( datasetInput()$Pizzeria )
                     , collapse = " & "
                     )
            , ", 2017"
            , "</p>"
            )
    
    # call the baseline leaflet map
    leaflet::leafletProxy( mapId = "myMap" ) %>%
      
      # clear all background markers
      clearControls() %>%
      
      # clear all markers
      clearMarkers() %>%
      
      # add pizza markers
      addMarkers( data = datasetInput()
                  , lng = ~Lon
                  , lat = ~Lat
                  , icon = pizzaIcon
                  ) %>%
      
      # add custom title
      addControl( html = mapTitle
                  , position = "topright"
      ) %>%
      
      # add north arrow marker
      addControl( html = northArrowIcon
                  , position = "bottomright"
                  )
    # if input$pizzeriaType is anything but 'All'
    # and input$yelpRating is NULL
      } else if( input$pizzeriaType != "All" & is.null( input$yelpRating ) ) {
        # return NULL to the Global Environment
        return( NULL )
    
    } else if( input$pizzeriaType != "All" & input$yelpRating == "All" ){

          # make pizzeria marker
          pizzaIcon <- leaflet::makeIcon(
            iconUrl = ifelse( test = chicago.pizza$Pizzeria[
              which( chicago.pizza$Pizzeria %in% input$pizzeriaType )
            ] %in% "Giordano's Pizzeria"
                              , yes = "https://github.com/cenuno/shiny/raw/master/Images/Pizza_Logos/giordanos_logo.png"
                              , no = "https://github.com/cenuno/shiny/raw/master/Images/Pizza_Logos/lm_logo.png"
            )
            , iconWidth = 96
            , iconHeight = 46
            , iconAnchorX = 76
            , iconAnchorY = 45
          )

          # make custom map title
          mapTitle <- paste0(
            "<p style='color:#ed7b46; font-size:15px;'>"
            , "Exploring "
            , unique( datasetInput()$Pizzeria )
            , ", 2017"
            , "</p>"
          )
          
          # call the baseline leaflet map
          leaflet::leafletProxy( mapId = "myMap" ) %>%
            
            # clear all background markers
            clearControls() %>%
            
            # clear all markers
            clearMarkers() %>%
            
            # add pizza markers
            addMarkers( data = datasetInput()
                        , lng = ~Lon
                        , lat = ~Lat
                        , icon = pizzaIcon
            ) %>%
            
            # add custom title
            addControl( html = mapTitle
                        , position = "topright"
            ) %>%
            
            # add north arrow marker
            addControl( html = northArrowIcon
                        , position = "bottomright"
            )
          
          } else if( input$pizzeriaType != "All" & input$yelpRating != "All" ){

                # make pizzeria marker
                pizzaIcon <- leaflet::makeIcon(
                  iconUrl = ifelse( test = chicago.pizza$Pizzeria[
                    which( chicago.pizza$Pizzeria %in% input$pizzeriaType )
                    ] %in% "Giordano's Pizzeria"
                    , yes = "https://github.com/cenuno/shiny/raw/master/Images/Pizza_Logos/giordanos_logo.png"
                    , no = "https://github.com/cenuno/shiny/raw/master/Images/Pizza_Logos/lm_logo.png"
                  )
                  , iconWidth = 96
                  , iconHeight = 46
                  , iconAnchorX = 76
                  , iconAnchorY = 45
                )

                # make custom map title
                mapTitle <- paste0(
                  "<p style='color:#ed7b46; font-size:15px;'>"
                  , "Exploring "
                  , unique( datasetInput()$Pizzeria )
                  , ", 2017"
                  , "</p>"
                )
                
                # call the baseline leaflet map
                leaflet::leafletProxy( mapId = "myMap" ) %>%
                  
                  # clear all background markers
                  clearControls() %>%
                  
                  # clear all markers
                  clearMarkers() %>%
                  
                  # add pizza markers
                  addMarkers( data = datasetInput()
                              , lng = ~Lon
                              , lat = ~Lat
                              , icon = pizzaIcon
                  ) %>%
                  
                  # add custom title
                  addControl( html = mapTitle
                              , position = "topright"
                  ) %>%
                  
                  # add north arrow marker
                  addControl( html = northArrowIcon
                              , position = "bottomright"
                  )
          } # end of if else statements
    
  }) # end of dynamicMap

  
  # make DT
  output$myDT <- DT::renderDataTable({
    
      
    # if pizzeriaType is All
    if( input$pizzeriaType == "All" ){
      DT::datatable( data = datasetInput()
                     , extensions = 'Buttons'
                     , options = list( 
                       autoWidth = TRUE
                       , dom = "Blfrtip"
                       , buttons = list( 
                         "copy"
                         , list( extend = "collection"
                                 , buttons = c( "csv"
                                                , "excel"
                                                , "pdf"
                                 )
                                 , text = "Download"
                         ) # end of download button
                       ) # end of buttons customization
                       
                       # customize the length menu
                       , lengthMenu = list( c(5, 100, -1) # declare values
                                            , c(5, 100, "All") # declare titles
                       ) # end of lengthMenu customization
                       
                       # enable horizontal scrolling due to many columns
                       , scrollX = TRUE
                       
                     ) # end of options
                     ) # end of DT creation
      
      # if input$pizzeriaType is anything but "All"
      # and
      # input$yelpRating is NULL
    } else if( input$pizzeriaType != "All" & is.null( input$yelpRating ) ) {
      # return NULL to the Global Environment
      return( NULL )
      
    } else if( input$pizzeriaType != "All" & input$yelpRating == "All" ){
      DT::datatable( data = datasetInput()
        , extensions = 'Buttons'
        , options = list( 
          autoWidth = TRUE
          , dom = "Blfrtip"
          , buttons = list( 
            "copy"
            , list( extend = "collection"
                    , buttons = c( "csv"
                                   , "excel"
                                   , "pdf"
                    )
                    , text = "Download"
            ) # end of download button
          ) # end of buttons customization
          
          # customize the length menu
          , lengthMenu = list( c(5, 100, -1) # declare values
                               , c(5, 100, "All") # declare titles
          ) # end of lengthMenu customization
          
          # enable horizontal scrolling due to many columns
          , scrollX = TRUE
          
        ) # end of options
        ) # end of DT creation
    } else if( input$pizzeriaType != "All" & input$yelpRating != "All" ){
      DT::datatable( data = datasetInput() 
        , extensions = 'Buttons'
        , options = list( 
          autoWidth = TRUE
          , dom = "Blfrtip"
          , buttons = list( 
            "copy"
            , list( extend = "collection"
                    , buttons = c( "csv"
                                   , "excel"
                                   , "pdf"
                    )
                    , text = "Download"
            ) # end of download button
          ) # end of buttons customization
          
          # customize the length menu
          , lengthMenu = list( c(5, 100, -1) # declare values
                               , c(5, 100, "All") # declare titles
          ) # end of lengthMenu customization
          
          # enable horizontal scrolling due to many columns
          , scrollX = TRUE
          
        ) # end of options
        ) # end of DT creation
    } # end of if else statements
  }) # end of render DT
        
  
} # end of server

## run shinyApp ##
shiny::shinyApp( ui = ui, server = server)





