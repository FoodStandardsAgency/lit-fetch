
library(httr)
library(jsonlite)
library(dplyr)
library(purrr)
library(stringr)
library(tidyr)

apikey <- Sys.getenv("SPRINGER_API")

# generate search url with query string and date range (date online not date published as this is only range option)

getsearchurl <- function(searchterm,
                         datefrom = as.character(Sys.Date() - 365),
                         dateto = as.character(Sys.Date()),
                         apikey) {
  
  baseurl <- "http://api.springernature.com/meta/v2/json?"
  
  term <- searchterm %>%
    str_replace_all(., "\"", "%22") %>% 
    str_replace_all(., " ", "+")

  searchurl <- paste0(baseurl,
                      "q=",term,"+onlinedatefrom:",datefrom,"+onlinedateto:",dateto,
                      "&api_key=",apikey)
  return(searchurl)
}


searchexample <- getsearchurl("aflatoxin AND (\"aspergillus parasiticus\" OR maize)", apikey = apikey)

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

result <- map_df(pages, getresults, searchurl = searchexample)

# filter to articles with desired terms in title and abstract

result %>% 
  filter_at(vars(title, abstract), any_vars(grepl("aflatoxin", ., ignore.case = T))) %>% 
  filter_at(vars(title, abstract), any_vars(grepl("aspergillus parasiticus|maize", ., ignore.case = T)))


