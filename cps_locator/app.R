#
# Author:   Cristian E. Nuno
# Date:     August 20, 2017
# Purpose:  Dynamic Filtering of Data With Shiny & Leaflet
#

# Import necessary packages
library(shiny)
library( shinydashboard )
library( DT )
library( leaflet )
library( dplyr )
library( magrittr )
library( htmltools )
library( htmlwidgets )
library( rgdal )
library( splancs )
library( stringr )
library( rgeos )

# Pre work
#### Time to Import CPS and Chicago Data ###

# save copied link as a character vector
geojson_comarea_url <- "https://data.cityofchicago.org/api/geospatial/cauq-8yn6?method=export&format=GeoJSON"

# transform vector into spatial dataframe
comarea606 <- readOGR( dsn = geojson_comarea_url
                       , layer = "OGRGeoJSON"
                       , stringsAsFactors = FALSE
)

# Find the center of each region and label lat and lon of centers
centroids <- rgeos::gCentroid( comarea606
                               , byid = TRUE
                               , id = comarea606$community
)
centroidLons <- as.list( coordinates(centroids)[,1] ) # obtain longitudinal coords

centroidLats <- as.list( coordinates(centroids)[,2] ) # obtain latitutde coords



# import cps school data for SY1617
cps_sy1617_url <- "https://data.cityofchicago.org/api/views/8i6r-et8s/rows.csv?accessType=DOWNLOAD"

# transform URL into a data frame using the base `read.csv` function
cps_sy1617 <- read.csv( file = cps_sy1617_url
                        , header = TRUE
                        , stringsAsFactors = FALSE
)

# Transform CPS School Profile urls from static to active
cps_sy1617$Active_CPS_School_Profile <- paste0("<a href='"
                                        , cps_sy1617$CPS_School_Profile
                                        , "' target='_blank'>"
                                        , cps_sy1617$CPS_School_Profile
                                        ,"</a>"
)

# Create get_poly_matrix_coord function to access
# coordinate values within multiple polygons 
# inside a spatial data frame.
get_poly_matrix_coord <- function( spatial_poly_df ) {
  # start counter
  i <- 1
  # create empty list
  empty_list <- list()
  # start while loop
  while( nrow( spatial_poly_df ) >= i ) {
    # fill the empty list with one set of coordinates
    empty_list[[i]] <- spatial_poly_df@polygons[[i]]@Polygons[[1]]@coords
    # add 1 to the counter
    i <- i + 1
  } # end of while loop
  return( empty_list )
} # end of function
# use the `get_poly_matrix_coord` function
# to retrieve all coordinate values that reside 
# within each polygon
com_area_polygons <- get_poly_matrix_coord( comarea606 ) # list of 77 matrices

# `com_area_polygons` is a list with 77 matrices
# to label each matrix
# use the `names` functions and assign its corresponding community area name
# by calling the "community" variable \
# inside the `comarea606` spatial polygon data frame
names( com_area_polygons ) <- comarea606$community


# Create 'Community_Area' variable inside the data frame
# and assign it a value of NA
cps_sy1617$Community_Area <- NA
# assigns individual points the name of the polygon they reside in
get_CA_names <- function( a.data.frame
                          , a.list.of.matrices
                          , a.spatial.df ) {
  # ensure necessary packages are imported
  require( splancs )
  require( dplyr )
  # start your counter
  i <- 1
  
  # start your while loop
  while( i <= length( a.list.of.matrices )  ) {
    # 1. df with only long and lat
    df_lon_lat <- select( a.data.frame
                          ###### CAUTION #####################
                          # More than likely, ################
                          # you will have to replace #########
                          # the column names to represent ####
                          # the longitutde and latitude ######
                          # variables within your data frame #
                          ####################################
                          , School_Longitude # double check
                          , School_Latitude # double check
    )
    # rename long as x and lat as y
    colnames(df_lon_lat)[1] <- "x"
    colnames(df_lon_lat)[2]  <- "y"
    
    # 2. add in.shape to dataframe
    df_lon_lat$in.shape <- 1:nrow( df_lon_lat) %in%
      inpip( df_lon_lat
             , a.list.of.matrices[[i]]
      )
    #### THIS IS WHERE YOU HAVE TO FILTER BASED ON WHETHER
    #### df_lon_lat$in.shape has any TRUE values
    #### if yes, procceed with steps 3-6
    #### if no, tell the counter to increase by 1
    #### and restart the function
    if( any( df_lon_lat$in.shape ) == FALSE ) {
      # add one to counter
      i <- i + 1
    } else{
      # 3. give me the elements that are TRUE
      only_true <- df_lon_lat[ df_lon_lat$in.shape == TRUE, ]
      
      # 4. filter the orgs data frame by the row names within step 3
      # 5. and assign the Community Area polygon name
      a.data.frame[ as.numeric( row.names( only_true ) ), ]$Community_Area <- a.spatial.df$community[i]
      
      # 6. repeat until all community areas are given a name
      i <- i + 1
    } # end of else statement
    
  } # end of while loop
  
  # return a new data frame
  return( a.data.frame )
  
} # end of function

