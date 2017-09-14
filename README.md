# Using Shiny

Useful tips and tricks when creating shiny apps.
****
# CPS Locator: making it easier to find the right Chicago Public School for you. 

[![CPS Locator Home Tab](https://github.com/cenuno/shiny/raw/master/Images/cps_locator_v2.png)](https://cenuno.shinyapps.io/cps_locator/)

[![CPS Locator Downloads Tab](https://github.com/cenuno/shiny/raw/master/Images/cps_locator_Downloads_v2.png)](https://cenuno.shinyapps.io/cps_locator/)

[Chicago Public Schools (CPS) Locator](https://cenuno.shinyapps.io/cps_locator/) is a web-based [Shiny app](https://shiny.rstudio.com/) that empowers users to interact firsthand with [CPS school year 2016-2017 data](https://data.cityofchicago.org/Education/Chicago-Public-Schools-School-Profile-Information-/8i6r-et8s).

## Run App from RStudio/R Console

Copy and paste the following R commands to run the app locally on your machine:

```R
# Install necessary packages
install.packages( c("shiny", "DT", "shinydashboard", "dplyr"
                     , "magrittr", "htmltools", "htmlwidgets"
                     , "sp", "splancs", "stringr", "rgeos" 
                     , "devtools", "bitops", "RCurl", "rgdal"
                     ) )
                     
# install `leaflet` package from source
# for more info, click here: https://rstudio.github.io/leaflet/
devtools::install_github( "rstudio/leaflet" )

# Load necessary packages
library( shiny )

# Run shiny app from your R/RStudio Console
shiny::runUrl( url = "https://github.com/cenuno/shiny/archive/master.zip"
                , subdir = "cps_locator"
                )
```

## Next Steps

Please check out the [CPS Locator Version 3.0 Projects Board](https://github.com/cenuno/shiny/projects/1) to get an update on the tasks remaining for this project. 


Thank you everyone for your feedback and encouragement on this project!

*Last updated on September 9, 2017*

*****************

## Customizing DT Download Button

To learn how to enable your shiny app user to download all rows of a data frame, [please click here](https://github.com/cenuno/shiny/tree/master/DT-Download-All-Rows-Button#summary).

![Screenshot of Downloading All Rows from DT within Shiny](https://github.com/cenuno/shiny/raw/master/Images/Screen%20Shot%202017-06-23%20at%203.16.36%20PM.png)
*Screenshot of Downloading All Rows from DT within Shiny*

****
