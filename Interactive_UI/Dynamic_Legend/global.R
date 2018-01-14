#
# Author:     Cristian E. Nuno
# Date:       January 14, 2018
# Purpose:    Dynamic Legends on a Leaflet Map
#

## import necessary packages ##
library( magrittr )
library( leaflet )
library( shiny )
library( sp )
library( stringr )
library( rgdal )

## import data ##

# chicago socioeconomic indicators, 2008-2012
chicago.se.indicators <- read.csv( file = "https://data.cityofchicago.org/api/views/kn9c-c2s2/rows.csv?accessType=DOWNLOAD"
                                   , header = TRUE
                                   , stringsAsFactors = FALSE
)
# chicago current community areas
comarea606 <- rgdal::readOGR( dsn = "https://data.cityofchicago.org/api/geospatial/cauq-8yn6?method=export&format=GeoJSON"
                              , layer = "OGRGeoJSON"
                              , stringsAsFactors = FALSE
)
# north arrow icon url
northArrowIcon <- "<img src='http://ian.umces.edu/imagelibrary/albums/userpics/10002/normal_ian-symbol-north-arrow-2.png' style='width:40px;height:60px;'>"

# make custom map title
mapTitle <- paste0(
  "<p style='color:#ED7B46; font-size:20px;'>"
  , "Census Data - Selected socioeconomic indicators in Chicago, 2008 – 2012"
  , "</p>"
)

## filter data ##

# exclude citywide row
chicago.se.indicators <- chicago.se.indicators[ which( !is.na( chicago.se.indicators$Community.Area.Number ) ) , ]

# exclude first two columns
se.values <- list( chicago.se.indicators$PERCENT.OF.HOUSING.CROWDED
                   , chicago.se.indicators$PERCENT.HOUSEHOLDS.BELOW.POVERTY
                   , chicago.se.indicators$PERCENT.AGED.16..UNEMPLOYED
                   , chicago.se.indicators$PERCENT.AGED.25..WITHOUT.HIGH.SCHOOL.DIPLOMA
                   , chicago.se.indicators$PERCENT.AGED.UNDER.18.OR.OVER.64
                   , chicago.se.indicators$PER.CAPITA.INCOME
                   , chicago.se.indicators$HARDSHIP.INDEX
)
names( se.values ) <- colnames( chicago.se.indicators )[ -c( 1:2 ) ]

# create GroupValuesIntoColors() function
GroupValuesIntoColors <- function( list.of.values, desired.breaks, min.color, max.color ){
  
  # check for list and for integer 
  if( !is.list( list.of.values ) ){
    stop("list.of.values is not a list.")
  } else if( !is.numeric( desired.breaks ) ){
    stop("desired.breaks is not numeric." )
  }
  
  # make colors from min.color to max.color
  color.function <- colorRampPalette( c( min.color, max.color) )
  
  # decide how many groups I want
  color.ramp <- color.function( desired.breaks )
  
  # group values into colors
  list.of.colors <- lapply( X = list.of.values
                            , FUN = function(i) 
                              as.character(
                                cut( # use cut to divide the range of i values into intervals
                                  x = rank( i ) # used to rank the values (always assigning order)
                                  , breaks = desired.breaks # define the numbers of groups to place certain values of X
                                  , labels = color.ramp # label the groups a color from color.ramp
                                )
                              )
  )
  # place 'color_' into the names of the values list.of.colors
  names( list.of.colors ) <- paste( "color"
                                    , names( list.of.values )
                                    , sep = "_"
  )
  # return list.of.colors to the Global Environment
  return( list.of.colors )
} # end of GroupValuesIntoColors() function

# use GroupValuesIntoColors() function
se.color.values <- GroupValuesIntoColors( list.of.values = se.values
                                          , desired.breaks = 5
                                          , min.color = "#CCCCCC"
                                          , max.color = "#104E8B"
)

# cbind se.color.values to chicago.se.indicators
chicago.se.indicators <- cbind.data.frame( chicago.se.indicators
                                           , se.color.values
                                           , stringsAsFactors = FALSE
)
## merge non spatial data onto spatial data frame ##
comarea606 <- sp::merge( x = comarea606
                         , y = chicago.se.indicators
                         , by.x = "area_numbe"
                         , by.y = "Community.Area.Number"
)

