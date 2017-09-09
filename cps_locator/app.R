#
# Author:   Cristian E. Nuno
# Date:     September 9, 2017
# Purpose:  Dynamic Filtering of Data With Shiny & Leaflet
#

# # Install necessary packages
# install.packages( c("shiny", "DT", "shinydashboard", "dplyr"
#                     , "magrittr", "htmltools", "htmlwidgets"
#                     , "sp", "splancs", "stringr", "rgeos" 
#                     , "devtools", "bitops", "RCurl", "rgdal"
# ) )
# 
# # install `leaflet` package from source
# # for more info, click here: https://rstudio.github.io/leaflet/
# devtools::install_github( "rstudio/leaflet" )


# Import necessary packages
library( bitops )
library( RCurl )
library( shiny )
library( shinydashboard )
library( DT )
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

# store raw url of gradesServed function
rawGradesServed_url <- "https://raw.githubusercontent.com/cenuno/shiny/master/cps_locator/Functions/gradesServed.R"

# call function from GitHub
source_github( url = rawGradesServed_url )

################## Pre work ######################
#### Time to Import Processed CPS SY1617 and  ####
#### Raw Chicago Community Area Boundary Data ####
##################################################

# Import cps_sy1617_processed.RDS from the /Data/processed-data folder
cps_sy1617_Processed_RDS_url <- "https://github.com/cenuno/shiny/blob/master/cps_locator/Data/processed-data/cps_sy1617_processed.RDS?raw=true"
cps_sy1617 <- readRDS( gzcon( url( cps_sy1617_Processed_RDS_url ) ) )

# Import comarea606_raw.RDS from the /Data/raw-data folder
comarea606Raw_RDS_url <- "https://github.com/cenuno/shiny/blob/master/cps_locator/Data/raw-data/comarea606_raw.RDS?raw=true"
comarea606 <- readRDS( gzcon( url( comarea606Raw_RDS_url ) ) )

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
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "cps_locator.css")
  )
  
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
                      , "YouTube"
                      , "Facebook"
                      , "Twitter"
                      , "Pinterest"
                      , "CPS_Profile_link"
                      , "Website_link"
                      , "Facebook_link"
                      , "Twitter_link"
                      , "YouTube_link"
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

