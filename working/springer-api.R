
library(httr)
library(jsonlite)
library(dplyr)
library(purrr)

apikey <- Sys.getenv("SPRINGER_API")

getsearchurl <- function(titleword, 
                         apikey) {
  
  baseurl <- "http://api.springernature.com/meta/v2/json?"
  
  term <- paste0("(title:%22",titleword,"%22)")

  searchurl <- paste0(baseurl,
                      "q=",term,
                      "&api_key=",apikey)
  return(searchurl)
}

searchexample <- getsearchurl("aflatoxin", apikey)

# how many results

total <- GET(searchexample) %>% 
  content(., "text") %>% 
  jsonlite::fromJSON() %>% 
  .$result %>% .$total 

# paginate

pages <- seq(1, total, 100)

# map across pages

getresults <- function(page, searchurl) {
  
  url <- paste0(searchurl,"&p=100&s=",page)
  
  GET(url) %>% 
    content(., "text") %>% 
    fromJSON() %>% 
    .$records %>% 
    as_tibble() %>% 
    select(doi, title, abstract)
  }

map_df(pages[1:3], getresults, searchurl = searchexample)

#todo:
# date range
# convert multi-word/boolean searches to query strings (https://dev.springernature.com/adding-constraints)


