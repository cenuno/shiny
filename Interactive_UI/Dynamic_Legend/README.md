# Overview

![](/Users/cristiannuno/Desktop/chicago_SE_2008_2012_ss.png)

This Shiny app updates a Leaflet map's legend based on which layer - socioeconomic variable - the user selects on the top right of the map. 

# Run App

Run the app yourself using the following lines of code:

```R
# install CRAN packages
install.packages( pkgs = c( "devtools", magrittr", "shiny"
                            , "sp", "stringr", "rgdal"
                            )
                    )
                    
# install developmental `leaflet` package from GitHub
devtools::install_github( "rstudio/leaflet" )

# load the shiny package
library( shiny )

# Run shiny app from your R/RStudio Console
shiny::runUrl( url = "https://github.com/cenuno/shiny/archive/master.zip"
                , subdir = "Dynamic_Legend"
                )
```

# Data

The following data sources were used from the City of Chicago's Open Data Portal:

* [Boundaries for the 77 current community areas](https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Community-Areas-current-/cauq-8yn6)

* [Census Data - Selected socioeconomic indicators in Chicago, 2008 – 2012](https://data.cityofchicago.org/Health-Human-Services/Census-Data-Selected-socioeconomic-indicators-in-C/kn9c-c2s2)


# Structure

* `global.R`: import, filter, and create objects to be used in `server.R`.
* `ui.R`: create the user-interface and objects to be used in `server.R`.
* `server.R`: performs a group of coordinated functions, tasks, or activities for the benefit of the user<sup>1</sup>.

# References

For more information, please see the following references:

* <sup>1</sup>[Application Software](https://en.wikipedia.org/wiki/Application_software)
* [Web Mapping in R using Leafet](https://bhaskarvk.github.io/leaflet-talk-rstudioconf-2017/RstudioConf2017.html#1)

* [Best Practices: Shiny Development](https://community.rstudio.com/t/best-practices-shiny-development/1694)

