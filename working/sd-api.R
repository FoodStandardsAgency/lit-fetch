
library(httr)
library(dplyr)
library(jsonlite)

apikey <- Sys.getenv("SD_API")


getrqbody <- function(tiab) {
  
  rqbody <- paste0("{ \"qs\": \"TITLE-ABS-KEY(",tiab,")\",\"display\": {\"offset\": 1,\"show\": 100,\"sortBy\": \"date\"} }")
  
  return(rqbody)
  
}

getcontent <- function(rqbody, apikey) {
  
  url <- paste0("https://api.elsevier.com/content/search/sciencedirect?apiKey=",apikey)

  PUT(url,
      body = rqbody,
      content_type("application/json")) %>% 
    content(., "text") %>% 
    jsonlite::fromJSON() %>% 
    .$results %>% 
    as_tibble() 
}





# can show up to 100 at a time, page through with offset parameter (which is record number not page number)

PUT("https://api.elsevier.com/content/search/sciencedirect?apiKey=4b477e75e890387702fa86038096014f",
    body = '{
  "qs": "TITLE-ABS-KEY(mouse)",
  "display": {
      "offset": 1,
      "show": 100,
      "sortBy": "date"
  }
}', content_type("application/json")) %>% 
  content(., "text") %>% 
  jsonlite::fromJSON() %>% 
  .$results %>% 
  as_tibble()

# this is how you set up the request body

'{
  "qs": "protein",
  "pub": "\"Cell\"",
  "filters": {
      "openAccess": true
  },
  "display": {
      "offset": 0,
      "show": 25,
      "sortBy": "date"
  }
}'

# SD API does not return abstract so here is one way to get an abstract via SD article retrieval API

GET("https://api.elsevier.com/content/article/doi/10.1016/j.molstruc.2019.04.106?view=META_ABS&apiKey=4b477e75e890387702fa86038096014f") %>% 
  content() %>% 
  .$`full-text-retrieval-response` %>% 
  .$`coredata` %>% 
  .$`dc:description`


# scopus API will give up to 25 at a time, can page along with start parameter (which is page) (cursor does not work)

GET("https://api.elsevier.com/content/search/scopus?query=title-abs-key(mars)&apiKey=4b477e75e890387702fa86038096014f&start=1850") %>% 
  content(., "text") %>% 
  jsonlite::fromJSON() %>% 
  as_tibble() %>% slice(6) %>% tidyr::unnest(cols = c(`search-results`))
  
