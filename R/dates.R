#' Format dates with month abbreviation and year
#' 
#' Format dates from Mar2020 to 2020-03-01
#'
#' @param s string in the format Mar2020
#' @importFrom stringr str_extract str_to_sentence str_pad
#' @return a string
format_month_abb_year <- function(s) {
  
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

# # --- DEBUG ---
# format_month_abb_year("Jan98")
# format_month_abb_year("dec2001")

# format_month_abb_year("Jan98") %>%
#   as.Date("%Y-%m-%d")
# 
# format_month_abb_year("dec2001") %>%
#   as.Date("%Y-%m-%d")

# format_month_abb_year("dec-oct2001") %>%
#   as.Date("%Y-%m-%d")

# format_month_abb_year("fev2001") %>%
#   as.Date("%Y-%m-%d")

# Warning: Problem with `mutate()` input `date_format_2`.
# i the condition has length > 1 and only the first element will be used
# i Input `date_format_2` is `format_month_abb_year(dt)`.