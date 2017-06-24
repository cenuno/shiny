#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library( DT )

# Define UI for application that creates a datatables
ui <- fluidPage(
   
   # Application title
   titlePanel("Download Datatable")
   
   # Show a plot of the generated distribution
   , mainPanel(
         DT::dataTableOutput("fancyTable")
      ) # end of main panel
   
) # end of fluid page

# Define server logic required to create datatable
server <- function(input, output) {
   
   output$fancyTable <- DT::renderDataTable(
     datatable( data = mtcars
                , extensions = 'Buttons'
                , options = list( 
                  dom = "Blfrtip"
                  , buttons = 
                    list("copy", list(
                      extend = "collection"
                      , buttons = c("csv", "excel", "pdf")
                      , text = "Download"
                    ) ) # end of buttons customization
                   
                   # customize the length menu
                  , lengthMenu = list( c(10, 20, -1) # declare values
                                       , c(10, 20, "All") # declare titles
                  ) # end of lengthMenu customization
                  , pageLength = 10
                   
                   
                ) # end of options
               
     ) # end of datatables
   )
} # end of server

# Run the application 
shinyApp(ui = ui, server = server)

