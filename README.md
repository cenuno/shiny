# Using Shiny

Useful tips and tricks when creating shiny apps.
****

## Customizing DT Download Button

![Screenshot of Downloading All Rows from DT within Shiny](https://github.com/cenuno/shiny/raw/master/Images/Screen%20Shot%202017-06-23%20at%203.16.36%20PM.png)

The `DT` package enables HTML tables to be created for visually appealing data tables. To download all rows within a data frame that is being shown in a data table, a little bit of customization is needed. 

This [source code](https://github.com/cenuno/shiny/blob/master/datatable_Buttons_Customization.R) will show you how to download all rows within a data frame that is being shown in a datatable.

```R

# Install necessary packages
install.packages( c("shiny", "DT") )

# Load necessary packages
library( shiny )
library( DT )

# Run shiny app from your R/RStudio Console
shiny::runUrl("https://github.com/cenuno/shiny/archive/master.zip")
```

For more information, please see the following sources:

* [RStudio DataTables Extension webpage](https://rstudio.github.io/DT/extensions.html)
* [DataTables.net, 'dom' - the table control elements argument](https://datatables.net/reference/option/dom)
****
