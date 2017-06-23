# shiny
Useful tips and tricks when creating shiny apps.

## Customizing DT Download Button

![Screenshot of Downloading All Rows from DT within Shiny](https://github.com/cenuno/shiny/raw/master/Images/Screen%20Shot%202017-06-23%20at%203.16.36%20PM.png)

The DT package enables HTML tables to be created for visually appealing datatables. To download all rows within a data frame that is being shown in a datatable, a little bit of customization is needed. 

The [source code](https://github.com/cenuno/shiny/blob/master/datatable_Buttons_Customization.R) will show you how to modify the `dom` argument within the `datatable` function to enable the download button and select box to appear at the top of the datatable.
