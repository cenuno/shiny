# Import necessary packages
library( bitops )
library( RCurl )
library( shiny )
library( shinydashboard )
library( DT )
library( data.table )
library( leaflet )
library( dplyr )
library( magrittr )
library( htmltools )
library( htmlwidgets )
library( sp )
library( rgdal )
library( splancs )
library( stringr )
library( rgeos )

# import necessary function

# run code from GitHub function
source_github <- function( url ) {
  # load package
  require(RCurl)
  
  # read script lines from website and evaluate
  # leaving all evaluated objects in the 
  # global environment
  script <- getURL( url, ssl.verifypeer = FALSE)
  eval( parse( text = script )
        , envir = .GlobalEnv 
  )
} # end of source_github function

# store raw url of DesiredValue function
rawDesiredValue_url <- "https://raw.githubusercontent.com/cenuno/shiny/master/cps_locator/Functions/DesiredValue.R"

# call function from GitHub
source_github( url = rawDesiredValue_url )



################## Pre work ######################
#### Time to Import Processed CPS SY1617 and  ####
#### Raw Chicago Community Area Boundary Data ####
##################################################

# Import cps_sy1617_processed.RDS from the /Data/processed-data folder
cps_sy1617_Processed_RDS_url <- "https://github.com/cenuno/shiny/blob/master/cps_locator/Data/processed-data/cps_sy1617_processed.RDS?raw=true"
cps_sy1617 <- readRDS( gzcon( url( cps_sy1617_Processed_RDS_url ) ) )

# store SeparateCSV.R function url
rawSeparateCSV_url <- "https://raw.githubusercontent.com/cenuno/shiny/master/cps_locator/Functions/SeparateCSV.R"

# call from github
source_github( url = rawSeparateCSV_url )

cps_sy1617$Separated_El <- SeparateCSV( csv.column = cps_sy1617$Transportation_El )


# Import comarea606_raw.RDS from the /Data/raw-data folder
comarea606Raw_RDS_url <- "https://github.com/cenuno/shiny/blob/master/cps_locator/Data/raw-data/comarea606_raw.RDS?raw=true"
comarea606 <- readRDS( gzcon( url( comarea606Raw_RDS_url ) ) )

SearchDataFrame <- function( a.data.frame, search.term) {
  # this function was designed by
  # Holger Brandi, a Stack Overflow user (https://stackoverflow.com/users/590437/holger-brandl)
  # who shared it on November 14, 2016 here: https://stackoverflow.com/questions/17288222/r-find-value-in-multiple-data-frame-columns
  # Thank you, Holger, for sharing your work!
  
  # require the dplyr package to filter a.data.frame
  require(dplyr)
  # require the stringr package to find text in a a.data.frame
  require(stringr)
  
  # applying a function over every row to determine
  # which identifies rows
  # that contain "some.text"
  apply( X = a.data.frame
         , MARGIN = 1
         , FUN = function( some.text ) {
           any( str_detect( string = as.character( some.text )
                            , pattern = fixed( search.term
                                               , ignore_case = TRUE
                            )
           )
           )
         }
  ) %>% 
    # now we filter a.data.frame 
    # by those rows which contain "some.text"
    dplyr::filter( a.data.frame, . )
  
}

