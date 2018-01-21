library(shiny)
library(ggmap)


runApp( 
  list(
    #############################################
    # UI 
    #############################################
    ui = fluidPage( title = "City Search" ,
                    position= "static-top",
                    tags$script(' $(document).on("keydown", function (e) {
                                Shiny.onInputChange("lastkeypresscode", e.keyCode);
                                });
                                '),
                    # Search panel:
                    textInput("search_city", "" , placeholder= "City"),
                    verbatimTextOutput("results")), 
    
    #############################################
    # SERVER 
    #############################################
    server = function(input, output, session) {
      
      observe({
        if(!is.null(input$lastkeypresscode)) {
          if(input$lastkeypresscode == 13){
            target_pos = geocode(input$search_city, messaging =FALSE)
            LAT = target_pos$lat
            LONG = target_pos$lon
            if (is.null(input$search_city) || input$search_city == "")
              return()
            output$results = renderPrint({
              sprintf("Longitude: %s ---- Latitude: %s", LONG, LAT)
            })
          }
        }
      })
    }
  )
  )