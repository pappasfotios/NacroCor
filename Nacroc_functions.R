if (!require(dplyr)){
  install.packages("dplyr")
}
require(dplyr)

## Sorensen
sorensen_index <- function(data1, data2) {
  intersection = length(intersect(rownames(data1), rownames(data2)))
  
  return(2*intersection/(nrow(data1) + nrow(data2)))
}

## N-tile acro-correlation
Nacroc <- function(data, c1_col, c2_col, step=0.01, method = "two-side") {
  
  c1_col_name <- deparse(substitute(c1_col))
  c2_col_name <- deparse(substitute(c2_col))
  
  if (!all(c1_col_name %in% colnames(data) && c2_col_name %in% colnames(data))) {
    stop("Invalid column names. Please check the column names.")
  }
  
  if (nrow(data[complete.cases(data), ]) < nrow(data)) {
    stop("Vector lengths not equal (check for missing values)")
  } else {
    
    comp <- c()
    weights <- c()
    
    for (i in seq(from = step, to = 0.5, by = step)) {
      
      sorensen_left <- sorensen_index(data[ntile(data[[c1_col_name]], 1/step) <= i/step, ], 
                                      data[ntile(data[[c2_col_name]], 1/step) <= i/step, ])
      
      sorensen_right <- sorensen_index(data[ntile(data[[c1_col_name]], 1/step) >= 1/step - i/step + 1, ], 
                                       data[ntile(data[[c2_col_name]], 1/step) >= 1/step - i/step + 1, ])
      
      weight <- 0.5 + (0.5 - i)^2
      
      if (method == "two-side") {
        comp <- c(comp, mean(c(sorensen_left, sorensen_right)) * weight)
      } else if (method == "left-side") {
        comp <- c(comp, sorensen_left * weight)
      } else if (method == "right-side") {
        comp <- c(comp, sorensen_right * weight)
      }
      
      weights <- c(weights, weight)
    }
    
    index <- sum(comp) / sum(weights)
    
    return(index)
  }
}