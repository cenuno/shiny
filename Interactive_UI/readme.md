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
                     , "webshot"          # Take a screenshot of a URL
                     , "dplyr"            # A Grammar of Data Manipulation
                     , "magrittr"         # Ceci n'est pas une pipe
                     , "DT"               # A Wrapper of the JavaScript Library 'DataTables'
                     , "mapview"          # Interactive Viewing of Spatial Data in R
                     )
                     )
# load necessary packages
library( shiny )

# call Shiny app from GitHub
shiny::runUrl( url = "https://github.com/cenuno/shiny/archive/master.zip"
                 , subdir = "Interactive_UI"
               )

## end of script ##
```

## Session Info

RStudio version [‘1.1.383’](https://www.rstudio.com/products/rstudio/release-notes/).

```
R version 3.4.2 (2017-09-28)
Platform: x86_64-apple-darwin15.6.0 (64-bit)
Running under: macOS Sierra 10.12.6

Matrix products: default
BLAS: /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib
LAPACK: /Library/Frameworks/R.framework/Versions/3.4/Resources/lib/libRlapack.dylib

locale:
[1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] mapview_2.2.0        DT_0.2               magrittr_1.5         dplyr_0.7.4         
[5] htmlwidgets_0.9      htmltools_0.3.6      leaflet_1.1.0        shinydashboard_0.6.1
[9] shiny_1.0.5         

loaded via a namespace (and not attached):
 [1] sf_0.5-5          lattice_0.20-35   colorspace_1.3-2  stats4_3.4.2      viridisLite_0.2.0
 [6] yaml_2.1.14       base64enc_0.1-3   rlang_0.1.4       R.oo_1.21.0       e1071_1.6-8      
[11] glue_1.2.0        DBI_0.7           R.utils_2.6.0     sp_1.2-5          bindrcpp_0.2     
[16] foreach_1.4.3     bindr_0.1         plyr_1.8.4        munsell_0.4.3     raster_2.5-8     
[21] R.methodsS3_1.7.1 codetools_0.2-15  httpuv_1.3.5      crosstalk_1.0.0   gdalUtils_2.0.1.7
[26] class_7.3-14      markdown_0.8      Rcpp_0.12.13      xtable_1.8-2      udunits2_0.13    
[31] scales_0.5.0      classInt_0.1-24   satellite_1.0.1   webshot_0.4.2     jsonlite_1.5     
[36] mime_0.5          png_0.1-7         digest_0.6.12     grid_3.4.2        rgdal_1.2-15     
[41] tools_3.4.2       tibble_1.3.4      pkgconfig_2.0.1   rsconnect_0.8.5   assertthat_0.2.0 
[46] iterators_1.0.8   R6_2.2.2          units_0.4-6       compiler_3.4.2   
```
