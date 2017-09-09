# 
# Author:   Cristian E. Nuno
# Date:     September 9, 2017
# Purpose:  Create the createClickButton function
#           which enables a web address to 
#           be hyperlinked using a clickable button

createClickButton <- function( web_address
                               , btn_background_color
                               , btn_label
) {
  
  # start counter
  i <- 1
  
  # start while loop
  while( i <= length( web_address ) ) {
  
    # if the i element of web_address does NOT equal ""
    # reassign the value of that element css features
    # that will enable the web_address to be clickable
    if( web_address[i] != "") {
      
      web_address[i] <- sprintf( 
        paste0( '<a'
                , ' href='
                , web_address[i]
                , ' target="_blank"'
                , ' class="btn btn-primary"'
                , ' style="'
                , 'background-color: '
                , btn_background_color
                , ';'
                , ' border: none; border-radius: 15px;">'
                , btn_label
                , '</a>'
        ) # end of paste0
      ) # end of CSS formatting
      
      # add one to counter
      i <- i + 1
      
    } else{
      # if the i element of web_address EQUALS ""
      # assign it the value of NA
      web_address[i] <- NA
      
      # add one to counter
      i <- i + 1
      
    } # end of if else logic
    
  } # end of while loop
  
  # return newly formated character vector
  # in the form of HTML
  return( web_address )
  
} # end of function
