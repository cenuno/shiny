# Customizing DT Download Button

![Screenshot of Downloading All Rows from DT within Shiny](https://github.com/cenuno/shiny/raw/master/Images/Screen%20Shot%202017-06-23%20at%203.16.36%20PM.png)

## Summary

The `DT`<sup>1</sup> package enables HTML tables to be created for visually appealing data tables. To download all rows within a data frame that is being shown in a data table, a little bit of customization is needed.

1. You must set the argument `dom`<sup>2</sup> equal to `"Blfrtip"` to enable the download button and the "Show Entries" button to coexist at the top right.

2. This coexistence enables you to tell manually declare which values will appear in the "Show Entries" button. 

```R
# customize the length menu
, lengthMenu = list( c(10, 20, -1) # declare values
                       , c(10, 20, "All") # declare titles
                       
                    ) # end of lengthMenu customization
```

*For the source code, [please click here](https://github.com/cenuno/shiny/blob/master/DT-Download-All-Rows-Button/app.r).*

## Run the App Yourself

The code below will allow you to run the app from your R/RStudio console:

```R

# Install necessary packages
install.packages( c("shiny", "DT") )

# Load necessary packages
library( shiny )
library( DT )

# Run shiny app from your R/RStudio Console
shiny::runUrl( url = "https://github.com/cenuno/shiny/archive/master.zip"
                , subdir = "DT-Download-All-Rows-Button"
                )
```

For more information, please see the following sources:

* <sup>1</sup>[RStudio DataTables Extension webpage](https://rstudio.github.io/DT/extensions.html)
* <sup>2</sup>[DataTables.net, 'dom' - the table control elements argument](https://datatables.net/reference/option/dom)
****
