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

## make Server ##
server <- function( input, output){
  
  # render the map
  output$map <- leaflet::renderLeaflet({
    comarea606.map
  })
  
  #### If statement for Dynamic Leaflet Legend ####
  observeEvent( input$map_groups,{
    
    map <- leafletProxy("map") %>% clearControls()
    
    if( input$map_groups == "% Living in Crowded Housing" ){
      
      map <- map %>%
        
        addLegend( position = "bottomright"
                   , title = "Legend"
                   , group = "% Living in Crowded Housing"
                   , colors = unique( comarea606@data[ order( comarea606@data$PERCENT.OF.HOUSING.CROWDED ) , ]$color_PERCENT.OF.HOUSING.CROWDED )
                   , opacity = 1
                   , labels = c( "0.3% - 1.8%"
                                 , "1.9% - 3.2%"
                                 , "3.3% - 4.5%"
                                 , "4.7% - 7.4%"
                                 , "7.6% - 15.8%" ) ) %>%
        
        addControl( html = northArrowIcon
                    , position = "bottomleft" ) %>%
        
        addControl( html = mapTitle
                    , position = "topleft" )
      
    } else if( input$map_groups == "% Households Below Poverty" ){
      
      map <- map %>%
        
        addLegend( position = "bottomright"
                   , title = "Legend"
                   , group = "% Households Below Poverty"
                   , colors = unique( comarea606@data[ order( comarea606@data$PERCENT.HOUSEHOLDS.BELOW.POVERTY ) , ]$color_PERCENT.HOUSEHOLDS.BELOW.POVERTY )
                   , opacity = 1
                   , labels = c( "3.3% - 12.3%"
                                 , "12.9% - 16.9%"
                                 , "17.1% - 21.7%"
                                 , "23.4% - 29.6%"
                                 , "29.5% - 56.5%" ) ) %>%
        
        addControl( html = northArrowIcon
                    , position = "bottomleft" ) %>%
        
        addControl( html = mapTitle
                    , position = "topleft" )
      
    } else if( input$map_groups == "% Unemployed (Age 16+)" ){
      
      map <- map %>%
        
        addLegend( position = "bottomright"
                   , title = "Legend"
                   , group = "% Unemployed (Age 16+)"
                   , colors = unique( comarea606@data[ order( comarea606@data$PERCENT.AGED.16..UNEMPLOYED ) , ]$color_PERCENT.AGED.16..UNEMPLOYED )
                   , opacity = 1
                   , labels = c( "4.7% - 8.7%"
                                 , "12.9% - 16.9%"
                                 , "17.1% - 21.7%"
                                 , "23.4% - 29.6%"
                                 , "29.8% - 56.5%" ) ) %>%
        
        addControl( html = northArrowIcon
                    , position = "bottomleft" ) %>%
        
        addControl( html = mapTitle
                    , position = "topleft" )
      
    } else if( input$map_groups == "% Without High School Diploma (Age 25+)" ){
      
      map <- map %>%  
        
        addLegend( position = "bottomright"
                   , title = "Legend"
                   , group = "% Without High School Diploma (Age 25+)"
                   , colors = unique( comarea606@data[ order( comarea606@data$PERCENT.AGED.25..WITHOUT.HIGH.SCHOOL.DIPLOMA ) , ]$color_PERCENT.AGED.25..WITHOUT.HIGH.SCHOOL.DIPLOMA )
                   , opacity = 1
                   , labels = c( "2.5% - 10.9%"
                                 , "11.0% - 15.9%"
                                 , "16.2% - 20.8%"
                                 , "21.0% - 28.5%"
                                 , "31.2% - 54.8%" ) ) %>%
        
        addControl( html = northArrowIcon
                    , position = "bottomleft" ) %>%
        
        addControl( html = mapTitle
                    , position = "topleft" )
      
    } else if( input$map_groups == "% Under Age 18 and Over Age 64" ){
      
      map <- map %>%
        
        addLegend( position = "bottomright"
                   , title = "Legend"
                   , group = "% Under Age 18 and Over Age 64"
                   , colors = unique( comarea606@data[ order( comarea606@data$PERCENT.AGED.UNDER.18.OR.OVER.64 ) , ]$color_PERCENT.AGED.UNDER.18.OR.OVER.64)
                   , opacity = 1
                   , labels = c( "13.5% - 30.7%"
                                 , "31.6% - 36.4%"
                                 , "36.8% - 39.0%"
                                 , "39.2% - 41.0%"
                                 , "41.1% - 51.5%" ) ) %>%
        
        addControl( html = northArrowIcon
                    , position = "bottomleft" ) %>%
        
        addControl( html = mapTitle
                    , position = "topleft" )
      
    } else if( input$map_groups == "Per Capita Income" ){
      
      map <- map %>%
        
        addLegend( position = "bottomright"
                   , title = "Legend"
                   , group = "Per Capita Income"
                   , colors = unique( comarea606@data[ order( comarea606@data$PER.CAPITA.INCOME ) , ]$color_PER.CAPITA.INCOME )
                   , opacity = 1
                   , labels = c( "$8,201 - $14,685"
                                 , "$15,089 - $17,949"
                                 , "$18,672 - $23,791"
                                 , "$23,939 - $33,385"
                                 , "$34,381 - $88,669" ) ) %>%
        
        addControl( html = northArrowIcon
                    , position = "bottomleft" ) %>%
        
        addControl( html = mapTitle
                    , position = "topleft" )
      
    } else if( input$map_groups == "Hardship Index" ){
      
      map <- map %>%
        
        addLegend( position = "bottomright"
                   , title = "Legend"
                   , group = "Hardship Index"
                   , colors = unique( comarea606@data[ order( comarea606@data$HARDSHIP.INDEX ) , ]$color_HARDSHIP.INDEX )
                   , opacity = 1
                   , labels = c( "1 - 20"
                                 , "21 - 39"
                                 , "41 - 58"
                                 , "60 - 78"
                                 , "79 - 98" ) ) %>%
        
        addControl( html = northArrowIcon
                    , position = "bottomleft" ) %>%
        
        addControl( html = mapTitle
                    , position = "topleft" )
      
    } # end of if else statements
  }) # end of observe event
  
} # end of server

## end of script ##