# Run the `get_CA_names` function
cps_sy1617 <- get_CA_names( a.data.frame = cps_sy1617
                            , a.list.of.matrices = com_area_polygons
                            , a.spatial.df = comarea606
)

############ Building the Dashboard##################

# A dashboard has 2 parts: a user-interface (ui) and a server

# The UI consists of a header, a sidebar, and a body.

# The server consists of functions that produce any objects
# that are called inside the UI

## customize header ##
header <- dashboardHeader( title = "Chicago Public Schools Locator"
                          , titleWidth = 590
                          , tags$li( a( href = "https://data.cityofchicago.org/Education/Chicago-Public-Schools-School-Profile-Information-/8i6r-et8s"
                                        , img( src = "https://upload.wikimedia.org/wikipedia/commons/5/5e/Seal_of_Chicago%2C_Illinois.png"
                                               , title = "CPS School Profile, SY1617"
                                               , height = "50px"
                                               )
                                        , style = "padding-top:10px; padding-bottom:10px;"
                                        )
                                     , class = "dropdown"
                          ) # end of City of Chicago Open Data Portal Logo
                          , tags$li( a( href = "https://cenuno.github.io/"
                                      , img( src = "https://github.com/cenuno/Spatial_Visualizations/raw/master/Images/UrbanDataScience_logo_2017-08-26.png"
                                             , title = "Urban Data Science (GitHub)"
                                             , height = "50px"
                                             )
                                      , style = "padding-top:10px; padding-bottom:10px;"
                                      )
                                    , class = "dropdown"
                          ) # end of Urban Data Science Logo
                          
) # end of header

## customize sidebar ##
sidebar <- dashboardSidebar(
  
  # initialize sidebar Menu
  sidebarMenu(
    
    menuItem( text = "Home Page"
              , tabName = "Home"
              , icon = icon("home")
              ) # end of menuItem
    , menuItem( text = "Chicago Public Schools Data"
                , tabName = "Data"
                , icon = icon("table")
                )
    
  ) # end of sidebarMenu
  
  , collapsed = TRUE
  , width = 300
  
) # end of dashboardsidebar

