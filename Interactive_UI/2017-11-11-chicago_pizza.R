#
# Author:   Cristian E. Nuno
# Purpose:  Reproducible Example of Interactive UI for a Shiny App
# Date:     November 11, 2017
#

###############################
## Import Necessary Packages ##
###############################
library( shiny )
library( shinydashboard )
library( leaflet )
library( htmltools )
library( htmlwidgets )
library( dplyr )
library( magrittr )
library( DT )

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
                                                , times = 2 )
                                        , rep( x = "Lou Malnati's Pizza"
                                               , times = 2 )
                                        )
                             , Website = c( "https://giordanos.com/locations/hyde-park/"
                                            , "https://giordanos.com/locations/mccormick-place-west-loop/"
                                            , "https://www.loumalnatis.com/chicago-river-north"
                                            , "https://www.loumalnatis.com/evanston"
                                            )
                             , Phone = c( "773.947.0200"
                                          , "312.421.1221"
                                          , "312.828.9800"
                                          , "847.328.5400"
                                          )
                             , Full.Address = c( "5311 S Blackstone Ave, Chicago, IL 60615"
                                                 , "815 W Van Buren St #115, Chicago, IL 60607"
                                                 , "439 North Wells Street, Chicago, IL 60654"
                                                 , "1850 Sherman Avenue, Evanston, IL 60201"
                             )
                             , Lat = c( 41.799115
                                        , 41.876448
                                        , 41.890344
                                        , 42.051465
                                        )
                             , Lon = c( -87.590199
                                        , -87.647936
                                        , -87.633743
                                        , -87.682001
                                        )
                             , Description = c( "Take a bite of Giordano’s pizzas and dishes and we think you’ll agree that you’ve gone to pizza heaven! Stop by our South Blackstone Avenue location and try us for yourself. Prefer eating at home? Order for pickup or delivery!"
                                                , "What better way to start a night at the United Center or end a trip to the UIC campus than with a trip to Giordano’s? Will a full bar, dining room and private room, we have your needs covered! Prefer eating in? Take advantage of convenient online ordering, and request pickup or delivery."
                                                , "Lou Malnati’s River North was the sixth Lou Malnati's Pizzeria to open and the first within the Chicago city limits. This location offers dine in, carryout, delivery, group ordering, and drop-off catering.  Inside features a full service bar and a cozy atmosphere.  During the warmer months, al fresco dining is an option.  We know there are many restaurants in River North to choose from, but if you head to Lou’s we promise you won’t be disappointed!"
                                                , "Nestled between the growing downtown Evanston district and illustrious Northwestern University, Lou’s in Evanston is a favorite of students and residents alike.  This location offers dine in, carryout, and delivery as well as catering services.  In the warmer months, outdoor seating is available."
                                                )
                             , Deep.Dish = c( rep( x = "The Special"
                                                   , times = 2
                                                   )
                                              , rep( x = "The Malnati Chicago Classic"
                                                     , times = 2
                                                     )
                                              )
                             , Deep.Dish.Ingredients = c( rep( x = "Sausage, mushrooms, green peppers and onions."
                                                               , times = 2
                                                               )
                                                          , rep( x = "Lean sausage, some extra cheese and vine-ripened tomato sauce on their butter crust."
                                                                 , times = 2
                                                                 )
                                                          )
                             , stringsAsFactors = FALSE
                             ) # done creating chicago.pizza data frame
# check dim
dim( chicago.pizza ) # [1] 4 9

# check colnames
colnames( chicago.pizza )
# [1] "Pizzeria"              "Website"               "Phone"                
# [4] "Full.Address"          "Lat"                   "Lon"                  
# [7] "Description"           "Deep.Dish"             "Deep.Dish.Ingredients"

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
                           , titleWidth = 400
                           ,  tags$li( a( href = "https://cenuno.github.io/"
                                               , img( src = "https://github.com/cenuno/Spatial_Visualizations/raw/master/Images/UrbanDataScience_logo_2017-08-26.png"
                                                      , title = "Urban Data Science (GitHub)"
                                                      , height = "50px"
                                               )
                                               , style = "padding-top:10px; padding-bottom:10px;"
                           )
                           , class = "dropdown"
                           ) # end of Urban Data Science Logo
) # end of header

## customize body ##
body <- dashboardBody( 
  fluidRow( 
    box( title = "Battle of Two Pizzas: Giordano's Vs. Lou Malnati's"
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
           ) # end of drop down pizerriaType menu
           
           # start drop down deepDishType menu
           , shiny::selectizeInput( inputId = "deepDishType"
                                    , label = shiny::h3( "Select Your Favorite Type of Deep Dish" )
                                    , choices = c( "All"
                                                   , sort( unique( chicago.pizza$Deep.Dish ) ) 
                                                   )
                                    , selected = "All"
                                    ) # end of deepDishType menu
           
         ) # end of first column
         , column(
           width = 8
           # create leaflet map
           , leaflet::leafletOutput( outputId = "myMap", height = 600 )
         )
    ) # end of box
  ) # end of fluidRow 1
  , fluidRow(
    box( title = "View the Data"
         , status = "info"
         , solidHeader = TRUE
         , collapsible = FALSE
         , width = 12
         
         # create DataTable to view and export data
         , DT::dataTableOutput( outputId = "myDT", height = 600 )
         ) # end of box
  ) # end of fluidRow2
) # end of dashboard body

## Shiny UI ##
ui <- dashboardPage(
  header
  , body
)

# Define server logic
server <- function(input, output) {
  
  # render leaflet output
  output$myMap <- leaflet::renderLeaflet({
    
    # Create a palette that assigns
    # colors to LM's pizza and to G's pizza
    pal <- leaflet::colorFactor( palette = c( "#FFFF66" # laser lemon: ES
                                              , "#214FC6" # new car: HS
                                              , "#FF6D3A" # pumpkin: MS
    )
    , domain = c( "ES" # elementary
                  , "MS" # middle
                  , "HS" # high
    )
    )
  })
}





