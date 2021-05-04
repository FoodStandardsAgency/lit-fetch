#' Format dates with month abbreviation and year
#' 
#' Format dates from Mar2020 to 2020-03-01
#'
#' @param s string in the format Mar2020
#' @importFrom stringr str_extract str_to_sentence str_pad
#' 
#' @return a string
format_month_abb_year <- function(s) {
  
  if (s == "") {
    return("")
  }
  
  month <- substr(s, 1, 3) %>%
    str_to_sentence() %>%
    match(month.abb) %>%
    str_pad(2, pad="0")
  
  year <- str_extract(s, "[0-9]{4}|[0-9]{2}")
  
  if (nchar(year) == 4) {
    paste0(year, "-", month, "-01")

  } else if (nchar(year) == 2) {
    current_year <- as.integer(format(Sys.Date(), "%Y"))
    
    yy <- as.integer(year)
    
    year <- if_else(
      yy > (current_year %% 100),
      1900 + yy,
      2000 + yy
    )    
    
    paste0(year, "-", month, "-01")
  }
}


#' Format dates with month abbreviation and year vectorized
#' 
#' Format vector of dates from Mar2020 to 2020-03-01
#'
#' @param s a vector of strings
#'
#' @return a string
format_month_abb_year_v <- 
  Vectorize(format_month_abb_year, vectorize.args = "s")