## customize body ##
body <- dashboardBody(
  
  # Also add some custom CSS to make the title background area the same
  # color as the rest of the header.
  tags$head( tags$style( shiny::HTML('
                                     /* content wrapper background */
                                     .content-wrapper .content {
                                     background-color: #0033A0;
                                     }
  
                                     /* Main Header Size */
                                     .main-header {
                                     height: 50px;
                                     }
                                     /* Main Title Font and Size */
                                     .main-header .logo {
                                     font-family: "Ostrich Sans Black";
                                     font-weight: bold;
                                     font-size: 40px;
                                     } 

                                     /* Main Title Background Color */
                                     .skin-blue .main-header .logo {
                                     background-color: #0033A0;
                                     }

                                     /* Main Title Hover Background Color */
                                     .skin-blue .main-header .logo:hover {
                                     background-color: #0033A0;
                                     }

                                     /* navbar (rest of the header) */
                                     .skin-blue .main-header .navbar {
                                     background-color: #0033A0;
                                     }        

                                     /* custom logos in the navbar */
                                     .skin-blue .main-header .navbar .navbar-custom-menu .dropdown a:hover{
                                     background-color: #F8E219;
                                     }

                                     /* main sidebar */
                                     .skin-blue .main-sidebar {
                                     background-color: #0033A0;
                                     }

                                     /* sidebar text */
                                     .skin-blue .main-sidebar .shiny-bound-input .sidebar-menu {
                                     font-family: "Ostrich Sans Black";
                                     font-weight: bold;
                                     font-size: 18px;
                                     }

                                      
                                     /* active selected tab in the sidebarmenu */
                                     .skin-blue .main-sidebar .sidebar .sidebar-menu .active a{
                                     background-color: #FFFFFF;
                                     color: #0033A0;
                                     }
                                     
                                     /* other links in the sidebarmenu */
                                     .skin-blue .main-sidebar .sidebar .sidebar-menu a{
                                     background-color: #0033A0;
                                     color: #FFFFFF;
                                     }
                                     
                                     /* other links in the sidebarmenu when hovered */
                                     .skin-blue .main-sidebar .sidebar .sidebar-menu a:hover{
                                     background-color: #F8E219; 
                                     color: #0033A0;
                                     }

                                     /* toggle button when hovered  */                    
                                     .skin-blue .main-header .navbar .sidebar-toggle:hover{
                                     background-color: #F8E219;
                                     color: #0033A0;
                                     }

                                     /* infoBox header */
                                     .box.box-solid.box-info>.box-header{
                                     color: #fff;
                                     background: #0033A0;
                                     }

                                     /* infoBox Title */
                                     .box.box-solid.box-info>.box-header .box-title {
                                     font-family: "Ostrich Sans Black";
                                     font-weight: bold;
                                     font-size: 25px;
                                     }

                                     /* infoBox body */
                                     .box.box-solid.box-info{
                                     border-bottom-color: #0033A0;
                                     border-left-color: #0033A0;
                                     border-right-color: #0033A0;
                                     border-top-color: #0033A0;
                                     }
                                     ') # end of marking characters as HTML
                         
                         ) # end of customizing HTML5 style tag
             
             ) # end of customizing HTML5 head tag
  
  # Initialize tabs
  , tabItems(
    
    # Home tab
    tabItem( tabName = "Home"
             
             , fluidRow( 
               
                 box( title = "Map of Chicago Public Schools"
                      , status = "info"
                      , solidHeader = TRUE
                      , collapsible = FALSE
                      , width = 12
                      
                      # create first column
                      , column(
                        width = 2
                        , shiny::selectizeInput( inputId = "dropDown"
                                                 , label = shiny::h3("Select a Community Area:") 
                                                 , choices = c("Citywide"
                                                               , str_to_title( sort( unique( cps_sy1617$Community_Area) ) )
                                                 )
                                                 , selected = "Citywide"
                        ) # end of drop down menu
                      ) # end of first column 
                      
                      # start of column 2
                      , column( width = 10
                                , leaflet::leafletOutput( outputId = "myMap"
                                                          , height = 700
                                ) # end of leaflet output
                      ) # end of column 2
                 ) # end of box 1
             ) # end of row 1
             
             # start of row 2
             , fluidRow(
               box( title = "Quick CPS Facts by Community Area"
                    , status = "info"
                    , solidHeader = TRUE
                    , collapsible = TRUE
                    , width = 6
                    , infoBoxOutput( outputId = "countALL"
                                     , width = 6
                    )
                    , infoBoxOutput( outputId = "countPK"
                                     , width = 6
                    )
                    , infoBoxOutput( outputId = "countK"
                                     , width = 6
                    )
                    , infoBoxOutput( outputId = "countES"
                                     , width = 6
                    )
                    , infoBoxOutput( outputId = "countMS"
                                     , width = 6
                    )
                    , infoBoxOutput( outputId = "countHS"
                                     , width = 6
                    )
                    , infoBoxOutput( outputId = "countSmall"
                                     , width = 6
                    )
                    , infoBoxOutput( outputId = "countContract"
                                     , width = 6
                    )
                    , infoBoxOutput( outputId = "countOption"
                                     , width = 6
                    )
                    , infoBoxOutput( outputId = "countCharter"
                                     , width = 6
                    )
                    , infoBoxOutput( outputId = "countNhood"
                                     , width = 6
                    )
                    , infoBoxOutput( outputId = "countSpecial"
                                     , width = 6
                    )
                    , infoBoxOutput( outputId = "countMagnet"
                                     , width = 6
                    )
                    , infoBoxOutput( outputId = "countMilitary"
                                     , width = 6
                    )
                    , infoBoxOutput( outputId = "countGifted"
                                     , width = 6
                    )
                    , infoBoxOutput( outputId = "countClassical"
                                     , width = 6
                    )
                    , infoBoxOutput( outputId = "countSelective"
                                     , width = 6
                    )
                    , infoBoxOutput( outputId = "countCareer"
                                     , width = 6
                    )
               ) # end of box q
               
             ) # end of row 2
              
    ) # end of Home Tab
    , tabItem(
      tabName = "Data"
        # start of row 1
        , fluidRow(
          
          # start of box
          box( title = "Contact and School Information Database during 2016-2017 School Year"
               , status = "info"
               , solidHeader = TRUE
               , collapsible = FALSE
               , width = 12
               , DT::dataTableOutput( outputId = "fancyTable" )
          ) # end of box
          
        ) # end of row 1
      
      ) # end of Data tab 
    
  ) # end of Tab Items
  
) # end of body

## Shiny UI ##
ui <- dashboardPage(
  header
  , sidebar
  , body
)


# Define server logic required to draw a histogram
server <- function(input, output) {
  
  # custom legend
  custom_legend_icon <- "<img src='https://github.com/cenuno/Spatial_Visualizations/raw/master/Images/awesomeMarkerIcons/blue_marker.png'
style='width:35px;height:40px;'> Primarily High School<br/>

<img src='https://github.com/cenuno/Spatial_Visualizations/raw/master/Images/awesomeMarkerIcons/green_marker.png'
style='width:35px;height:40px;'> Primarily Middle School<br/>

<img src='https://github.com/cenuno/Spatial_Visualizations/raw/master/Images/awesomeMarkerIcons/orange_marker.png'
style='width:35px;height:40px;'> Primarily Elementary School"
  
  # now render info box
  output$countALL <- shinydashboard::renderInfoBox({
    
    # if 'Citywide' is selected
    # count all CPS schools
    if( input$dropDown == "Citywide" ){
      
      schoolCount <- nrow( cps_sy1617 )
      
      # now add an 'else' statement for whenever 
      # 'Citywide' is NOT selected
      # count CPS schools in user-selected commmunity area
    } else{
      
      schoolCount <- nrow( dplyr::filter( cps_sy1617
                                          , Community_Area ==
                                            str_to_upper( input$dropDown )
      )
      )
      } # end of else 

      # create infoBox
      infoBox(
        title = "All Schools"
        , value = schoolCount
        , icon = icon( name = "child"
                       , lib = "font-awesome"
        )
        , color = "olive"
      ) # end of info box
    
    }) # end of renderInfoBox
    
  
  # render infoBox for
  # number of CPS PreK Schools
  
  output$countPK <- shinydashboard::renderInfoBox({
    
    # if 'Citywide' is selected
    # count all CPS Pre-K schools
    if( input$dropDown == "Citywide" ){
      
      schoolCount <- length( grep( pattern = "PK"
                                   , x = cps_sy1617$Grades_Offered_All
                                   , fixed = TRUE
      )) # end of calculation
      
      # now add an 'else' statement for whenever 
      # 'Citywide' is NOT selected
      # count CPS Pre-K schools in user-selected commmunity area
    } else{
      
      schoolCount <- length( grep( pattern = "PK"
                                   , x = dplyr::filter( cps_sy1617
                                                        , Community_Area ==
                                                          str_to_upper( input$dropDown )
                                   )$Grades_Offered_All
                                   , fixed = TRUE
      )) # end of calculation
      
    } # end of else 

    infoBox(
      title = "Pre-K"
      , value = schoolCount
      , icon = icon( name = "child"
                     , lib = "font-awesome"
                     )
      , color = "olive"
    ) # end of info box
    
    
  })
  
  # render infoBox for
  # number of CPS K Schools
  
  output$countK <- shinydashboard::renderInfoBox({
    
    # if 'Citywide' is selected
    # count all CPS Kindergarten schools
    if( input$dropDown == "Citywide" ){
      
      schoolCount <- length( grep( pattern = "^K|PK,K"
                                   , x = cps_sy1617$Grades_Offered_All
      )) # end of calculation
      
      # now add an 'else' statement for whenever 
      # 'Citywide' is NOT selected
      # count CPS Kindergarten schools in user-selected commmunity area
    } else{
      
      schoolCount <- length( grep( pattern = "^K|PK,K"
                                   , x = dplyr::filter( cps_sy1617
                                                        , Community_Area ==
                                                          str_to_upper( input$dropDown )
                                   )$Grades_Offered_All
      )) # end of calculation
      
    } # end of else 
    
    infoBox(
      title = "Kindergarten"
      , value = schoolCount
      , icon = icon( name = "child"
                     , lib = "font-awesome"
      )
      , color = "olive"
    ) # end of info box
    
    
  })
  
  # render infoBox for
  # number of CPS PreK Schools
  
  output$countES <- shinydashboard::renderInfoBox({
    
    # if 'Citywide' is selected
    # count all CPS Elementary schools
    if( input$dropDown == "Citywide" ){
      
      schoolCount <- length( cps_sy1617$Is_Elementary_School[ 
        cps_sy1617$Is_Elementary_School == "Y"
        ] # end of filtering
      ) # end of calculation
      
      # now add an 'else' statement for whenever 
      # 'Citywide' is NOT selected
      # count CPS Kindergarten schools in user-selected commmunity area
    } else{
      
      schoolCount <- length( dplyr::filter( cps_sy1617
                                            , Community_Area ==
                                              str_to_upper( input$dropDown )
      )$Is_Elementary_School[ 
        dplyr::filter( cps_sy1617
                       , Community_Area ==
                         str_to_upper( input$dropDown )
        )$Is_Elementary_School == "Y"
        ] # end of filtering
      ) # end of calculation
      
    } # end of else 
    
    infoBox(
      title = "Elementary Schools"
      # calculate
      # Couldn't figure out how to do this the regex way
      , value = schoolCount
      , icon = icon( name = "child"
                     , lib = "font-awesome"
      )
      , color = "olive"
    ) # end of info box
    
    
  })
  
  # render infoBox for
  # number of CPS MS
  
  output$countMS <- shinydashboard::renderInfoBox({
    
    # if 'Citywide' is selected
    # count all CPS Elementary schools
    if( input$dropDown == "Citywide" ){
      
      schoolCount <- length( cps_sy1617$Is_Middle_School[ 
        cps_sy1617$Is_Middle_School == "Y"
        ] # end of filtering
      ) # end of calculation
      
      # now add an 'else' statement for whenever 
      # 'Citywide' is NOT selected
      # count CPS Kindergarten schools in user-selected commmunity area
    } else{
      
      schoolCount <- length( dplyr::filter( cps_sy1617
                                            , Community_Area ==
                                              str_to_upper( input$dropDown )
      )$Is_Middle_School[ 
        dplyr::filter( cps_sy1617
                       , Community_Area ==
                         str_to_upper( input$dropDown )
        )$Is_Middle_School == "Y"
        ] # end of filtering
      ) # end of calculation
      
    } # end of else 
    
    infoBox(
      title = "Middle Schools"
      # how many CPS SY1617 schools
      # offer Middle School grades: 6,7,8
      , value = schoolCount
      , icon = icon( name = "child"
                     , lib = "font-awesome"
      )
      , color = "olive"
    ) # end of info box
    
    
  })
  
  output$countHS <- shinydashboard::renderInfoBox({
    
    # if 'Citywide' is selected
    # count all CPS Elementary schools
    if( input$dropDown == "Citywide" ){
      
      schoolCount <- length( cps_sy1617$Is_High_School[ 
        cps_sy1617$Is_High_School == "Y"
        ] # end of filtering
      ) # end of calculation
      
      # now add an 'else' statement for whenever 
      # 'Citywide' is NOT selected
      # count CPS Kindergarten schools in user-selected commmunity area
    } else{
      
      schoolCount <- length( dplyr::filter( cps_sy1617
                                            , Community_Area ==
                                              str_to_upper( input$dropDown )
      )$Is_High_School[ 
        dplyr::filter( cps_sy1617
                       , Community_Area ==
                         str_to_upper( input$dropDown )
        )$Is_High_School == "Y"
        ] # end of filtering
      ) # end of calculation
      
    } # end of else statement
    
    infoBox(
      title = "High Schools"
      # how many CPS SY1617 schools
      # offer Middle School grades: 6,7,8
      , value = schoolCount
      , icon = icon( name = "child"
                     , lib = "font-awesome"
      )
      , color = "olive"
    ) # end of info box
    
    }) # end of renderInfoBox
  
  output$countSmall <- shinydashboard::renderInfoBox({
    
    # if 'Citywide' is selected
    # count all CPS Elementary schools
    if( input$dropDown == "Citywide" ){
      
      schoolCount <- length( grep( pattern = "Small"
                                   , x = cps_sy1617$School_Type
                                   , fixed = TRUE
                                   )
                             ) # end of calculation
      
      # now add an 'else' statement for whenever 
      # 'Citywide' is NOT selected
      # count CPS Small schools in user-selected commmunity area
    } else{
      
      schoolCount <- length( grep( pattern = "Small"
                                   , x = dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      
    } # end of else statement
    
    infoBox(
      title = "Small (Type)"
      # how many CPS SY1617 schools
      # are classified as 'Small'
      , value = schoolCount
      , icon = icon( name = "child"
                     , lib = "font-awesome"
      )
      , color = "orange"
    ) # end of info box
    
  }) # end of renderInfoBox
  
  output$countContract <- shinydashboard::renderInfoBox({
    
    # if 'Citywide' is selected
    # count all CPS Elementary schools
    if( input$dropDown == "Citywide" ){
      
      schoolCount <- length( grep( pattern = "Contract"
                                   , x = cps_sy1617$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      # now add an 'else' statement for whenever 
      # 'Citywide' is NOT selected
      # count CPS Contract schools in user-selected commmunity area
    } else{
      
      schoolCount <- length( grep( pattern = "Contract"
                                   , x = dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      
    } # end of else statement
    
    infoBox(
      title = "Contract (Type)"
      # how many CPS SY1617 schools
      # are classified as 'Contract'
      , value = schoolCount
      , icon = icon( name = "child"
                     , lib = "font-awesome"
      )
      , color = "orange"
    ) # end of info box
    
  }) # end of renderInfoBox
  
  output$countOption <- shinydashboard::renderInfoBox({
    
    # if 'Citywide' is selected
    # count all CPS Elementary schools
    if( input$dropDown == "Citywide" ){
      
      schoolCount <- length( grep( pattern = "Citywide-Option"
                                   , x = cps_sy1617$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      # now add an 'else' statement for whenever 
      # 'Citywide' is NOT selected
      # count CPS citywide option schools in user-selected commmunity area
    } else{
      
      schoolCount <- length( grep( pattern = "Citywide-Option"
                                   , x = dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      
    } # end of else statement
    
    infoBox(
      title = "Citywide-Option (Type)"
      # how many CPS SY1617 schools
      # are classified as 'Citywide-Option'
      , value = schoolCount
      , icon = icon( name = "child"
                     , lib = "font-awesome"
      )
      , color = "orange"
    ) # end of info box
    
  }) # end of renderInfoBox
  
  output$countCharter <- shinydashboard::renderInfoBox({
    
    # if 'Citywide' is selected
    # count all CPS Elementary schools
    if( input$dropDown == "Citywide" ){
      
      schoolCount <- length( grep( pattern = "Charter"
                                   , x = cps_sy1617$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      # now add an 'else' statement for whenever 
      # 'Citywide' is NOT selected
      # count CPS charter schools in user-selected commmunity area
    } else{
      
      schoolCount <- length( grep( pattern = "Charter"
                                   , x = dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      
    } # end of else statement
    
    infoBox(
      title = "Charter (Type)"
      # how many CPS SY1617 schools
      # are classified as 'Charter'
      , value = schoolCount
      , icon = icon( name = "child"
                     , lib = "font-awesome"
      )
      , color = "orange"
    ) # end of info box
    
  }) # end of renderInfoBox
  
  output$countNhood <- shinydashboard::renderInfoBox({
    
    # if 'Citywide' is selected
    # count all CPS Elementary schools
    if( input$dropDown == "Citywide" ){
      
      schoolCount <- length( grep( pattern = "Neighborhood"
                                   , x = cps_sy1617$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      # now add an 'else' statement for whenever 
      # 'Citywide' is NOT selected
      # count CPS neighborhood schools in user-selected commmunity area
    } else{
      
      schoolCount <- length( grep( pattern = "Neighborhood"
                                   , x = dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      
    } # end of else statement
    
    infoBox(
      title = "Neighborhood (Type)"
      # how many CPS SY1617 schools
      # are classified as 'Neighborhood'
      , value = schoolCount
      , icon = icon( name = "child"
                     , lib = "font-awesome"
      )
      , color = "orange"
    ) # end of info box
    
  }) # end of renderInfoBox
  
  output$countSpecial <- shinydashboard::renderInfoBox({
    
    # if 'Citywide' is selected
    # count all CPS Elementary schools
    if( input$dropDown == "Citywide" ){
      
      schoolCount <- length( grep( pattern = "Special Education"
                                   , x = cps_sy1617$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      # now add an 'else' statement for whenever 
      # 'Citywide' is NOT selected
      # count CPS special education schools in user-selected commmunity area
    } else{
      
      schoolCount <- length( grep( pattern = "Special Education"
                                   , x = dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      
    } # end of else statement
    
    infoBox(
      title = "Special Education (Type)"
      # how many CPS SY1617 schools
      # are classified as 'Special Education'
      , value = schoolCount
      , icon = icon( name = "child"
                     , lib = "font-awesome"
      )
      , color = "orange"
    ) # end of info box
    
  }) # end of renderInfoBox
  
  output$countMagnet <- shinydashboard::renderInfoBox({
    
    # if 'Citywide' is selected
    # count all CPS Elementary schools
    if( input$dropDown == "Citywide" ){
      
      schoolCount <- length( grep( pattern = "Magnet"
                                   , x = cps_sy1617$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      # now add an 'else' statement for whenever 
      # 'Citywide' is NOT selected
      # count CPS magnet schools in user-selected commmunity area
    } else{
      
      schoolCount <- length( grep( pattern = "Magnet"
                                   , x = dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      
    } # end of else statement
    
    infoBox(
      title = "Magnet (Type)"
      # how many CPS SY1617 schools
      # are classified as 'Magnet'
      , value = schoolCount
      , icon = icon( name = "child"
                     , lib = "font-awesome"
      )
      , color = "orange"
    ) # end of info box
    
  }) # end of renderInfoBox
  
  output$countMilitary <- shinydashboard::renderInfoBox({
    
    # if 'Citywide' is selected
    # count all CPS Elementary schools
    if( input$dropDown == "Citywide" ){
      
      schoolCount <- length( grep( pattern = "Military"
                                   , x = cps_sy1617$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      # now add an 'else' statement for whenever 
      # 'Citywide' is NOT selected
      # count CPS Military schools in user-selected commmunity area
    } else{
      
      schoolCount <- length( grep( pattern = "Military"
                                   , x = dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      
    } # end of else statement
    
    infoBox(
      title = "Military (Type)"
      # how many CPS SY1617 schools
      # are classified as 'Military'
      , value = schoolCount
      , icon = icon( name = "child"
                     , lib = "font-awesome"
      )
      , color = "orange"
    ) # end of info box
    
  }) # end of renderInfoBox
  
  output$countGifted <- shinydashboard::renderInfoBox({
    
    # if 'Citywide' is selected
    # count all CPS Elementary schools
    if( input$dropDown == "Citywide" ){
      
      schoolCount <- length( grep( pattern = "Regional gifted center"
                                   , x = cps_sy1617$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      # now add an 'else' statement for whenever 
      # 'Citywide' is NOT selected
      # count CPS regional gifted center schools in user-selected commmunity area
    } else{
      
      schoolCount <- length( grep( pattern = "Regional gifted center"
                                   , x = dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      
    } # end of else statement
    
    infoBox(
      title = "Regional gifted center (Type)"
      # how many CPS SY1617 schools
      # are classified as 'Regional gifted center'
      , value = schoolCount
      , icon = icon( name = "child"
                     , lib = "font-awesome"
      )
      , color = "orange"
    ) # end of info box
    
  }) # end of renderInfoBox
  
  output$countClassical <- shinydashboard::renderInfoBox({
    
    # if 'Citywide' is selected
    # count all CPS Elementary schools
    if( input$dropDown == "Citywide" ){
      
      schoolCount <- length( grep( pattern = "Classical"
                                   , x = cps_sy1617$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      # now add an 'else' statement for whenever 
      # 'Citywide' is NOT selected
      # count CPS classical schools in user-selected commmunity area
    } else{
      
      schoolCount <- length( grep( pattern = "Classical"
                                   , x = dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      
    } # end of else statement
    
    infoBox(
      title = "Classical (Type)"
      # how many CPS SY1617 schools
      # are classified as 'Classical'
      , value = schoolCount
      , icon = icon( name = "child"
                     , lib = "font-awesome"
      )
      , color = "orange"
    ) # end of info box
    
  }) # end of renderInfoBox
  
  output$countClassical <- shinydashboard::renderInfoBox({
    
    # if 'Citywide' is selected
    # count all CPS Elementary schools
    if( input$dropDown == "Citywide" ){
      
      schoolCount <- length( grep( pattern = "Selective enrollment"
                                   , x = cps_sy1617$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      # now add an 'else' statement for whenever 
      # 'Citywide' is NOT selected
      # count CPS selective enrollment schools in user-selected commmunity area
    } else{
      
      schoolCount <- length( grep( pattern = "Selective enrollment"
                                   , x = dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      
    } # end of else statement
    
    infoBox(
      title = "Selective Enrollment (Type)"
      # how many CPS SY1617 schools
      # are classified as 'Selective Enrollment'
      , value = schoolCount
      , icon = icon( name = "child"
                     , lib = "font-awesome"
      )
      , color = "orange"
    ) # end of info box
    
  }) # end of renderInfoBox
  
  output$countCareer <- shinydashboard::renderInfoBox({
    
    # if 'Citywide' is selected
    # count all CPS Elementary schools
    if( input$dropDown == "Citywide" ){
      
      schoolCount <- length( grep( pattern = "Career academy"
                                   , x = cps_sy1617$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      # now add an 'else' statement for whenever 
      # 'Citywide' is NOT selected
      # count CPS career academy schools in user-selected commmunity area
    } else{
      
      schoolCount <- length( grep( pattern = "Career academy"
                                   , x = dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$School_Type
                                   , fixed = TRUE
      )
      ) # end of calculation
      
      
    } # end of else statement
    
    infoBox(
      title = "Career Academy (Type)"
      # how many CPS SY1617 schools
      # are classified as 'Career Academy'
      , value = schoolCount
      , icon = icon( name = "child"
                     , lib = "font-awesome"
      )
      , color = "orange"
    ) # end of info box
    
  }) # end of renderInfoBox
  
  # render myMap
  output$myMap <- leaflet::renderLeaflet({
    
    
    # if 'Citywide' is selected
    # add all CPS schools to the map
    # as markers
    if( input$dropDown == "Citywide" ){
      
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
                     , fillOpacity = 0.05
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
        
        # # add all schools
        addCircleMarkers( data = cps_sy1617
                           , lng = cps_sy1617$School_Longitude
                           , lat = cps_sy1617$School_Latitude
                           , label = cps_sy1617$Long_Name
                           , labelOptions = labelOptions( style = list(
                                                            "font-family" = "Ostrich Sans Black"
                                                            , "font-weight" =  "bold"
                                                            , "cursor" = "pointer"
                                                            , "font-size" = "20px"
                                                          ))
                           , popup = paste0( "<b> School ID: </b>"
                                             , cps_sy1617$School_ID
                                             , "<br>"
                                             , "<b> School Short Name: </b>"
                                             , cps_sy1617$Short_Name
                                             , "<br>"
                                             , "<b> School Long Name: </b>"
                                             , cps_sy1617$Long_Name
                                             , "<br>"
                                             , "<b> Grades Served: </b>"
                                             , cps_sy1617$Grades_Offered
                                             , "<br>"
                                             , "<b> Community Area: </b>"
                                             , stringr::str_to_title( cps_sy1617$Community_Area )
                                             , "<br>"
                                             , "<b> CPS School Profile: </b>"
                                             , cps_sy1617$Active_CPS_School_Profile
                           )
                          , color = ~pal( cps_sy1617$Primary_Category )
                          , stroke = FALSE
                          , fillOpacity = 0.5
                          , radius = 12
        ) %>%
        
        # add custom legend to mark primary category of CPS schools
        addControl( html = custom_legend_icon
                    , position = "bottomleft"
                    )
      # now add an 'else' statement for whenever 
      # 'Citywide' is NOT selected
    } else{
      # call chi_map with dynamic twists
      # make leaflet object

      # get centroid longitude based on Com. Area selected
      dynamic_lng <- centroidLons[[ str_to_upper( input$dropDown ) ]]
      # get centroid latitude based on Com. Area selected
      dynamic_lat <- centroidLats[[ str_to_upper( input$dropDown ) ]]
      
      leaflet( data = comarea606 ) %>%
        # now set the view to change based
        # on the values in dynamic_lng & dynamic_lat
        setView( lng = dynamic_lng
                   , lat = dynamic_lat
                   , zoom = 13
          ) %>%
          
          # set max bounds view to cover the City of Chicago
          setMaxBounds( lng1 = comarea606@bbox[1], lat1 = comarea606@bbox[2]
                        , lng2 = comarea606@bbox[3], lat2 = comarea606@bbox[4]
          ) %>% 
          
          # add background to map
          addProviderTiles( providers$CartoDB.DarkMatterNoLabels ) %>%
          
          # add mini map
          addMiniMap(
            tiles = providers$Esri.WorldStreetMap
            , toggleDisplay = TRUE
            , minimized = TRUE
          ) %>%
          
          # add zoom out button
          addEasyButton( easyButton(
            icon = "ion-android-globe", title = "Zoom Back Out"
            , onClick = leaflet::JS("function(btn, map){ map.setZoom(10); }")
          ) ) %>%
          
          # add community area polygons
          addPolygons( smoothFactor = 0.2
                       , fillOpacity = 0.1
                       , color = "blue"
                       , label = str_to_title( comarea606@data$community )
                       , labelOptions = labelOptions( textsize = "25px"
                                                      , textOnly = TRUE 
                                                      )
                       , highlightOptions = highlightOptions( color = "orange"
                                                              , weight = 5
                                                              #, bringToFront = TRUE
                       )
          ) %>%
        
        # add lines to polygon
        addPolylines( data = comarea606[ comarea606$community == str_to_upper( input$dropDown ) , ]
                      , stroke = TRUE
                      , weight = 10
                      , fillOpacity = 1
                      , color = "orange"
                      ) %>%
        
        
        #plot points which are only located
        # in the community area selected
        addAwesomeMarkers( data = dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )
                    , lng = dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$School_Longitude
                    , lat = dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$School_Latitude
                    , label = dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$Long_Name
                    , labelOptions = labelOptions( noHide = FALSE
                                                   , direction = "auto"
                                                   , textsize = "15px"
                    )
                    , icon = awesomeIcons( icon = "graduation-cap"
                                           , library = "fa"
                                           , markerColor = dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$Color
                    )
                    , popup = paste0( "<b> School ID: </b>"
                                      , dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$School_ID
                                      , "<br>"
                                      , "<b> School Short Name: </b>"
                                      , dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$Short_Name
                                      , "<br>"
                                      , "<b> School Long Name: </b>"
                                      , dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$Long_Name
                                      , "<br>"
                                      , "<b> Grades Served: </b>"
                                      , dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$Grades_Offered
                                      , "<br>"
                                      , "<b> Community Area: </b>"
                                      , stringr::str_to_title( dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$Community_Area )
                                      , "<br>"
                                      , "<b> CPS School Profile: </b>"
                                      , dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$CPS_Active_School_Profile
                    )
        ) %>%
          
        # add custom legend to mark primary category of CPS schools
        addControl( html = custom_legend_icon
                    , position = "bottomleft"
        )
      } # end of else statement

      

  }) # end of render map
  
  # render datatable
  output$fancyTable <- DT::renderDataTable({
    
    # if 'Citywide' selected
    # show a datatable for all CPS schools
    if( input$dropDown == "Citywide" ) {
      # make datatable 
      DT::datatable( data = cps_sy1617
                 , rownames = FALSE
                 , caption = "Table 1: School profile information for all schools in the Chicago Public School district for the school year 2016-2017."
                 , extensions = 'Buttons'
                 , options = list( 
                   dom = "Blfrtip"
                   , buttons = 
                     list("copy", list(
                       extend = "collection"
                       , buttons = c("csv", "excel", "pdf")
                       , text = "Download"
                     ) ) # end of buttons customization
                   
                   # customize the length menu
                   , lengthMenu = list( c(100, 300, -1) # declare values
                                        , c(100, 300, "All") # declare titles
                   ) # end of lengthMenu customization
                   
                   # enable horizontal scrolling due to many columns
                   , scrollX = TRUE
                 ) # end of options
      ) # end of datatable
      
      # now add an 'else' statement for whenever 
      # 'Citywide' is NOT selected
      # thereby showing CPS schools by the
      # Community Area that was selected
    } else{
      # filterd data frame
      CPS_School_CCA <- dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )
      # create fancy table
      datatable( data = CPS_School_CCA
                 , rownames = FALSE
                 , caption = paste0( "Table 1: School profile information for all schools within "
                                    , input$dropDown
                                    , " in the Chicago Public School district for the school year 2016-2017."
                 )
                 , extensions = 'Buttons'
                 , options = list( 
                   dom = "Blfrtip"
                   , buttons = 
                     list("copy", list(
                       extend = "collection"
                       , buttons = c("csv", "excel", "pdf")
                       , text = "Download"
                     ) ) # end of buttons customization
                   
                   # customize the length menu
                   , lengthMenu = list( c(100, 300, -1) # declare values
                                        , c(100, 300, "All") # declare titles
                   ) # end of lengthMenu customization
                   
                   # enable horizontal scrolling due to many columns
                   , scrollX = TRUE
                   
                 ) # end of options
                 
      ) # end of datatable
      
    } # end of else statement
    
  }) # end of render datatable
  
  
} # end of server

# Run the application 
shinyApp(ui = ui, server = server)

