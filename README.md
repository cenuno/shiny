# Using Shiny

Useful tips and tricks when creating shiny apps.
****

# CPS Locator

[![](https://github.com/cenuno/shiny/raw/master/Images/Screen%20Shot%202017-08-27%20at%203.50.54%20AM.png)](https://cenuno.shinyapps.io/cps_locator/)

[Chicago Public Schools (CPS) Locator](https://cenuno.shinyapps.io/cps_locator/) is a Shiny app, a web app made using the R programming language.

The goal is simple: to make finding a CPS school of interest easier using open-source tools. 

## Run App from RStudio/R Console

Copy and paste the following R commands to run the app locally on your machine:

```R
# Install necessary packages
install.packages( c("shiny", "DT", "shinydashboard", "dplyr"
                     , "magrittr", "htmltools", "htmlwidgets"
                     , "rgdal", "splancs", "stringr", "rgeos" 
                     , "devtools"
                     ) )
                     
# install `leaflet` package from source
# for more info, click here: https://rstudio.github.io/leaflet/
devtools::install_github("rstudio/leaflet")

# Load necessary packages
library( shiny )

# Run shiny app from your R/RStudio Console
shiny::runUrl( url = "https://github.com/cenuno/shiny/archive/master.zip"
                , subdir = "cps_locator"
                )
```

## Next Steps

As of August 27, 2017 deployment, here is what needs to continue to be done:

- [x] [Launch Version 1.0 of App](https://cenuno.shinyapps.io/cps_locator/)
- [x] [Post .R script of Version 1.0](https://github.com/cenuno/shiny/blob/master/cps_locator/app.R)
- [ ] Solicit feedback
- [ ] Build a regular expression tool that returns a list of CPS schools based on user-defined grade level(s) of interest
- [ ] Use the Checkbox Shiny Widget to allow users to filter which CPS schools appear on the Leaflet map based on the type of school (i.e. neighborhood, charter, military academy, etc.)
- [ ] Add CTA 'L' rail lines, CTA bus stops, and bike paths to indicate which schools are located near public transportation.
- [ ] Launch Version 2.0 of App
- [ ] Update .R script of Version 2.0

Thank you everyone for your feedback and encouragement on this project!

*Last updated on August 27, 2017*

*****************

## Customizing DT Download Button

To learn how to enable your shiny app user to download all rows of a data frame, [please click here](https://github.com/cenuno/shiny/tree/master/DT-Download-All-Rows-Button#summary).

![Screenshot of Downloading All Rows from DT within Shiny](https://github.com/cenuno/shiny/raw/master/Images/Screen%20Shot%202017-06-23%20at%203.16.36%20PM.png)
*Screenshot of Downloading All Rows from DT within Shiny*

****
