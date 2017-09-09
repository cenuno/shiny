#
# Author:   Cristian E. Nuno
# Date:     September 9, 2017
# Purpose:  create the createClickFA function
#           which enables web addresses to be clickable in datatables
#           using Font Awesome (FA) version 4.7.0 icons, accessible at http://fontawesome.io/ and at
#           https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css


createClickFA <- function( web_address
                           , btn_background_color
                           , fa_icon
) {
  
  # start counter
  i <- 1
  
  # start while loop
  while( i <= length( web_address ) ) {
  
    # if the element of link_or_url does NOT equal ""
    # reassign the value of that element css features
    # that will enable the link to be clickable
    
    if( web_address[i] != "") {
      
      web_address[i] <- sprintf( 
        paste0( '<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">'
                , '<a'
                , ' href="'
                , web_address[i]
                , '"'
                , ' target="_blank"'
                , ' class="btn btn-primary"'
                , ' style="'
                , 'background-color: '
                , btn_background_color
                , ';'
                , ' border: none; border-radius: 15px;">'
                , '<i'
                , ' class="fa '
                , fa_icon
                , ' fa-3x"'
                , ' aria-hidden="true">' # hides icons used just for decoration for screen-readers
                , '</i>'
                , '</a>'
        ) # end of paste0
        
      ) # end of CSS formatting
      
      # add one to counter
      i <- i + 1
      
    } else{
      # if web_address[i] does EQUAL ""
      # assign that element a value of NA
      web_address[i] <- NA
      
      # add one to counter
      i <- i + 1
    } # end of if-else logic
    
  } # end of while loop
  
  # return clickable web_address using font awesome icons
  return( web_address )
  
} # end of function
