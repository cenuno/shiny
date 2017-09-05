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

# covert school ID to character
cps_sy1617$School_ID <- as.character( cps_sy1617$School_ID )
# going to add 14 new columns to cps_sy1617

# create function that separates the grades contained in the
# $Grades_Offered_All column
separateGrades <- function( csv_column ) {
  
  # create list from csv_column
  csv_column <- as.list( csv_column )
  
  # create counter
  i <- 1
  
  # start while loop
  while( i <= length( csv_column ) ) {
    
    # take the first vector inside csv_column
    # and create new elements
    if( grepl( pattern = ","
               , x = csv_column[[i]]
    ) == TRUE
    ) {
      # split by ","
      # with fixed = TRUE
      # because I am not regular expressions
      csv_column[i] <- strsplit( x = csv_column[[i]]
                                 , split = ","
                                 , fixed = TRUE
      )
      # move the counter by 1
      i <- i + 1
    } else{
      # move the counter by 1
      i <- i + 1
    }
    
  } # end of while loop
  
  # return csv_column
  return( csv_column )
  
} # end of separateGrades function

# use the separateGrades function
cps_sy1617$Separated_GradesOffered_All <- separateGrades( csv_column = cps_sy1617$Grades_Offered_All )

# name the list by school ID
names( cps_sy1617$Separated_GradesOffered_All ) <- cps_sy1617$School_ID

# how to separate the entire data frame
# based on whether or not each particular school
# serves a particular grade(s)
gradesServed <- function( a.list.object, grades ) {
  # start counter
  i <- 1
  # create empty character vector
  empty_character <- character()
  # start while loop
  while( length( a.list.object ) >= i ) {
    # given a set of grades as characters (i.e. "8", not 8)
    # test if all user defined grades are served by
    # each school.
    if( all( grades %in% a.list.object[[i]] ) == FALSE ) {
      # add one to the counter
      i <- i + 1
      
    } else{
      # if true
      # set the i element inside empty_character
      # to contain the School_ID which serves
      # the user defined grades
      empty_character[i] <- names( a.list.object )[i]
      
      # add one to counter
      i <- i + 1
      
    } # end of ifelse statement
  } # end of while loop
  
  # return empty_character with no NA values
  empty_character <- empty_character[ !is.na( empty_character ) ]
  return( empty_character )
  
} # end of function

# enable web addresses to be clickable in datatables
# using Font Awesome (FA) icons
# http://fontawesome.io/
createClickFA <- function( web_address
                              , btn_background_color
                              , fa_icon
                              ) {
  
  # start counter
  i <- 1
  
  # start while loop
  while( i <= length( web_address ) ) {
    # if the element of link_or_url does NOT equal ""
    # reassign the value of that element css features
    # that will enable the link to be clickable
    if( web_address[i] != "") {
      
      web_address[i] <- sprintf( 
        paste0( '<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">'
                , '<a'
                , ' href="'
                , web_address[i]
                , '"'
                , ' target="_blank"'
                , ' class="btn btn-primary"'
                , ' style="'
                , 'background-color: '
                , btn_background_color
                , ';'
                , ' border: none; border-radius: 15px;">'
                , '<i'
                , ' class="fa '
                , fa_icon
                , ' fa-3x"'
                , ' aria-hidden="true">' # hides icons used just for decoration for screen-readers
                , '</i>'
                , '</a>'
                ) # end of paste0
      ) # end of CSS formatting
      
      # add one to counter
      i <- i + 1
    } else{
      web_address[i] <- NA
      # add one to counter
      i <- i + 1
    }

  } # end of while loop
  
  # return newly formated character vector
  return( web_address )
  
} # end of function

# create Twitter Button
cps_sy1617$Click_Twitter <- createClickFA( web_address = cps_sy1617$Twitter
                                         , btn_background_color = "#1DA1F2"
                                         , fa_icon = "fa-twitter"
                                         )

# create Facebook Button
cps_sy1617$Click_Facebook <- createClickFA( web_address = cps_sy1617$Facebook
                                                , btn_background_color = "#3B5998"
                                                , fa_icon = "fa-facebook-f"
                                                )

