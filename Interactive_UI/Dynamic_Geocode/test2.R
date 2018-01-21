#
# Author:   Cristian E. Nuno
# Date:     January 18, 2018
# Purpose:  Deny addresses whose Lat Lon is outside the bounding box
#

# import necessary packages
library( leaflet )
library( magrittr )
library( sp )
library( rgdal )


# import data
# import City of Chicago boundary
chicago.boundary <- rgdal::readOGR( dsn = "https://data.cityofchicago.org/api/geospatial/ewy2-6yfk?method=export&format=GeoJSON"
                                    , layer = "OGRGeoJSON"
                                    , stringsAsFactors = FALSE
                                    )

# import a few addresses
example.data <- data.frame(
  ID = 1:3
  , Place_Name = c( "Wrigley Field", "Guaranteed Rate Field", "NBT Bank Stadium" )
  , Long = c( -87.655333, -87.633752, -76.165413 )
  , Lat  = c( 41.948438, 41.829902, 43.079264 )
  , stringsAsFactors = FALSE
)

# test if each coordinate pair lays within 
# the city of chicago area by use of the bounding box
CoordinatesWithinBoundingBox <- function( lng, min.lng, max.lng, lat, min.lat, max.lat ){
  
  # create vector full of NAs
  true.or.false <- rep( x = NA, times = length( lng ) )
  
  # create condition
  condition <- lng >= min.lng && lng <= max.lng &
    lat >= min.lat && lat <= max.lat
  
  # if true, assign a value of TRUE
  if( condition ){
    
    true.or.false[ which( condition == TRUE ) ] <- TRUE
    
  } else{
    # if false, assign a value of FALSE
    true.or.false[ which( condition == FALSE ) ] <- FALSE
  }
  
  # return the vector to the Global Environment
  return( true.or.false )
  
} # end of CoordinatesWithinBoundingBox() function

# test
example.data$In_Chicago_Area <- mapply( FUN = CoordinatesWithinBoundingBox
                                   , example.data$Long
                                   , chicago.boundary@bbox[ "x", ][1]
                                   , chicago.boundary@bbox[ "x", ][2]
                                   , example.data$Lat
                                   , chicago.boundary@bbox[ "y", ][1]
                                   , chicago.boundary@bbox[ "y", ][2]
                                   )

# build map
myMap <- leaflet() %>%
  
  # add background to map
  addTiles( urlTemplate = "https://{s}.tile.openstreetmap.se/hydda/base/{z}/{x}/{y}.png" ) %>%
  

  fitBounds( lng1 = -87.94011
                , lat1 = 41.64454
                , lng2 = -87.52414
                , lat2 = 42.02304 ) %>%
  

  addCircleMarkers( lng = example.data$Long
                    , lat = example.data$Lat
                    , color = "#800000" )



