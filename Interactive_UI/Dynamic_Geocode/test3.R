
# install GitHub Version of Leaflet
if( !require( package = "devtools") ) install.packages( pkgs = "devtools" )
devtools::install_github('rstudio/leaflet')

# load leaflet package
library( leaflet )

# create leaflet map
myMap <- leaflet() %>%
  addTiles() %>%
  setView( lng = -87.567215
           , lat = 41.822582
           , zoom = 11 ) %>%
  setMaxBounds( lng1 = -87.94011
                , lat1 = 41.64454
                , lng2 = -87.52414
                , lat2 = 42.02304 )

# display leaflet map
myMap
