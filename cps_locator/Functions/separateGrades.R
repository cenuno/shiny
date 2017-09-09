#
# Author:   Cristian E. Nuno
# Date:     September 9, 2017
# Purpose:  Create separateGrades function that separates the grades contained in the
#           'csv_column' and returns a list of each grade served by each school
#           where a 'csv_column' is a column whose elements are separated by a comma
#           Example: the first element in cps_sy1617$Grades_Offered_All[1]
#           looks like this [1] "K,1,2,3,4,5,6,7,8,9,10,11,12"

separateGrades <- function( csv_column ) {
  
  # create list from csv_column
  csv_column <- as.list( csv_column )
  
  # create counter
  i <- 1
  
  # start while loop
  while( i <= length( csv_column ) ) {
    
    # take the first vector inside csv_column
    # and create new elements
    if( grepl( pattern = ","
               , x = csv_column[[i]]
    ) == TRUE
    ) {
      # split by ","
      # with fixed = TRUE
      # because I am not regular expressions
      csv_column[i] <- strsplit( x = csv_column[[i]]
                                 , split = ","
                                 , fixed = TRUE
      )
      # move the counter by 1
      i <- i + 1
    } else{
      # move the counter by 1
      i <- i + 1
    }
    
  } # end of while loop
  
  # return csv_column
  return( csv_column )
  
} # end of separateGrades function
