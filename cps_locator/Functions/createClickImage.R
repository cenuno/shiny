#
# Author:   Cristian E. Nuno
# Date:     September 9, 2017
# Purpose:  create the createClickImage function
#           which enables web addresses to be clickable in datatables
#           using a png image from the internet

createClickImage <- function( web_address
                              , img_source
                              , height
) {
  
  # start counter
  i <- 1
  
  # start while loop
  while( i <= length( web_address ) ) {
  
    # if the i element of web_adress does NOT equal ""
    # reassign the value of that element css features
    # that will enable the link to be clickable
    if( web_address[i] != "") {
      
      web_address[i] <- sprintf( 
        paste0( '<a'
                , ' href="'
                , web_address[i]
                , '"'
                , ' target="_blank"'
                , '>'
                , '<img'
                , ' src="'
                , img_source
                , '"'
                , ' height="'
                , height
                , '">'
                , '</img>'
                , '</a>'
        ) # end of paste0
      ) # end of CSS formatting
      
      # add one to counter
      i <- i + 1
    } else{
      # if the web_address[i] element EQUALS ""
      # assign that element the value of NA
      web_address[i] <- NA
      
      # add one to counter
      i <- i + 1
      
    } # end of if-else logic
    
  } # end of while loop
  
  # return newly formated character vector
  # if the form of HTML
  return( web_address )
  
} # end of createClickImage function