## create Leaflet map ##
# Thank you, SO: https://stackoverflow.com/questions/36365897/r-leaflet-zoomcontrol-option
comarea606.map <- leaflet( options = leafletOptions( zoomControl = FALSE
                                                     , dragging = FALSE 
) ) %>%
  
  # set zoom level
  # so that all 77 community areas can be seen when the
  # map is opened
  # Note: the lng/lat pair is northeast of Promontory Point
  # between West Pershing Rd and W 47th st
  setView( lng = -87.567215
           , lat = 41.822582
           , zoom = 11 ) %>%
  
  # add background to map
  addTiles( urlTemplate = "https://{s}.tile.openstreetmap.se/hydda/base/{z}/{x}/{y}.png" ) %>%
  
  # add polygon to map by
  # the color related to one and only one socioeconomic indicator
  addPolygons( data = comarea606
               , fillOpacity = 1
               , fillColor = ~color_PERCENT.OF.HOUSING.CROWDED
               , opacity = 1
               , color = "#161F48"
               , weight = 3
               , label = str_to_title( comarea606@data$community )
               , labelOptions = popupOptions( textsize = "25px"
                                              , textOnly = TRUE
                                              , style = list(
                                                "color" = "#ED7B46"
                                                , "font-family" = "Ostrich Sans Black black"
                                                , "font-weight" =  "bold"
                                                , "text-shadow" = "1px 1px #000000"
                                              )
               )
               , highlightOptions = highlightOptions( color = "#ED7B46"
                                                      , weight = 6
                                                      , opacity = 1 
               )
               
               , group = "% Living in Crowded Housing" ) %>%
  
  addPolygons( data = comarea606
               , fillOpacity = 1
               , fillColor = ~color_PERCENT.HOUSEHOLDS.BELOW.POVERTY
               , opacity = 1
               , color = "#161F48"
               , weight = 3
               , label = str_to_title( comarea606@data$community )
               , labelOptions = popupOptions( textsize = "25px"
                                              , textOnly = TRUE
                                              , style = list(
                                                "color" = "#ED7B46"
                                                , "font-family" = "Ostrich Sans Black black"
                                                , "font-weight" =  "bold"
                                                , "text-shadow" = "1px 1px #000000"
                                              )
               )
               , highlightOptions = highlightOptions( color = "#ED7B46"
                                                      , weight = 6
                                                      , opacity = 1
               )
               , group = "% Households Below Poverty" ) %>%
  
  addPolygons( data = comarea606
               , fillOpacity = 1
               , fillColor = ~color_PERCENT.AGED.16..UNEMPLOYED
               , opacity = 1
               , color = "#161F48"
               , weight = 3
               , label = str_to_title( comarea606@data$community )
               , labelOptions = popupOptions( textsize = "25px"
                                              , textOnly = TRUE
                                              , style = list(
                                                "color" = "#ED7B46"
                                                , "font-family" = "Ostrich Sans Black black"
                                                , "font-weight" =  "bold"
                                                , "text-shadow" = "1px 1px #000000"
                                              )
               )
               , highlightOptions = highlightOptions( color = "#ED7B46"
                                                      , weight = 6
                                                      , opacity = 1
               )
               , group = "% Unemployed (Age 16+)" ) %>%
  
  addPolygons( data = comarea606
               , fillOpacity = 1
               , fillColor = ~color_PERCENT.AGED.25..WITHOUT.HIGH.SCHOOL.DIPLOMA
               , opacity = 1
               , color = "#161F48"
               , weight = 3
               , label = str_to_title( comarea606@data$community )
               , labelOptions = popupOptions( textsize = "25px"
                                              , textOnly = TRUE
                                              , style = list(
                                                "color" = "#ED7B46"
                                                , "font-family" = "Ostrich Sans Black black"
                                                , "font-weight" =  "bold"
                                                , "text-shadow" = "1px 1px #000000"
                                              )
               )
               , highlightOptions = highlightOptions( color = "#ED7B46"
                                                      , weight = 6
                                                      , opacity = 1
               )
               , group = "% Without High School Diploma (Age 25+)" ) %>%
  
  addPolygons( data = comarea606
               , fillOpacity = 1
               , fillColor = ~color_PERCENT.AGED.UNDER.18.OR.OVER.64
               , opacity = 1
               , color = "#161F48"
               , weight = 3
               , label = str_to_title( comarea606@data$community )
               , labelOptions = popupOptions( textsize = "25px"
                                              , textOnly = TRUE
                                              , style = list(
                                                "color" = "#ED7B46"
                                                , "font-family" = "Ostrich Sans Black black"
                                                , "font-weight" =  "bold"
                                                , "text-shadow" = "1px 1px #000000"
                                              )
               )
               , highlightOptions = highlightOptions( color = "#ED7B46"
                                                      , weight = 6
                                                      , opacity = 1
               )
               , group = "% Under Age 18 and Over Age 64" ) %>%
  
  addPolygons( data = comarea606
               , fillOpacity = 1
               , fillColor = ~color_PER.CAPITA.INCOME
               , opacity = 1
               , color = "#161F48"
               , weight = 3
               , label = str_to_title( comarea606@data$community )
               , labelOptions = popupOptions( textsize = "25px"
                                              , textOnly = TRUE
                                              , style = list(
                                                "color" = "#ED7B46"
                                                , "font-family" = "Ostrich Sans Black black"
                                                , "font-weight" =  "bold"
                                                , "text-shadow" = "1px 1px #000000"
                                              )
               )
               , highlightOptions = highlightOptions( color = "#ED7B46"
                                                      , weight = 6
                                                      , opacity = 1
               )
               , group = "Per Capita Income" ) %>%
  
  addPolygons( data = comarea606
               , fillOpacity = 1
               , fillColor = ~color_HARDSHIP.INDEX
               , opacity = 1
               , color = "#161F48"
               , weight = 3
               , label = str_to_title( comarea606@data$community )
               , labelOptions = popupOptions( textsize = "25px"
                                              , textOnly = TRUE
                                              , style = list(
                                                "color" = "#ED7B46"
                                                , "font-family" = "Ostrich Sans Black black"
                                                , "font-weight" =  "bold"
                                                , "text-shadow" = "1px 1px #000000"
                                              )
               )
               , highlightOptions = highlightOptions( color = "#ED7B46"
                                                      , weight = 6
                                                      , opacity = 1
               )
               , group = "Hardship Index" ) %>%
  
  # change choropleth map by user-selected group
  addLayersControl( baseGroups = c( "% Living in Crowded Housing"
                                    , "% Households Below Poverty"
                                    , "% Unemployed (Age 16+)"
                                    , "% Without High School Diploma (Age 25+)"
                                    , "% Under Age 18 and Over Age 64"
                                    , "Per Capita Income"
                                    , "Hardship Index"
  )
  , options = layersControlOptions( collapsed = FALSE )
  , position = "topright" )

## end of script ##

