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
- [x] Solicit feedback

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
- [x] Create custom css file and save it in GitHub. This file will store all the color, font, spacing, and other customizations I used to modify the `shinydashboard` appearance.
- [ ] Clean up code and ensure readability -- doesn't matter if it works if no one else can learn from what I've written

Thank you everyone for your feedback and encouragement on this project!

##### Session Configurations

```R
sessionInfo()
```
> R version 3.4.1 (2017-06-30)
> Platform: x86_64-apple-darwin15.6.0 (64-bit)
> Running under: macOS Sierra 10.12.6

> Matrix products: default
> BLAS: /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib
> LAPACK: /Library/Frameworks/R.framework/Versions/3.4/Resources/lib/libRlapack.dylib

> locale:
[1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

> attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods  
[7] base     

> other attached packages:
[1] rgeos_0.3-23         stringr_1.2.0        splancs_2.01-40     
[4] rgdal_1.2-8          sp_1.2-5             htmlwidgets_0.9     
[7] htmltools_0.3.6      magrittr_1.5         dplyr_0.7.2         
[10] leaflet_1.1.0.9000   DT_0.2               shinydashboard_0.6.1
[13] shiny_1.0.5         

> loaded via a namespace (and not attached):
[1] Rcpp_0.12.12     bindr_0.1        lattice_0.20-35 
[4] xtable_1.8-2     R6_2.2.2         rlang_0.1.2     
[7] tools_3.4.1      grid_3.4.1       crosstalk_1.0.0 
[10] digest_0.6.12    assertthat_0.2.0 tibble_1.3.4    
[13] bindrcpp_0.2     glue_1.1.1       mime_0.5        
[16] stringi_1.1.5    compiler_3.4.1   httpuv_1.3.5    
[19] pkgconfig_2.0.1 

#### RStudio Version

```R
RStudio.Version()
```
$citation

To cite RStudio in publications use:

  RStudio Team (2016). RStudio: Integrated Development for R.
  RStudio, Inc., Boston, MA URL http://www.rstudio.com/.

 A BibTeX entry for LaTeX users is

 @Manual{,
   title = {RStudio: Integrated Development Environment for R},
   author = {{RStudio Team}},
   organization = {RStudio, Inc.},
   address = {Boston, MA},
   year = {2016},
   url = {http://www.rstudio.com/},
 }

$mode
[1] "desktop"

$version
[1] ‘1.0.153’

*Last updated on September 9, 2017*

*****************
