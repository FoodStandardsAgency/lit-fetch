
library(httr)
library(dplyr)
library(jsonlite)
library(purrr)
library(stringr)

apikey <- Sys.getenv("SD_API")

# function will accept a boolean search string, including with brackets, as is!
# (as long as AND OR and NOT are uppercase)

#date search:
# can only either search by publication year or since online date (https://dev.elsevier.com/tecdoc_sdsearch_migration.html)
# online date is likely to be well in advance of publication date - may need to broaden online date then filter on publication date
# (returned date is at least a YYYY-MM-DD)


getn <- function(searchterm, datefrom = as.character(Sys.Date() - 365), apikey) {
  
  url <- paste0("https://api.elsevier.com/content/search/sciencedirect?apiKey=",apikey)
  
  searchterm <- str_replace_all(searchterm, "(\")([^\"]+)(\")", "{\\2}")
  
  rqbody <- paste0("{ \"qs\": \"",searchterm,"\" ,
                   \"loadedAfter\": \"",datefrom,"T00:00:00Z\" }")
  
  PUT(url,
      body = rqbody,
      content_type("application/json")) %>% 
    content(., "parsed") %>% 
    .$resultsFound
  
}


pages <- seq(1, getn("aflatoxin AND (\"aspergillus parasiticus\" OR maize)", apikey = apikey), 100)


getresults <- function(searchterm, datefrom = as.character(Sys.Date() - 365), page, apikey) {
  
  searchterm <- str_replace_all(searchterm, "(\")([^\"]+)(\")", "{\\2}")
  
  rqbody <- paste0("{ \"qs\": \"",searchterm,"\" ,
                   \"loadedAfter\": \"",datefrom,"T00:00:00Z\",
                   \"display\": {\"offset\":", page, ",\"show\": 100,\"sortBy\": \"date\"} }")
  
  url <- paste0("https://api.elsevier.com/content/search/sciencedirect?apiKey=",apikey)
  
  PUT(url,
      body = rqbody,
      content_type("application/json")) %>% 
    content(., "text") %>%  
    fromJSON() %>% 
    .$results %>% 
    as_tibble() %>%   
  select(doi, title, loadDate, publicationDate, sourceTitle)
}


articles <- map_df(pages, slowly(function(x) getresults(page = x, 
                                                        searchterm = "aflatoxin AND (\"aspergillus parasiticus\" OR maize)", 
                                                        apikey = apikey), 
                                 rate = purrr::rate_delay(pause = 1)))

dois <- articles %>% pull(doi) %>% unique()

getabs <- function(doi, apikey) {
  
  url <- paste0("https://api.elsevier.com/content/article/doi/",doi,"?view=META_ABS&apiKey=",apikey)
  
  ab <- GET(url) %>% 
    content() %>% 
    .$`full-text-retrieval-response` %>% 
    .$`coredata` %>% 
    .$`dc:description`
  
  if(!is.null(ab)) {
    tibble(doi = doi, abstract = ab)
  } else {
    tibble(doi = doi, abstract = "")
  }
}


abstracts <- map_df(dois, function(x) getabs(doi = x, apikey = apikey))

# how many actually have the search term in title (14) or abstract or title (49)?

articles %>% 
  left_join(abstracts, by = "doi") %>% 
  filter_at(vars(title, abstract), any_vars(grepl("aflatoxin", ., ignore.case = T))) %>% 
  filter_at(vars(title, abstract), any_vars(grepl("aspergillus parasiticus|maize", ., ignore.case = T)))


