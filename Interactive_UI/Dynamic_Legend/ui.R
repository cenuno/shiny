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

## make UI ##
ui <- shiny::fluidPage(
  title = "Census Data - Selected socioeconomic indicators in Chicago, 2008 – 2012"
  , leaflet::leafletOutput( outputId = "map"
                            , height = 900
  )
)

## end of script ##

