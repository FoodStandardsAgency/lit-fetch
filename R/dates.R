#' Format dates with month abbreviation and year
#' 
#' Format dates from Mar2020 to 2020-03-01
#'
#' @param s string in the format Mar2020
#' @importFrom stringr str_extract
#' @return a string
format_month_abb_year <- function(s) {
  
  month <- substr(s, 1, 3) %>%
    match(month.abb)
  
  year <- str_extract(s, "[0-9]{4}")
  
  paste0(year, "-", month, "-01")
}
