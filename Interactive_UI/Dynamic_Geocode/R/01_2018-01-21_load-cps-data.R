#
# Author:     Cristian E. Nuno
# Purpose:    Import Chicago Public School SY1718 Locations Data
#             and Export as RDS File
# Date:       January 21, 2018
#

# set working directory
setwd( dir = "/Users/cristiannuno/RStudio_All/shiny/Interactive_UI/Dynamic_Geocode/Data" )

# load necessary packages
library( sp )
library( rgdal )

# load necessary data
chicago.public.school.locations.sy1718 <-
  rgdal::readOGR( dsn = "https://data.cityofchicago.org/api/geospatial/4g38-vs8v?method=export&format=GeoJSON"
                  , layer = "OGRGeoJSON"
                  , stringsAsFactors = FALSE
                  )
# export Spatial Points Data Frame as an RDS file
saveRDS( object = chicago.public.school.locations.sy1718
         , file = "chicago.public.school.locations.sy1718.RDS"
         )

# end of script #
