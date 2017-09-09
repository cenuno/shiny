#
# Author:   Cristian E. Nuno
# Date:     September 9, 2017
# Purpose:  Import Raw .CSV and GeoJSON files
#           from the Chicago Data Portal
#
# install necessary packages
# install.packages( "rgdal" )

# Import necessary packages
library( rgdal )

# import current community area boundaries
# for the City of Chicago
geojson_comarea_url <- "https://data.cityofchicago.org/api/geospatial/cauq-8yn6?method=export&format=GeoJSON"

# transform vector into spatial dataframe
comarea606 <- rgdal::readOGR( dsn = geojson_comarea_url
                       , layer = "OGRGeoJSON"
                       , stringsAsFactors = FALSE
)

# export comarea606 as RDS in the /Data/raw-data folder
saveRDS( object = comarea606
         , file = "/Users/cristiannuno/RStudio_All/shiny/cps_locator/Data/raw-data/comarea606_raw.RDS"
         )

# import chicago public school 
# information data for the 2016-2017 school year (SY1617)
cps_sy1617_url <- "https://data.cityofchicago.org/api/views/8i6r-et8s/rows.csv?accessType=DOWNLOAD"

# transform URL into a data frame using the base `read.csv` function
cps_sy1617 <- read.csv( file = cps_sy1617_url
                        , header = TRUE
                        , stringsAsFactors = FALSE
)

# export cps_sy1617 as RDS in the /Data/raw-data folder
saveRDS( object = cps_sy1617
         , file = "/Users/cristiannuno/Rstudio_All/shiny/cps_locator/Data/raw-data/cps_sy1617_raw.RDS"
         )

#########################################################
### Successfully Imported Raw Data into R Environment ###
### and Exported as .RDS files                        ###
#########################################################