# create Youtube Button
cps_sy1617$Click_Youtube <- createClickFA( web_address = cps_sy1617$Youtube
                                               , btn_background_color = "#FF0000"
                                               , fa_icon = "fa-youtube-play"
                                               )

# create Pinterest Button
cps_sy1617$Click_Pinterest <- createClickFA( web_address = cps_sy1617$Pinterest
                                                 , btn_background_color = "#BD081B"
                                                 , fa_icon = "fa-pinterest-p"
                                                 )
# enable web addresses to be clickable in datatables
createClickImage <- function( web_address
                          , img_source
                          , height
                          ) {
  
  # start counter
  i <- 1
  
  # start while loop
  while( i <= length( web_address ) ) {
    # if the element of link_or_url does NOT equal ""
    # reassign the value of that element css features
    # that will enable the link to be clickable
    if( web_address[i] != "") {
      
      web_address[i] <- sprintf( 
        paste0( '<a'
                , ' href="'
                , web_address[i]
                , '"'
                , ' target="_blank"'
                , '>'
                , '<img'
                , ' src="'
                , img_source
                , '"'
                , ' height="'
                , height
                , '">'
                , '</img>'
                , '</a>'
        ) # end of paste0
      ) # end of CSS formatting
      
      # add one to counter
      i <- i + 1
    } else{
      web_address[i] <- NA
      # add one to counter
      i <- i + 1
    }
    
  } # end of while loop
  
  # return newly formated character vector
  return( web_address )
  
} # end of function

# create clickable CPS school profiles
cps_sy1617$Click_CPS_Profile <- createClickImage( web_address = cps_sy1617$CPS_School_Profile
                                                    , img_source = "http://cps.edu/ScriptLibrary/Responsive/images/cpslogo@2x.png"
                                                    , height = 52
                                                    )

# create clickable button
createClickButton <- function( web_address
                               , btn_background_color
                               , btn_label
                               ) {
  
  # start counter
  i <- 1
  
  # start while loop
  while( i <= length( web_address ) ) {
    # if the element of link_or_url does NOT equal ""
    # reassign the value of that element css features
    # that will enable the link to be clickable
    if( web_address[i] != "") {
      
      web_address[i] <- sprintf( 
        paste0( '<a'
                , ' href='
                , web_address[i]
                , ' target="_blank"'
                , ' class="btn btn-primary"'
                , ' style="'
                , 'background-color: '
                , btn_background_color
                , ';'
                , ' border: none; border-radius: 15px;">'
                , btn_label
                , '</a>'
        ) # end of paste0
      ) # end of CSS formatting
      
      # add one to counter
      i <- i + 1
    } else{
      web_address[i] <- NA
      # add one to counter
      i <- i + 1
    }
    
  } # end of while loop
  
  # return newly formated character vector
  return( web_address )
  
} # end of function

# create clickable button for each school website
cps_sy1617$Click_Website <- createClickButton( web_address = cps_sy1617$Website
                                               , btn_background_color = "#6DAD1D"
                                               , btn_label = "Website"
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
    
    menuItem( text = "Home"
              , tabName = "Home"
              , icon = icon("home")
              ) # end of menuItem
    , menuItem( text = "Downloads"
                , tabName = "Data"
                , icon = icon("table")
                )
    
  ) # end of sidebarMenu
  
  , collapsed = TRUE
  , width = 300
  
) # end of dashboardsidebar