# Define UI for dataset viewer app ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Reactivity"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Text for providing a caption ----
      # Note: Changes made to the caption in the textInput control
      # are updated in the output area immediately as you type
      shiny::textInput(inputId = "globalSearch",
                label = "Global Search:",
                value = NULL
                ),
      
      # Input: Selector for choosing dataset ----
      shiny::selectInput(inputId = "cca",
                  label = "Choose a community area:",
                  choices = c( "Citywide"
                               , sort( unique( cps_sy1617$Community_Area ) )
                               )
      )
      
      # start drop down gradesOffered menu
      , shiny::selectizeInput( inputId = "gradesOffered"
                               , label = shiny::h3( "Filter Schools by Grades:" )
                               , choices = c( "Pre-Kindergarten" = "PK"
                                              , "Kindergarten" = "K"
                                              , "1st Grade" = "1"
                                              , "2nd Grade" = "2"
                                              , "3rd Grade" = "3"
                                              , "4th Grade" = "4"
                                              , "5th Grade" = "5"
                                              , "6th Grade" = "6"
                                              , "7th Grade" = "7"
                                              , "8th Grade" = "8"
                                              , "9th Grade" = "9"
                                              , "10th Grade" = "10"
                                              , "11th Grade" = "11"
                                              , "12th Grade" = "12"
                               )
                               , selected = NULL
                               , multiple = TRUE
      )
      
      # Input: download ----
      , shiny::downloadButton(outputId = "downloadData"
                              , label = "Download Data as .CSV File"
                              )
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Formatted text for caption ----
      h3(textOutput( outputId = "globalSearch"
                     , container = span
                     )
         ),
      
      # Output: leaflet
      leaflet::leafletOutput( outputId = "myMap"
                              , height = 650
      ),
      
      # Output: HTML table with requested number of observations ----
      DT::dataTableOutput("view")
      
      
      
    )
  )
)
# Define server logic to summarize and view selected dataset ----
server <- function(input, output) {
  
  # Return the requested dataset ----
  # By declaring datasetInput as a reactive expression we ensure
  # that:
  #
  # 1. It is only called when the inputs it depends on changes
  # 2. The computation and result are shared by all the callers,
  #    i.e. it only executes a single time
  datasetInput <- reactive({
    if( input$cca == "Citywide") {
      dplyr::filter( .data = cps_sy1617
                     , School_ID %in% DesiredValue( 
                       a.list.object = cps_sy1617$Separated_GradesOffered_All
                       , desired.value = input$gradesOffered
                     )
                     # , stringr::str_detect( string = as.character( School_ID )
                     #                        , pattern = input$globalSearch
                     # )
                     # , stringr::str_detect( string = as.character( Short_Name )
                     #                        , pattern = input$globalSearch
                     # )
                     # , stringr::str_detect( string = as.character( Long_Name )
                     #                        , pattern = input$globalSearch
                     # )
                     # , stringr::str_detect( string = as.character( School_Type )
                     #                        , pattern = input$globalSearch
                     # )
                     # , stringr::str_detect( string = as.character( Primary_Category )
                     #                        , pattern = input$globalSearch
                     # )
                     # , stringr::str_detect( string = as.character( School_Summary )
                     #                        , pattern = input$globalSearch
                     # )
                     ) %>%
      dplyr::arrange( Long_Name )
      
    } else { 
      dplyr::filter( .data = cps_sy1617
                     , Community_Area == input$cca
                     , School_ID %in% DesiredValue( 
                       a.list.object = cps_sy1617$Separated_GradesOffered_All
                       , desired.value = input$gradesOffered
                     )
                     , stringr::str_detect( string = School_Summary
                                            , pattern = input$globalSearch
                                            )
                     ) %>%
        dplyr::arrange( Long_Name )
      }
  })
  
  # Create caption ----
  # The output$globalSearch is computed based on a reactive expression
  # that returns input$globalSearch. When the user changes the
  # "Global Search" field:
  #
  # 1. This function is automatically called to recompute the output
  # 2. New global search is pushed back to the browser for re-display
  #
  # Note that because the data-oriented reactive expressions
  # below don't depend on input$globalSearch, those expressions are
  # NOT called when input$globalSearch changes
  output$globalSearch <- renderText({
    input$globalSearch
  })
  
  # Generate a summary of the dataset ----
  # The output$summary depends on the datasetInput reactive
  # expression, so will be re-executed whenever datasetInput is
  # invalidated, i.e. whenever the input$dataset changes
  # output$summary <- renderPrint({
  #   dataset <- datasetInput()
  #   summary( head( dataset) )
  # })
  
  # Show the first "n" observations ----
  # The output$view depends on both the databaseInput reactive
  # expression and input$globalSearch, so it will be re-executed whenever
  # input$dataset or input$globalSearch is changed
  output$view <- DT::renderDataTable({
    DT::datatable( data = datasetInput()
                   , options = list(
                     search = list(
                       search = input$globalSearch
                     )
                   )
    )
                   
  })
  
  # Find the center of each polygon
  # and identify the centers by the $community column in comarea606
  centroids <- rgeos::gCentroid( comarea606
                                 , byid = TRUE
                                 , id = comarea606$community
  )
  
  # obtain longitudinal coords by taking all rows from the first column
  # and transfrom from spatial points object
  # to a list object
  centroidLons <- as.list( coordinates(centroids)[,1] ) 
  
  # obtain latitutde coords by taking all rows from the second column
  # and transform from spaital points object
  # to a list object
  centroidLats <- as.list( coordinates(centroids)[,2] ) 
  
  # render myMap
  output$myMap <- leaflet::renderLeaflet({
    
    # Create a palette that maps factor levels to colors
    pal <- leaflet::colorFactor( palette = c( "#FFFF66" # laser lemon: ES
                                              , "#214FC6" # new car: HS
                                              , "#FF6D3A" # pumpkin: MS
    )
    , domain = c( "ES" # elementary
                  , "MS" # middle
                  , "HS" # high
    )
    )
    
    # if 'Citywide' is selected
    # add all CPS schools to the map
    # as markers
    if( input$cca == "Citywide" ){
      
      # make leaflet object
      leaflet( data = comarea606 ) %>%
        
        # set zoom level
        setView( lng = -87.645814
                 , lat = 41.865769
                 , zoom = 10
        ) %>%
        
        # set max bounds view to cover the City of Chicago
        setMaxBounds( lng1 = comarea606@bbox[1], lat1 = comarea606@bbox[2]
                      , lng2 = comarea606@bbox[3], lat2 = comarea606@bbox[4]
        ) %>% 
        
        # add background to map
        addProviderTiles( providers$CartoDB.DarkMatterNoLabels ) %>%
        
        # add zoom out button
        addEasyButton( easyButton(
          icon = "ion-android-globe", title = "Zoom Back Out"
          , onClick = leaflet::JS("function(btn, map){ map.setZoom(10); }")
        ) ) %>%
        
        # add community area polygons
        addPolygons( smoothFactor = 0.2
                     , fillOpacity = 0.1
                     , color = "#D9D6CF"
                     , weight = 1
                     , label = str_to_title( string = comarea606@data$community )
                     , labelOptions = labelOptions( textsize = "25px"
                                                    , textOnly = TRUE
                                                    , style = list(
                                                      "color" = "white"
                                                      , "font-family" = "Ostrich Sans Black black"
                                                      , "font-weight" =  "bold"
                                                    )
                     )
                     , highlightOptions = highlightOptions( color = "white"
                                                            , weight = 7
                     )
        ) %>%
        
        # # add all schools
        addCircleMarkers( data = dplyr::filter( .data = cps_sy1617
                                                , School_ID %in% 
                                                  DesiredValue( 
                                                    a.list.object = cps_sy1617$Separated_GradesOffered_All
                                                    , desired.value = input$gradesOffered
                                                  )
                                                )
                          , lng = ~School_Longitude
                          , lat = ~School_Latitude
                          , label = ~Long_Name
                          , labelOptions = labelOptions( style = list(
                            "font-family" = "Ostrich Sans Black"
                            , "font-weight" =  "bold"
                            , "cursor" = "pointer"
                            , "font-size" = "18px"
                            )
                            )
                          , popup = paste0( "<b> School ID: </b>"
                                            , dplyr::filter( .data = cps_sy1617
                                                             , School_ID %in% 
                                                               DesiredValue( 
                                                                 a.list.object = cps_sy1617$Separated_GradesOffered_All
                                                                 , desired.value = input$gradesOffered
                                                               )
                                            )$School_ID
                                            , "<br>"
                                            , "<b> School Short Name: </b>"
                                            , dplyr::filter( .data = cps_sy1617
                                                             , School_ID %in% 
                                                               DesiredValue( 
                                                                 a.list.object = cps_sy1617$Separated_GradesOffered_All
                                                                 , desired.value = input$gradesOffered
                                                               )
                                            )$Short_Name
                                            , "<br>"
                                            , "<b> School Long Name: </b>"
                                            , dplyr::filter( .data = cps_sy1617
                                                             , School_ID %in% 
                                                               DesiredValue( 
                                                                 a.list.object = cps_sy1617$Separated_GradesOffered_All
                                                                 , desired.value = input$gradesOffered
                                                               )
                                            )$Long_Name
                                            , "<br>"
                                            , "<b> Grades Served: </b>"
                                            , dplyr::filter( .data = cps_sy1617
                                                             , School_ID %in% 
                                                               DesiredValue( 
                                                                 a.list.object = cps_sy1617$Separated_GradesOffered_All
                                                                 , desired.value = input$gradesOffered
                                                               )
                                            )$Grades_Offered
                                            , "<br>"
                                            , "<b> Community Area: </b>"
                                            , dplyr::filter( .data = cps_sy1617
                                                             , School_ID %in% 
                                                               DesiredValue( 
                                                                 a.list.object = cps_sy1617$Separated_GradesOffered_All
                                                                 , desired.value = input$gradesOffered
                                                               )
                                            )$Community_Area
                                            , "<br>"
                                            , "<b> CPS School Profile: </b>"
                                            , dplyr::filter( .data = cps_sy1617
                                                             , School_ID %in% 
                                                               DesiredValue( 
                                                                 a.list.object = cps_sy1617$Separated_GradesOffered_All
                                                                 , desired.value = input$gradesOffered
                                                               )
                                            )$Active_CPS_School_Profile
                                            )
                          , color = ~pal( dplyr::filter( .data = cps_sy1617
                                                         , School_ID %in% 
                                                           DesiredValue( 
                                                             a.list.object = cps_sy1617$Separated_GradesOffered_All
                                                             , desired.value = input$gradesOffered
                                                             )
                                                         )$Primary_Category
                                          )
                          , stroke = FALSE
                          , fillOpacity = 1
                          , radius = 7
                          ) 
        
        # add custom legend to mark primary category of CPS schools
      # addControl( html = custom_legend_icon
      #              , position = "bottomleft"
      #  )
      
      # now add an 'else' statement for whenever 
      # 'Citywide' is NOT selected
    } else{
      # call chi_map with dynamic twists
      # make leaflet object
      
      # get centroid longitude based on Com. Area selected
      dynamic_lng <- centroidLons[[ str_to_upper( string = input$cca ) ]]
      # get centroid latitude based on Com. Area selected
      dynamic_lat <- centroidLats[[ str_to_upper( string = input$cca ) ]]
      
      leaflet( data = comarea606 ) %>%
        # now set the view to change based
        # on the values in dynamic_lng & dynamic_lat
        setView( lng = dynamic_lng
                 , lat = dynamic_lat
                 , zoom = 14
        ) %>%
        
        # set max bounds view to cover the City of Chicago
        setMaxBounds( lng1 = comarea606@bbox[1], lat1 = comarea606@bbox[2]
                      , lng2 = comarea606@bbox[3], lat2 = comarea606@bbox[4]
        ) %>% 
        
        # add background to map
        addProviderTiles( providers$CartoDB.DarkMatterNoLabels ) %>%
        
        # add zoom out button
        addEasyButton( easyButton(
          icon = "ion-android-globe", title = "Zoom Back Out"
          , onClick = leaflet::JS("function(btn, map){ map.setZoom(13); }")
        ) ) %>%
        
        # add community area polygons
        addPolygons( smoothFactor = 0.2
                     , fillOpacity = 0.1
                     , color = "#D9D6CF"
                     , weight = 1
                     , label = str_to_title( comarea606@data$community )
                     , labelOptions = labelOptions( textsize = "25px"
                                                    , textOnly = TRUE
                                                    , style = list(
                                                      "color" = "white"
                                                      , "font-family" = "Ostrich Sans Black black"
                                                      , "font-weight" =  "bold"
                                                    )
                     )
                     , highlightOptions = highlightOptions( color = "white"
                                                            , weight = 7
                     )
        ) %>%
        
        # add lines to polygon
        addPolylines( data =
                        comarea606[ comarea606$community ==
                                      str_to_upper( input$cca )
                                    , ]
                      , stroke = TRUE
                      , weight = 10
                      , fillOpacity = 1
                      , color = "orange"
                      ) %>%
        
        
        # plot points which are only located
        # in the community area selected
        # and by the grades they select
        addCircleMarkers( data = dplyr::filter( .data = cps_sy1617
                                                , Community_Area == input$cca
                                                , School_ID %in% 
                                                  DesiredValue( 
                                                    a.list.object = cps_sy1617$Separated_GradesOffered_All
                                                    , desired.value = input$gradesOffered
                                                  )
                                                )
                          , lng = ~School_Longitude
                          , lat = ~School_Latitude
                          , label = ~Long_Name
                          , labelOptions = labelOptions( 
                            style = list( 
                              "font-family" = "Ostrich Sans Black"
                              , "font-weight" =  "bold"
                              , "cursor" = "pointer"
                              , "font-size" = "18px"
                              )
                            ) 
                          , popup = paste0( "<b> School ID: </b>"
                                            , dplyr::filter( .data = cps_sy1617
                                                             , Community_Area == input$cca
                                                             , School_ID %in% 
                                                               DesiredValue( 
                                                                 a.list.object = cps_sy1617$Separated_GradesOffered_All
                                                                 , desired.value = input$gradesOffered
                                                               )
                                            )$School_ID
                                            , "<br>"
                                            , "<b> School Short Name: </b>"
                                            , dplyr::filter( .data = cps_sy1617
                                                             , Community_Area == input$cca
                                                             , School_ID %in% 
                                                               DesiredValue( 
                                                                 a.list.object = cps_sy1617$Separated_GradesOffered_All
                                                                 , desired.value = input$gradesOffered
                                                               )
                                            )$Short_Name
                                            , "<br>"
                                            , "<b> School Long Name: </b>"
                                            , dplyr::filter( .data = cps_sy1617
                                                             , Community_Area == input$cca
                                                             , School_ID %in% 
                                                               DesiredValue( 
                                                                 a.list.object = cps_sy1617$Separated_GradesOffered_All
                                                                 , desired.value = input$gradesOffered
                                                               )
                                            )$Long_Name
                                            , "<br>"
                                            , "<b> Grades Served: </b>"
                                            , dplyr::filter( .data = cps_sy1617
                                                             , Community_Area == input$cca
                                                             , School_ID %in% 
                                                               DesiredValue( 
                                                                 a.list.object = cps_sy1617$Separated_GradesOffered_All
                                                                 , desired.value = input$gradesOffered
                                                               )
                                            )$Grades_Offered
                                            , "<br>"
                                            , "<b> Community Area: </b>"
                                            , dplyr::filter( .data = cps_sy1617
                                                             , Community_Area == input$cca
                                                             , School_ID %in% 
                                                               DesiredValue( 
                                                                 a.list.object = cps_sy1617$Separated_GradesOffered_All
                                                                 , desired.value = input$gradesOffered
                                                               )
                                            )$Community_Area
                                            , "<br>"
                                            , "<b> CPS School Profile: </b>"
                                            , dplyr::filter( .data = cps_sy1617
                                                             , Community_Area == input$cca
                                                             , School_ID %in% 
                                                               DesiredValue( 
                                                                 a.list.object = cps_sy1617$Separated_GradesOffered_All
                                                                 , desired.value = input$gradesOffered
                                                               )
                                            )$Active_CPS_School_Profile
                          )
                          , color = ~pal( dplyr::filter( .data = cps_sy1617
                                                         , Community_Area == input$cca
                                                         , School_ID %in% 
                                                           DesiredValue( 
                                                             a.list.object = cps_sy1617$Separated_GradesOffered_All
                                                             , desired.value = input$gradesOffered
                                                           )
                                                         )
                                          )
                          , stroke = FALSE
                          , fillOpacity = 0.5
                          , radius = 12
        )
        
        # # add custom legend to mark primary category of CPS schools
        # addControl( html = custom_legend_icon
        #             , position = "bottomleft"
        # )
    } # end of else statement
    
    
    
  }) # end of render map
  
  output$downloadData <- downloadHandler(
    # A string of the filename, including extension, 
    # that the user's web browser should default to 
    # when downloading the file; 
    # or a function that returns such a string.
    filename = function() {
      paste( "CPS_SY1617_School_Profile_"
             , Sys.Date()
             , ".csv"
             , sep = ""
             )
    } # end of filename
    
    # A function that takes a single argument file 
    # that is a file path (string) of a nonexistent temp file, 
    # and writes the content to that file path. 
    , content = function(con) {
      require( data.table )
      # As write.csv but much faster (e.g. 2 seconds versus 1 minute) 
      # and just as flexible. Modern machines almost surely have more 
      # than one CPU so fwrite uses them; 
      # on all operating systems including Linux, Mac and Windows.
      data.table::fwrite( x = datasetInput()
                          , file = con
                          )
    }
  )
  
}

shinyApp( ui, server)
