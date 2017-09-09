#
# Author:   Cristian E. Nuno
# Date:     September 9, 2017
# Purpose:  Create gradesServed function
#           which filters the entire data frame
#           based on whether or not each particular school
#           serves a particular set of grades

gradesServed <- function( a.list.object, grades ) {

  # start counter
  i <- 1
  
  # create empty character vector
  empty_character <- character()
  
  # start while loop
  while( length( a.list.object ) >= i ) {
  
    # given a set of grades as characters (i.e. "8", not 8)
    # test if all user defined grades are served by
    # each school
    
    if( all( grades %in% a.list.object[[i]] ) == FALSE ) {
      # add one to the counter
      i <- i + 1
      
    } else{
      # if true
      # set the i element inside empty_character
      # to contain the School_ID which serves
      # the user defined grades
      empty_character[i] <- names( a.list.object )[i]
      
      # add one to counter
      i <- i + 1
      
    } # end of ifelse statement
    
  } # end of while loop
  
  # ensure empty_character contains no NA values
  empty_character <- empty_character[ !is.na( empty_character ) ]
  
  # return empty_character to the Global Environment
  return( empty_character )
  
} # end of gradesServed function
