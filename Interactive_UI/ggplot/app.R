#
# Author:   Cristian E. Nuno
# Date:     May 3, 2018
# Purpose:  Exporting ggplot objects within shiny app
#

# load necessary packages
library( DT )
library( ggplot2 )
library( shiny )

# load necessary data
df <- diamonds

# create scatterplot
sp <- 
  ggplot( data = df
          , aes( x = carat, y = price, col = color ) ) +
  geom_jitter( alpha = 0.50 ) +
  labs( title = "Exploring the Relationship between Carat and Price by Diamond Color" 
        , caption = "Source: ggplot2::diamonds data set" )

# create barplot
bp <-
  ggplot( data = df
          , aes( x = carat, fill = color ) ) +
  geom_bar( stat = "count" ) +
  facet_grid( facets = . ~ color ) +
  theme( legend.position = "none" ) +
  labs( title = "Exploring the Relationship between Carat and Diamond Color" 
        , caption = "Source: ggplot2::diamonds data set" )


# create UI
ui <- fluidPage(
  title = "Exporting ggplot objects within a Shiny app"
  , plotOutput( outputId = "scatterplot" )
  , downloadButton( outputId = "dwnld.sp"
                    , label = "Download Scatterplot" )
  , br()
  , plotOutput( outputId = "barplot" )
  , downloadButton( output = "dwnlod.bp"
                    , label = "Download Barplot")
  , br()
  , dataTableOutput( outputId = "datatable" )
) # end of UI

# create server
server <- function( input, output, session ){
  
  # render the scatterplot
  output$scatterplot <- renderPlot({
    sp
  })
  
  # save the scatterplot
  output$dwnld.sp <- downloadHandler(
    filename = "scatterplot.png"
    , content = function( file ){
      ggsave( filename = file
              , plot = sp
              , device = "png")
    }
  )
  
  # render the barchart
  output$barplot <- renderPlot({
    bp
  })
  
  # save the barchart
  output$dwnld.bp <- downloadHandler(
    filename = "barchart.png"
    , content = function( file ){
      ggsave( filename = file
              , plot = bp
              , device = "png")
    }
  )
  
  # save and render the table
  output$datatable <- renderDataTable({
    DT::datatable( data = df
                   , extensions = "Buttons"
                   , options = list( dom = "Blfrtip"
                                     , buttons = "csv"
                                     , lengthMenu = list( c(1000, 10000, -1)
                                                          , c(1000, 10000, "All") )
                                     , pageLength = 1000 ) )
  })
  
} # end of server

# Run the Shiny app
shinyApp( ui = ui, server = server )

# end of script #