## customize body ##
body <- dashboardBody(
  
  # Add some custom CSS to make the title background area the same
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
                        # start drop down dropDown menu
                        , shiny::selectizeInput( inputId = "dropDown"
                                                 , label = shiny::h3("Zoom Into a Community Area:") 
                                                 , choices = c("Citywide"
                                                               , str_to_title( sort( unique( cps_sy1617$Community_Area) ) )
                                                 )
                                                 , selected = "Citywide"
                                                 ) # end of drop down menu
                        
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
                                                 ) # end of drop down menu
                      ) # end of first column 
                      
                      # start of column 2
                      , column( width = 10
                                , leaflet::leafletOutput( outputId = "myMap"
                                                          , height = 650
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
          
          # start of box 1
          box( title = "Social Media Accounts"
               , status = "info"
               , solidHeader = TRUE
               , collapsible = TRUE
               , collapsed = FALSE
               , width = 6
               , DT::dataTableOutput( outputId = "socialMediaTable" )
          ) # end of box 1
          
          # start box 2
          , box( title = "School Location"
                 , status = "info"
                 , solidHeader = TRUE
                 , collapsible = TRUE
                 , collapsed = FALSE
                 , width = 6
                 , DT::dataTableOutput( outputId = "locationTable" )
                 ) # end of box 2
          
        ) # end of row 1
      
      # start row 2
      , fluidRow(
        
        # start box 1
        box( title = "Hours of Operation"
             , status = "info"
             , solidHeader = TRUE
             , collapsible = TRUE
             , collapsed = FALSE
             , width = 4
             , DT::dataTableOutput( outputId = "hoursTable" )
             ) # end of box 2
        
        # start box 2
        , box( title = "Contact Information"
             , status = "info"
             , solidHeader = TRUE
             , collapsible = TRUE
             , collapsed = FALSE
             , width = 4
             , DT::dataTableOutput( outputId = "contactTable")
             ) # end of box 2
        
        # start box 3
        , box( title = "Services Offered"
               , status = "info"
               , solidHeader = TRUE
               , collapsible = TRUE
               , collapsed = FALSE
               , width = 4
               , DT::dataTableOutput( outputId = "servicesTable" )
        ) # end of box 3
        
        
      ) # end of row 2
      
      # start of row 3
      , fluidRow(
        
        # start box 1
        box( title = "Student Demographics"
             , status = "info"
             , solidHeader = TRUE
             , collapsible = TRUE
             , collapsed = FALSE
             , width = 4
             , DT::dataTableOutput( outputId = "demographicsTable" )
             ) # end of box 1
        
        # start box 2
        , box( title = "School Type & Grades Offered"
               , status = "info"
               , solidHeader = TRUE
               , collapsible = TRUE
               , collapsed = FALSE
               , width = 4
               , DT::dataTableOutput( outputId = "typeTable" )
        ) # end of box 2
        
        # start box 3
        , box( title = "School Statistics"
               , status = "info"
               , solidHeader = TRUE
               , collapsible = TRUE
               , collapsed = FALSE
               , width = 4
               , DT::dataTableOutput( outputId = "statsTable" )
               ) # end of box 3
        
      ) # end of row 3
      
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
  custom_legend_icon <- "<img src='https://github.com/cenuno/shiny/raw/master/Images/circleMarkerLegend/blue_CM.png'
style='width:40px;height:35px;'> Primarily High School<br/>

<img src='https://github.com/cenuno/shiny/raw/master/Images/circleMarkerLegend/orange_CM.png'
style='width:40px;height:35px;'> Primarily Middle School<br/>

<img src='https://github.com/cenuno/shiny/raw/master/Images/circleMarkerLegend/yellow_CM.png'
style='width:40px;height:35px;'> Primarily Elementary School"
  
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
    if( input$dropDown == "Citywide" ){
    
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
        addCircleMarkers( data = cps_sy1617[ cps_sy1617$School_ID %in% gradesServed( 
          a.list.object = cps_sy1617$Separated_GradesOffered_All
          , grades = input$gradesOffered
        ) , ]
                           , lng = cps_sy1617[ cps_sy1617$School_ID %in% gradesServed( 
                             a.list.object = cps_sy1617$Separated_GradesOffered_All
                             , grades = input$gradesOffered
                           ) , ]$School_Longitude
                           , lat = cps_sy1617[ cps_sy1617$School_ID %in% gradesServed( 
                             a.list.object = cps_sy1617$Separated_GradesOffered_All
                             , grades = input$gradesOffered
                           ) , ]$School_Latitude
                           , label = cps_sy1617[ cps_sy1617$School_ID %in% gradesServed( 
                             a.list.object = cps_sy1617$Separated_GradesOffered_All
                             , grades = input$gradesOffered
                           ) , ]$Long_Name
                           , labelOptions = labelOptions( style = list(
                                                            "font-family" = "Ostrich Sans Black"
                                                            , "font-weight" =  "bold"
                                                            , "cursor" = "pointer"
                                                            , "font-size" = "20px"
                                                          ))
                           , popup = paste0( "<b> School ID: </b>"
                                             , cps_sy1617[ cps_sy1617$School_ID %in% gradesServed( 
                                               a.list.object = cps_sy1617$Separated_GradesOffered_All
                                               , grades = input$gradesOffered
                                             ) , ]$School_ID
                                             , "<br>"
                                             , "<b> School Short Name: </b>"
                                             , cps_sy1617[ cps_sy1617$School_ID %in% gradesServed( 
                                               a.list.object = cps_sy1617$Separated_GradesOffered_All
                                               , grades = input$gradesOffered
                                             ) , ]$Short_Name
                                             , "<br>"
                                             , "<b> School Long Name: </b>"
                                             , cps_sy1617[ cps_sy1617$School_ID %in% gradesServed( 
                                               a.list.object = cps_sy1617$Separated_GradesOffered_All
                                               , grades = input$gradesOffered
                                             ) , ]$Long_Name
                                             , "<br>"
                                             , "<b> Grades Served: </b>"
                                             , cps_sy1617[ cps_sy1617$School_ID %in% gradesServed( 
                                               a.list.object = cps_sy1617$Separated_GradesOffered_All
                                               , grades = input$gradesOffered
                                             ) , ]$Grades_Offered
                                             , "<br>"
                                             , "<b> Community Area: </b>"
                                             , stringr::str_to_title( cps_sy1617[ cps_sy1617$School_ID %in% gradesServed( 
                                               a.list.object = cps_sy1617$Separated_GradesOffered_All
                                               , grades = input$gradesOffered
                                             ) , ]$Community_Area )
                                             , "<br>"
                                             , "<b> CPS School Profile: </b>"
                                             , cps_sy1617[ cps_sy1617$School_ID %in% gradesServed( 
                                               a.list.object = cps_sy1617$Separated_GradesOffered_All
                                               , grades = input$gradesOffered
                                             ) , ]$Active_CPS_School_Profile
                           )
                          , color = ~pal( cps_sy1617[ cps_sy1617$School_ID %in% gradesServed( 
                            a.list.object = cps_sy1617$Separated_GradesOffered_All
                            , grades = input$gradesOffered
                          ) , ]$Primary_Category )
                          , stroke = FALSE
                          , fillOpacity = 1
                          , radius = 6
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
        addPolylines( data = comarea606[ comarea606$community == str_to_upper( input$dropDown ) , ]
                      , stroke = TRUE
                      , weight = 10
                      , fillOpacity = 1
                      , color = "orange"
                      ) %>%
        
        
        #plot points which are only located
        # in the community area selected
        addCircleMarkers( data = dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )
                    , lng = dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$School_Longitude
                    , lat = dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$School_Latitude
                    , label = dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$Long_Name
                    , labelOptions = labelOptions( style = list( "font-family" = "Ostrich Sans Black"
                                                                 , "font-weight" =  "bold"
                                                                 , "cursor" = "pointer"
                                                                 , "font-size" = "20px"
                                                                 )
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
                                      , dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$Active_CPS_School_Profile
                    )
                    , color = ~pal( dplyr::filter( cps_sy1617, Community_Area == str_to_upper( input$dropDown ) )$Primary_Category )
                    , stroke = FALSE
                    , fillOpacity = 0.5
                    , radius = 6
        ) %>%
          
        # add custom legend to mark primary category of CPS schools
        addControl( html = custom_legend_icon
                    , position = "bottomleft"
        )
      } # end of else statement

      

  }) # end of render map
  
  # render social media datatable
  output$socialMediaTable <- DT::renderDataTable({
    
      # make datatable 
      DT::datatable( data = dplyr::arrange( dplyr::select( cps_sy1617
                                           , School_ID
                                           , Long_Name
                                           , Click_CPS_Profile
                                           , Click_Website
                                           , Click_Youtube
                                           , Click_Facebook
                                           , Click_Twitter
                                           , Click_Pinterest
                                           , CPS_School_Profile
                                           , Website
                                           , Pinterest
                                           , Facebook
                                           , Twitter
                                           , Youtube
                                           , Community_Area
      ) # end of select certain columns
      , Long_Name
      ) # end of arrange datatable by Long Name
      , rownames = FALSE
      , colnames = c( "School_ID" 
                      , "Long_Name"
                      , "CPS_Profile"
                      , "Website"
                      , "Youtube"
                      , "Facebook"
                      , "Twitter"
                      , "Pinterest"
                      , "CPS_Profile_link"
                      , "Website_link"
                      , "Facebook_link"
                      , "Twitter_link"
                      , "Youtube_link"
                      , "Pinterest_link"
                      , "Community_Area"
                      )
      , filter = "top"
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
      
      , escape = FALSE
      
      ) # end of datatable
    
  }) # end of render social media datatable
  
  # render location datatable
  output$locationTable <- DT::renderDataTable({

      # make datatable 
      DT::datatable( data = dplyr::arrange( dplyr::select( cps_sy1617
                                           , School_ID
                                           , Long_Name
                                           , Address
                                           , City
                                           , State
                                           , Zip
                                           , School_Longitude
                                           , School_Latitude
                                           , Community_Area
                                           , Attendance_Boundaries
                                           , Transportation_Bus
                                           , Transportation_El
                                           , Transportation_Metra
                                           ) # end of select certain columns
                                           , Long_Name
      ) # end of arrange datatable by Long Name
                     , rownames = FALSE
                     , filter = "top"
                     , extensions = 'Buttons'
                     , options = list( autoWidth = TRUE
                                       , dom = "Blfrtip"
                                       , buttons = list( "copy"
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
      
      ) # end of datatable
    
  }) # end of render location table
  
  # render hours datatable
  output$hoursTable <- DT::renderDataTable({
    
    DT::datatable( data = dplyr::arrange( dplyr::select( cps_sy1617
                                         , School_ID
                                         , Long_Name
                                         , School_Hours
                                         , Freshman_Start_End_Time
                                         , Earliest_Drop_Off_Time
                                         , After_School_Hours
                                         , Community_Area
                                         ) # end of select certain columns
                                         , Long_Name
    ) # end of arrange datatable by Long Name
                   , rownames = FALSE
                   , filter = "top"
                   , extensions = 'Buttons'
                   , options = list( autoWidth = TRUE
                                     , dom = "Blfrtip"
                                     , buttons = list( "copy"
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
                   
    ) # end of datatable
    
    
  }) # end of render hours table
  
  # render contact datatable
  output$contactTable <- DT::renderDataTable({

    DT::datatable( data = dplyr::arrange( dplyr::select( cps_sy1617
                                         , School_ID
                                         , Long_Name
                                         , Phone
                                         , Fax
                                         , Administrator_Title
                                         , Administrator
                                         , Secondary_Contact_Title
                                         , Secondary_Contact
                                         , Third_Contact_Title
                                         , Third_Contact_Name
                                         , Fourth_Contact_Title
                                         , Fourth_Contact_Name
                                         , Fifth_Contact_Title
                                         , Fifth_Contact_Name
                                         , Sixth_Contact_Title
                                         , Sixth_Contact_Name
                                         , Seventh_Contact_Title
                                         , Seventh_Contact_Name
                                         , Community_Area
                   ) # end of select certain columns
                   , Long_Name
    ) # end of arrange datatable by Long Name
                   , rownames = FALSE
                   , filter = "top"
                   , extensions = 'Buttons'
                   , options = list( autoWidth = TRUE
                                     , dom = "Blfrtip"
                                     , buttons = list( "copy"
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
                   
    ) # end of datatable
    
  }) # end of render contact table
  
  # render type datatable
  output$typeTable <- DT::renderDataTable({
    
    DT::datatable( data = dplyr::arrange( dplyr::select( cps_sy1617
                                         , School_ID
                                         , Long_Name
                                         , School_Type
                                         , Classification_Description
                                         , Grades_Offered_All
                                         , Primary_Category
                                         , PreK_School_Day
                                         , Kindergarten_School_Day
                                         , Is_Pre_School
                                         , Is_Elementary_School
                                         , Is_Middle_School
                                         , Is_High_School
                                         , Community_Area
                                         ) # end of select columns
                                         , Long_Name
    ) # end of arrange datatable by Long Name
                   , rownames = FALSE
                   , filter = "top"
                   , extensions = 'Buttons'
                   , options = list( autoWidth = TRUE
                                     , dom = "Blfrtip"
                                     , buttons = list( "copy"
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
                   
                   ) # end of datatable
    
  }) # end of render school type table
  
  # render demographics table
  output$demographicsTable <- DT::renderDataTable({
    
    DT::datatable( data = dplyr::arrange( dplyr::select( cps_sy1617
                                         , School_ID
                                         , Long_Name
                                         , Demographic_Description
                                         , Statistics_Description
                                         , Student_Count_Total                 
                                         , Student_Count_Low_Income               
                                         , Student_Count_Special_Ed             
                                         , Student_Count_English_Learners        
                                         , Student_Count_Black                 
                                         , Student_Count_Hispanic               
                                         , Student_Count_White                
                                         , Student_Count_Asian                
                                         , Student_Count_Native_American         
                                         , Student_Count_Other_Ethnicity        
                                         , Student_Count_Asian_Pacific_Islander  
                                         , Student_Count_Multi   
                                         , Student_Count_Hawaiian_Pacific_Islander
                                         , Student_Count_Ethnicity_Not_Available
                                         , Community_Area
                                         ) # end of select certain columns
                                         , Long_Name
    ) # end of arrange datatable by Long Name
                   , rownames = FALSE
                   , filter = "top"
                   , extensions = 'Buttons'
                   , options = list( autoWidth = TRUE
                                     , dom = "Blfrtip"
                                     , buttons = list( "copy"
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
                   
                   ) # end of datatable
    
    
  }) # end of render demographics table
  
  # render services table
  output$servicesTable <- DT::renderDataTable({
    
    DT::datatable( data = dplyr::arrange( dplyr::select( cps_sy1617
                                         , School_ID
                                         , Long_Name
                                         , ADA_Accessible
                                         , Dress_Code
                                         , Classroom_Languages
                                         , Bilingual_Services
                                         , Refugee_Services
                                         , Title_1_Eligible
                                         , PreSchool_Inclusive
                                         , Preschool_Instructional
                                         , Significantly_Modified
                                         , Hard_Of_Hearing
                                         , Visual_Impairments
                                         , Community_Area
                                         ) # end of select certain columns
                                         , Long_Name
    ) # end of arrange datatable by Long Name
                   , rownames = FALSE
                   , filter = "top"
                   , extensions = 'Buttons'
                   , options = list( autoWidth = TRUE
                                     , dom = "Blfrtip"
                                     , buttons = list( "copy"
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
                   
                   ) # end of datatable
    
  }) # end of render services table
  
  # render statistics table
  output$statsTable <- DT::renderDataTable({
    
    DT::datatable( data = dplyr::arrange( dplyr::select( cps_sy1617
                                         , School_ID
                                         , Long_Name
                                         , Average_ACT_School
                                         , Mean_ACT
                                         , College_Enrollment_Rate_School
                                         , College_Enrollment_Rate_Mean
                                         , Graduation_Rate_School
                                         , Graduation_Rate_Mean
                                         , Overall_Rating
                                         , Rating_Status
                                         , Rating_Statement
                                         , Community_Area
                                         ) # end of select certain columns
                                         , Long_Name
    ) # end of arrange datatable by Long Name
                   , rownames = FALSE
                   , filter = "top"
                   , extensions = 'Buttons'
                   , options = list( autoWidth = TRUE
                                     , dom = "Blfrtip"
                                     , buttons = list( "copy"
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
                   
                   ) # end of datatable
    
  }) # end of render stats table
  
} # end of server

# Run the application 
shinyApp(ui = ui, server = server)

