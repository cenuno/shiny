# Interactive_UI

## Introduction

`Interactive_UI` stores `r` code to make a shiny user-interface interactive.

## Run App Yourself

Run the following lines of code in `R`. 

```R
# install necessary packages
install.packages( c( "shiny"              # Web Application Framework for R
                     , "shinydashboard"   # Create Dashboards with 'Shiny'
                     , "leaflet"          # Create Interactive Web Maps with the JavaScript 'Leaflet' Library
                     , "htmltools"        # Tools for HTML
                     , "htmlwidgets"      # HTML Widgets for R
                     , "dplyr"            # A Grammar of Data Manipulation
                     , "magrittr"         # Ceci n'est pas une pipe
                     , "DT"               # A Wrapper of the JavaScript Library 'DataTables'
                     , "magrittr"          # Interactive Viewing of Spatial Data in R
                     )
                     )
# load necessary packages
library( shiny )

# call Shiny app from GitHub
shiny::runURL( url = "https://github.com/cenuno/shiny/archive/master.zip"
                 , subdir = "Interactive_UI"
               )

## end of script ##
```
