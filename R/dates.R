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
format_month_abb_year_v <- Vectorize(format_month_abb_year, vectorize.args = "s")


# # --- DEBUG ---
# library(stringr)
# library(tibble)
# library(dplyr)
# format_month_abb_year("Jan98")
# format_month_abb_year("dec2001")
# format_month_abb_year("May98")

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

# tb <- tibble(
#   dt = c("May98", "the other one", "dec2001", "dec 2009")
# )
# 
# tb %>%
#   mutate(
#     date_format_1 = as.Date(dt, "%m/%d/%Y")
#   ) %>%
#   mutate(
#     date_format_2 = if_else(
#       grepl(".*[a-zA-Z]{3}[0-9]{4}|.*[a-zA-Z]{3}[0-9]{2}", dt),
#       str_extract(dt, "[a-zA-Z]{3}[0-9]{4}|[a-zA-Z]{3}[0-9]{2}"),
#       ""
#     )
#   ) %>%
#   mutate_at(
#     "date_format_2",
#     ~ format_month_abb_year_v(.x)
#   ) %>%
#   mutate_at(
#     "date_format_2",
#     ~ as.Date(.x, "%Y-%m-%d")
#   ) %>%
#   mutate(
#     date_format_3 = if_else(
#       grepl("\\b[0-9]{4}\\b", dt),
#       str_extract(dt, "\\b[0-9]{4}\\b"),
#       ""
#     )
#   ) %>%
#   mutate_at(
#     "date_format_3",
#     ~ format(as.Date(.x, "%Y"), "%Y-01-01")
#   ) %>%
#   mutate_at(
#     "date_format_3",
#     ~ as.Date(date_format_3)
#   ) %>%
#   mutate(
#     pdate = case_when(
#       !is.na(date_format_1) ~ date_format_1,
#       !is.na(date_format_2) ~ date_format_2,
#       !is.na(date_format_3) ~ date_format_3
#     )    
#   )
