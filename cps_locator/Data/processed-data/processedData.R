#
# Author:   Cristian E. Nuno
# Date:     September 9, 2017
# Purpose:  Store the raw data from rawData.R.
#           Process the cps_sy1617 data frame.
#           Store the processed data for the CPS Locator app
#

# Import necessary packages
library( dplyr )
library( rgeos )
library( sp )
library( rgdal )
library( splancs )
library( bitops )
library( RCurl )

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

# Import comarea606_raw.RDS from the /Data/raw-data folder
comarea606Raw_RDS_url <- "https://github.com/cenuno/shiny/blob/master/cps_locator/Data/raw-data/comarea606_raw.RDS?raw=true"
comarea606 <- readRDS( gzcon( url( comarea606Raw_RDS_url ) ) )

# Import cps_sy1617_raw.RDS from the /Data/raw-data folder
cps_sy1617Raw_RDS_url <- "https://github.com/cenuno/shiny/blob/master/cps_locator/Data/raw-data/cps_sy1617_raw.RDS?raw=true"
cps_sy1617 <- readRDS( gzcon( url( cps_sy1617Raw_RDS_url ) ) )

# covert school ID to character
cps_sy1617$School_ID <- as.character( cps_sy1617$School_ID )
# going to add 14 new columns to cps_sy1617

# store raw url from separateGrades function
rawSeparateGrades_url <- "https://raw.githubusercontent.com/cenuno/shiny/master/cps_locator/Functions/separateGrades.R"

# call function from GitHub
source_github( url = rawSeparateGrades_url )

# use the separateGrades function
cps_sy1617$Separated_GradesOffered_All <- separateGrades( csv_column = cps_sy1617$Grades_Offered_All )

# name the list by school ID
names( cps_sy1617$Separated_GradesOffered_All ) <- cps_sy1617$School_ID

# enable web addresses to be clickable in datatables
# using Font Awesome (FA) icons
# http://fontawesome.io/
rawCreateClickFA_url <- "https://raw.githubusercontent.com/cenuno/shiny/master/cps_locator/Functions/createClickFA.R"

# call function from GitHub
source_github( url = rawCreateClickFA_url )

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

# create YouTube Button
cps_sy1617$Click_YouTube <- createClickFA( web_address = cps_sy1617$Youtube
                                           , btn_background_color = "#FF0000"
                                           , fa_icon = "fa-youtube-play"
)

# create Pinterest Button
cps_sy1617$Click_Pinterest <- createClickFA( web_address = cps_sy1617$Pinterest
                                             , btn_background_color = "#BD081B"
                                             , fa_icon = "fa-pinterest-p"
)

# enable web addresses to be clickable in datatables
# using a png image from the internet
rawCreateClickImage_url <- "https://raw.githubusercontent.com/cenuno/shiny/master/cps_locator/Functions/createClickImage.R"

# call function from GitHub
source_github( url = rawCreateClickImage_url )

# create clickable CPS school profiles
cps_sy1617$Click_CPS_Profile <- createClickImage( web_address = cps_sy1617$CPS_School_Profile
                                                  , img_source = "http://cps.edu/ScriptLibrary/Responsive/images/cpslogo@2x.png"
                                                  , height = 52
)

# create raw url of clickable button function
rawCreateClickButton_url <- "https://raw.githubusercontent.com/cenuno/shiny/master/cps_locator/Functions/createClickButton.R"

# call function from github
source_github( url = rawCreateClickButton_url )

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

# Call get_poly_matrix_coord function to access
# coordinate values within multiple polygons 
# inside a spatial data frame.
rawGetPolyMatrixCoord_url <- "https://raw.githubusercontent.com/cenuno/Spatial_Visualizations/master/Point-n-Polygon/get_poly_matrix_coord.r"

# call from GitHub
source_github( url = rawGetPolyMatrixCoord_url )

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

# store get_CA_names function in vector
rawGet_CA_Names_url <- "https://raw.githubusercontent.com/cenuno/Spatial_Visualizations/master/Point-n-Polygon/get_CA_names.r"

# call function from github
source_github( url = rawGet_CA_Names_url )

# assign individual points the name of the polygon they reside in
# by running the `get_CA_names` function
cps_sy1617 <- get_CA_names( a.data.frame = cps_sy1617
                            , a.list.of.matrices = com_area_polygons
                            , a.spatial.df = comarea606
)

# Save as .RDS file
saveRDS( object = cps_sy1617
         , file = "/Users/cristiannuno/RStudio_All/shiny/cps_locator/Data/processed-data/cps_sy1617_processed.RDS"
         )
