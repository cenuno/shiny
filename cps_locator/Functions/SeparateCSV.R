#
# Author:   Cristian E. Nuno
# Date:     September 17, 2017
# Purpose:  Create SeparateCSV function that separates the items contained in the
#           'csv_column' and returns a list of each item. 
#           Example: the first element in cps_sy1617$Grades_Offered_All[1]
#           looks like this [1] "K,1,2,3,4,5,6,7,8,9,10,11,12"

SeparateCSV <- function( csv.column ) {
  
  # require the `stringr` package for text manipulation
  # https://cran.r-project.org/web/packages/stringr/vignettes/stringr.html
  # require( stringr )
  
  # replace all white space (i.e. " ") within the csv.column
  # with no white space (i.e. "" )
  # https://stackoverflow.com/questions/5992082/how-to-remove-all-whitespace-from-a-string
  # csv.column <- stringr::str_replace_all( string = csv.column
  #                             , pattern = fixed(" ")
  #                             , replacement = ""
  #                            )
  
  # create list from csv.column
  csv.column <- as.list( csv.column )
  
  # create counter
  i <- 1
  
  # start while loop
  while( i <= length( csv.column ) ) {
    
    # take the first vector inside csv.column
    # and create new elements
    if( grepl( pattern = ",|, "
              , x = csv.column[[i]]
              , fixed = FALSE
             ) == TRUE
      ) {
      # split by ","
      # with fixed = FALSE
      # because the pattern is a regular expression
      csv.column[i] <- strsplit( x = csv.column[[i]]
                                 , split = ",|, "
                                 , fixed = FALSE
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
