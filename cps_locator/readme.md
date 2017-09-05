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

As of September 4, 2017 version 2.0 deployment, here is what needs to be done:

### Version 1.0
- [x] [Launch Version 1.0 of App](https://cenuno.shinyapps.io/cps_locator/)
- [x] [Post .R script of Version 1.0](https://github.com/cenuno/shiny/blob/master/cps_locator/app.R)

### Version 2.0
- [x] Solicit feedback
- [x] Launch Version 2.0 of App
- [x] Update .R script of Version 2.0
- [x] ~~Build a regular expression tool that returns a list of CPS schools based on user-defined grade level(s) of interest~~
- [x] Separate grades based on a user-defined drop-down selection by using a list

### Version 3.0
- [ ] Solicit feedback

#### Filtering Map
- [ ] Use the Checkbox Shiny Widget to allow users to filter which CPS schools appear on the Leaflet map based on the type of school (i.e. neighborhood, charter, military academy, etc.)
- [ ] Add CTA 'L' rail lines, CTA bus stops, and bike paths to indicate which schools are located near public transportation
- [ ] Download button where dataset is filtered based on which CPS schools are located on the map based on the users preferences.
- [ ] Radio button that filters schools by all categories, only primarily elementary schools, only primarily middle schools, or only primarliy high schools
- [ ] Slider widget that filters schools based on their [School Quality Rankings (Level 1+, Level 1, Level 2+, Level 2, and Level 3)](http://cps.edu/Performance/Documents/SQRP_Introduction.pdf)(slide page number 10, entitled *What Does the School's Rating Mean?*)

#### Download Data 
- [ ] Filter data tables by Citywide or by Community Area
- [ ] Enable a "master search" input box, where that value populates each datatables "Search" box
- [ ] Make collapsible buttons white on blue, rather than blue on white

#### Speed Up the App
- [ ] Save .RDS file of pre-processed data cleaning work inside of GitHub folder
- [ ] Build out folder structure of cps_locator app
- [ ] Split app.r file into two files: ui.r and server.r
- [ ] Create custom css file and save it in GitHub. This file will store all the color, font, spacing, and other customizations I used to modify the `shinydashboard` appearance.
- [ ] Clean up code and ensure readability -- doesn't matter if it works if no one else can learn from what I've written

Thank you everyone for your feedback and encouragement on this project!

*Last updated on September 4, 2017*

*****************
