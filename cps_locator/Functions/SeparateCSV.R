#
# Author:   Cristian E. Nuno
# Date:     September 17, 2017
# Purpose:  Create SeparateCSV function that separates the items contained in the
#           'csv_column' and returns a list of each item. 
#           Example: the first element in cps_sy1617$Grades_Offered_All[1]
#           looks like this [1] "K,1,2,3,4,5,6,7,8,9,10,11,12"

SeparateCSV <- function( csv.column ) {
  
  # create list from csv_column
  csv.column <- as.list( csv.column )
  
  # create counter
  i <- 1
  
  # start while loop
  while( i <= length( csv.column ) ) {
    
    # take the first vector inside csv.column
    # and create new elements
    if( grepl( pattern = ","
               , x = csv.column[[i]]
    ) == TRUE
    ) {
      # split by ","
      # with fixed = TRUE
      # because the pattern is not a regular expression
      csv.column[i] <- strsplit( x = csv.column[[i]]
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
  
  # return csv.column
  return( csv.column )
  
} # end of SeparateCSV function
