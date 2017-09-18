#
# Author:   Cristian E. Nuno
# Date:     September 17, 2017
# Purpose:  Create DesiredValue function
#           which filters the entire data frame
#           based on whether or not a desired.value
#           exists within a list object

DesiredValue <- function( a.list.object, desired.value ) {

  # start counter
  i <- 1
  
  # create empty character vector
  empty.character <- character()
  
  # start while loop
  while( length( a.list.object ) >= i ) {
  
    # Example:
    # given a set of grades as characters (i.e. "8", not 8)
    # test if all user defined grades are served by
    # each school
    
    if( all( desired.value %in% a.list.object[[i]] ) == FALSE ) {
      # add one to the counter
      i <- i + 1
      
    } else{
      # if true
      # set the i element inside empty_character
      # to contain the School_ID
      # where desired.value is TRUE
      empty.character[i] <- names( a.list.object )[i]
      
      # add one to counter
      i <- i + 1
      
    } # end of ifelse statement
    
  } # end of while loop
  
  # ensure empty.character contains no NA values
  empty.character <- empty.character[ !is.na( empty.character ) ]
  
  # return empty.character to the Global Environment
  return( empty.character )
  
} # end of DesiredValue function
