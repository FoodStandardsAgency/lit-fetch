

# code fragment not being used any more
# turning a search term into something that can be used to filter a dataset
# turn search term into string and pass to filter 

#' Turn a search term into a dplyr filter condition
#' 
#' @param searchterm Search term (including AND, OR, NOT, quotes and brackets where required)
#' @import stringr
#' @import purrr
#' @import dplyr
#' @return A string to pass to a dplyr filter
#' 
search2filter <- function(searchterm) {
  
  terms <- searchterm %>% 
    str_split(., " AND | OR ") %>% 
    .[[1]] %>% 
    str_remove_all(., "[\\(\\)\"]") %>% 
    map_chr(., str_squish) %>% 
    str_c(., collapse = "|") %>% 
    paste0("(",.,")")
  
  filterterm <- searchterm %>% 
    str_remove_all(., "\"") %>% 
    str_replace_all(., (terms), "grepl(\"\\1\", ., ignore.case = T)") %>% 
    str_replace_all(., " AND ", " & ") %>% 
    str_replace_all(., " OR ", " | ") 
  
  return(filterterm)
  
}
  


# # filter to articles with desired terms in title and abstract

 filterbysearch <- function(searchterm, data) {

   filterterm <- search2filter(searchterm)

   func_call <- rlang::parse_expr(filterterm)

   data %>%
     filter_at(vars(title, abstract), any_vars(!!func_call))

 }

 fresult <- filterbysearch(searchterm, result)



  


